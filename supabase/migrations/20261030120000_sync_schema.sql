-- Livre Serviço — online database for sync between the phone and the web.
--
-- Run it once in the Supabase dashboard (SQL Editor → New query → paste → Run),
-- or with the Supabase CLI (`supabase db push`).
--
-- The app keeps working offline on its own local database and syncs with this
-- one. Every local row (Person, TruckReception, the lists, HorarioMes, the
-- vasilhame and other settings...) is stored here as one JSON document in
-- `records`, so adding a field to a model never needs a migration here.
--
--   stores         one per store; all of a store's data and people share it.
--   store_members  who can open a store: viewer (read), editor (read/write),
--                  owner (read/write and manage members).
--   records        the synced rows. (store_id, collection, id) is the key:
--                  collection is the model name ("Person"), id its syncUuid
--                  (or a fixed key, e.g. the month "2026-10" for HorarioMes).
--
-- Sync rules:
--   * Push with push_records(): a row replaces the server copy only if its
--     updated_at (the client's syncUpdatedAt) is newer: last write wins. The
--     rows where the server copy won come back, so the client can keep them.
--   * Pull with a plain select on records where server_updated_at is after the
--     last pull, ordered by server_updated_at. server_updated_at is the
--     server's clock, set on every write, so phones with a wrong clock can't
--     skip rows. Pull from a little before the last cursor (a minute): a write
--     still committing when the last pull ran can carry an earlier time.
--     Applying a row twice is harmless.
--   * Nothing is deleted: a delete is a row with deleted_at set (the app's
--     syncDeletedAt tombstones).

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

-- Ordered, so roles compare: viewer < editor < owner.
create type public.store_role as enum ('viewer', 'editor', 'owner');

create table public.stores (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  created_at  timestamptz not null default now()
);

create table public.store_members (
  store_id    uuid not null references public.stores (id) on delete cascade,
  user_id     uuid not null references auth.users (id) on delete cascade,
  role        public.store_role not null default 'editor',
  created_at  timestamptz not null default now(),
  primary key (store_id, user_id)
);
create index store_members_user_idx on public.store_members (user_id);

create table public.records (
  store_id           uuid not null references public.stores (id) on delete cascade,
  collection         text not null,
  id                 text not null,
  data               jsonb not null,
  updated_at         timestamptz not null,
  deleted_at         timestamptz,
  server_updated_at  timestamptz not null default clock_timestamp(),
  updated_by         uuid references auth.users (id) on delete set null,
  primary key (store_id, collection, id)
);
create index records_pull_idx on public.records (store_id, server_updated_at);

-- server_updated_at and updated_by are always the server's, never the client's.
create function public.records_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.server_updated_at := clock_timestamp();
  new.updated_by := auth.uid();
  return new;
end;
$$;

create trigger records_touch
  before insert or update on public.records
  for each row execute function public.records_touch();

-- ---------------------------------------------------------------------------
-- Access
-- ---------------------------------------------------------------------------

-- The signed-in user's role in p_store, or null when not a member.
-- Security definer so the policies below can read store_members without
-- going through its own policies.
create function public.my_store_role(p_store uuid)
returns public.store_role
language sql
stable
security definer
set search_path = ''
as $$
  select role from public.store_members
  where store_id = p_store and user_id = auth.uid();
$$;

-- The stores where the signed-in user has at least p_role.
create function public.my_store_ids(p_role public.store_role)
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select store_id from public.store_members
  where user_id = auth.uid() and role >= p_role;
$$;

alter table public.stores enable row level security;
alter table public.store_members enable row level security;
alter table public.records enable row level security;

create policy "members read their stores" on public.stores
  for select to authenticated
  using (id in (select public.my_store_ids('viewer')));

create policy "owners rename their stores" on public.stores
  for update to authenticated
  using (id in (select public.my_store_ids('owner')))
  with check (id in (select public.my_store_ids('owner')));

create policy "members see who else is in their stores" on public.store_members
  for select to authenticated
  using (store_id in (select public.my_store_ids('viewer')));

-- Owners manage the others but not themselves, so a store always keeps an
-- owner. New members are added with add_store_member().
create policy "owners change other members" on public.store_members
  for update to authenticated
  using (store_id in (select public.my_store_ids('owner')) and user_id <> auth.uid())
  with check (store_id in (select public.my_store_ids('owner')) and user_id <> auth.uid());

create policy "owners remove other members" on public.store_members
  for delete to authenticated
  using (store_id in (select public.my_store_ids('owner')) and user_id <> auth.uid());

create policy "members read records" on public.records
  for select to authenticated
  using (store_id in (select public.my_store_ids('viewer')));

create policy "editors add records" on public.records
  for insert to authenticated
  with check (store_id in (select public.my_store_ids('editor')));

create policy "editors change records" on public.records
  for update to authenticated
  using (store_id in (select public.my_store_ids('editor')))
  with check (store_id in (select public.my_store_ids('editor')));

-- ---------------------------------------------------------------------------
-- Functions the app calls
-- ---------------------------------------------------------------------------

-- Creates a store with the signed-in user as its owner; returns its id.
create function public.create_store(p_name text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_store uuid;
begin
  if auth.uid() is null then
    raise exception 'Sessão não iniciada.' using errcode = '42501';
  end if;
  insert into public.stores (name) values (p_name) returning id into v_store;
  insert into public.store_members (store_id, user_id, role)
    values (v_store, auth.uid(), 'owner');
  return v_store;
end;
$$;

-- Adds (or changes the role of) the user with p_email in p_store. Owners only;
-- that person must have created their account first.
create function public.add_store_member(
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
  if public.my_store_role(p_store) is distinct from 'owner' then
    raise exception 'Só o dono da loja pode adicionar pessoas.' using errcode = '42501';
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

-- Saves p_rows, a JSON array of {collection, id, data, updated_at, deleted_at},
-- into p_store: each one only if it is newer than the server's copy. Returns
-- the server's copy of every row that was newer, so the client takes it.
-- No (collection, id) may appear twice in one call.
create function public.push_records(p_store uuid, p_rows jsonb)
returns setof public.records
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if coalesce(public.my_store_role(p_store) >= 'editor', false) is false then
    raise exception 'Sem permissão para alterar os dados desta loja.' using errcode = '42501';
  end if;

  insert into public.records as r (store_id, collection, id, data, updated_at, deleted_at)
  select p_store, x.collection, x.id, x.data, x.updated_at, x.deleted_at
  from jsonb_to_recordset(p_rows)
    as x (collection text, id text, data jsonb, updated_at timestamptz, deleted_at timestamptz)
  on conflict (store_id, collection, id) do update
    set data = excluded.data,
        updated_at = excluded.updated_at,
        deleted_at = excluded.deleted_at
    where r.updated_at < excluded.updated_at;

  return query
    select r.*
    from public.records r
    join jsonb_to_recordset(p_rows) as x (collection text, id text, updated_at timestamptz)
      on r.collection = x.collection and r.id = x.id
    where r.store_id = p_store and r.updated_at > x.updated_at;
end;
$$;

revoke execute on function public.my_store_role(uuid) from public, anon;
revoke execute on function public.my_store_ids(public.store_role) from public, anon;
revoke execute on function public.create_store(text) from public, anon;
revoke execute on function public.add_store_member(uuid, text, public.store_role) from public, anon;
revoke execute on function public.push_records(uuid, jsonb) from public, anon;
grant execute on function public.my_store_role(uuid) to authenticated;
grant execute on function public.my_store_ids(public.store_role) to authenticated;
grant execute on function public.create_store(text) to authenticated;
grant execute on function public.add_store_member(uuid, text, public.store_role) to authenticated;
grant execute on function public.push_records(uuid, jsonb) to authenticated;

-- Changes reach other open devices right away (Supabase Realtime), on top of
-- the regular pull.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.records;
  end if;
end;
$$;
