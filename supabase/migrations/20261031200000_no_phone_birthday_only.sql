-- People keep no phone number and, instead of a date of birth, only the
-- birthday: its day and month (birthDay, birthMonth). A trigger cleans every
-- Person row written (by the app, an older app version or this migration's
-- own pass over the existing rows), so neither can come back.

-- p_data without phoneNumber and dateOfBirth; a date of birth (microseconds
-- since the epoch, as the app writes dates, or an ISO string) becomes the
-- birthday, in Portugal's time, unless one is already set.
create function public.person_without_removed_fields(p_data jsonb)
returns jsonb
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_born date;
begin
  if jsonb_typeof(p_data -> 'dateOfBirth') = 'number'
    and (p_data ->> 'dateOfBirth')::numeric > -62135596800000000 then
    v_born := (to_timestamp((p_data ->> 'dateOfBirth')::numeric / 1000000)
      at time zone 'Europe/Lisbon')::date;
  elsif jsonb_typeof(p_data -> 'dateOfBirth') = 'string' then
    v_born := ((p_data ->> 'dateOfBirth')::timestamptz at time zone 'Europe/Lisbon')::date;
  end if;
  if v_born is not null and not (p_data ? 'birthDay' and p_data ? 'birthMonth'
    and jsonb_typeof(p_data -> 'birthDay') = 'number') then
    p_data := p_data || jsonb_build_object(
      'birthDay', extract(day from v_born)::int,
      'birthMonth', extract(month from v_born)::int
    );
  end if;
  return p_data - 'phoneNumber' - 'dateOfBirth';
end;
$$;

create function public.records_person_clean()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.collection = 'Person' then
    new.data := public.person_without_removed_fields(new.data);
  end if;
  return new;
end;
$$;

create trigger records_person_clean
  before insert or update on public.records
  for each row execute function public.records_person_clean();

-- The rows already there (their server_updated_at moves on, so every
-- device pulls them again, cleaned).
update public.records set data = data
where collection = 'Person' and (data ? 'phoneNumber' or data ? 'dateOfBirth');

-- The birthday is public, like the date of birth was.
create or replace function public.person_public_keys()
returns text[]
language sql
immutable
set search_path = ''
as $$
  select array['fullName', 'photoPath', 'genero', 'birthDay', 'birthMonth', 'team',
    'chefe', 'supervisor', 'segundaLinha', 'permanencia', 'createdAt', 'syncUuid',
    'syncUpdatedAt', 'syncDeletedAt'];
$$;

-- person_edit_keys (see the person access migration): the person edits
-- their birthday instead of a phone and a date of birth.
create or replace function public.person_edit_keys(p_store uuid, p_person_id text, p_data jsonb)
returns text[]
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_me jsonb := public.member_person(p_store, auth.uid());
  v_keys text[] := '{}';
  v_request text[] := array['profileUpdateRequestedAt', 'profileUpdateRequestedBy'];
begin
  if public.my_store_role(p_store) = 'owner' then
    return null;
  end if;
  if exists (
    select 1 from public.store_members
    where store_id = p_store and user_id = auth.uid() and status = 'approved'
      and person_id = p_person_id
  ) then
    v_keys := v_keys || array['fullName', 'photoPath', 'birthDay', 'birthMonth',
      'genero', 'notes'] || v_request;
  end if;
  if v_me ->> 'team' = 'gerencia' then
    v_keys := v_keys || array['folgas', 'ausencias', 'team', 'chefe', 'turno',
      'supervisor', 'segundaLinha', 'permanencia'] || v_request;
  elsif public.person_chefe_team(v_me) = p_data ->> 'team' then
    v_keys := v_keys || array['folgas', 'ausencias'] || v_request;
  end if;
  return v_keys;
end;
$$;

revoke execute on function public.person_without_removed_fields(jsonb) from public, anon, authenticated;
