// Runs the migrations on an in-memory Postgres (PGlite) and checks the sync
// rules and access rules. From supabase/tests: npm install, then npm test.
import { PGlite } from '@electric-sql/pglite';
import { readdirSync, readFileSync } from 'node:fs';

const db = new PGlite();
const dir = new URL('../migrations/', import.meta.url);
const migrations = readdirSync(dir).filter((f) => f.endsWith('.sql')).sort()
  .map((f) => readFileSync(new URL(f, dir), 'utf8'));

// Minimal stand-in for Supabase's auth schema and roles.
await db.exec(`
  create role anon nologin; create role authenticated nologin;
  create schema auth;
  create table auth.users (id uuid primary key, email text);
  create function auth.uid() returns uuid language sql stable as
    $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
  grant usage on schema auth to authenticated, anon;
  -- Minimal stand-in for Supabase Storage.
  create schema storage;
  create table storage.buckets (id text primary key, name text, public boolean);
  create table storage.objects (id serial primary key, bucket_id text, name text);
  alter table storage.objects enable row level security;
  create function storage.foldername(name text) returns text[] language sql immutable as
    $$ select (string_to_array(name, '/'))[1:array_length(string_to_array(name, '/'), 1) - 1] $$;
  grant usage on schema storage to authenticated;
  grant select, insert, update on storage.objects to authenticated;
  grant usage on sequence storage.objects_id_seq to authenticated;
  grant execute on function auth.uid() to authenticated, anon;
  insert into auth.users values
    ('00000000-0000-0000-0000-00000000000a','owner@x.pt'),
    ('00000000-0000-0000-0000-00000000000b','Editor@x.pt'),
    ('00000000-0000-0000-0000-00000000000c','viewer@x.pt'),
    ('00000000-0000-0000-0000-00000000000d','stranger@x.pt'),
    ('00000000-0000-0000-0000-00000000000e','new@x.pt'),
    ('00000000-0000-0000-0000-00000000000f','admin@x.pt');
`);
for (const m of migrations) await db.exec(m);
await db.exec(`
  grant usage on schema public to authenticated, anon;
  grant select, insert, update, delete on all tables in schema public to authenticated;
`);

const A = '00000000-0000-0000-0000-00000000000a', B = '00000000-0000-0000-0000-00000000000b',
  C = '00000000-0000-0000-0000-00000000000c', D = '00000000-0000-0000-0000-00000000000d',
  E = '00000000-0000-0000-0000-00000000000e', F = '00000000-0000-0000-0000-00000000000f';
let fails = 0;
const as = async (user, sql, params) => {
  await db.exec(`reset role; select set_config('request.jwt.claim.sub', '${user}', false); set role authenticated;`);
  return (await db.query(sql, params)).rows;
};
const ok = (name, cond) => { console.log((cond ? 'ok   ' : 'FAIL ') + name); if (!cond) fails++; };
const throws = async (name, fn, re) => {
  try { await fn(); ok(name + ' (expected error)', false); }
  catch (e) { ok(name + ' -> ' + e.message, re ? re.test(e.message) : true); }
};

const [{ create_store: store }] = await as(A, `select public.create_store('Pingo Doce X')`);
ok('owner sees store', (await as(A, 'select * from stores')).length === 1);
await as(A, `select public.add_store_member($1, ' editor@X.pt ', 'editor')`, [store]);
await as(A, `select public.add_store_member($1, 'viewer@x.pt', 'viewer')`, [store]);
await throws('unknown email', () => as(A, `select public.add_store_member($1, 'nobody@x.pt')`, [store]), /Não há/);
await throws('editor cannot add members', () => as(B, `select public.add_store_member($1, 'stranger@x.pt')`, [store]), /dono/);
await throws('owner cannot change self', () => as(A, `select public.add_store_member($1, 'owner@x.pt', 'viewer')`, [store]), /próprio/);

const row = (id, t, data, del = null) => ({ collection: 'Person', id, data, updated_at: t, deleted_at: del });
const push = (u, rows) => as(u, 'select * from public.push_records($1, $2)', [store, JSON.stringify(rows)]);

