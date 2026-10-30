-- The "Quem é você?" list shows only each person's name and collaborator
-- number: someone who isn't a member yet sees no other personal details.

drop function public.store_unlinked_people(uuid);
drop function public.unlinked_people(uuid);

-- The store's people with no account linked yet, by name.
create function public.unlinked_people(p_store uuid)
returns table (id text, full_name text, collaborator_number text)
language sql
stable
security definer
set search_path = ''
as $$
  select r.id, r.data ->> 'fullName', r.data ->> 'collaboratorNumber'
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

-- unlinked_people for members (join_store_preview calls it for the others).
create function public.store_unlinked_people(p_store uuid)
returns table (id text, full_name text, collaborator_number text)
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

revoke execute on function public.unlinked_people(uuid) from public, anon, authenticated;
revoke execute on function public.store_unlinked_people(uuid) from public, anon;
grant execute on function public.store_unlinked_people(uuid) to authenticated;
