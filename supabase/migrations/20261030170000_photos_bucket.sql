-- Photos (people, Informações) in Supabase Storage: a private bucket,
-- "photos", one folder per store ("<store id>/<photo name>"). Members of a
-- store read its photos; editors and owners add them. Photos are never
-- changed or deleted: a new photo gets a new name.

insert into storage.buckets (id, name, public)
values ('photos', 'photos', false)
on conflict (id) do nothing;

create policy "members read their store's photos" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] in
      (select s::text from public.my_store_ids('viewer') s)
  );

create policy "editors add photos to their store" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] in
      (select s::text from public.my_store_ids('editor') s)
  );

-- An upload is an upsert: a photo sent again after a lost answer updates
-- the same object.
create policy "editors re-upload their store's photos" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] in
      (select s::text from public.my_store_ids('editor') s)
  )
  with check (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] in
      (select s::text from public.my_store_ids('editor') s)
  );