let back = await push(B, [row('p1', '2026-10-30T10:00:00Z', { name: 'Ana' }), row('p2', '2026-10-30T10:00:00Z', { name: 'Rui' })]);
ok('editor push inserts, nothing returned', back.length === 0);
let rows = await as(C, `select * from records order by id`);
ok('viewer reads 2 rows', rows.length === 2);
ok('updated_by is the pusher', rows[0].updated_by === B);

back = await push(A, [row('p1', '2026-10-30T09:00:00Z', { name: 'Old' }), row('p2', '2026-10-30T11:00:00Z', { name: 'Rui 2' }, '2026-10-30T11:00:00Z')]);
ok('older push returns server copy', back.length === 1 && back[0].id === 'p1' && back[0].data.name === 'Ana');
rows = await as(A, `select * from records order by id`);
ok('older push did not overwrite', rows[0].data.name === 'Ana');
ok('newer push overwrote, tombstone kept', rows[1].data.name === 'Rui 2' && rows[1].deleted_at !== null);
ok('server_updated_at advanced', rows[1].server_updated_at > rows[0].server_updated_at);

await throws('viewer cannot push', () => push(C, [row('p3', '2026-10-30T12:00:00Z', {})]), /permissão/);
await throws('stranger cannot push', () => push(D, [row('p3', '2026-10-30T12:00:00Z', {})]), /permissão/);
ok('stranger reads nothing', (await as(D, 'select * from records')).length === 0);
ok('stranger sees no store', (await as(D, 'select * from stores')).length === 0);
await throws('viewer direct insert blocked', () => as(C, `insert into records (store_id, collection, id, data, updated_at) values ($1,'X','y','{}',now())`, [store]), /row-level security/);
ok('nobody can hard-delete', (await as(A, 'delete from records returning id')).length === 0);
await throws('client cannot fake server time',
  async () => { await as(B, `update records set server_updated_at = '2000-01-01' where id = 'p1'`); const r = await as(B, `select server_updated_at from records where id='p1'`); if (r[0].server_updated_at.getFullYear() === 2000) throw new Error('faked'); throw new Error('trigger wins'); }, /trigger wins/);

let members = await as(B, 'select * from public.store_member_list($1)', [store]);
ok('members list has emails, owner first', members.length === 3 && members[0].email === 'owner@x.pt' && members[0].role === 'owner');
await throws('stranger cannot list members', () => as(D, 'select * from public.store_member_list($1)', [store]), /Não pertence/);

await db.exec('reset role');
ok('photos bucket is private', (await db.query(`select public from storage.buckets where id = 'photos'`)).rows[0].public === false);
await as(B, `insert into storage.objects (bucket_id, name) values ('photos', $1)`, [store + '/a.jpg']);
ok('viewer sees the photo', (await as(C, `select * from storage.objects`)).length === 1);
ok('stranger sees no photo', (await as(D, `select * from storage.objects`)).length === 0);
await throws('viewer cannot add a photo', () => as(C, `insert into storage.objects (bucket_id, name) values ('photos', $1)`, [store + '/b.jpg']), /row-level security/);
await throws('editor cannot add to another store', () => as(B, `insert into storage.objects (bucket_id, name) values ('photos', 'other/c.jpg')`), /row-level security/);

ok('owner cannot remove self', (await as(A, 'delete from store_members where user_id = $1 returning *', [A])).length === 0);
ok('owner removes viewer', (await as(A, 'delete from store_members where user_id = $1 returning *', [C])).length === 1);
ok('removed viewer reads nothing', (await as(C, 'select * from records')).length === 0);
ok('editor cannot promote self', (await as(B, `update store_members set role = 'owner' where user_id = $1 returning *`, [B])).length === 0);
ok('pull query works', (await as(B, `select id from records where store_id = $1 and server_updated_at > $2 order by server_updated_at`, [store, '2000-01-01'])).length === 2);

