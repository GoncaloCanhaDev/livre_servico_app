-- One store per person, moved only by the admin.
--
-- Everyone but the app's admin belongs to one store: they join it with its
-- code once, and from then on can't join or be added to another. To move,
-- they ask (request_store_transfer, with a note saying where to); the admin
-- sees the requests (store_transfer_requests) and moves them
-- (transfer_member): the account and its person go to the new store, and
-- the old store keeps the person as a tombstone (their history stays
-- there).

create table public.store_transfers (
  user_id     uuid primary key references auth.users (id) on delete cascade,
  from_store  uuid not null references public.stores (id) on delete cascade,
  note        text not null default '',
  created_at  timestamptz not null default now()
);
alter table public.store_transfers enable row level security;
-- No policies: only through the functions below.

-- Whether p_user belongs to (or asked to join) a store other than p_store.
create function public.in_other_store(p_user uuid, p_store uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.store_members
    where user_id = p_user and store_id <> p_store
  );
$$;

-- join_store (see the join approval migration), refusing someone already in
-- another store: moving is the admin's.
create or replace function public.join_store(
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
  if not public.is_app_admin() and public.in_other_store(auth.uid(), v_store) then
    raise exception 'Já pertence a uma loja. Para mudar, peça ao administrador (Conta → Pedir mudança de loja).'
      using errcode = '42501';
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

-- add_store_member (see the no store owners migration), refusing someone
-- already in another store.
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
  if public.in_other_store(v_user, p_store)
    and not exists (select 1 from public.app_admins where user_id = v_user) then
    raise exception 'Esta pessoa pertence a outra loja: só o administrador a muda de loja.'
      using errcode = '42501';
  end if;
  insert into public.store_members (store_id, user_id, role)
    values (p_store, v_user, p_role)
    on conflict (store_id, user_id) do update set role = excluded.role;
  return v_user;
end;
$$;

-- Asks the admin to move this account out of p_store (a member of it), with
-- a note saying where to; replaces an earlier request.
create function public.request_store_transfer(p_store uuid, p_note text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.store_members
    where store_id = p_store and user_id = auth.uid() and status = 'approved'
  ) then
    raise exception 'Não pertence a esta loja.' using errcode = '42501';
  end if;
  insert into public.store_transfers (user_id, from_store, note)
    values (auth.uid(), p_store, trim(coalesce(p_note, '')))
    on conflict (user_id) do update
      set from_store = excluded.from_store, note = excluded.note, created_at = now();
end;
$$;

-- This account's request to move, if any.
create function public.my_store_transfer()
returns table (from_store uuid, note text, created_at timestamptz)
language sql
stable
security definer
set search_path = ''
as $$
  select from_store, note, created_at from public.store_transfers
  where user_id = auth.uid();
$$;

-- Withdraws this account's request to move.
create function public.cancel_store_transfer()
returns void
language sql
security definer
set search_path = ''
as $$
  delete from public.store_transfers where user_id = auth.uid();
$$;

-- Every request to move, oldest first: the admin only.
create function public.store_transfer_requests()
returns table (
  user_id uuid,
  email text,
  from_store uuid,
  from_store_name text,
  person_id text,
  person_name text,
  note text,
  created_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador muda pessoas de loja.' using errcode = '42501';
  end if;
  return query
    select t.user_id, u.email::text, t.from_store, s.name, m.person_id,
      r.data ->> 'fullName', t.note, t.created_at
    from public.store_transfers t
    join auth.users u on u.id = t.user_id
    join public.stores s on s.id = t.from_store
    left join public.store_members m
      on m.store_id = t.from_store and m.user_id = t.user_id
    left join public.records r
      on r.store_id = t.from_store and r.collection = 'Person' and r.id = m.person_id
    order by t.created_at;
end;
$$;

-- Moves p_user from p_from to p_to: the admin only. Their person goes with
-- them (same id; the old store keeps a tombstone, and their history), the
-- membership is approved in p_to, and their request (if any) is done.
create function public.transfer_member(p_user uuid, p_from uuid, p_to uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_person text;
  v_now bigint := (extract(epoch from now()) * 1000000)::bigint;
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador muda pessoas de loja.' using errcode = '42501';
  end if;
  if p_from = p_to then
    raise exception 'Escolha outra loja.' using errcode = '22023';
  end if;
  select person_id into v_person from public.store_members
  where store_id = p_from and user_id = p_user;
  if not found then
    raise exception 'Esta pessoa já não está nessa loja.' using errcode = 'P0002';
  end if;
  if v_person is not null then
    insert into public.records (store_id, collection, id, data, updated_at)
      select p_to, 'Person', r.id,
        (r.data - 'syncDeletedAt') || jsonb_build_object('syncUpdatedAt', v_now),
        now()
      from public.records r
      where r.store_id = p_from and r.collection = 'Person' and r.id = v_person
    on conflict (store_id, collection, id) do update
      set data = excluded.data, updated_at = excluded.updated_at, deleted_at = null;
    update public.records
      set data = data || jsonb_build_object('syncDeletedAt', v_now, 'syncUpdatedAt', v_now),
          updated_at = now(),
          deleted_at = now()
    where store_id = p_from and collection = 'Person' and id = v_person;
  end if;
  delete from public.store_members where store_id = p_from and user_id = p_user;
  insert into public.store_members (store_id, user_id, role, status, person_id)
    values (p_to, p_user, 'editor', 'approved', v_person)
    on conflict (store_id, user_id) do update
      set status = 'approved', person_id = coalesce(excluded.person_id, public.store_members.person_id);
  delete from public.store_transfers where user_id = p_user;
end;
$$;

revoke execute on function public.in_other_store(uuid, uuid) from public, anon, authenticated;
revoke execute on function public.request_store_transfer(uuid, text) from public, anon;
revoke execute on function public.my_store_transfer() from public, anon;
revoke execute on function public.cancel_store_transfer() from public, anon;
revoke execute on function public.store_transfer_requests() from public, anon;
revoke execute on function public.transfer_member(uuid, uuid, uuid) from public, anon;
grant execute on function public.request_store_transfer(uuid, text) to authenticated;
grant execute on function public.my_store_transfer() to authenticated;
grant execute on function public.cancel_store_transfer() to authenticated;
grant execute on function public.store_transfer_requests() to authenticated;
grant execute on function public.transfer_member(uuid, uuid, uuid) to authenticated;
