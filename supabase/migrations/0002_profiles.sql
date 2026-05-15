-- Profiles table: one row per Supabase user, holding the bits of identity
-- the app needs but that don't fit in auth.users (employee number, names).
--
-- The trigger at the bottom auto-creates a profile row from the metadata
-- passed in `auth.signUp(..., data: {...})`.

create table if not exists profiles (
  user_id         uuid primary key references auth.users(id) on delete cascade,
  email           text not null,
  employee_number text not null default '',
  first_name      text not null default '',
  last_name       text not null default '',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- Unique only when set (an empty string isn't an identity).
create unique index if not exists profiles_employee_number_uniq
  on profiles (employee_number)
  where employee_number <> '';

alter table profiles enable row level security;

drop policy if exists "profiles_self_select" on profiles;
create policy "profiles_self_select" on profiles
  for select to authenticated
  using (user_id = auth.uid());

drop policy if exists "profiles_self_insert" on profiles;
create policy "profiles_self_insert" on profiles
  for insert to authenticated
  with check (user_id = auth.uid());

drop policy if exists "profiles_self_update" on profiles;
create policy "profiles_self_update" on profiles
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Sign-in by employee number needs to resolve the email without being
-- authenticated yet. This function is SECURITY DEFINER so it can read
-- the table, but it only returns the single matching email — RLS still
-- protects everything else.
create or replace function public.email_for_employee_number(empnum text)
returns text
language sql
security definer
set search_path = public, pg_temp
as $$
  select email from profiles where employee_number = empnum limit 1;
$$;

grant execute on function public.email_for_employee_number(text)
  to anon, authenticated;

-- When a new auth.users row is created, copy the sign-up metadata into
-- the profiles table so the rest of the app can rely on it being there.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  insert into public.profiles (user_id, email, employee_number, first_name, last_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'employee_number', ''),
    coalesce(new.raw_user_meta_data->>'first_name', ''),
    coalesce(new.raw_user_meta_data->>'last_name', '')
  )
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
