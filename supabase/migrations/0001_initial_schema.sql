-- Livre Serviço — initial schema.
--
-- Run this once in Supabase SQL Editor (Dashboard → SQL Editor → New query).
-- It creates one table per Isar collection, scoped to each authenticated
-- user via Row Level Security.
--
-- Conventions:
--   uuid          : primary key, generated client-side (matches Isar.syncUuid)
--   user_id       : owner; foreign key to auth.users with cascade delete
--   updated_at    : LWW timestamp (matches Isar.syncUpdatedAt)
--   deleted_at    : soft-delete tombstone (matches Isar.syncDeletedAt); rows
--                   may stay in the table forever or be hard-deleted later.
--
-- Embedded objects (TruckReception.pallets, sentVasilhame) are stored as
-- JSONB so we don't fan out into extra tables.

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table if not exists shift_events (
  uuid         uuid primary key,
  user_id      uuid not null references auth.users(id) on delete cascade,
  updated_at   timestamptz not null,
  deleted_at   timestamptz,
  timestamp    timestamptz not null,
  type         text not null,            -- clockIn / pause / lunch / resume / clockOut
  shift_id     bigint not null,
  note         text
);
create index if not exists shift_events_user_idx        on shift_events (user_id);
create index if not exists shift_events_updated_idx     on shift_events (updated_at);

create table if not exists truck_receptions (
  uuid           uuid primary key,
  user_id        uuid not null references auth.users(id) on delete cascade,
  updated_at     timestamptz not null,
  deleted_at     timestamptz,
  arrival_time   timestamptz not null,
  license_plate  text,
  supplier       text,
  notes          text,
  pallets        jsonb not null default '[]'::jsonb,
  sent_vasilhame jsonb not null default '[]'::jsonb
);
create index if not exists truck_receptions_user_idx    on truck_receptions (user_id);
create index if not exists truck_receptions_updated_idx on truck_receptions (updated_at);

create table if not exists products (
  uuid                uuid primary key,
  user_id             uuid not null references auth.users(id) on delete cascade,
  updated_at          timestamptz not null,
  deleted_at          timestamptz,
  ean                 text not null,
  sap_code            text not null,
  name                text not null,
  department          text not null,
  notes               text,
  created_at          timestamptz not null,
  product_updated_at  timestamptz not null,
  unique (user_id, ean)
);
create index if not exists products_user_idx            on products (user_id);
create index if not exists products_updated_idx         on products (updated_at);

create table if not exists opening_lists (
  uuid            uuid primary key,
  user_id         uuid not null references auth.users(id) on delete cascade,
  updated_at      timestamptz not null,
  deleted_at      timestamptz,
  service_day     timestamptz not null,
  congelados      integer not null default 0,
  opls            integer not null default 0,
  nao_pereciveis  integer not null default 0,
  finalized_at    timestamptz,
  unique (user_id, service_day)
);
create index if not exists opening_lists_user_idx       on opening_lists (user_id);
create index if not exists opening_lists_updated_idx    on opening_lists (updated_at);

create table if not exists auto_lists (
  uuid            uuid primary key,
  user_id         uuid not null references auth.users(id) on delete cascade,
  updated_at      timestamptz not null,
  deleted_at      timestamptz,
  created_at      timestamptz not null,
  congelados      integer not null default 0,
  opls            integer not null default 0,
  nao_pereciveis  integer not null default 0
);
create index if not exists auto_lists_user_idx          on auto_lists (user_id);
create index if not exists auto_lists_updated_idx       on auto_lists (updated_at);

create table if not exists report_lists (
  uuid             uuid primary key,
  user_id          uuid not null references auth.users(id) on delete cascade,
  updated_at       timestamptz not null,
  deleted_at       timestamptz,
  service_day      timestamptz not null,
  dias_sem_vendas  integer not null default 0,
  regularizacoes   integer not null default 0,
  massiva          integer not null default 0,
  repetidos        integer not null default 0,
  finalized_at     timestamptz,
  unique (user_id, service_day)
);
create index if not exists report_lists_user_idx        on report_lists (user_id);
create index if not exists report_lists_updated_idx     on report_lists (updated_at);

