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
  create table auth.users (id uuid primary key, email text,
    created_at timestamptz not null default now(), last_sign_in_at timestamptz);
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
  grant select, insert, update, delete on storage.objects to authenticated;
  grant usage on sequence storage.objects_id_seq to authenticated;
  grant execute on function auth.uid() to authenticated, anon;
  insert into auth.users values
    ('00000000-0000-0000-0000-00000000000a','owner@x.pt'),
    ('00000000-0000-0000-0000-00000000000b','Editor@x.pt'),
    ('00000000-0000-0000-0000-00000000000c','viewer@x.pt'),
    ('00000000-0000-0000-0000-00000000000d','stranger@x.pt'),
    ('00000000-0000-0000-0000-00000000000e','new@x.pt'),
    ('00000000-0000-0000-0000-00000000000f','admin@x.pt'),
    ('00000000-0000-0000-0000-000000000011','h@x.pt');
`);
// Like Supabase: the API roles get every new table, before the migrations
// take away what they shouldn't have.
await db.exec(`
  grant usage on schema public to authenticated, anon;
  alter default privileges in schema public grant select, insert, update, delete on tables to authenticated;
`);
for (const m of migrations) await db.exec(m);

const A = '00000000-0000-0000-0000-00000000000a', B = '00000000-0000-0000-0000-00000000000b',
  C = '00000000-0000-0000-0000-00000000000c', D = '00000000-0000-0000-0000-00000000000d',
  E = '00000000-0000-0000-0000-00000000000e', F = '00000000-0000-0000-0000-00000000000f',
  H = '00000000-0000-0000-0000-000000000011';
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

// A is the app's admin (there are no store owners).
await db.query(`insert into app_admins values ($1)`, [A]);
await throws('only the admin creates stores', () => as(B, `select public.create_store('Outra')`), /administrador/);
const [{ create_store: store }] = await as(A, `select public.create_store('Pingo Doce X')`);
ok('admin sees store', (await as(A, 'select * from stores')).length === 1);
ok('the creator is a plain member', (await as(A, 'select role from store_members where user_id = $1', [A]))[0].role === 'editor');
await as(A, `select public.add_store_member($1, ' editor@X.pt ', 'editor')`, [store]);
await as(A, `select public.add_store_member($1, 'viewer@x.pt', 'viewer')`, [store]);
await throws('unknown email', () => as(A, `select public.add_store_member($1, 'nobody@x.pt')`, [store]), /Não há/);
await throws('editor cannot add members', () => as(B, `select public.add_store_member($1, 'stranger@x.pt')`, [store]), /gerência/);
await throws('nobody is made owner', () => as(A, `select public.add_store_member($1, 'stranger@x.pt', 'owner')`, [store]), /dono/);
await throws('owner cannot change self', () => as(A, `select public.add_store_member($1, 'owner@x.pt', 'viewer')`, [store]), /próprio/);

const row = (id, t, data, del = null, collection = 'Note') => ({ collection, id, data, updated_at: t, deleted_at: del });
const person = (id, t, data, del = null) => row(id, t, data, del, 'Person');
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
ok('members list has emails, no owner', members.length === 3 && members.some((m) => m.email === 'owner@x.pt') && !members.some((m) => m.role === 'owner'));
await throws('stranger cannot list members', () => as(D, 'select * from public.store_member_list($1)', [store]), /Não pertence/);

await db.exec('reset role');
ok('photos bucket is private', (await db.query(`select public from storage.buckets where id = 'photos'`)).rows[0].public === false);
await as(B, `insert into storage.objects (bucket_id, name) values ('photos', $1)`, [store + '/a.jpg']);
ok('viewer sees the photo', (await as(C, `select * from storage.objects`)).length === 1);
ok('stranger sees no photo', (await as(D, `select * from storage.objects`)).length === 0);
await throws('viewer cannot add a photo', () => as(C, `insert into storage.objects (bucket_id, name) values ('photos', $1)`, [store + '/b.jpg']), /row-level security/);
await throws('editor cannot add to another store', () => as(B, `insert into storage.objects (bucket_id, name) values ('photos', 'other/c.jpg')`), /row-level security/);

ok('admin cannot remove self', (await as(A, 'delete from store_members where user_id = $1 returning *', [A])).length === 0);
ok('admin removes viewer', (await as(A, 'delete from store_members where user_id = $1 returning *', [C])).length === 1);
ok('removed viewer reads nothing', (await as(C, 'select * from records')).length === 0);
await throws('editor cannot promote self', () => as(B, `update store_members set role = 'owner' where user_id = $1 returning *`, [B]), /permission denied/);
ok('pull query works', (await as(B, `select id from records where store_id = $1 and server_updated_at > $2 order by server_updated_at`, [store, '2000-01-01'])).length === 2);

// Joining with the store's code and linking an account to its person.
await push(A, [person('p1', '2026-10-30T10:00:00Z', { name: 'Ana' }), person('p2', '2026-10-30T11:00:00Z', { name: 'Rui' }, '2026-10-30T11:00:00Z'), person('p4', '2026-10-30T12:00:00Z', { fullName: 'Zé', collaboratorNumber: '4321', team: 'livre', weeklyHours: '900' }), person('p5', '2026-10-30T12:00:00Z', { fullName: 'Bia' })]);
await throws('editor cannot see the code', () => as(B, 'select public.store_join_code($1)', [store]), /gerência/);
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
await push(A, [person('pc', '2026-10-30T12:00:00Z', { fullName: 'Chefe', team: 'talho', chefe: 'chefe' })]);
await throws('member cannot claim a chefe', () => as(B, 'select public.claim_person($1, $2)', [store, 'pc']), /gerência \(Membros\)/);
ok('admin links a member to a chefe', (await as(A, `update store_members set person_id = 'pc' where user_id = $1 returning *`, [B])).length === 1);
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
ok('admin sees the typed name', requests.length === 1 && requests[0].requested_name === 'Nova' && requests[0].person_id === null);
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
await throws('linked member cannot switch person', () => as(E, 'select public.claim_person($1, $2)', [store, 'p5']), /já está ligada/);
await db.exec('reset role'); await db.query(`update store_members set person_id = null where user_id = $1`, [E]);
await as(E, 'select public.claim_person($1, $2)', [store, 'p5']);
ok('members see who is unlinked', (await as(E, 'select id from public.store_unlinked_people($1)', [store])).map((p) => p.id).join() === nova.id + ',p1');
members = await as(A, 'select * from public.store_member_list($1)', [store]);
ok('members list has the persons', members.find((m) => m.user_id === D).person_id === 'p4' && members.find((m) => m.user_id === A).person_id === null);
await push(A, [person('pg', '2026-10-30T12:00:00Z', { fullName: 'Gerente', team: 'gerencia' })]);
await db.exec('reset role'); await db.query(`update store_members set person_id = 'pg' where user_id = $1`, [E]);
ok('gerencia access', (await as(E, 'select public.my_access($1) a', [store]))[0].a.gerencia === true);
const sorted = (o) => JSON.stringify(Object.fromEntries(Object.entries(o).sort()));
await db.exec('reset role');
const p4team = (await db.query(`select data ->> 'team' t from records where collection = 'Person' and id = 'p4'`)).rows[0].t;
ok('member access', sorted((await as(D, 'select public.my_access($1) a', [store]))[0].a) === sorted({ admin: false, level: 1, team: p4team, gerencia: false, chefe_team: null, person_id: 'p4', status: 'approved' }));
await db.exec('reset role');
const chefeTeam = async (d) => (await db.query('select public.person_chefe_team($1) t', [JSON.stringify(d)])).rows[0].t;
ok('chefe de dia is chefe of livre servico', await chefeTeam({ team: 'livre_servico', chefe: 'dia' }) === 'livre_servico');
ok('frente de loja has no chefe', await chefeTeam({ team: 'frente_de_loja', chefe: 'chefe' }) === null);
ok('no slot, no chefe', await chefeTeam({ team: 'talho' }) === null);
await db.query(`insert into app_admins values ($1)`, [F]);
const fStores = await as(F, 'select * from public.my_stores()');
ok('admin sees every store', fStores.length === 1 && fStores[0].role === 'owner' && fStores[0].status === 'approved');
ok('admin reads records', (await as(F, 'select * from records')).length > 0);
ok('admin access', (await as(F, 'select public.my_access($1) a', [store]))[0].a.admin === true);
ok('admin approves', (await as(F, 'select public.can_approve($1) c', [store]))[0].c === true);
await as(A, 'select public.join_store($1, $2)', [code, 'p1']);
ok('a member joining again keeps their membership', (await as(A, 'select role, person_id from store_members where user_id = $1', [A]))[0].role === 'editor');
ok('editor cannot unlink others', (await as(B, 'update store_members set person_id = null where user_id = $1 returning *', [D])).length === 0);
ok('admin unlinks a member', (await as(A, 'update store_members set person_id = null where user_id = $1 returning *', [D])).length === 1);
await throws('stranger cannot claim', () => as(C, 'select public.claim_person($1, $2)', [store, 'p4']), /Não pertence/);
const [{ reset_store_join_code: code2 }] = await as(A, 'select public.reset_store_join_code($1)', [store]);
ok('new code', code2 !== code);
await throws('old code stops working', () => as(C, 'select public.join_store_preview($1)', [code]), /Não há/);
await throws('editor cannot reset the code', () => as(B, 'select public.reset_store_join_code($1)', [store]), /gerência/);
await throws('internal function hidden', () => as(D, `select public.store_by_code('x')`), /permission denied/);

// People's personal data by hierarchy. B: chefe of talho (pc); D: p4 in
// talho; H: pn in peixaria; E: Gerência (pg); A and F: admins.
await db.exec('reset role');
await db.query(`update records set data = data || '{"team":"talho","folgas":[1],"notes":["x"],"weeklyHours":"900"}' where id = 'p4'`);
await db.query(`update store_members set person_id = 'p4' where user_id = $1`, [D]);
await push(A, [person('pn', '2026-10-30T12:00:00Z', { fullName: 'Nuno', team: 'peixaria', weeklyHours: '111', folgas: [3] })]);
await as(H, 'select public.join_store($1, $2)', [code2, 'pn']);
await as(A, 'select public.approve_join($1, $2)', [store, H]);
const pulled = async (u, id) => (await as(u, 'select * from public.pull_records($1, $2, $3)', [store, null, 1000])).find((r) => r.id === id);
const stored = async (id) => { await db.exec('reset role'); return (await db.query(`select * from records where collection = 'Person' and id = $1`, [id])).rows[0]; };
let r4 = await pulled(H, 'p4');
ok('member sees others redacted', r4.data.fullName === 'Zé' && r4.data.team === 'talho' && !('weeklyHours' in r4.data) && !('folgas' in r4.data) && !('notes' in r4.data) && !('collaboratorNumber' in r4.data));
ok('member sees own full', (await pulled(H, 'pn')).data.weeklyHours === '111');
ok('chefe sees own team full', (await pulled(B, 'p4')).data.weeklyHours === '900');
ok('chefe does not see other team', !('weeklyHours' in (await pulled(B, 'pn')).data));
ok('gerencia sees all full', (await pulled(E, 'pn')).data.weeklyHours === '111' && (await pulled(E, 'p4')).data.weeklyHours === '900');
ok('admin sees all full', (await pulled(F, 'pn')).data.weeklyHours === '111');
ok('a second admin sees all full', (await pulled(A, 'pn')).data.weeklyHours === '111');
ok('pull_records keeps other rows whole', (await as(H, 'select * from public.pull_records($1, $2, $3)', [store, null, 1000])).some((r) => r.collection === 'Note'));
await throws('stranger cannot pull', () => as(C, 'select * from public.pull_records($1, $2, $3)', [store, null, 10]), /Não pertence/);
ok('select policy hides personal rows', !(await as(H, `select id from records where collection = 'Person'`)).some((r) => r.id === 'p4'));
ok('select policy shows own row', (await as(H, `select id from records where collection = 'Person'`)).some((r) => r.id === 'pn'));

back = await push(D, [person('p4', '2026-10-30T13:00:00Z', { ...(await stored('p4')).data, team: 'gerencia', chefe: 'chefe', notes: ['911'], collaboratorNumber: '0' })]);
let s4 = (await stored('p4')).data;
ok('self cannot change own role', s4.team === 'talho' && !('chefe' in s4) && s4.collaboratorNumber === '4321');
ok('self edits own notes', s4.notes[0] === '911');
ok('push returns the merged row', back.length === 1 && back[0].data.team === 'talho');
ok('self is still not gerencia', (await as(D, 'select public.my_access($1) a', [store]))[0].a.gerencia === false);

await push(B, [person('p4', '2026-10-30T14:00:00Z', { ...s4, folgas: [2], notes: ['000'] })]);
s4 = (await stored('p4')).data;
ok('chefe edits team folgas only', JSON.stringify(s4.folgas) === '[2]' && s4.notes[0] === '911');
const sn = (await stored('pn')).data;
await push(B, [person('pn', '2026-10-30T14:00:00Z', { ...sn, folgas: [5] })]);
ok('chefe cannot edit other team', JSON.stringify((await stored('pn')).data.folgas) === '[3]');
await push(E, [person('p4', '2026-10-30T15:00:00Z', { ...s4, chefe: 'chefe', turno: 'noite', folgas: [6] })]);
s4 = (await stored('p4')).data;
ok('gerencia changes roles, turno and folgas', s4.chefe === 'chefe' && s4.turno === 'noite' && JSON.stringify(s4.folgas) === '[6]');
await push(E, [person('p4', '2026-10-30T15:30:00Z', { ...s4, chefe: null })]);
s4 = (await stored('p4')).data;

const redacted = (await pulled(H, 'p4')).data;
await push(H, [person('p4', '2026-10-30T16:00:00Z', redacted)]);
s4 = (await stored('p4')).data;
ok('redacted push keeps hidden fields', s4.weeklyHours === '900' && JSON.stringify(s4.folgas) === '[6]' && s4.notes[0] === '911');
await push(H, [person('px', '2026-10-30T16:00:00Z', { fullName: 'Intruso' })]);
ok('member cannot add people', (await stored('px')) === undefined);
await push(H, [person('p4', '2026-10-30T17:00:00Z', redacted, '2026-10-30T17:00:00Z')]);
ok('member cannot delete people', (await stored('p4')).deleted_at === null);
await push(E, [person('py', '2026-10-30T16:00:00Z', { fullName: 'Novo' })]);
ok('gerencia adds people', (await stored('py'))?.data.fullName === 'Novo');
await push(E, [person('py', '2026-10-30T17:00:00Z', { fullName: 'Novo' }, '2026-10-30T17:00:00Z')]);
ok('a Gestor de Área deletes an Operador', (await stored('py')).deleted_at !== null);
await push(F, [person('py', '2026-10-30T18:00:00Z', { fullName: 'Novo' }, '2026-10-30T18:00:00Z')]);
ok('admin deletes people', (await stored('py')).deleted_at !== null);

s4 = (await stored('p4')).data;
await push(B, [person('p4', '2026-10-30T19:00:00Z', { ...s4, profileUpdateRequestedAt: 1, profileUpdateRequestedBy: 'Chefe' })]);
s4 = (await stored('p4')).data;
ok('chefe asks for an update', s4.profileUpdateRequestedAt === 1 && s4.profileUpdateRequestedBy === 'Chefe');
const { profileUpdateRequestedAt: _a, profileUpdateRequestedBy: _b, ...cleared } = s4;
await push(D, [person('p4', '2026-10-30T20:00:00Z', cleared)]);
s4 = (await stored('p4')).data;
ok('self clears the request', !('profileUpdateRequestedAt' in s4) && !('profileUpdateRequestedBy' in s4));
await push(D, [person('p4', '2026-10-30T21:00:00Z', { ...s4, profileUpdateRequestedAt: 2, profileUpdateRequestedBy: 'Zé' })]);
ok('self cannot set a request', !('profileUpdateRequestedAt' in (await stored('p4')).data));
await push(H, [person('pn', '2026-10-30T21:00:00Z', { ...(await stored('pn')).data, profileUpdateRequestedAt: 3 })]);
ok('member cannot ask others', !('profileUpdateRequestedAt' in (await stored('p4')).data) && (await stored('pn')).data.profileUpdateRequestedAt === undefined);

const before4 = (await stored('p4')).updated_at;
await push(H, [person('p4', '2100-01-01T00:00:00Z', (await pulled(H, 'p4')).data)]);
ok('a push with nothing allowed leaves the row alone', (await stored('p4')).updated_at.getTime() === before4.getTime());
await push(D, [person('p4', '2100-01-01T00:00:00Z', { ...(await stored('p4')).data, notes: ['922'] })]);
const future = await stored('p4');
ok('a person is never saved in the future', future.data.notes[0] === '922' && future.updated_at <= new Date());
await push(B, [person('p4', new Date(Date.now() + 1000).toISOString(), { ...future.data, folgas: [4] })]);
ok('later edits still count after a future push', JSON.stringify((await stored('p4')).data.folgas) === '[4]');
ok('gerencia sees the code', /^[A-HJ-NP-Z2-9]{8}$/.test((await as(E, 'select public.store_join_code($1) c', [store]))[0].c));
ok('gerencia unlinks a member', (await as(E, 'update store_members set person_id = null where user_id = $1 returning *', [H])).length === 1);
ok('gerencia links a member', (await as(E, `update store_members set person_id = 'pn' where user_id = $1 returning *`, [H])).length === 1);
await throws('gerencia cannot change roles', () => as(E, `update store_members set role = 'owner' where user_id = $1`, [H]), /permission denied/);
ok('gerencia cannot relink themselves', (await as(E, `update store_members set person_id = 'p5' where user_id = $1 returning *`, [E])).length === 0);
ok('a chefe does not manage members', (await as(B, 'update store_members set person_id = null where user_id = $1 returning *', [H])).length === 0);
await push(H, [row('d1', '2026-10-30T12:00:00Z', { done: true }, null, 'DailyTasks')]);
ok('non-Person rows unchanged', (await as(D, `select * from records where collection = 'DailyTasks'`)).length === 1);
await throws('direct Person insert blocked', () => as(H, `insert into records (store_id, collection, id, data, updated_at) values ($1, 'Person', 'pz', '{}', now())`, [store]), /row-level security/);
ok('direct Person update blocked', (await as(D, `update records set data = data || '{"team":"gerencia"}' where id = 'p4' returning id`)).length === 0);

ok('gerencia removes a member', (await as(E, 'delete from store_members where user_id = $1 returning *', [H])).length === 1);
// Moving to another store: only the admin does it, on request.
const [{ create_store: store2 }] = await as(A, `select public.create_store('Pingo Doce Y')`);
const [{ c: codeY }] = await as(A, 'select public.store_join_code($1) c', [store2]);
await throws('a member does not join a second store', () => as(D, 'select public.join_store($1, null, $2)', [codeY, 'Zé']), /administrador/);
await throws('nobody adds someone from another store', () => as(A, `select public.add_store_member($1, 'stranger@x.pt')`, [store2]), /administrador/);
await as(D, 'select public.request_store_transfer($1, $2)', [store, '  Braga, a partir de 1/11 ']);
ok('a member asks to move', (await as(D, 'select * from public.my_store_transfer()'))[0]?.note === 'Braga, a partir de 1/11');
await throws('only the admin lists moves', () => as(E, 'select * from public.store_transfer_requests()'), /administrador/);
let moves = await as(A, 'select * from public.store_transfer_requests()');
ok('the admin sees the request', moves.length === 1 && moves[0].user_id === D && moves[0].from_store_name === 'Pingo Doce X' && moves[0].person_name === 'Zé');
await throws('only the admin moves people', () => as(E, 'select public.transfer_member($1, $2, $3)', [D, store, store2]), /administrador/);
await as(A, 'select public.transfer_member($1, $2, $3)', [D, store, store2]);
const mine2 = await as(D, 'select * from public.my_stores()');
ok('the member is now in the new store only', mine2.length === 1 && mine2[0].id === store2 && mine2[0].person_id === 'p4' && mine2[0].status === 'approved');
await db.exec('reset role');
const moved = (await db.query(`select store_id, deleted_at, data from records where collection = 'Person' and id = 'p4' order by deleted_at nulls first`)).rows;
ok('the profile moves with them', moved.length === 2 && moved[0].store_id === store2 && moved[0].deleted_at === null && moved[0].data.fullName === 'Zé' && !('syncDeletedAt' in moved[0].data && moved[0].data.syncDeletedAt));
ok('the old store keeps a tombstone', moved[1].store_id === store && moved[1].deleted_at !== null && typeof moved[1].data.syncDeletedAt === 'number');
ok('the request is done', (await as(A, 'select * from public.store_transfer_requests()')).length === 0);
ok('they read the new store', (await as(D, 'select * from public.pull_records($1, null, 100)', [store2])).some((r) => r.id === 'p4'));
await throws('and not the old one', () => as(D, 'select * from public.pull_records($1, null, 100)', [store]), /Não pertence/);
await as(D, 'select public.request_store_transfer($1, $2)', [store2, 'engano']);
await as(D, 'select public.cancel_store_transfer()');
ok('a request can be withdrawn', (await as(D, 'select * from public.my_store_transfer()')).length === 0);

// No phone numbers, and birthdays without the year.
const lisbon = (y, m, d) => new Date(`${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}T00:00:00+01:00`).getTime() * 1000;
await push(A, [person('pb', '2026-10-31T10:00:00Z', { fullName: 'Bea', phoneNumber: '933', dateOfBirth: lisbon(1990, 5, 20) })]);
let pb = (await stored('pb')).data;
ok('a phone number is never kept', !('phoneNumber' in pb));
ok('a date of birth becomes a birthday', !('dateOfBirth' in pb) && pb.birthDay === 20 && pb.birthMonth === 5);
await push(A, [person('pb', '2026-10-31T11:00:00Z', { fullName: 'Bea', birthDay: 3, birthMonth: 12, dateOfBirth: lisbon(1990, 5, 20) })]);
pb = (await stored('pb')).data;
ok('a birthday set beats an old date of birth', pb.birthDay === 3 && pb.birthMonth === 12 && !('dateOfBirth' in pb));
ok('everyone sees birthdays', (await pulled(B, 'pb')).data.birthMonth === 12);

// Authority levels. B: Chefe de Secção of talho (pc, old chefe slot); E:
// Gerência (pg, no role: Gestor de Área); I: Operador of talho (pi); J:
// Segunda Linha of talho (pj).
await db.exec('reset role');
const level = async (d) => (await db.query('select public.person_level($1) l', [JSON.stringify(d)])).rows[0].l;
ok('old Gerência row is level 4', await level({ team: 'gerencia' }) === 4);
ok('old Gerência chefe is level 5', await level({ team: 'gerencia', chefe: 'chefe' }) === 5);
ok('old Livre Serviço chefe is level 3', await level({ team: 'livre_servico', chefe: 'noite' }) === 3);
ok('old Frente de Loja supervisor is level 2', await level({ team: 'frente_de_loja', supervisor: true }) === 2);
ok('a role set beats the old fields', await level({ team: 'talho', chefe: 'chefe', role: 'operador' }) === 1);
ok('a role the team does not allow is Operador', await level({ team: 'talho', role: 'gestorArea' }) === 1);
ok('no team is Operador', await level({ role: 'chefeSeccao' }) === 1);
await db.query(`insert into auth.users values ('00000000-0000-0000-0000-000000000012', 'i@x.pt'), ('00000000-0000-0000-0000-000000000013', 'j@x.pt')`);
const I = '00000000-0000-0000-0000-000000000012', J = '00000000-0000-0000-0000-000000000013';
await push(A, [
  person('pi', '2026-10-31T12:00:00Z', { fullName: 'Inês', team: 'talho', role: 'operador', weeklyHours: 40 }),
  person('pj', '2026-10-31T12:00:00Z', { fullName: 'João', team: 'talho', role: 'segundaLinha' }),
  person('pt', '2026-10-31T12:00:00Z', { fullName: 'Tó', team: 'talho', weeklyHours: 20, folgas: [1] }),
  person('pc2', '2026-10-31T12:00:00Z', { fullName: 'Outro Chefe', team: 'talho', role: 'chefeSeccao' }),
  person('ps', '2026-10-31T12:00:00Z', { fullName: 'Sara', team: 'gerencia', role: 'secretaria', folgas: [1] }),
]);
await as(A, `select public.add_store_member($1, 'i@x.pt')`, [store]);
await as(A, `select public.add_store_member($1, 'j@x.pt')`, [store]);
await as(A, `update store_members set person_id = 'pi' where user_id = $1`, [I]);
await as(A, `update store_members set person_id = 'pj' where user_id = $1`, [J]);
const accB = (await as(B, 'select public.my_access($1) a', [store]))[0].a;
ok('my_access has level and team', accB.level === 3 && accB.team === 'talho' && accB.chefe_team === 'talho' && accB.gerencia === false);
ok('a Gestor de Área still reads as gerencia for older apps', (await as(E, 'select public.my_access($1) a', [store]))[0].a.gerencia === true);
let st = (await stored('pt')).data;
await push(B, [person('pt', '2026-10-31T13:00:00Z', { ...st, role: 'chefeSeccao' })]);
ok('a chefe cannot promote to their own level', !('role' in (await stored('pt')).data));
await push(B, [person('pt', '2026-10-31T13:10:00Z', { ...st, role: 'segundaLinha' })]);
ok('a chefe gives a lower role', (await stored('pt')).data.role === 'segundaLinha');
st = (await stored('pt')).data;
await push(B, [person('pt', '2026-10-31T13:20:00Z', { ...st, team: 'peixaria' })]);
ok('a chefe cannot move someone out of their team', (await stored('pt')).data.team === 'talho');
const { weeklyHours: _w, ...noHours } = (await stored('pt')).data;
await push(B, [person('pt', '2026-10-31T13:30:00Z', { ...noHours, folgas: [2] })]);
st = (await stored('pt')).data;
ok('a chefe\'s push without a field wipes nothing', st.weeklyHours === 20 && JSON.stringify(st.folgas) === '[2]');
await push(B, [person('pc2', '2026-10-31T13:40:00Z', { ...(await stored('pc2')).data, role: 'operador', folgas: [4] })]);
const pc2 = (await stored('pc2')).data;
ok('a chefe cannot change a peer\'s role, but plans their folgas', pc2.role === 'chefeSeccao' && JSON.stringify(pc2.folgas) === '[4]');
await push(B, [
  person('pa1', '2026-10-31T14:00:00Z', { fullName: 'Novo Talho', team: 'talho', role: 'operador' }),
  person('pa2', '2026-10-31T14:00:00Z', { fullName: 'Novo Peixe', team: 'peixaria' }),
  person('pa3', '2026-10-31T14:00:00Z', { fullName: 'Novo Chefe', team: 'talho', role: 'chefeSeccao' }),
]);
ok('a chefe adds into their own team only, below their level', (await stored('pa1')) !== undefined && (await stored('pa2')) === undefined && (await stored('pa3')) === undefined);
await push(J, [person('pa4', '2026-10-31T14:00:00Z', { fullName: 'Por J', team: 'talho' })]);
ok('a Segunda Linha does not add people', (await stored('pa4')) === undefined);
ok('a Segunda Linha sees only public fields', !('weeklyHours' in (await pulled(J, 'pi')).data));
ok('a Segunda Linha does not approve', (await as(J, 'select public.can_approve($1) c', [store]))[0].c === false);
await push(B, [person('pi', '2026-10-31T15:00:00Z', (await stored('pi')).data, '2026-10-31T15:00:00Z')]);
ok('a chefe removes someone in their team', (await stored('pi')).deleted_at !== null);
ok('and their account leaves the store', (await as(A, 'select * from store_members where user_id = $1', [I])).length === 0);
await push(B, [person('pc2', '2026-10-31T15:10:00Z', (await stored('pc2')).data, '2026-10-31T15:10:00Z')]);
ok('a chefe cannot remove a peer', (await stored('pc2')).deleted_at === null);
await push(E, [person('ps', '2026-10-31T16:00:00Z', { ...(await stored('ps')).data, folgas: [5] })]);
ok('a Gestor de Área does not reach Gerência', JSON.stringify((await stored('ps')).data.folgas) === '[1]');
await push(E, [person('pt', '2026-10-31T16:00:00Z', { ...(await stored('pt')).data, team: 'peixaria', role: 'chefeSeccao' })]);
ok('a Gestor de Área moves and promotes below their level', (await stored('pt')).data.team === 'peixaria' && (await stored('pt')).data.role === 'chefeSeccao');
await push(E, [person('ps', '2026-10-31T16:10:00Z', { ...(await stored('ps')).data, role: 'gestorArea' })]);
ok('a Gestor de Área cannot give their own level', (await stored('ps')).data.role === 'secretaria');
await push(A, [person('pg', '2026-10-31T17:00:00Z', { ...(await stored('pg')).data, role: 'gerente' })]);
await push(E, [person('ps', '2026-10-31T17:10:00Z', { ...(await stored('ps')).data, folgas: [6] })]);
ok('the Gerente reaches Gerência', JSON.stringify((await stored('ps')).data.folgas) === '[6]');
await push(E, [
  person('ps', '2026-10-31T17:20:00Z', { ...(await stored('ps')).data, role: 'gerente' }),
  person('pg', '2026-10-31T17:20:00Z', { ...(await stored('pg')).data, role: 'operador' }),
]);
ok('the Gerente hands over and steps down', (await stored('ps')).data.role === 'gerente' && (await stored('pg')).data.role === 'operador');
await throws('a chefe is only linked by Gerência', () => as(C, 'select public.claim_person($1, $2)', [store, 'pc2']), /Não pertence|chefia/);

// Avisos. B: Chefe de Secção of talho (pc); J: Segunda Linha of talho (pj);
// E: now Operador in Gerência (pg).
const aviso = (id, t, data, del = null) => row(id, t, { syncUuid: id, ...data }, del, 'Aviso');
const visto = (id, t, data) => row(id, t, data, null, 'AvisoVisto');
const stored2 = async (collection, id) => { await db.exec('reset role'); return (await db.query('select * from records where collection = $1 and id = $2', [collection, id])).rows[0]; };
await push(B, [aviso('av1', '2026-10-31T18:00:00Z', { text: 'Validades', fromPersonId: 'pc', fromName: 'Chefe', toPersonIds: ['pj'] })]);
ok('a chefe sends an aviso to their team', (await stored2('Aviso', 'av1')) !== undefined);
ok('the sender reads it', (await pulled(B, 'av1')) !== undefined);
ok('the recipient reads it', (await pulled(J, 'av1'))?.data.text === 'Validades');
ok('someone else does not pull it', (await pulled(E, 'av1')) === undefined);
ok('nor select it', (await as(E, `select id from records where collection = 'Aviso'`)).length === 0);
await push(E, [aviso('av2', '2026-10-31T18:00:00Z', { text: 'x', fromPersonId: 'pg', fromName: 'G', toPersonIds: ['pj'] })]);
ok('level 1 cannot send', (await stored2('Aviso', 'av2')) === undefined);
await push(B, [aviso('av3', '2026-10-31T18:00:00Z', { text: 'x', fromPersonId: 'pc', fromName: 'C', toPersonIds: ['pj', 'pn'] })]);
ok('an aviso to someone not reached is dropped', (await stored2('Aviso', 'av3')) === undefined);
await push(J, [aviso('av4', '2026-10-31T18:00:00Z', { text: 'x', fromPersonId: 'pc', fromName: 'C', toPersonIds: ['pa1'] })]);
ok('an aviso in someone else\'s name is dropped', (await stored2('Aviso', 'av4')) === undefined);
await push(J, [aviso('av5', '2026-10-31T18:00:00Z', { text: 'x', fromPersonId: 'pj', fromName: 'J', toPersonIds: ['pa1'] })]);
ok('a Segunda Linha sends to their team', (await stored2('Aviso', 'av5')) !== undefined);
await push(B, [aviso('av6', '2026-10-31T18:00:00Z', { text: 'x', fromPersonId: 'pc', fromName: 'C', toPersonIds: [] })]);
ok('an aviso to nobody is dropped', (await stored2('Aviso', 'av6')) === undefined);
await throws('a direct aviso insert is blocked', () => as(B, `insert into records (store_id, collection, id, data, updated_at) values ($1, 'Aviso', 'avx', '{}', now())`, [store]), /row-level security/);
await push(J, [visto('av1/pj', '2026-10-31T18:10:00Z', { avisoId: 'av1', personId: 'pj', seenAt: 1 })]);
ok('the recipient marks it seen', (await stored2('AvisoVisto', 'av1/pj')) !== undefined);
ok('the sender reads the Visto', (await pulled(B, 'av1/pj')) !== undefined);
ok('someone else does not', (await pulled(E, 'av1/pj')) === undefined);
await push(E, [visto('av1/pg', '2026-10-31T18:10:00Z', { avisoId: 'av1', personId: 'pg', seenAt: 1 })]);
ok('no Visto on an aviso not received', (await stored2('AvisoVisto', 'av1/pg')) === undefined);
await push(J, [visto('av1/pc', '2026-10-31T18:10:00Z', { avisoId: 'av1', personId: 'pc', seenAt: 1 })]);
ok('no Visto for someone else', (await stored2('AvisoVisto', 'av1/pc')) === undefined);
const av1 = (await stored2('Aviso', 'av1')).data;
await push(J, [aviso('av1', '2026-10-31T19:00:00Z', av1, '2026-10-31T19:00:00Z')]);
ok('a recipient cannot delete it', (await stored2('Aviso', 'av1')).deleted_at === null);
await push(J, [aviso('av1', '2026-10-31T19:05:00Z', { ...av1, text: 'mudado' })]);
ok('nobody edits it', (await stored2('Aviso', 'av1')).data.text === 'Validades');
await push(B, [aviso('av1', '2026-10-31T19:10:00Z', av1, '2026-10-31T19:10:00Z')]);
ok('the sender deletes it', (await stored2('Aviso', 'av1')).deleted_at !== null);
await push(B, [aviso('av7', '2026-10-31T20:00:00Z', { text: 'y', fromPersonId: 'pc', fromName: 'C', toPersonIds: ['pj', 'pa1'] })]);
await push(A, [visto('av7/pa1', '2026-10-31T20:01:00Z', { avisoId: 'av7', personId: 'pa1', seenAt: 1 })]);
await push(J, [visto('av7/pa1', '2026-10-31T20:02:00Z', { avisoId: 'av7', personId: 'pj', seenAt: 2 })]);
ok('a Visto cannot overwrite someone else\'s', (await stored2('AvisoVisto', 'av7/pa1')).data.personId === 'pa1');
await push(J, [visto('whatever', '2026-10-31T20:03:00Z', { avisoId: 'av7', personId: 'pj', seenAt: 3 })]);
ok('a Visto is keyed by its aviso and person', (await stored2('AvisoVisto', 'whatever')) === undefined);

// Documentos: one list for every store; members read, the admin writes.
await db.exec('reset role');
const K = '00000000-0000-0000-0000-000000000099';
await db.query(`insert into auth.users values ($1, 'nobody@x.pt')`, [K]);
ok('documents bucket is private', (await db.query(`select public from storage.buckets where id = 'documents'`)).rows[0].public === false);
await as(A, `insert into storage.objects (bucket_id, name) values ('documents', 'd1.pdf')`);
await as(A, `insert into public.documents (title, file_name, size) values ('Regras', 'd1.pdf', 10)`);
await throws('a member cannot add a document', () => as(B, `insert into public.documents (title, file_name) values ('X', 'x.pdf')`), /row-level security/);
await throws('a member cannot add a document file', () => as(B, `insert into storage.objects (bucket_id, name) values ('documents', 'x.pdf')`), /row-level security/);
ok('a member reads the documents', (await as(B, `select * from public.documents`)).length === 1);
ok('a member reads the document files', (await as(B, `select * from storage.objects where bucket_id = 'documents'`)).length === 1);
ok('an account with no store reads none', (await as(K, `select * from public.documents`)).length === 0);
ok('an account with no store reads no files', (await as(K, `select * from storage.objects where bucket_id = 'documents'`)).length === 0);
await as(B, `update public.documents set title = 'Mudado'`);
await as(B, `delete from public.documents`);
ok('a member neither renames nor removes', (await as(A, `select title from public.documents`))[0]?.title === 'Regras');
await as(A, `update public.documents set title = 'Regras novas'`);
ok('the admin renames', (await as(B, `select title from public.documents`))[0].title === 'Regras novas');
await as(A, `delete from storage.objects where bucket_id = 'documents'`);
await as(A, `delete from public.documents`);
ok('the admin removes', (await as(B, `select * from public.documents`)).length === 0);

// Erros e sugestões: anyone signed in sends; only the admin reads them.
await throws('a message is needed', () => as(K, `select public.send_feedback('erro', '   ')`), /mensagem/);
await throws('erro or sugestão', () => as(K, `select public.send_feedback('outro', 'x')`), /erro ou sugestão/);
await as(K, `select public.send_feedback('sugestao', ' Mais cores ', $1, '0.77.0', 'web')`, [store]);
await as(B, `select public.send_feedback('erro', 'Não grava', $1, '0.77.0', 'android')`, [store]);
ok('a direct read shows nothing', (await as(B, `select * from public.feedback`)).length === 0);
await throws('only the admin lists them', () => as(B, `select * from public.feedback_list()`), /administrador/);
let fb = await as(A, `select * from public.feedback_list()`);
ok('the admin lists them, newest first', fb.length === 2 && fb[0].kind === 'erro' && fb[1].message === 'Mais cores');
ok('a store is kept only for its members', fb[1].store_name === null && fb[0].store_name === 'Pingo Doce X');
ok('with the sender\'s email', fb[0].email === 'Editor@x.pt');
await throws('only the admin marks them', () => as(B, `select public.set_feedback_done($1, true)`, [fb[0].id]), /administrador/);
await as(A, `select public.set_feedback_done($1, true)`, [fb[0].id]);
ok('the admin marks one dealt with', (await as(A, `select * from public.feedback_list()`))[0].done_at !== null);
await throws('only the admin removes them', () => as(B, `select public.delete_feedback($1)`, [fb[0].id]), /administrador/);
await as(A, `select public.delete_feedback($1)`, [fb[0].id]);
ok('the admin removes one', (await as(A, `select * from public.feedback_list()`)).length === 1);

// Administração: the admin sees every store, account and request at once.
const [{ store_join_code: adminCode }] = await as(A, `select public.store_join_code($1)`, [store]);
await as(K, 'select public.join_store($1, null, $2)', [adminCode, 'Kátia']);
await throws('only the admin sees the summary', () => as(B, `select public.admin_summary()`), /administrador/);
await throws('only the admin lists every request', () => as(B, `select * from public.admin_join_requests()`), /administrador/);
await throws('only the admin lists every store', () => as(B, `select * from public.admin_stores()`), /administrador/);
await throws('only the admin lists every account', () => as(B, `select * from public.admin_accounts()`), /administrador/);
await throws('only the admin lists a store\'s people', () => as(B, `select * from public.admin_store_people($1)`, [store]), /administrador/);
const [{ admin_summary: summary }] = await as(A, `select public.admin_summary()`);
ok('the summary counts the requests and open feedback', summary.join_requests >= 1 && summary.feedback === 1 && typeof summary.transfers === 'number');
const everyRequest = await as(A, `select * from public.admin_join_requests()`);
ok('every request, with its store', everyRequest.some((r) => r.user_id === K && r.store_name === 'Pingo Doce X' && r.requested_name === 'Kátia'));
const everyStore = await as(A, `select * from public.admin_stores()`);
const x = everyStore.find((s) => s.id === store);
ok('every store, with its counts', x && Number(x.pending) >= 1 && Number(x.members) >= 1 && Number(x.people) >= 1);
const accounts = await as(A, `select * from public.admin_accounts()`);
ok('every account, with its store and status', accounts.some((a) => a.user_id === K && a.status === 'pending' && a.store_name === 'Pingo Doce X'));
ok('the admin is marked', accounts.some((a) => a.user_id === A && a.is_admin));
const people = await as(A, `select * from public.admin_store_people($1)`, [store]);
ok('a store\'s people, with linked accounts', people.length >= 1 && people.some((p) => p.email !== null));
await as(A, 'select public.refuse_join($1, $2)', [store, K]);

// The admin removes an account (never their own or another admin's).
await as(K, 'select public.join_store($1, null, $2)', [adminCode, 'Kátia']);
await as(K, `select public.send_feedback('erro', 'Antes de sair')`);
await throws('only the admin removes accounts', () => as(B, 'select public.admin_delete_account($1)', [K]), /administrador/);
await throws('not their own account', () => as(A, 'select public.admin_delete_account($1)', [A]), /própria/);
await as(A, 'select public.admin_delete_account($1)', [K]);
ok('the account is gone', !(await as(A, `select * from public.admin_accounts()`)).some((a) => a.user_id === K));
ok('with its membership', (await db.query('select * from public.store_members where user_id = $1', [K])).rows.length === 0);
ok('its feedback stays, unlinked', (await as(A, `select * from public.feedback_list()`)).some((f) => f.message === 'Antes de sair'));
await throws('an account already removed', () => as(A, 'select public.admin_delete_account($1)', [K]), /já não existe/);
await db.exec('reset role');
await db.query(`insert into auth.users values ('00000000-0000-0000-0000-000000000098', 'admin2@x.pt')`);
await db.query(`insert into app_admins values ('00000000-0000-0000-0000-000000000098')`);
await throws('not another admin', () => as(A, 'select public.admin_delete_account($1)', ['00000000-0000-0000-0000-000000000098']), /administrador/);

// Disposable emails can't make an account, or be changed to.
await db.exec('reset role');
await throws('a disposable email', () => db.query(`insert into auth.users values ('00000000-0000-0000-0000-000000000099', 'x@en2ch.com')`), /temporários/);
await throws('under any ending, in capitals', () => db.query(`insert into auth.users values ('00000000-0000-0000-0000-000000000099', ' X@Mail.EN2CH.net ')`), /temporários/);
await throws('a listed domain', () => db.query(`insert into auth.users values ('00000000-0000-0000-0000-000000000099', 'x@yopmail.fr')`), /temporários/);
await throws('nor changed to one', () => db.query(`update auth.users set email = 'h@mailinator.com' where id = $1`, [H]), /temporários/);
await db.query(`insert into auth.users values ('00000000-0000-0000-0000-000000000099', 'x@gmail.com')`);
ok('other emails make accounts', (await db.query(`select 1 from auth.users where email = 'x@gmail.com'`)).rows.length === 1);
await db.query(`insert into auth.users values ('00000000-0000-0000-0000-000000000097', 'x@noten2ch.com')`);
ok('a name only containing a blocked one passes', (await db.query(`select 1 from auth.users where email = 'x@noten2ch.com'`)).rows.length === 1);
await throws('the API cannot read the list', async () => { await db.exec(`set role authenticated`); await db.query(`select * from public.blocked_email_domains`); }, /permission denied/);

await db.exec('reset role');
await throws('anon cannot send feedback', async () => { await db.exec(`set role anon`); await db.query(`select public.send_feedback('erro', 'x')`); }, /permission denied/);
await db.exec('reset role');
await throws('anon cannot call create_store', async () => { await db.exec(`set role anon`); await db.query(`select public.create_store('x')`); }, /permission denied/);

console.log(fails ? `\n${fails} FAILED` : '\nall passed');
process.exit(fails ? 1 : 0);
