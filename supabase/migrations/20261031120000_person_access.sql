-- People's personal data by hierarchy.
--
-- A Person row stays one JSON document, but the server decides who reads
-- and writes which part of it:
--
--   * Everyone in the store reads the public fields (person_public_keys):
--     name, photo, género, date of birth and role. The whole row is read by
--     the person themselves, the chefe de secção of their team, Gerência,
--     the owner and the admin (person_access = 'full').
--   * The app pulls through pull_records, which redacts Person rows; the
--     records select policy hides the rows a caller may not read whole, so
--     neither a plain select nor Realtime gives them out.
--   * push_records takes from each Person row only the fields the caller
--     may edit (person_edit_keys), keeping the rest as the server has it: a
--     redacted copy pushed back wipes nothing, and nobody makes themselves
--     Gerência. New people: Gerência, the owner, the admin. Deletes: the
--     owner and the admin.

-- The fields every member reads.
create function public.person_public_keys()
returns text[]
language sql
immutable
set search_path = ''
as $$
  select array['fullName', 'photoPath', 'genero', 'dateOfBirth', 'team', 'chefe',
    'supervisor', 'segundaLinha', 'permanencia', 'createdAt', 'syncUuid',
    'syncUpdatedAt', 'syncDeletedAt'];
$$;

-- p_data with only the public fields.
create function public.redact_person(p_data jsonb)
returns jsonb
language sql
immutable
set search_path = ''
as $$
  select coalesce(jsonb_object_agg(key, value), '{}'::jsonb)
  from jsonb_each(p_data)
  where key = any (public.person_public_keys());
$$;

-- 'full' when the signed-in user reads the whole of the Person p_person_id
-- (data p_data) in p_store, else 'public'.
create function public.person_access(p_store uuid, p_person_id text, p_data jsonb)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when public.my_store_role(p_store) = 'owner' then 'full'
    when exists (
      select 1 from public.store_members
      where store_id = p_store and user_id = auth.uid() and status = 'approved'
        and person_id = p_person_id
    ) then 'full'
    when me ->> 'team' = 'gerencia' then 'full'
    when public.person_chefe_team(me) = p_data ->> 'team' then 'full'
    else 'public'
  end
  from (select public.member_person(p_store, auth.uid()) as me) m;
$$;

-- p_row as the signed-in user may read it.
create function public.visible_record(p_row public.records)
returns public.records
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if p_row.collection = 'Person'
    and public.person_access(p_row.store_id, p_row.id, p_row.data) = 'public' then
    p_row.data := public.redact_person(p_row.data);
  end if;
  return p_row;
end;
$$;

-- Whether the signed-in user asks the Person (data p_data) in p_store to
-- update their profile: chefe of their team, Gerência, owner, admin.
create function public.can_request_update(p_store uuid, p_data jsonb)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.my_store_role(p_store) = 'owner'
    or coalesce(me ->> 'team' = 'gerencia', false)
    or coalesce(public.person_chefe_team(me) = p_data ->> 'team', false)
  from (select public.member_person(p_store, auth.uid()) as me) m;
$$;

-- The fields of the Person p_person_id (the server's data p_data) the
-- signed-in user may write; null for every field (owner, admin). The
-- update-request fields are included for the person themselves, who may
-- only clear them (push_records checks).
create function public.person_edit_keys(p_store uuid, p_person_id text, p_data jsonb)
returns text[]
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_me jsonb := public.member_person(p_store, auth.uid());
  v_keys text[] := '{}';
  v_request text[] := array['profileUpdateRequestedAt', 'profileUpdateRequestedBy'];
begin
  if public.my_store_role(p_store) = 'owner' then
    return null;
  end if;
  if exists (
    select 1 from public.store_members
    where store_id = p_store and user_id = auth.uid() and status = 'approved'
      and person_id = p_person_id
  ) then
    v_keys := v_keys || array['fullName', 'photoPath', 'phoneNumber', 'dateOfBirth',
      'genero', 'notes'] || v_request;
  end if;
  if v_me ->> 'team' = 'gerencia' then
    v_keys := v_keys || array['folgas', 'ausencias', 'team', 'chefe', 'supervisor',
      'segundaLinha', 'permanencia'] || v_request;
  elsif public.person_chefe_team(v_me) = p_data ->> 'team' then
    v_keys := v_keys || array['folgas', 'ausencias'] || v_request;
  end if;
  return v_keys;
end;
$$;

-- Up to p_limit of p_store's rows written at p_since or later (all with
-- null), oldest write first, Person rows redacted for the caller.
create function public.pull_records(p_store uuid, p_since timestamptz, p_limit int)
returns setof public.records
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if public.my_store_role(p_store) is null then
    raise exception 'Não pertence a esta loja.' using errcode = '42501';
  end if;
  return query
    select (public.visible_record(r)).*
    from public.records r
    where r.store_id = p_store
      and (p_since is null or r.server_updated_at >= p_since)
    order by r.server_updated_at
    limit p_limit;
end;
$$;

