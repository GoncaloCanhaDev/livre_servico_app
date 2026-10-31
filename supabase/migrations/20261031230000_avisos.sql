-- Avisos: short in-app notices (the app's Aviso and AvisoVisto, see
-- lib/models/aviso.dart), private to whoever sent them, whoever they were
-- sent to and the app's admin.
--
--   * Aviso rows: read by the sender (data ->> 'fromPersonId'), the
--     recipients (data -> 'toPersonIds') and the admin; nobody else gets
--     them, not through pull_records, a plain select or Realtime.
--   * AvisoVisto rows (one per aviso and person, keyed '<aviso>/<person>'):
--     read by that person, the aviso's sender and the admin.
--   * Both are written only through push_records, which checks them (see
--     below); the insert and update policies refuse them.

-- Whether the signed-in user may read a p_collection row with data p_data
-- in p_store (true for every collection but the two above).
create function public.aviso_visible(p_store uuid, p_collection text, p_data jsonb)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when p_collection not in ('Aviso', 'AvisoVisto') then true
    when public.my_store_role(p_store) = 'owner' then true
    else coalesce((
      select case p_collection
        when 'Aviso' then p_data ->> 'fromPersonId' = m.me or p_data -> 'toPersonIds' ? m.me
        else p_data ->> 'personId' = m.me or exists (
          select 1 from public.records a
          where a.store_id = p_store and a.collection = 'Aviso'
            and a.id = p_data ->> 'avisoId' and a.data ->> 'fromPersonId' = m.me
        )
      end
      from (
        select person_id as me from public.store_members
        where store_id = p_store and user_id = auth.uid() and status = 'approved'
          and person_id is not null
      ) m
    ), false)
  end;
$$;

drop policy "members read records" on public.records;
create policy "members read records" on public.records
  for select to authenticated
  using (
    store_id in (select public.my_store_ids('viewer'))
    and (collection <> 'Person' or public.person_access(store_id, id, data) = 'full')
    and public.aviso_visible(store_id, collection, data)
  );

drop policy "editors add records" on public.records;
create policy "editors add records" on public.records
  for insert to authenticated
  with check (store_id in (select public.my_store_ids('editor'))
    and collection not in ('Person', 'Aviso', 'AvisoVisto'));

drop policy "editors change records" on public.records;
create policy "editors change records" on public.records
  for update to authenticated
  using (store_id in (select public.my_store_ids('editor'))
    and collection not in ('Person', 'Aviso', 'AvisoVisto'))
  with check (store_id in (select public.my_store_ids('editor'))
    and collection not in ('Person', 'Aviso', 'AvisoVisto'));

-- pull_records (see the person access migration), without the avisos the
-- caller may not read.
create or replace function public.pull_records(p_store uuid, p_since timestamptz, p_limit int)
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
      and public.aviso_visible(r.store_id, r.collection, r.data)
    order by r.server_updated_at
    limit p_limit;
end;
$$;

-- push_records (see the authority levels migration), with avisos: a new
-- Aviso only from level 2, in the caller's own name, to people they reach;
-- an existing one only deleted, by its sender; an AvisoVisto only the
-- caller's own, on an aviso they received. Returns no aviso the caller
-- may not read.
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
  v_role_keys text[] := array['team', 'role', 'chefe', 'turno', 'supervisor',
    'segundaLinha', 'permanencia'];
  v_role public.store_role := public.my_store_role(p_store);
  v_self boolean;
  v_me text := (
    select person_id from public.store_members
    where store_id = p_store and user_id = auth.uid() and status = 'approved'
  );
  v_admin boolean := public.my_store_role(p_store) = 'owner';
