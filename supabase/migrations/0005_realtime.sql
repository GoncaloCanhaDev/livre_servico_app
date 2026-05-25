-- Enable Supabase Realtime broadcasts for every collection. RLS still
-- applies to subscribers, so users only receive events for rows they're
-- allowed to see.
--
-- Wrapped so re-running is a no-op when a table is already in the
-- publication (alter publication ... add table errors otherwise).

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
    begin
      execute format('alter publication supabase_realtime add table %I', t);
    exception when duplicate_object then
      null;
    end;
  end loop;
end$$;