-- Saves p_rows (see the first migration) into p_store, each only if newer
-- than the server's copy; Person rows field by field, as person_edit_keys
-- allows. Returns, as the caller may read them, the rows where the server's
-- copy was newer and the Person rows saved differently from what was sent.
create or replace function public.push_records(p_store uuid, p_rows jsonb)
returns setof public.records
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_row record;
  v_server public.records;
  v_keys text[];
  v_data jsonb;
  v_key text;
  v_can_request boolean;
  v_request text[] := array['profileUpdateRequestedAt', 'profileUpdateRequestedBy'];
  v_role public.store_role := public.my_store_role(p_store);
begin
  if coalesce(v_role >= 'editor', false) is false then
    raise exception 'Sem permissão para alterar os dados desta loja.' using errcode = '42501';
  end if;

  insert into public.records as r (store_id, collection, id, data, updated_at, deleted_at)
  select p_store, x.collection, x.id, x.data, x.updated_at, x.deleted_at
  from jsonb_to_recordset(p_rows)
    as x (collection text, id text, data jsonb, updated_at timestamptz, deleted_at timestamptz)
  where x.collection <> 'Person'
  on conflict (store_id, collection, id) do update
    set data = excluded.data,
        updated_at = excluded.updated_at,
        deleted_at = excluded.deleted_at
    where r.updated_at < excluded.updated_at;

  for v_row in
    select * from jsonb_to_recordset(p_rows)
      as y (collection text, id text, data jsonb, updated_at timestamptz, deleted_at timestamptz)
    where y.collection = 'Person'
  loop
    select * into v_server from public.records r
    where r.store_id = p_store and r.collection = 'Person' and r.id = v_row.id;
    if not found then
      if v_role = 'owner'
        or coalesce(public.member_person(p_store, auth.uid()) ->> 'team' = 'gerencia', false)
      then
        insert into public.records (store_id, collection, id, data, updated_at, deleted_at)
          values (p_store, 'Person', v_row.id, v_row.data, v_row.updated_at,
                  case when v_role = 'owner' then v_row.deleted_at end);
      end if;
      continue;
    end if;
    if v_server.updated_at >= v_row.updated_at then
      continue;
    end if;
    v_keys := public.person_edit_keys(p_store, v_row.id, v_server.data);
    if v_keys is null then
      update public.records
        set data = v_row.data, updated_at = v_row.updated_at, deleted_at = v_row.deleted_at
      where store_id = p_store and collection = 'Person' and id = v_row.id;
      continue;
    end if;
    v_can_request := public.can_request_update(p_store, v_server.data);
    v_data := v_server.data;
    foreach v_key in array v_keys loop
      -- The person themselves only clears a request.
      if v_key = any (v_request) and not v_can_request
        and coalesce(v_row.data -> v_key, 'null'::jsonb) <> 'null'::jsonb then
        continue;
      end if;
      if v_row.data ? v_key then
        v_data := v_data || jsonb_build_object(v_key, v_row.data -> v_key);
      else
        v_data := v_data - v_key;
      end if;
    end loop;
    if v_row.data ? 'syncUpdatedAt' then
      v_data := v_data || jsonb_build_object('syncUpdatedAt', v_row.data -> 'syncUpdatedAt');
    end if;
    update public.records
      set data = v_data, updated_at = v_row.updated_at
    where store_id = p_store and collection = 'Person' and id = v_row.id;
  end loop;

  return query
    select (public.visible_record(r)).*
    from public.records r
    join jsonb_to_recordset(p_rows)
      as x (collection text, id text, data jsonb, updated_at timestamptz)
      on r.collection = x.collection and r.id = x.id
    where r.store_id = p_store
      and (r.updated_at > x.updated_at
        or (r.collection = 'Person' and r.updated_at = x.updated_at and r.data <> x.data));
end;
$$;

-- Person rows: read whole only as person_access allows (pull_records gives
-- everyone the redacted rest), written only through push_records.
drop policy "members read records" on public.records;
create policy "members read records" on public.records
  for select to authenticated
  using (
    store_id in (select public.my_store_ids('viewer'))
    and (collection <> 'Person' or public.person_access(store_id, id, data) = 'full')
  );

drop policy "editors add records" on public.records;
create policy "editors add records" on public.records
  for insert to authenticated
  with check (store_id in (select public.my_store_ids('editor')) and collection <> 'Person');

drop policy "editors change records" on public.records;
create policy "editors change records" on public.records
  for update to authenticated
  using (store_id in (select public.my_store_ids('editor')) and collection <> 'Person')
  with check (store_id in (select public.my_store_ids('editor')) and collection <> 'Person');

revoke execute on function public.person_public_keys() from public, anon;
revoke execute on function public.redact_person(jsonb) from public, anon;
revoke execute on function public.person_access(uuid, text, jsonb) from public, anon;
revoke execute on function public.visible_record(public.records) from public, anon, authenticated;
revoke execute on function public.can_request_update(uuid, jsonb) from public, anon;
revoke execute on function public.person_edit_keys(uuid, text, jsonb) from public, anon;
revoke execute on function public.pull_records(uuid, timestamptz, int) from public, anon;
grant execute on function public.person_public_keys() to authenticated;
grant execute on function public.redact_person(jsonb) to authenticated;
grant execute on function public.person_access(uuid, text, jsonb) to authenticated;
grant execute on function public.can_request_update(uuid, jsonb) to authenticated;
grant execute on function public.person_edit_keys(uuid, text, jsonb) to authenticated;
grant execute on function public.pull_records(uuid, timestamptz, int) to authenticated;
