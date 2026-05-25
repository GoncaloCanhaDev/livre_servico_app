-- Inventory session redesign: add session metadata to inventories and
-- introduce inventory_lines for individual EAN counts.

alter table inventories add column if not exists code text;
alter table inventories add column if not exists started_at timestamptz;
alter table inventories add column if not exists running_since timestamptz;
alter table inventories add column if not exists accumulated_seconds integer not null default 0;
alter table inventories add column if not exists finished_at timestamptz;
alter table inventories add column if not exists final_value_cents integer;

-- ---------------------------------------------------------------------------
-- inventory_lines
-- ---------------------------------------------------------------------------

create table if not exists inventory_lines (
  uuid                 uuid primary key,
  user_id              uuid not null references auth.users(id) on delete cascade,
  updated_at           timestamptz not null,
  deleted_at           timestamptz,
  created_by_initials  text,
  parent_uuid          uuid not null,
  ean                  text not null,
  product_name         text,
  count                integer not null default 0,
  created_at           timestamptz not null,
  updated_at_local     timestamptz not null
);
create index if not exists inventory_lines_user_idx     on inventory_lines (user_id);
create index if not exists inventory_lines_updated_idx  on inventory_lines (updated_at);
create index if not exists inventory_lines_parent_idx   on inventory_lines (parent_uuid);
create index if not exists inventory_lines_ean_idx      on inventory_lines (ean);

alter table inventory_lines enable row level security;

-- Shared read/update/delete; own-only insert (same pattern as 0004).
drop policy if exists "inventory_lines_select_shared" on inventory_lines;
create policy "inventory_lines_select_shared" on inventory_lines
  for select to authenticated using (true);

drop policy if exists "inventory_lines_insert_own" on inventory_lines;
create policy "inventory_lines_insert_own" on inventory_lines
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "inventory_lines_update_shared" on inventory_lines;
create policy "inventory_lines_update_shared" on inventory_lines
  for update to authenticated using (true) with check (true);

drop policy if exists "inventory_lines_delete_shared" on inventory_lines;
create policy "inventory_lines_delete_shared" on inventory_lines
  for delete to authenticated using (true);

create or replace function public.preserve_user_id()
returns trigger
language plpgsql
as $$
begin
  new.user_id = old.user_id;
  return new;
end;
$$;

drop trigger if exists preserve_user_id_trg on inventory_lines;
create trigger preserve_user_id_trg before update on inventory_lines
  for each row execute function public.preserve_user_id();

do $$
begin
  alter publication supabase_realtime add table inventory_lines;
exception when duplicate_object then
  null;
end$$;
