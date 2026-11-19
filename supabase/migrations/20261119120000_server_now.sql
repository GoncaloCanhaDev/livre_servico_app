-- The server's time, so each phone can measure how far its own clock is
-- (`ServerClock` in the app): tasks marked on two phones are then compared
-- by one clock. Reads nothing.
create or replace function public.server_now()
returns timestamptz
language sql
stable
as $$ select now() $$;

revoke all on function public.server_now() from public;
grant execute on function public.server_now() to authenticated;