begin
  if coalesce(v_role >= 'editor', false) is false then
    raise exception 'Sem permissão para alterar os dados desta loja.' using errcode = '42501';
  end if;

  insert into public.records as r (store_id, collection, id, data, updated_at, deleted_at)
  select p_store, x.collection, x.id, x.data, x.updated_at, x.deleted_at
  from jsonb_to_recordset(p_rows)
    as x (collection text, id text, data jsonb, updated_at timestamptz, deleted_at timestamptz)
  where x.collection not in ('Person', 'Aviso', 'AvisoVisto')
  on conflict (store_id, collection, id) do update
    set data = excluded.data,
        updated_at = excluded.updated_at,
        deleted_at = excluded.deleted_at
    where r.updated_at < excluded.updated_at;

  for v_row in
    select * from jsonb_to_recordset(p_rows)
      as y (collection text, id text, data jsonb, updated_at timestamptz, deleted_at timestamptz)
    where y.collection = 'Aviso'
  loop
    select * into v_server from public.records r
    where r.store_id = p_store and r.collection = 'Aviso' and r.id = v_row.id;
    if not found then
      if v_admin or (
        public.my_level(p_store) >= 2
        and v_row.data ->> 'fromPersonId' = v_me
        and jsonb_typeof(v_row.data -> 'toPersonIds') = 'array'
        and jsonb_array_length(v_row.data -> 'toPersonIds') > 0
        and not exists (
          select 1 from jsonb_array_elements_text(v_row.data -> 'toPersonIds') t (id)
          where t.id = v_me or not exists (
            select 1 from public.records p
            where p.store_id = p_store and p.collection = 'Person' and p.id = t.id
              and p.deleted_at is null and public.reaches(p_store, p.data ->> 'team')
          )
        )
      ) then
        insert into public.records (store_id, collection, id, data, updated_at)
          values (p_store, 'Aviso', v_row.id, v_row.data, least(v_row.updated_at, now()));
      end if;
    elsif v_row.deleted_at is not null and v_server.deleted_at is null
      and v_server.updated_at < v_row.updated_at
      and (v_admin or v_server.data ->> 'fromPersonId' = v_me) then
      update public.records
        set data = v_server.data || jsonb_strip_nulls(jsonb_build_object(
              'syncDeletedAt', v_row.data -> 'syncDeletedAt',
              'syncUpdatedAt', v_row.data -> 'syncUpdatedAt')),
            updated_at = least(v_row.updated_at, now()),
            deleted_at = least(v_row.deleted_at, now())
      where store_id = p_store and collection = 'Aviso' and id = v_row.id;
    end if;
  end loop;

  insert into public.records as r (store_id, collection, id, data, updated_at, deleted_at)
  select p_store, x.collection, x.id, x.data, least(x.updated_at, now()), x.deleted_at
  from jsonb_to_recordset(p_rows)
    as x (collection text, id text, data jsonb, updated_at timestamptz, deleted_at timestamptz)
  where x.collection = 'AvisoVisto'
    and (v_admin or (
      x.data ->> 'personId' = v_me
      and exists (
        select 1 from public.records a
        where a.store_id = p_store and a.collection = 'Aviso' and a.id = x.data ->> 'avisoId'
          and a.data -> 'toPersonIds' ? v_me
      )
    ))
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
      if v_role = 'owner' or public.can_assign(p_store, v_row.data) then
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
      if v_row.deleted_at is not null and v_server.deleted_at is null then
        delete from public.store_members where store_id = p_store and person_id = v_row.id;
      end if;
      continue;
    end if;
    -- A removal, by someone above the person (never themselves).
    if v_row.deleted_at is not null and v_server.deleted_at is null then
      v_self := exists (
        select 1 from public.store_members
        where store_id = p_store and user_id = auth.uid() and person_id = v_row.id
      );
      if not v_self and public.my_level(p_store) >= 3
        and public.is_above(p_store, v_server.data) then
        update public.records
          set data = v_server.data || jsonb_strip_nulls(jsonb_build_object(
                'syncDeletedAt', v_row.data -> 'syncDeletedAt',
                'syncUpdatedAt', v_row.data -> 'syncUpdatedAt')),
              updated_at = least(v_row.updated_at, now()),
              deleted_at = least(v_row.deleted_at, now())
        where store_id = p_store and collection = 'Person' and id = v_row.id;
        delete from public.store_members where store_id = p_store and person_id = v_row.id;
        continue;
      end if;
    end if;
    -- Nothing this caller may change: the row (and its time) stays as it is.
    if v_keys = '{}' then
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
    -- A team or role this caller may not give: all of it stays as it was.
    if (public.person_role(v_data) is distinct from public.person_role(v_server.data)
        or v_data ->> 'team' is distinct from v_server.data ->> 'team')
      and not public.can_assign(p_store, v_data) then
      foreach v_key in array v_role_keys loop
        if v_server.data ? v_key then
          v_data := v_data || jsonb_build_object(v_key, v_server.data -> v_key);
        else
          v_data := v_data - v_key;
        end if;
      end loop;
    end if;
    if v_row.data ? 'syncUpdatedAt' then
      v_data := v_data || jsonb_build_object('syncUpdatedAt', v_row.data -> 'syncUpdatedAt');
    end if;
    -- Never later than now: a time in the future would make every real
    -- edit after it look older, and lose (last write wins).
    update public.records
      set data = v_data, updated_at = least(v_row.updated_at, now())
    where store_id = p_store and collection = 'Person' and id = v_row.id;
  end loop;

  return query
    select (public.visible_record(r)).*
    from public.records r
    join jsonb_to_recordset(p_rows)
      as x (collection text, id text, data jsonb, updated_at timestamptz)
      on r.collection = x.collection and r.id = x.id
    where r.store_id = p_store
      and public.aviso_visible(r.store_id, r.collection, r.data)
      and (r.updated_at > x.updated_at
        or (r.collection = 'Person' and r.updated_at = x.updated_at and r.data <> x.data));
end;
$$;

revoke execute on function public.aviso_visible(uuid, text, jsonb) from public, anon;
grant execute on function public.aviso_visible(uuid, text, jsonb) to authenticated;
