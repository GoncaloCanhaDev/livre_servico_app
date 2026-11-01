-- Administração: the app's admin sees every store at once: what waits for
-- them (admin_summary), every request to join any store
-- (admin_join_requests, approved or refused with approve_join /
-- refuse_join, which already take the store), every store with its counts
-- (admin_stores), every account and where it is (admin_accounts) and one
-- store's people (admin_store_people). The admin only, read only.

-- How many requests to join (in every store), to move store and error
-- reports or suggestions not yet dealt with.
create function public.admin_summary()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador vê a administração.' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'join_requests', (select count(*) from public.store_members where status = 'pending'),
    'transfers', (select count(*) from public.store_transfers),
    'feedback', (select count(*) from public.feedback where done_at is null)
  );
end;
$$;

-- Every pending request to join, in every store, oldest first.
create function public.admin_join_requests()
returns table (
  store_id uuid,
  store_name text,
  user_id uuid,
  email text,
  person_id text,
  person_name text,
  requested_name text,
  created_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador vê a administração.' using errcode = '42501';
  end if;
  return query
    select m.store_id, s.name, m.user_id, u.email::text, m.person_id,
      r.data ->> 'fullName', m.requested_name, m.created_at
    from public.store_members m
    join public.stores s on s.id = m.store_id
    join auth.users u on u.id = m.user_id
    left join public.records r
      on r.store_id = m.store_id and r.collection = 'Person' and r.id = m.person_id
    where m.status = 'pending'
    order by m.created_at;
end;
$$;

-- Every store, by name, with its approved members, pending requests and
-- people (not removed).
create function public.admin_stores()
returns table (
  id uuid,
  name text,
  created_at timestamptz,
  members bigint,
  pending bigint,
  people bigint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador vê a administração.' using errcode = '42501';
  end if;
  return query
    select s.id, s.name, s.created_at,
      (select count(*) from public.store_members m
        where m.store_id = s.id and m.status = 'approved'),
      (select count(*) from public.store_members m
        where m.store_id = s.id and m.status = 'pending'),
      (select count(*) from public.records r
        where r.store_id = s.id and r.collection = 'Person' and r.deleted_at is null)
    from public.stores s
    order by s.name;
end;
$$;

-- Every account, by email, with its store (one each but the admin's: a row
-- per membership, or one with no store), whether it is approved there and
-- the person it is linked to.
create function public.admin_accounts()
returns table (
  user_id uuid,
  email text,
  created_at timestamptz,
  last_sign_in_at timestamptz,
  is_admin boolean,
  store_id uuid,
  store_name text,
  status text,
  person_name text
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador vê a administração.' using errcode = '42501';
  end if;
  return query
    select u.id, u.email::text, u.created_at, u.last_sign_in_at,
      exists (select 1 from public.app_admins a where a.user_id = u.id),
      m.store_id, s.name, m.status::text, r.data ->> 'fullName'
    from auth.users u
    left join public.store_members m on m.user_id = u.id
    left join public.stores s on s.id = m.store_id
    left join public.records r
      on r.store_id = m.store_id and r.collection = 'Person' and r.id = m.person_id
    order by lower(u.email::text), s.name;
end;
$$;

-- The store p_store's people (not removed), by name, with the account
-- linked to each.
create function public.admin_store_people(p_store uuid)
returns table (
  id text,
  full_name text,
  collaborator_number text,
  team text,
  role text,
  email text
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador vê a administração.' using errcode = '42501';
  end if;
  return query
    select r.id, r.data ->> 'fullName', r.data ->> 'collaboratorNumber',
      r.data ->> 'team', r.data ->> 'role', u.email::text
    from public.records r
    left join public.store_members m
      on m.store_id = r.store_id and m.person_id = r.id
    left join auth.users u on u.id = m.user_id
    where r.store_id = p_store and r.collection = 'Person' and r.deleted_at is null
    order by lower(r.data ->> 'fullName');
end;
$$;

revoke execute on function public.admin_summary() from public, anon;
revoke execute on function public.admin_join_requests() from public, anon;
revoke execute on function public.admin_stores() from public, anon;
revoke execute on function public.admin_accounts() from public, anon;
revoke execute on function public.admin_store_people(uuid) from public, anon;
grant execute on function public.admin_summary() to authenticated;
grant execute on function public.admin_join_requests() to authenticated;
grant execute on function public.admin_stores() to authenticated;
grant execute on function public.admin_accounts() to authenticated;
grant execute on function public.admin_store_people(uuid) to authenticated;