create table if not exists visual_lists (
  uuid             uuid primary key,
  user_id          uuid not null references auth.users(id) on delete cascade,
  updated_at       timestamptz not null,
  deleted_at       timestamptz,
  created_at       timestamptz not null,
  service_day      timestamptz not null,
  itens_picados    integer not null default 0,
  quebra_cents     integer not null default 0,
  beneficio_cents  integer not null default 0
);
create index if not exists visual_lists_user_idx        on visual_lists (user_id);
create index if not exists visual_lists_updated_idx     on visual_lists (updated_at);

create table if not exists daily_tasks (
  uuid                          uuid primary key,
  user_id                       uuid not null references auth.users(id) on delete cascade,
  updated_at                    timestamptz not null,
  deleted_at                    timestamptz,
  service_day                   timestamptz not null,
  kiwi_abertura                 boolean not null default false,
  alteracoes_preco              boolean not null default false,
  alteracoes_preco_count        integer not null default 0,
  verificacao_temperaturas      boolean not null default false,
  preenchimento_quadro          boolean not null default false,
  verificacao_validades         boolean not null default false,
  verificacao_validades_count   integer not null default 0,
  kiwi_fecho                    boolean not null default false,
  limpeza_maquina_voltas        boolean not null default false,
  last_updated_at               timestamptz,
  unique (user_id, service_day)
);
create index if not exists daily_tasks_user_idx         on daily_tasks (user_id);
create index if not exists daily_tasks_updated_idx      on daily_tasks (updated_at);

create table if not exists inventories (
  uuid         uuid primary key,
  user_id      uuid not null references auth.users(id) on delete cascade,
  updated_at   timestamptz not null,
  deleted_at   timestamptz,
  name         text not null,
  value_cents  integer not null,
  created_at   timestamptz not null
);
create index if not exists inventories_user_idx         on inventories (user_id);
create index if not exists inventories_updated_idx      on inventories (updated_at);

create table if not exists info_entries (
  uuid         uuid primary key,
  user_id      uuid not null references auth.users(id) on delete cascade,
  updated_at   timestamptz not null,
  deleted_at   timestamptz,
  bucket       text not null,
  title        text not null,
  description  text not null,
  contact      text,
  created_at   timestamptz not null
);
create index if not exists info_entries_user_idx        on info_entries (user_id);
create index if not exists info_entries_updated_idx     on info_entries (updated_at);

create table if not exists notification_logs (
  uuid           uuid primary key,
  user_id        uuid not null references auth.users(id) on delete cascade,
  updated_at     timestamptz not null,
  deleted_at     timestamptz,
  title          text not null,
  body           text not null,
  channel        text,
  scheduled_for  timestamptz not null,
  created_at     timestamptz not null
);
create index if not exists notification_logs_user_idx     on notification_logs (user_id);
create index if not exists notification_logs_updated_idx  on notification_logs (updated_at);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table shift_events       enable row level security;
alter table truck_receptions   enable row level security;
alter table products           enable row level security;
alter table opening_lists      enable row level security;
alter table auto_lists         enable row level security;
alter table report_lists       enable row level security;
alter table visual_lists       enable row level security;
alter table daily_tasks        enable row level security;
alter table inventories        enable row level security;
alter table info_entries       enable row level security;
alter table notification_logs  enable row level security;

-- For each table: an authenticated user can do anything to their own rows,
-- and nothing to anyone else's.

do $$
declare
  t text;
  tables text[] := array[
    'shift_events','truck_receptions','products','opening_lists','auto_lists',
    'report_lists','visual_lists','daily_tasks','inventories','info_entries',
    'notification_logs'
  ];
begin
  foreach t in array tables loop
    execute format('drop policy if exists "%s_select_own" on %I', t, t);
    execute format(
      'create policy "%s_select_own" on %I for select to authenticated using (user_id = auth.uid())',
      t, t);

    execute format('drop policy if exists "%s_insert_own" on %I', t, t);
    execute format(
      'create policy "%s_insert_own" on %I for insert to authenticated with check (user_id = auth.uid())',
      t, t);

    execute format('drop policy if exists "%s_update_own" on %I', t, t);
    execute format(
      'create policy "%s_update_own" on %I for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid())',
      t, t);

    execute format('drop policy if exists "%s_delete_own" on %I', t, t);
    execute format(
      'create policy "%s_delete_own" on %I for delete to authenticated using (user_id = auth.uid())',
      t, t);
  end loop;
end$$;
