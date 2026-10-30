-- Joining a store with its code, and each account linked to its person.
--
--   store_codes             one code per store (e.g. "K7QM-2XPA"), which the
--                           owner shares with the team. Read only through
--                           the functions below, so only the owner sees it.
--   store_members.person_id the syncUuid of the account's Person in the store
--                           (its "profile"); at most one account per person.
--
-- Someone with the code sees the store's people that have no account yet
-- (join_store_preview), picks themselves or none, and joins as an editor
-- (join_store). A member can still link themselves later (claim_person).

create table public.store_codes (
  store_id  uuid primary key references public.stores (id) on delete cascade,
  code      text not null unique
);
alter table public.store_codes enable row level security;
-- No policies: nobody reads store_codes directly.

alter table public.store_members add column person_id text;
create unique index store_members_person_idx
  on public.store_members (store_id, person_id);

-- Eight characters without look-alikes (no I, O, 0, 1), from the strong
-- random bytes of a uuid (skipping its version and variant bytes).
create function public.new_store_code()
returns text
language sql
volatile
set search_path = ''
as $$
  select string_agg(
    substr('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', get_byte(u.b, i) % 32 + 1, 1),
    '' order by i
  )
  from (select uuid_send(gen_random_uuid()) as b) u,
    unnest(array[0, 1, 2, 3, 4, 5, 10, 11]) as i;
$$;

-- The store with code p_code: any case, dashes and spaces ignored.
create function public.store_by_code(p_code text)
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_store uuid;
begin
  select store_id into v_store from public.store_codes
  where code = upper(regexp_replace(coalesce(p_code, ''), '[^A-Za-z0-9]', '', 'g'));
  if v_store is null then
    raise exception 'Não há nenhuma loja com este código.' using errcode = 'P0002';
  end if;
  return v_store;
end;
$$;

-- The store's people with no account linked yet, by name.
create function public.unlinked_people(p_store uuid)
returns table (id text, full_name text, team text)
language sql
stable
security definer
set search_path = ''
as $$
  select r.id, r.data ->> 'fullName', r.data ->> 'team'
  from public.records r
  where r.store_id = p_store
    and r.collection = 'Person'
    and r.deleted_at is null
    and not exists (
      select 1 from public.store_members m
      where m.store_id = p_store and m.person_id = r.id
    )
  order by 2;
$$;

-- The store's join code, for its owner; made the first time it is asked for.
create function public.store_join_code(p_store uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_code text;
begin
  if public.my_store_role(p_store) is distinct from 'owner' then
    raise exception 'Só o dono da loja vê o código.' using errcode = '42501';
  end if;
  select code into v_code from public.store_codes where store_id = p_store;
  if v_code is null then
    insert into public.store_codes (store_id, code)
      values (p_store, public.new_store_code())
      returning code into v_code;
  end if;
  return v_code;
end;
$$;

-- A new code for the store, so the old one stops working. Owners only.
create function public.reset_store_join_code(p_store uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_code text := public.new_store_code();
begin
  if public.my_store_role(p_store) is distinct from 'owner' then
    raise exception 'Só o dono da loja muda o código.' using errcode = '42501';
  end if;
  insert into public.store_codes (store_id, code) values (p_store, v_code)
    on conflict (store_id) do update set code = excluded.code;
  return v_code;
end;
$$;

-- What someone with the code sees before joining: the store's name and the
-- people they can say they are, as {store_id, store_name, people: [{id,
-- full_name, team}]}.
create function public.join_store_preview(p_code text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_store uuid := public.store_by_code(p_code);
begin
  if auth.uid() is null then
    raise exception 'Sessão não iniciada.' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'store_id', v_store,
    'store_name', (select name from public.stores where id = v_store),
    'people', coalesce(
      (select jsonb_agg(to_jsonb(p)) from public.unlinked_people(v_store) p),
      '[]'::jsonb
    )
  );
end;
$$;

-- Links the signed-in member of p_store to the Person p_person (replacing
-- any person they were linked to), unless another account has it.
create function public.claim_person(p_store uuid, p_person text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if public.my_store_role(p_store) is null then
    raise exception 'Não pertence a esta loja.' using errcode = '42501';
  end if;
  if exists (
    select 1 from public.records
    where store_id = p_store and collection = 'Person' and id = p_person
      and deleted_at is not null
  ) then
    raise exception 'Esta pessoa foi apagada.' using errcode = 'P0002';
  end if;
  update public.store_members set person_id = p_person
  where store_id = p_store and user_id = auth.uid();
exception
  when unique_violation then
    raise exception 'Esta pessoa já tem conta.' using errcode = '23505';
end;
$$;

-- Joins the store with code p_code as an editor (a member already keeps
-- their role) and, given p_person, links this account to that person.
-- Returns the store's id.
create function public.join_store(p_code text, p_person text default null)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_store uuid := public.store_by_code(p_code);
begin
  if auth.uid() is null then
    raise exception 'Sessão não iniciada.' using errcode = '42501';
  end if;
  insert into public.store_members (store_id, user_id, role)
    values (v_store, auth.uid(), 'editor')
    on conflict (store_id, user_id) do nothing;
  if p_person is not null then
    perform public.claim_person(v_store, p_person);
  end if;
  return v_store;
end;
$$;

-- The members list now says which person each account is.
drop function public.store_member_list(uuid);
create function public.store_member_list(p_store uuid)
returns table (user_id uuid, email text, role public.store_role, person_id text)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if public.my_store_role(p_store) is null then
    raise exception 'Não pertence a esta loja.' using errcode = '42501';
  end if;
  return query
    select m.user_id, u.email::text, m.role, m.person_id
    from public.store_members m
    join auth.users u on u.id = m.user_id
    where m.store_id = p_store
    order by m.role desc, u.email;
end;
$$;

-- unlinked_people for members (join_store_preview calls it for the others).
create function public.store_unlinked_people(p_store uuid)
returns table (id text, full_name text, team text)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if public.my_store_role(p_store) is null then
    raise exception 'Não pertence a esta loja.' using errcode = '42501';
  end if;
  return query select * from public.unlinked_people(p_store);
end;
$$;

revoke execute on function public.new_store_code() from public, anon, authenticated;
revoke execute on function public.store_by_code(text) from public, anon, authenticated;
revoke execute on function public.unlinked_people(uuid) from public, anon, authenticated;
revoke execute on function public.store_join_code(uuid) from public, anon;
revoke execute on function public.reset_store_join_code(uuid) from public, anon;
revoke execute on function public.join_store_preview(text) from public, anon;
revoke execute on function public.claim_person(uuid, text) from public, anon;
revoke execute on function public.join_store(text, text) from public, anon;
revoke execute on function public.store_member_list(uuid) from public, anon;
revoke execute on function public.store_unlinked_people(uuid) from public, anon;
grant execute on function public.store_join_code(uuid) to authenticated;
grant execute on function public.reset_store_join_code(uuid) to authenticated;
grant execute on function public.join_store_preview(text) to authenticated;
grant execute on function public.claim_person(uuid, text) to authenticated;
grant execute on function public.join_store(text, text) to authenticated;
grant execute on function public.store_member_list(uuid) to authenticated;
grant execute on function public.store_unlinked_people(uuid) to authenticated;
