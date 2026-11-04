-- Administração → Contas: the app's admin removes an account for good. Its
-- memberships and store-change request go with it (on delete cascade), its
-- error reports and the rows it saved keep no link to it (on delete set
-- null); the store's data, its Person among it, stays. Never the admin's
-- own account or another admin's.
create function public.admin_delete_account(p_user uuid)
returns void
language plpgsql
volatile
security definer
set search_path = ''
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador remove contas.' using errcode = '42501';
  end if;
  if p_user = auth.uid() then
    raise exception 'Não pode remover a sua própria conta.' using errcode = '42501';
  end if;
  if exists (select 1 from public.app_admins a where a.user_id = p_user) then
    raise exception 'Não pode remover a conta de um administrador.' using errcode = '42501';
  end if;
  delete from auth.users where id = p_user;
  if not found then
    raise exception 'Essa conta já não existe.' using errcode = 'P0002';
  end if;
end;
$$;

revoke execute on function public.admin_delete_account(uuid) from public, anon;
grant execute on function public.admin_delete_account(uuid) to authenticated;
