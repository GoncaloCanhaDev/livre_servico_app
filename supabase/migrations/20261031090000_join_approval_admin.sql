-- Joining a store waits for approval, and the app has an admin.
--
--   store_members.status          'pending' until a chefe de secção, a
--                                 member of Gerência, the owner or the admin
--                                 approves the request; a pending member
--                                 sees nothing of the store.
--   store_members.requested_name  the name typed by someone who isn't in the
--                                 store's list yet; approving creates that
--                                 Person and links it.
--   app_admins                    the app's admin(s): owner of every store.
--                                 Set by hand in the SQL Editor:
--                                 insert into public.app_admins
--                                 select id from auth.users where email = '...';
--
-- Who is a chefe or in Gerência comes from the Person the account is linked
-- to (store_members.person_id → that Person's record).

create table public.app_admins (
  user_id  uuid primary key references auth.users (id) on delete cascade
);
alter table public.app_admins enable row level security;
-- No policies: read only through is_app_admin().

alter table public.store_members
  add column status text not null default 'approved'
    check (status in ('pending', 'approved')),
  add column requested_name text;

-- "Só leitura" is gone: every approved member edits the everyday data.
update public.store_members set role = 'editor' where role = 'viewer';

create function public.is_app_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.app_admins where user_id = auth.uid());
$$;

-- The signed-in user's role in p_store: owner for the admin, null when not
-- an (approved) member.
create or replace function public.my_store_role(p_store uuid)
returns public.store_role
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when public.is_app_admin() then 'owner'::public.store_role
    else (
      select role from public.store_members
      where store_id = p_store and user_id = auth.uid() and status = 'approved'
    )
  end;
$$;

-- The stores where the signed-in user has at least p_role: every store for
-- the admin.
create or replace function public.my_store_ids(p_role public.store_role)
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select id from public.stores where public.is_app_admin()
  union
  select store_id from public.store_members
  where user_id = auth.uid() and role >= p_role and status = 'approved';
$$;

