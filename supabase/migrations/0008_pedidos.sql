-- Pedidos: scan-driven order sheets (EAN + caixas), finalized with a
-- pedido number. Shared across users like the other collections.

create table if not exists pedidos (
  uuid                 uuid primary key,
  user_id              uuid not null references auth.users(id) on delete cascade,
  updated_at           timestamptz not null,
  deleted_at           timestamptz,
  created_by_initials  text,
  created_at           timestamptz not null,
  finished_at          timestamptz,
  numero               text
);
create index if not exists pedidos_user_idx       on pedidos (user_id);
create index if not exists pedidos_updated_idx    on pedidos (updated_at);
create index if not exists pedidos_created_idx    on pedidos (created_at);

create table if not exists pedido_lines (
  uuid                 uuid primary key,
  user_id              uuid not null references auth.users(id) on delete cascade,
  updated_at           timestamptz not null,
  deleted_at           timestamptz,
  created_by_initials  text,
  parent_uuid          uuid not null,
  ean                  text not null,
  product_name         text,
  caixas               integer not null default 0,
  created_at           timestamptz not null,
  updated_at_local     timestamptz not null
);
create index if not exists pedido_lines_user_idx     on pedido_lines (user_id);
create index if not exists pedido_lines_updated_idx  on pedido_lines (updated_at);
create index if not exists pedido_lines_parent_idx   on pedido_lines (parent_uuid);
create index if not exists pedido_lines_ean_idx      on pedido_lines (ean);

alter table pedidos       enable row level security;
alter table pedido_lines  enable row level security;

create or replace function public.preserve_user_id()
returns trigger
language plpgsql
as $$
begin
  new.user_id = old.user_id;
  return new;
end;
$$;

do $$
declare
  t text;
  tables text[] := array['pedidos','pedido_lines'];
begin
  foreach t in array tables loop
    execute format('drop policy if exists "%s_select_shared" on %I', t, t);
    execute format(
      'create policy "%s_select_shared" on %I for select to authenticated using (true)',
      t, t);

    execute format('drop policy if exists "%s_insert_own" on %I', t, t);
    execute format(
      'create policy "%s_insert_own" on %I for insert to authenticated with check (user_id = auth.uid())',
      t, t);

    execute format('drop policy if exists "%s_update_shared" on %I', t, t);
    execute format(
      'create policy "%s_update_shared" on %I for update to authenticated using (true) with check (true)',
      t, t);

    execute format('drop policy if exists "%s_delete_shared" on %I', t, t);
    execute format(
      'create policy "%s_delete_shared" on %I for delete to authenticated using (true)',
      t, t);

    execute format('drop trigger if exists preserve_user_id_trg on %I', t);
    execute format(
      'create trigger preserve_user_id_trg before update on %I for each row execute function public.preserve_user_id()',
      t);
  end loop;
end$$;

do $$
declare
  t text;
  tables text[] := array['pedidos','pedido_lines'];
begin
  foreach t in array tables loop
    begin
      execute format('alter publication supabase_realtime add table %I', t);
    exception when duplicate_object then
      null;
    end;
  end loop;
end$$;
