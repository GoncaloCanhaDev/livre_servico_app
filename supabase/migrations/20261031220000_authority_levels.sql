-- Authority levels instead of chefe slots and the Gerência team.
--
-- Every Person has one role (data ->> 'role', a Role.name in the app's
-- lib/models/teams.dart), each with a level:
--
--   1 operador · 2 segundaLinha, supervisor · 3 chefeSeccao ·
--   4 gestorArea, secretaria (Gerência only) · 5 gerente (Gerência only)
--
-- A role the person's team doesn't allow reads as operador. Rows without a
-- role (saved before the app's 0.68.0) take it from the old fields:
-- Gerência's chefe is gerente and the rest of Gerência gestorArea, another
-- team's chefe chefeSeccao, then supervisor and segundaLinha where the team
-- had them (person_role; the app's roleOf does the same).
--
-- What a member may do comes from their person's level and team, as the
-- app's StoreAccess says:
--
--   * reaches: whose people their authority covers. Level 5 every team,
--     level 4 every team but Gerência, levels 2 and 3 their own team (level
--     3 also people with no team), level 1 nobody.
--   * is_above: reaches them with a higher level (level 5: any).
--   * Level 3+ reads the whole profile, plans folgas and ausências and asks
--     for updates of the people they reach; adds people (can_assign) and
--     changes the team, role and turno of, or removes, the people they are
--     above. A removed person's account leaves the store. Level 3+ approves
--     join requests; level 4+ manages members.
--
-- The app's admin stays above everything (my_store_role 'owner').

-- The fixed teams (lib/models/teams.dart).
create function public.store_team_ids()
returns text[]
language sql
immutable
set search_path = ''
as $$
  select array['livre_servico', 'gerencia', 'charcutaria', 'meal_solutions', 'talho',
    'peixaria', 'frente_de_loja', 'bem_estar', 'padaria', 'fruta'];
$$;

-- The level of the role named p_role (1 for an unknown one).
create function public.role_level(p_role text)
returns int
language sql
immutable
set search_path = ''
as $$
  select case p_role
    when 'segundaLinha' then 2
    when 'supervisor' then 2
    when 'chefeSeccao' then 3
    when 'gestorArea' then 4
    when 'secretaria' then 4
    when 'gerente' then 5
    else 1
  end;
$$;

-- The role of the Person p_data (see the header).
create function public.person_role(p_data jsonb)
returns text
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_team text := p_data ->> 'team';
  v_role text := p_data ->> 'role';
  v_chefe text := p_data ->> 'chefe';
  v_production text[] := array['charcutaria', 'meal_solutions', 'talho', 'peixaria',
    'padaria', 'fruta'];
begin
  if v_team is null or not (v_team = any (public.store_team_ids())) then
    return 'operador';
  end if;
  if v_role is not null then
    if v_role in ('operador', 'segundaLinha', 'supervisor', 'chefeSeccao')
      or (v_team = 'gerencia' and v_role in ('gestorArea', 'secretaria', 'gerente')) then
      return v_role;
    end if;
    return 'operador';
  end if;
  if v_team = 'gerencia' then
    return case when v_chefe = 'chefe' then 'gerente' else 'gestorArea' end;
  end if;
  if (v_team = 'livre_servico' and v_chefe in ('dia', 'noite'))
    or (v_team = any (v_production) and v_chefe = 'chefe') then
    return 'chefeSeccao';
  end if;
  if v_team = 'frente_de_loja' and coalesce((p_data ->> 'supervisor')::boolean, false) then
    return 'supervisor';
  end if;
  if v_team = any (v_production) and coalesce((p_data ->> 'segundaLinha')::boolean, false) then
    return 'segundaLinha';
  end if;
  return 'operador';
end;
$$;

create function public.person_level(p_data jsonb)
returns int
language sql
immutable
set search_path = ''
as $$
  select public.role_level(public.person_role(p_data));
$$;

-- The level of the signed-in member's person in p_store; 0 when unlinked.
create function public.my_level(p_store uuid)
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(public.person_level(public.member_person(p_store, auth.uid())), 0);
$$;

-- Whether the signed-in user's authority in p_store covers team p_team.
create function public.reaches(p_store uuid, p_team text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.my_store_role(p_store) = 'owner' or coalesce(
    case public.my_level(p_store)
      when 5 then true
      when 4 then p_team is distinct from 'gerencia'
      when 3 then p_team = me ->> 'team' or p_team is null
        or not (p_team = any (public.store_team_ids()))
      when 2 then p_team = me ->> 'team'
      else false
    end, false)
  from (select public.member_person(p_store, auth.uid()) as me) m;
$$;

-- Whether the signed-in user reaches the Person p_data with a higher level.
create function public.is_above(p_store uuid, p_data jsonb)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.my_store_role(p_store) = 'owner'
    or (public.reaches(p_store, p_data ->> 'team')
      and (public.person_level(p_data) < public.my_level(p_store)
        or public.my_level(p_store) = 5));
$$;

-- Whether the signed-in user may give the Person p_data their team and role:
-- a team they reach, a role below their own level (level 5: any).
create function public.can_assign(p_store uuid, p_data jsonb)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.my_store_role(p_store) = 'owner'
    or (public.my_level(p_store) >= 3
      and public.reaches(p_store, p_data ->> 'team')
      and (public.my_level(p_store) = 5
        or public.person_level(p_data) < public.my_level(p_store)));
$$;

-- What the signed-in user may do in p_store, for the app:
-- {admin, level, team, person_id, status}, plus gerencia and chefe_team for
-- versions before 0.68.0.
create or replace function public.my_access(p_store uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with m as (
    select status, person_id from public.store_members
    where store_id = p_store and user_id = auth.uid()
  ), p as (
    select public.member_person(p_store, auth.uid()) as data
  ), l as (
    select greatest(public.my_level(p_store), 1) as level, data ->> 'team' as team from p
  )
  select jsonb_build_object(
    'admin', public.is_app_admin(),
    'level', (select level from l),
    'team', (select team from l),
    'gerencia', (select level >= 4 from l),
    'chefe_team', (select case when level = 3 then team end from l),
    'person_id', (select person_id from m),
    'status', case when public.is_app_admin() then 'approved'
                   else (select status from m) end
  );
$$;

create or replace function public.can_manage_members(p_store uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.is_app_admin() or public.my_level(p_store) >= 4;
$$;

create or replace function public.can_approve(p_store uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.my_store_role(p_store) = 'owner' or public.my_level(p_store) >= 3;
$$;

-- The role is public, with the old fields older versions show.
create or replace function public.person_public_keys()
returns text[]
language sql
immutable
set search_path = ''
as $$
  select array['fullName', 'photoPath', 'genero', 'birthDay', 'birthMonth', 'team',
    'role', 'chefe', 'supervisor', 'segundaLinha', 'permanencia', 'createdAt', 'syncUuid',
    'syncUpdatedAt', 'syncDeletedAt'];
$$;

create or replace function public.person_access(p_store uuid, p_person_id text, p_data jsonb)
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
    when public.my_level(p_store) >= 3 and public.reaches(p_store, p_data ->> 'team')
      then 'full'
    else 'public'
  end;
$$;

create or replace function public.can_request_update(p_store uuid, p_data jsonb)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.my_store_role(p_store) = 'owner'
    or (public.my_level(p_store) >= 3 and public.reaches(p_store, p_data ->> 'team'));
$$;

-- The fields of the Person p_person_id (the server's data p_data) the
-- signed-in user may write; null for every field (the admin).
create or replace function public.person_edit_keys(p_store uuid, p_person_id text, p_data jsonb)
returns text[]
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_keys text[] := '{}';
  v_request text[] := array['profileUpdateRequestedAt', 'profileUpdateRequestedBy'];
  v_self boolean;
  v_level int := public.my_level(p_store);
begin
  if public.my_store_role(p_store) = 'owner' then
    return null;
  end if;
  v_self := exists (
    select 1 from public.store_members
    where store_id = p_store and user_id = auth.uid() and status = 'approved'
      and person_id = p_person_id
  );
  if v_self then
    v_keys := v_keys || array['fullName', 'photoPath', 'birthDay', 'birthMonth',
      'genero', 'notes'] || v_request;
  end if;
  if v_level >= 3 and public.reaches(p_store, p_data ->> 'team') then
    v_keys := v_keys || array['folgas', 'ausencias'] || v_request;
  end if;
  if v_level >= 3 and (v_self or public.is_above(p_store, p_data)) then
    v_keys := v_keys || array['team', 'role', 'chefe', 'turno', 'supervisor',
      'segundaLinha', 'permanencia'];
  end if;
  return v_keys;
end;
$$;

-- Links the signed-in member of p_store to the Person p_person; someone at
-- level 3 or above is linked only by Gerência or the admin, in Membros.
create or replace function public.claim_person(p_store uuid, p_person text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_data jsonb;
begin
  if public.my_store_role(p_store) is null then
    raise exception 'Não pertence a esta loja.' using errcode = '42501';
  end if;
  select data into v_data from public.records
  where store_id = p_store and collection = 'Person' and id = p_person
    and deleted_at is null;
  if v_data is null then
    raise exception 'Esta pessoa foi apagada.' using errcode = 'P0002';
  end if;
  if not public.is_app_admin() then
    if exists (
      select 1 from public.store_members
      where store_id = p_store and user_id = auth.uid() and person_id is not null
    ) then
      raise exception 'A sua conta já está ligada a uma pessoa. Peça à gerência para a desligar.'
        using errcode = '42501';
    end if;
    if public.person_level(v_data) >= 3 then
      raise exception 'Uma pessoa com função de chefia só é ligada pela gerência (Membros).'
        using errcode = '42501';
    end if;
  end if;
  update public.store_members set person_id = p_person
  where store_id = p_store and user_id = auth.uid();
exception
  when unique_violation then
    raise exception 'Esta pessoa já tem conta.' using errcode = '23505';
end;
$$;

-- push_records (see the person access migration), by level: new people
-- from level 3 (can_assign), removals by those above the person (their
-- account leaves the store), and a team or role change kept only when the
-- caller may give it.
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
      and (r.updated_at > x.updated_at
        or (r.collection = 'Person' and r.updated_at = x.updated_at and r.data <> x.data));
end;
$$;

revoke execute on function public.store_team_ids() from public, anon;
revoke execute on function public.role_level(text) from public, anon;
revoke execute on function public.person_role(jsonb) from public, anon;
revoke execute on function public.person_level(jsonb) from public, anon;
revoke execute on function public.my_level(uuid) from public, anon;
revoke execute on function public.reaches(uuid, text) from public, anon;
revoke execute on function public.is_above(uuid, jsonb) from public, anon;
revoke execute on function public.can_assign(uuid, jsonb) from public, anon;
grant execute on function public.store_team_ids() to authenticated;
grant execute on function public.role_level(text) to authenticated;
grant execute on function public.person_role(jsonb) to authenticated;
grant execute on function public.person_level(jsonb) to authenticated;
grant execute on function public.my_level(uuid) to authenticated;
grant execute on function public.reaches(uuid, text) to authenticated;
grant execute on function public.is_above(uuid, jsonb) to authenticated;
grant execute on function public.can_assign(uuid, jsonb) to authenticated;
