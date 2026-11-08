-- Erros e sugestões get a state (Novo, Visto, Em curso, Resolvido, Não será
-- feito) set by the admin, and everyone signed in reads the public ones
-- (feedback_public_list): the kind, the text, the state and the date, never
-- who sent it or from which store. Only messages sent once the app said so
-- are public (send_feedback's p_public); older ones stay the admin's,
-- though their senders still see them, as their own.

alter table public.feedback
  add column status text not null default 'novo'
    check (status in ('novo', 'visto', 'em_curso', 'resolvido', 'recusado')),
  add column public boolean not null default false;

update public.feedback set status = 'resolvido' where done_at is not null;

-- done_at stays: set while the state is closed (resolvido or recusado), so
-- admin_summary's count of those still open is unchanged.

drop function public.send_feedback(text, text, uuid, text, text);
create function public.send_feedback(
  p_kind text,
  p_message text,
  p_store uuid default null,
  p_version text default '',
  p_platform text default '',
  p_public boolean default false
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
  v_message text := trim(coalesce(p_message, ''));
begin
  if auth.uid() is null then
    raise exception 'Sessão não iniciada.' using errcode = '42501';
  end if;
  if p_kind not in ('erro', 'sugestao') then
    raise exception 'Escolha erro ou sugestão.' using errcode = '22023';
  end if;
  if v_message = '' then
    raise exception 'Escreva a mensagem.' using errcode = '22023';
  end if;
  if length(v_message) > 4000 then
    raise exception 'A mensagem é demasiado longa.' using errcode = '22023';
  end if;
  insert into public.feedback
      (user_id, store_id, kind, message, app_version, platform, public)
    values (
      auth.uid(),
      case when exists (
        select 1 from public.store_members
        where store_id = p_store and user_id = auth.uid()
      ) then p_store end,
      p_kind,
      v_message,
      left(coalesce(p_version, ''), 40),
      left(coalesce(p_platform, ''), 40),
      coalesce(p_public, false)
    )
    returning id into v_id;
  return v_id;
end;
$$;

drop function public.feedback_list();
create function public.feedback_list()
returns table (
  id uuid,
  kind text,
  message text,
  email text,
  store_name text,
  person_name text,
  app_version text,
  platform text,
  created_at timestamptz,
  done_at timestamptz,
  status text,
  is_public boolean
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador vê os erros e sugestões.' using errcode = '42501';
  end if;
  return query
    select f.id, f.kind, f.message, u.email::text, s.name,
      r.data ->> 'fullName', f.app_version, f.platform, f.created_at, f.done_at,
      f.status, f.public
    from public.feedback f
    left join auth.users u on u.id = f.user_id
    left join public.stores s on s.id = f.store_id
    left join public.store_members m
      on m.store_id = f.store_id and m.user_id = f.user_id
    left join public.records r
      on r.store_id = f.store_id and r.collection = 'Person' and r.id = m.person_id
    order by f.created_at desc;
end;
$$;

-- What everyone signed in reads: the public messages and their own, newest
-- first, with nothing about who sent them (mine says whether it was them).
create function public.feedback_public_list()
returns table (
  id uuid,
  kind text,
  message text,
  status text,
  created_at timestamptz,
  mine boolean
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Sessão não iniciada.' using errcode = '42501';
  end if;
  return query
    select f.id, f.kind, f.message, f.status, f.created_at,
      coalesce(f.user_id = auth.uid(), false)
    from public.feedback f
    where f.public or f.user_id = auth.uid()
    order by f.created_at desc;
end;
$$;

-- Sets a message's state: the admin only.
create function public.set_feedback_status(p_id uuid, p_status text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador vê os erros e sugestões.' using errcode = '42501';
  end if;
  if p_status not in ('novo', 'visto', 'em_curso', 'resolvido', 'recusado') then
    raise exception 'Estado desconhecido.' using errcode = '22023';
  end if;
  update public.feedback
    set status = p_status,
      done_at = case
        when p_status in ('resolvido', 'recusado') then coalesce(done_at, now())
      end
  where id = p_id;
end;
$$;

-- The admin opened the list: every new message is now Visto.
create function public.mark_feedback_seen()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador vê os erros e sugestões.' using errcode = '42501';
  end if;
  update public.feedback set status = 'visto' where status = 'novo';
end;
$$;

-- Kept for older apps: dealt with is Resolvido, reopened is Visto.
create or replace function public.set_feedback_done(p_id uuid, p_done boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.set_feedback_status(
    p_id, case when p_done then 'resolvido' else 'visto' end
  );
end;
$$;

revoke execute on function public.send_feedback(text, text, uuid, text, text, boolean) from public, anon;
revoke execute on function public.feedback_list() from public, anon;
revoke execute on function public.feedback_public_list() from public, anon;
revoke execute on function public.set_feedback_status(uuid, text) from public, anon;
revoke execute on function public.mark_feedback_seen() from public, anon;
grant execute on function public.send_feedback(text, text, uuid, text, text, boolean) to authenticated;
grant execute on function public.feedback_list() to authenticated;
grant execute on function public.feedback_public_list() to authenticated;
grant execute on function public.set_feedback_status(uuid, text) to authenticated;
grant execute on function public.mark_feedback_seen() to authenticated;
