-- Accounts can't be made with a disposable (temporary) email. A trigger on
-- auth.users refuses a new account, or a change of email, whose domain is in
-- blocked_email_domains. Supabase Auth then answers "Database error saving
-- new user" (status 500), which the app shows in Portuguese
-- (accountErrorText). Existing accounts are untouched: the admin removes them
-- in Administração → Contas.
--
-- An entry with a dot ("mailinator.com") blocks that domain and its
-- subdomains; one without ("en2ch") blocks that name under any ending
-- (en2ch.com, en2ch.net, mail.en2ch.org...). Add more in the SQL Editor:
--   insert into public.blocked_email_domains values ('example.com');
create table public.blocked_email_domains (
  domain text primary key check (domain = lower(trim(domain)) and domain <> '')
);

-- Not read or written through the API: only the trigger (and the SQL Editor).
alter table public.blocked_email_domains enable row level security;
revoke all on public.blocked_email_domains from public, anon, authenticated;

insert into public.blocked_email_domains (domain) values
  ('en2ch'),
  ('10minutemail'),
  ('20minutemail'),
  ('33mail.com'),
  ('anonbox.net'),
  ('burnermail.io'),
  ('discard.email'),
  ('dispostable.com'),
  ('dropmail.me'),
  ('emailondeck.com'),
  ('fakeinbox.com'),
  ('fakemail.net'),
  ('getairmail.com'),
  ('getnada.com'),
  ('guerrillamail'),
  ('guerrillamailblock.com'),
  ('grr.la'),
  ('sharklasers.com'),
  ('pokemail.net'),
  ('spam4.me'),
  ('harakirimail.com'),
  ('inboxkitten.com'),
  ('mail.tm'),
  ('mailcatch.com'),
  ('maildrop.cc'),
  ('mailinator'),
  ('mailnesia.com'),
  ('mailpoof.com'),
  ('mintemail.com'),
  ('mohmal.com'),
  ('mytemp.email'),
  ('nada.email'),
  ('spambox.us'),
  ('spamgourmet.com'),
  ('tempail.com'),
  ('temp-mail.org'),
  ('temp-mail.io'),
  ('tempmail'),
  ('tempmailo.com'),
  ('tempr.email'),
  ('throwawaymail.com'),
  ('trashmail'),
  ('yopmail'),
  ('emailfake.com'),
  ('email-temporaire.fr'),
  ('mailtemp.net'),
  ('tmpmail.org'),
  ('tmpmail.net'),
  ('moakt.com'),
  ('1secmail.com'),
  ('1secmail.org'),
  ('1secmail.net');

-- Whether an email's domain is blocked (case and spaces don't matter).
create function public.email_domain_blocked(p_email text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  with d as (
    select lower(trim(split_part(trim(p_email), '@', 2))) as domain
  )
  select exists (
    select 1
      from public.blocked_email_domains b, d
     where d.domain <> ''
       and (
         d.domain = b.domain
         or d.domain like '%.' || b.domain
         or (position('.' in b.domain) = 0
             and b.domain = any (string_to_array(d.domain, '.')))
       )
  );
$$;

revoke execute on function public.email_domain_blocked(text) from public, anon, authenticated;

create function public.refuse_blocked_email()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.email is not null and public.email_domain_blocked(new.email) then
    raise exception 'Não são aceites emails temporários. Use outro email.'
      using errcode = '22023';
  end if;
  return new;
end;
$$;

revoke execute on function public.refuse_blocked_email() from public, anon, authenticated;

create trigger refuse_blocked_email
  before insert or update of email on auth.users
  for each row execute function public.refuse_blocked_email();
