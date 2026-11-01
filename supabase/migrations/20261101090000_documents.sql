-- Documentos: PDF documents for every store (procedures, rules…), kept by
-- the app's admin. Not part of any store: one list, read by the admin and
-- every approved member of any store; added, renamed and removed only by
-- the admin. The PDFs are in the private "documents" bucket, one object per
-- upload ("<uuid>.pdf"): a new version of a document is a new object.

create table public.documents (
  id uuid primary key default gen_random_uuid(),
  title text not null check (length(trim(title)) > 0),
  file_name text not null unique,
  size bigint not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Whether the signed-in user may read the documents: the admin, or an
-- approved member of some store.
create function public.can_read_documents()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select public.is_app_admin() or exists (
    select 1 from public.store_members
    where user_id = auth.uid() and status = 'approved'
  );
$$;

alter table public.documents enable row level security;

create policy "members read the documents" on public.documents
  for select to authenticated
  using (public.can_read_documents());

create policy "the admin adds documents" on public.documents
  for insert to authenticated
  with check (public.is_app_admin());

create policy "the admin edits documents" on public.documents
  for update to authenticated
  using (public.is_app_admin())
  with check (public.is_app_admin());

create policy "the admin removes documents" on public.documents
  for delete to authenticated
  using (public.is_app_admin());

insert into storage.buckets (id, name, public)
values ('documents', 'documents', false)
on conflict (id) do nothing;

create policy "members read the document files" on storage.objects
  for select to authenticated
  using (bucket_id = 'documents' and public.can_read_documents());

create policy "the admin adds document files" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'documents' and public.is_app_admin());

create policy "the admin replaces document files" on storage.objects
  for update to authenticated
  using (bucket_id = 'documents' and public.is_app_admin())
  with check (bucket_id = 'documents' and public.is_app_admin());

create policy "the admin removes document files" on storage.objects
  for delete to authenticated
  using (bucket_id = 'documents' and public.is_app_admin());