// Joining with the store's code and linking an account to its person.
await push(B, [row('p4', '2026-10-30T12:00:00Z', { fullName: 'Zé', collaboratorNumber: '4321', team: 'livre', phoneNumber: '900' }), row('p5', '2026-10-30T12:00:00Z', { fullName: 'Bia' })]);
await throws('editor cannot see the code', () => as(B, 'select public.store_join_code($1)', [store]), /dono/);
const [{ store_join_code: code }] = await as(A, 'select public.store_join_code($1)', [store]);
ok('code has 8 plain characters', /^[A-HJ-NP-Z2-9]{8}$/.test(code));
ok('code stays the same', (await as(A, 'select public.store_join_code($1) c', [store]))[0].c === code);
await throws('wrong code', () => as(D, `select public.join_store_preview('NOPE')`), /Não há/);
const typed = code.slice(0, 4).toLowerCase() + '-' + code.slice(4);
let [{ join_store_preview: preview }] = await as(D, 'select public.join_store_preview($1)', [typed]);
ok('preview has the store name', preview.store_id === store && preview.store_name === 'Pingo Doce X');
ok('preview lists live people, by name', preview.people.map((p) => p.id).join() === 'p5,p4,p1' && preview.people[1].full_name === 'Zé' && preview.people[1].collaborator_number === '4321');
ok('preview shows only name and number', Object.keys(preview.people[1]).sort().join() === 'collaborator_number,full_name,id');
ok('preview joins nothing', (await as(D, 'select * from records')).length === 0);
await as(D, 'select public.join_store($1, $2)', [code, 'p4']);
let mine = await as(D, 'select user_id from store_members');
ok('pending member sees only their own membership', mine.length === 1 && mine[0].user_id === D);
mine = await as(D, 'select * from public.my_stores()');
ok('join asks: pending with the person', mine.length === 1 && mine[0].status === 'pending' && mine[0].person_id === 'p4');
ok('pending member reads no records', (await as(D, 'select * from records')).length === 0);
ok('pending member sees no store', (await as(D, 'select * from stores')).length === 0);
await throws('pending member cannot push', () => push(D, [row('p9', '2026-10-30T12:00:00Z', {})]), /permissão/);
ok('pending member sees no photos', (await as(D, `select * from storage.objects`)).length === 0);
await throws('pending member cannot claim', () => as(D, 'select public.claim_person($1, $2)', [store, 'p5']), /Não pertence/);
await throws('editor without chefe cannot list requests', () => as(B, 'select * from public.store_join_requests($1)', [store]), /aprovar/);
await throws('editor without chefe cannot approve', () => as(B, 'select public.approve_join($1, $2)', [store, D]), /aprovar/);
await push(B, [row('pc', '2026-10-30T12:00:00Z', { fullName: 'Chefe', team: 'talho', chefe: 'chefe' })]);
await as(B, 'select public.claim_person($1, $2)', [store, 'pc']);
ok('chefe access', (await as(B, 'select public.my_access($1) a', [store]))[0].a.chefe_team === 'talho');
let requests = await as(B, 'select * from public.store_join_requests($1)', [store]);
ok('chefe sees the request', requests.length === 1 && requests[0].user_id === D && requests[0].email === 'stranger@x.pt' && requests[0].person_name === 'Zé');
await as(B, 'select public.approve_join($1, $2)', [store, D]);
ok('approved member reads records', (await as(D, 'select * from records')).length > 0);
ok('approved as editor, linked', (await as(D, 'select role, status, person_id from store_members where user_id = $1', [D]))[0]?.status === 'approved');
[{ join_store_preview: preview }] = await as(E, 'select public.join_store_preview($1)', [code]);
ok('linked person leaves the list', !preview.people.some((p) => p.id === 'p4'));
await throws('nobody else takes a linked person', () => as(E, 'select public.join_store($1, $2)', [code, 'p4']), /já tem conta/);
await throws('join needs a person or a name', () => as(E, 'select public.join_store($1)', [code]), /nome/);
ok('failed join adds nothing', (await as(E, 'select * from public.my_stores()')).length === 0);
await as(E, 'select public.join_store($1, null, $2)', [code, '  Nova ']);
requests = await as(A, 'select * from public.store_join_requests($1)', [store]);
ok('owner sees the typed name', requests.length === 1 && requests[0].requested_name === 'Nova' && requests[0].person_id === null);
await as(A, 'select public.approve_join($1, $2)', [store, E]);
const [nova] = await as(E, `select r.id, r.data, s.person_id from records r join store_members s on s.person_id = r.id where s.user_id = $1`, [E]);
ok('typed name creates the person', nova?.data.fullName === 'Nova' && nova.data.syncUuid === nova.id && typeof nova.data.syncUpdatedAt === 'number');
await as(C, 'select public.join_store($1, null, $2)', [code, 'Xa']);
await as(A, 'select public.refuse_join($1, $2)', [store, C]);
ok('refuse deletes the request', (await as(C, 'select * from public.my_stores()')).length === 0);
await as(C, 'select public.join_store($1, null, $2)', [code, 'Xa']);
ok('pending member cancels own request', (await as(C, 'delete from store_members where user_id = $1 returning *', [C])).length === 1);
ok('approved member cannot delete self', (await as(D, 'delete from store_members where user_id = $1 returning *', [D])).length === 0);
await throws('deleted person', () => as(E, 'select public.claim_person($1, $2)', [store, 'p2']), /apagada/);
await as(E, 'select public.claim_person($1, $2)', [store, 'p5']);
ok('members see who is unlinked', (await as(E, 'select id from public.store_unlinked_people($1)', [store])).map((p) => p.id).join() === nova.id + ',p1');
members = await as(A, 'select * from public.store_member_list($1)', [store]);
ok('members list has the persons', members.find((m) => m.user_id === D).person_id === 'p4' && members.find((m) => m.user_id === A).person_id === null);
await push(B, [row('pg', '2026-10-30T12:00:00Z', { fullName: 'Gerente', team: 'gerencia' })]);
await as(E, 'select public.claim_person($1, $2)', [store, 'pg']);
ok('gerencia access', (await as(E, 'select public.my_access($1) a', [store]))[0].a.gerencia === true);
const sorted = (o) => JSON.stringify(Object.fromEntries(Object.entries(o).sort()));
ok('member access', sorted((await as(D, 'select public.my_access($1) a', [store]))[0].a) === sorted({ admin: false, owner: false, gerencia: false, chefe_team: null, person_id: 'p4', status: 'approved' }));
await db.exec('reset role');
const chefeTeam = async (d) => (await db.query('select public.person_chefe_team($1) t', [JSON.stringify(d)])).rows[0].t;
ok('chefe de dia is chefe of livre servico', await chefeTeam({ team: 'livre_servico', chefe: 'dia' }) === 'livre_servico');
ok('frente de loja has no chefe', await chefeTeam({ team: 'frente_de_loja', chefe: 'chefe' }) === null);
ok('no slot, no chefe', await chefeTeam({ team: 'talho' }) === null);
await db.query(`insert into app_admins values ($1)`, [F]);
const fStores = await as(F, 'select * from public.my_stores()');
ok('admin sees every store as owner', fStores.length === 1 && fStores[0].role === 'owner' && fStores[0].status === 'approved');
ok('admin reads records', (await as(F, 'select * from records')).length > 0);
ok('admin access', (await as(F, 'select public.my_access($1) a', [store]))[0].a.admin === true);
ok('admin approves', (await as(F, 'select public.can_approve($1) c', [store]))[0].c === true);
await as(A, 'select public.join_store($1, $2)', [code, 'p1']);
ok('owner joining keeps owner', (await as(A, 'select role, person_id from store_members where user_id = $1', [A]))[0].role === 'owner');
ok('editor cannot unlink others', (await as(B, 'update store_members set person_id = null where user_id = $1 returning *', [D])).length === 0);
ok('owner unlinks a member', (await as(A, 'update store_members set person_id = null where user_id = $1 returning *', [D])).length === 1);
await throws('stranger cannot claim', () => as(C, 'select public.claim_person($1, $2)', [store, 'p4']), /Não pertence/);
const [{ reset_store_join_code: code2 }] = await as(A, 'select public.reset_store_join_code($1)', [store]);
ok('new code', code2 !== code);
await throws('old code stops working', () => as(C, 'select public.join_store_preview($1)', [code]), /Não há/);
await throws('editor cannot reset the code', () => as(B, 'select public.reset_store_join_code($1)', [store]), /dono/);
await throws('internal function hidden', () => as(D, `select public.store_by_code('x')`), /permission denied/);

await db.exec('reset role');
await throws('anon cannot call create_store', async () => { await db.exec(`set role anon`); await db.query(`select public.create_store('x')`); }, /permission denied/);

console.log(fails ? `\n${fails} FAILED` : '\nall passed');
process.exit(fails ? 1 : 0);
