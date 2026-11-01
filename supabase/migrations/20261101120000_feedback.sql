-- Erros e sugestões: anyone signed in reports an error or leaves a
-- suggestion (send_feedback); only the app's admin reads them
-- (feedback_list), marks them dealt with (set_feedback_done) and removes
-- them (delete_feedback). Not part of any store's records, so nothing syncs.

create table public.feedback (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users (id) on delete set null,
  store_id    uuid references public.stores (id) on delete set null,
  kind        text not null check (kind in ('erro', 'sugestao')),
  message     text not null check (length(trim(message)) > 0 and length(message) <= 4000),
  app_version text not null default '',
  platform    text not null default '',
  created_at  timestamptz not null default now(),
  done_at     timestamptz
);
alter table public.feedback enable row level security;
-- No policies: only through the functions below.

-- Records an error report or a suggestion from this account; p_store is the
-- store it uses, kept only when it is a member of it.
create function public.send_feedback(
  p_kind text,
  p_message text,
  p_store uuid default null,
  p_version text default '',
  p_platform text default ''
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
  insert into public.feedback (user_id, store_id, kind, message, app_version, platform)
    values (
      auth.uid(),
      case when exists (
        select 1 from public.store_members
        where store_id = p_store and user_id = auth.uid()
      ) then p_store end,
      p_kind,
      v_message,
      left(coalesce(p_version, ''), 40),
      left(coalesce(p_platform, ''), 40)
    )
    returning id into v_id;
  return v_id;
end;
$$;

-- Every report and suggestion, newest first, with who sent it: the admin
-- only.
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
  done_at timestamptz
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
      r.data ->> 'fullName', f.app_version, f.platform, f.created_at, f.done_at
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

-- Marks a report or suggestion as dealt with (or not): the admin only.
create function public.set_feedback_done(p_id uuid, p_done boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador vê os erros e sugestões.' using errcode = '42501';
  end if;
  update public.feedback
    set done_at = case when p_done then coalesce(done_at, now()) end
  where id = p_id;
end;
$$;

-- Removes a report or suggestion: the admin only.
create function public.delete_feedback(p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Só o administrador vê os erros e sugestões.' using errcode = '42501';
  end if;
  delete from public.feedback where id = p_id;
end;
$$;

revoke execute on function public.send_feedback(text, text, uuid, text, text) from public, anon;
revoke execute on function public.feedback_list() from public, anon;
revoke execute on function public.set_feedback_done(uuid, boolean) from public, anon;
revoke execute on function public.delete_feedback(uuid) from public, anon;
grant execute on function public.send_feedback(text, text, uuid, text, text) to authenticated;
grant execute on function public.feedback_list() to authenticated;
grant execute on function public.set_feedback_done(uuid, boolean) to authenticated;
grant execute on function public.delete_feedback(uuid) to authenticated;
