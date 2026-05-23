-- Justifications: free-text reasons explaining why a given daily list/task
-- was not completed on a specific service day. Shared across users like the
-- other collections (except shift_events).

create table if not exists justifications (
  uuid                 uuid primary key,
  user_id              uuid not null references auth.users(id) on delete cascade,
  updated_at           timestamptz not null,
  deleted_at           timestamptz,
  created_by_initials  text,
  service_day          timestamptz not null,
  kind                 text not null,
  reason               text not null
);
create index if not exists justifications_user_idx        on justifications (user_id);
create index if not exists justifications_updated_idx     on justifications (updated_at);
create index if not exists justifications_service_day_idx on justifications (service_day);
create index if not exists justifications_kind_idx        on justifications (kind);

alter table justifications enable row level security;

-- Shared read/update/delete; own-only insert (same pattern as 0004).
drop policy if exists "justifications_select_shared" on justifications;
create policy "justifications_select_shared" on justifications
  for select to authenticated using (true);

drop policy if exists "justifications_insert_own" on justifications;
create policy "justifications_insert_own" on justifications
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "justifications_update_shared" on justifications;
create policy "justifications_update_shared" on justifications
  for update to authenticated using (true) with check (true);

drop policy if exists "justifications_delete_shared" on justifications;
create policy "justifications_delete_shared" on justifications
  for delete to authenticated using (true);

-- Preserve original ownership when others edit. (Re-declared here so this
-- migration can run standalone if 0004 hasn't been applied yet.)
create or replace function public.preserve_user_id()
returns trigger
language plpgsql
as $$
begin
  new.user_id = old.user_id;
  return new;
end;
$$;

drop trigger if exists preserve_user_id_trg on justifications;
create trigger preserve_user_id_trg before update on justifications
  for each row execute function public.preserve_user_id();

-- Realtime broadcasts.
alter publication supabase_realtime add table justifications;
