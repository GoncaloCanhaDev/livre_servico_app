-- No store owners: the app's admin (app_admins) creates stores and may do
-- everything everywhere; Gerência manages each store's members (join code,
-- adding by email, linking accounts to people, removing). "Apagar Todos os
-- Dados" is the admin's alone (in the app). The owner role stays in the
-- enum, but nobody holds it: my_store_role still says 'owner' for the admin.

update public.store_members set role = 'editor' where role = 'owner';

-- Whether the signed-in user manages p_store's members: the admin, or a
-- member whose person is in Gerência.
create function public.can_manage_members(p_store uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.is_app_admin()
    or coalesce(public.member_person(p_store, auth.uid()) ->> 'team' = 'gerencia', false);
$$;

-- What the signed-in user may do in p_store, for the app:
-- {admin, gerencia, chefe_team, person_id, status}.
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
  )
  select jsonb_build_object(
    'admin', public.is_app_admin(),
    'gerencia', coalesce((select data ->> 'team' = 'gerencia' from p), false),
    'chefe_team', (select public.person_chefe_team(data) from p),
    'person_id', (select person_id from m),
    'status', case when public.is_app_admin() then 'approved'
                   else (select status from m) end
  );
$$;

-- Creates a store (the admin only), with the admin as a plain member so
-- they can be linked to their person there; returns its id.
create or replace function public.create_store(p_name text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_store uuid;
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador da aplicação cria lojas.' using errcode = '42501';
  end if;
  insert into public.stores (name) values (p_name) returning id into v_store;
  insert into public.store_members (store_id, user_id, role)
    values (v_store, auth.uid(), 'editor');
  return v_store;
end;
$$;

-- Adds (or changes the role of) the user with p_email in p_store: Gerência
-- and the admin; never as owner.
create or replace function public.add_store_member(
  p_store uuid,
  p_email text,
  p_role public.store_role default 'editor'
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid;
begin
  if not public.can_manage_members(p_store) then
    raise exception 'Só a gerência pode adicionar pessoas.' using errcode = '42501';
  end if;
  if p_role = 'owner' then
    raise exception 'Não há donos de loja.' using errcode = '22023';
  end if;
  select id into v_user from auth.users where lower(email) = lower(trim(p_email));
  if v_user is null then
    raise exception 'Não há nenhuma conta com o email %.', p_email using errcode = 'P0002';
  end if;
  if v_user = auth.uid() then
    raise exception 'Não pode mudar o seu próprio papel.' using errcode = '42501';
  end if;
  insert into public.store_members (store_id, user_id, role)
    values (p_store, v_user, p_role)
    on conflict (store_id, user_id) do update set role = excluded.role;
  return v_user;
end;
$$;

-- The store's join code, for Gerência and the admin; made the first time it
-- is asked for.
create or replace function public.store_join_code(p_store uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_code text;
begin
  if not public.can_manage_members(p_store) then
    raise exception 'Só a gerência vê o código.' using errcode = '42501';
  end if;
  select code into v_code from public.store_codes where store_id = p_store;
  if v_code is null then
    insert into public.store_codes (store_id, code)
      values (p_store, public.new_store_code())
      returning code into v_code;
  end if;
  return v_code;
end;
$$;

-- A new code for the store, so the old one stops working: Gerência and the
-- admin.
create or replace function public.reset_store_join_code(p_store uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_code text := public.new_store_code();
begin
  if not public.can_manage_members(p_store) then
    raise exception 'Só a gerência muda o código.' using errcode = '42501';
  end if;
  insert into public.store_codes (store_id, code) values (p_store, v_code)
    on conflict (store_id) do update set code = excluded.code;
  return v_code;
end;
$$;

-- Links the signed-in member of p_store to the Person p_person (see the
-- join approval migration); a chefe or Gerência person is linked only by
-- Gerência or the admin, in Membros.
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
    if v_data ->> 'team' = 'gerencia' or public.person_chefe_team(v_data) is not null then
      raise exception 'Uma pessoa chefe ou da gerência só é ligada pela gerência (Membros).'
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

-- Gerência (and the admin) link, unlink and remove the other members; the
-- app changes nothing else of a membership directly (role and status only
-- through the functions above).
drop policy "owners change other members" on public.store_members;
drop policy "owners remove other members" on public.store_members;

create policy "gerencia links other members" on public.store_members
  for update to authenticated
  using (public.can_manage_members(store_id) and user_id <> auth.uid())
  with check (public.can_manage_members(store_id) and user_id <> auth.uid());

create policy "gerencia removes other members" on public.store_members
  for delete to authenticated
  using (public.can_manage_members(store_id) and user_id <> auth.uid());

revoke update on public.store_members from authenticated;
grant update (person_id) on public.store_members to authenticated;

revoke execute on function public.can_manage_members(uuid) from public, anon;
grant execute on function public.can_manage_members(uuid) to authenticated;
