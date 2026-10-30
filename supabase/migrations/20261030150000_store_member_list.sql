-- Who is in a store, with their emails, for the app's Membros screen.
-- store_members only has user ids and auth.users can't be read by the app,
-- so this security definer function joins them, for members of the store.

create function public.store_member_list(p_store uuid)
returns table (user_id uuid, email text, role public.store_role)
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
    select m.user_id, u.email::text, m.role
    from public.store_members m
    join auth.users u on u.id = m.user_id
    where m.store_id = p_store
    order by m.role desc, u.email;
end;
$$;

revoke execute on function public.store_member_list(uuid) from public, anon;
grant execute on function public.store_member_list(uuid) to authenticated;
