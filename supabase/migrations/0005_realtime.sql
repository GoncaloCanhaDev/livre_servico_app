-- Enable Supabase Realtime broadcasts for every collection. RLS still
-- applies to subscribers, so users only receive events for rows they're
-- allowed to see.

alter publication supabase_realtime add table shift_events;
alter publication supabase_realtime add table truck_receptions;
alter publication supabase_realtime add table products;
alter publication supabase_realtime add table opening_lists;
alter publication supabase_realtime add table auto_lists;
alter publication supabase_realtime add table report_lists;
alter publication supabase_realtime add table visual_lists;
alter publication supabase_realtime add table daily_tasks;
alter publication supabase_realtime add table inventories;
alter publication supabase_realtime add table info_entries;
alter publication supabase_realtime add table notification_logs;
