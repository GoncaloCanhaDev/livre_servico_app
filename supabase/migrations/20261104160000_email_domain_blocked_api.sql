-- Conta → Criar conta asks before signing up whether the email is a disposable
-- one, so the app can say so in a popup before the Política de Privacidade.
-- Only a yes or no for the email given: the list itself stays unreadable.
-- The refuse_blocked_email trigger still refuses the account either way.
grant execute on function public.email_domain_blocked(text) to anon, authenticated;
