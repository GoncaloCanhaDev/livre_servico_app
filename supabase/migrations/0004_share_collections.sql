-- Opens up all collections except shift_events (and notification_logs,
-- which are device-specific). Any authenticated user can read, write,
-- and delete any row on these tables. The original `user_id` is
-- preserved on update via a trigger so attribution (created_by_initials,
-- user_id) doesn't silently shift when someone else edits.
--
-- shift_events: untouched — still strictly per-user.
-- notification_logs: untouched — still strictly per-user.

-- ---------------------------------------------------------------------------
-- Tables to share
-- ---------------------------------------------------------------------------

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
  tables text[] := array[
    'truck_receptions','products','opening_lists','auto_lists',
    'report_lists','visual_lists','daily_tasks','inventories','info_entries'
  ];
begin
  foreach t in array tables loop
    -- Replace the per-user RLS policies with open ones.
    execute format('drop policy if exists "%s_select_own" on %I', t, t);
    execute format(
      'create policy "%s_select_shared" on %I for select to authenticated using (true)',
      t, t);

    -- INSERT stays own-only so you can only create rows as yourself.
    -- (no change needed — the original "_insert_own" policy is fine.)

    execute format('drop policy if exists "%s_update_own" on %I', t, t);
    execute format(
      'create policy "%s_update_shared" on %I for update to authenticated using (true) with check (true)',
      t, t);

    execute format('drop policy if exists "%s_delete_own" on %I', t, t);
    execute format(
      'create policy "%s_delete_shared" on %I for delete to authenticated using (true)',
      t, t);

    -- Protect user_id from being overwritten by clients on update.
    execute format('drop trigger if exists preserve_user_id_trg on %I', t);
    execute format(
      'create trigger preserve_user_id_trg before update on %I for each row execute function public.preserve_user_id()',
      t);
  end loop;
end$$;

-- ---------------------------------------------------------------------------
-- shift_events and notification_logs are intentionally left alone.
-- Their per-user select/insert/update/delete policies from migration 0001
-- remain in effect.
-- ---------------------------------------------------------------------------