-- The data of the live Person that p_user (an approved member) is in
-- p_store, or null.
create function public.member_person(p_store uuid, p_user uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select r.data
  from public.store_members m
  join public.records r
    on r.store_id = m.store_id and r.collection = 'Person' and r.id = m.person_id
  where m.store_id = p_store and m.user_id = p_user and m.status = 'approved'
    and r.deleted_at is null;
$$;

-- The team the person p_data is chefe de secção of (a chefe slot that team
-- has, as lib/models/teams.dart), or null.
create function public.person_chefe_team(p_data jsonb)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when p_data ->> 'team' = 'livre_servico'
      and p_data ->> 'chefe' in ('dia', 'noite') then 'livre_servico'
    when p_data ->> 'team' in
        ('gerencia', 'charcutaria', 'meal_solutions', 'talho', 'peixaria', 'padaria')
      and p_data ->> 'chefe' = 'chefe' then p_data ->> 'team'
  end;
$$;

-- What the signed-in user may do in p_store, for the app:
-- {admin, owner, gerencia, chefe_team, person_id, status}.
create function public.my_access(p_store uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with m as (
    select role, status, person_id from public.store_members
    where store_id = p_store and user_id = auth.uid()
  ), p as (
    select public.member_person(p_store, auth.uid()) as data
  )
  select jsonb_build_object(
    'admin', public.is_app_admin(),
    'owner', coalesce((select role = 'owner' and status = 'approved' from m), false),
    'gerencia', coalesce((select data ->> 'team' = 'gerencia' from p), false),
    'chefe_team', (select public.person_chefe_team(data) from p),
    'person_id', (select person_id from m),
    'status', case when public.is_app_admin() then 'approved'
                   else (select status from m) end
  );
$$;

-- The signed-in user's stores (pending requests included), or every store
-- for the admin, by name.
create function public.my_stores()
returns table (id uuid, name text, role public.store_role, person_id text, status text)
language sql
stable
security definer
set search_path = ''
as $$
  select s.id, s.name,
    case when public.is_app_admin() then 'owner'::public.store_role else m.role end,
    m.person_id,
    case when public.is_app_admin() then 'approved' else m.status end
  from public.stores s
  left join public.store_members m on m.store_id = s.id and m.user_id = auth.uid()
  where public.is_app_admin() or m.user_id is not null
  order by s.name;
$$;

-- Whether the signed-in user approves join requests in p_store: the admin,
-- the owner, Gerência and every chefe de secção.
create function public.can_approve(p_store uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.my_store_role(p_store) = 'owner'
    or coalesce((
      select data ->> 'team' = 'gerencia' or public.person_chefe_team(data) is not null
      from (select public.member_person(p_store, auth.uid()) as data) p
    ), false);
$$;

-- Links the signed-in member of p_store to the Person p_person, unless
-- another account has it. Access comes from that person (chefe, Gerência),
-- so a member links themselves only once, and never to a chefe or to
-- Gerência: for those, the request goes through an approver (join_store) or
-- the owner sets the link. The owner (and the admin) may link freely.
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
  if public.my_store_role(p_store) <> 'owner' then
    if exists (
      select 1 from public.store_members
      where store_id = p_store and user_id = auth.uid() and person_id is not null
    ) then
      raise exception 'A sua conta já está ligada a uma pessoa. Peça ao dono da loja para a desligar.'
        using errcode = '42501';
    end if;
    if v_data ->> 'team' = 'gerencia' or public.person_chefe_team(v_data) is not null then
      raise exception 'Para ser um chefe ou da gerência, peça a um chefe ou à gerência que aprove.'
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

-- Asks to join the store with code p_code as the person p_person, or (not in
-- the list) with the name p_name; a member already keeps their membership
-- and, given p_person, is linked to it. Returns the store's id.
drop function public.join_store(text, text);
create function public.join_store(
  p_code text,
  p_person text default null,
  p_name text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_store uuid := public.store_by_code(p_code);
  v_name text := nullif(trim(coalesce(p_name, '')), '');
begin
  if auth.uid() is null then
    raise exception 'Sessão não iniciada.' using errcode = '42501';
  end if;
  if exists (
    select 1 from public.store_members
    where store_id = v_store and user_id = auth.uid()
  ) then
    if p_person is not null and public.my_store_role(v_store) is not null then
      perform public.claim_person(v_store, p_person);
    end if;
    return v_store;
  end if;
  if (p_person is null) = (v_name is null) then
    raise exception 'Escolha quem é ou escreva o seu nome.' using errcode = '22023';
  end if;
  if p_person is not null and not exists (
    select 1 from public.records
    where store_id = v_store and collection = 'Person' and id = p_person
      and deleted_at is null
  ) then
    raise exception 'Esta pessoa foi apagada.' using errcode = 'P0002';
  end if;
  insert into public.store_members (store_id, user_id, role, status, person_id, requested_name)
    values (v_store, auth.uid(), 'editor', 'pending', p_person,
            case when p_person is null then v_name end);
  return v_store;
exception
  when unique_violation then
    raise exception 'Esta pessoa já tem conta.' using errcode = '23505';
end;
$$;

-- Pending requests to join p_store, oldest first, for those who approve.
create function public.store_join_requests(p_store uuid)
returns table (
  user_id uuid,
  email text,
  person_id text,
  person_name text,
  requested_name text,
  created_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.can_approve(p_store) then
    raise exception 'Sem permissão para aprovar pedidos.' using errcode = '42501';
  end if;
  return query
    select m.user_id, u.email::text, m.person_id, r.data ->> 'fullName',
      m.requested_name, m.created_at
    from public.store_members m
    join auth.users u on u.id = m.user_id
    left join public.records r
      on r.store_id = m.store_id and r.collection = 'Person' and r.id = m.person_id
    where m.store_id = p_store and m.status = 'pending'
    order by m.created_at;
end;
$$;

-- Approves p_user's request to join p_store; a typed name becomes a new
-- Person (dates as the app writes them: microseconds since the epoch),
-- linked to them.
create function public.approve_join(p_store uuid, p_user uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_name text;
  v_person text;
  v_now bigint := (extract(epoch from now()) * 1000000)::bigint;
begin
  if not public.can_approve(p_store) then
    raise exception 'Sem permissão para aprovar pedidos.' using errcode = '42501';
  end if;
  select requested_name into v_name from public.store_members
  where store_id = p_store and user_id = p_user and status = 'pending';
  if not found then
    raise exception 'Este pedido já não existe.' using errcode = 'P0002';
  end if;
  if v_name is not null then
    v_person := gen_random_uuid()::text;
    insert into public.records (store_id, collection, id, data, updated_at)
      values (p_store, 'Person', v_person, jsonb_build_object(
        'syncUuid', v_person,
        'fullName', v_name,
        'createdAt', v_now,
        'syncUpdatedAt', v_now
      ), now());
  end if;
  update public.store_members
    set status = 'approved',
        person_id = coalesce(v_person, person_id),
        requested_name = null
  where store_id = p_store and user_id = p_user;
end;
$$;

-- Refuses (deletes) p_user's request to join p_store.
create function public.refuse_join(p_store uuid, p_user uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.can_approve(p_store) then
    raise exception 'Sem permissão para aprovar pedidos.' using errcode = '42501';
  end if;
  delete from public.store_members
  where store_id = p_store and user_id = p_user and status = 'pending';
end;
$$;

-- Approved members only: requests are listed by store_join_requests.
create or replace function public.store_member_list(p_store uuid)
returns table (user_id uuid, email text, role public.store_role, person_id text)
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
    select m.user_id, u.email::text, m.role, m.person_id
    from public.store_members m
    join auth.users u on u.id = m.user_id
    where m.store_id = p_store and m.status = 'approved'
    order by m.role desc, u.email;
end;
$$;

create policy "everyone sees their own memberships" on public.store_members
  for select to authenticated
  using (user_id = auth.uid());

create policy "members cancel their own pending request" on public.store_members
  for delete to authenticated
  using (user_id = auth.uid() and status = 'pending');

revoke execute on function public.is_app_admin() from public, anon;
revoke execute on function public.member_person(uuid, uuid) from public, anon, authenticated;
revoke execute on function public.person_chefe_team(jsonb) from public, anon;
revoke execute on function public.my_access(uuid) from public, anon;
revoke execute on function public.my_stores() from public, anon;
revoke execute on function public.can_approve(uuid) from public, anon;
revoke execute on function public.join_store(text, text, text) from public, anon;
revoke execute on function public.store_join_requests(uuid) from public, anon;
revoke execute on function public.approve_join(uuid, uuid) from public, anon;
revoke execute on function public.refuse_join(uuid, uuid) from public, anon;
grant execute on function public.is_app_admin() to authenticated;
grant execute on function public.person_chefe_team(jsonb) to authenticated;
grant execute on function public.my_access(uuid) to authenticated;
grant execute on function public.my_stores() to authenticated;
grant execute on function public.can_approve(uuid) to authenticated;
grant execute on function public.join_store(text, text, text) to authenticated;
grant execute on function public.store_join_requests(uuid) to authenticated;
grant execute on function public.approve_join(uuid, uuid) to authenticated;
grant execute on function public.refuse_join(uuid, uuid) to authenticated;
