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
  grant execute on function auth.uid() to authenticated, anon;
  insert into auth.users values
    ('00000000-0000-0000-0000-00000000000a','owner@x.pt'),
    ('00000000-0000-0000-0000-00000000000b','Editor@x.pt'),
    ('00000000-0000-0000-0000-00000000000c','viewer@x.pt'),
    ('00000000-0000-0000-0000-00000000000d','stranger@x.pt');
`);
for (const m of migrations) await db.exec(m);
await db.exec(`
  grant usage on schema public to authenticated, anon;
  grant select, insert, update, delete on all tables in schema public to authenticated;
`);

const A = '00000000-0000-0000-0000-00000000000a', B = '00000000-0000-0000-0000-00000000000b',
  C = '00000000-0000-0000-0000-00000000000c', D = '00000000-0000-0000-0000-00000000000d';
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

ok('owner cannot remove self', (await as(A, 'delete from store_members where user_id = $1 returning *', [A])).length === 0);
ok('owner removes viewer', (await as(A, 'delete from store_members where user_id = $1 returning *', [C])).length === 1);
ok('removed viewer reads nothing', (await as(C, 'select * from records')).length === 0);
ok('editor cannot promote self', (await as(B, `update store_members set role = 'owner' where user_id = $1 returning *`, [B])).length === 0);
ok('pull query works', (await as(B, `select id from records where store_id = $1 and server_updated_at > $2 order by server_updated_at`, [store, '2000-01-01'])).length === 2);

await db.exec('reset role');
await throws('anon cannot call create_store', async () => { await db.exec(`set role anon`); await db.query(`select public.create_store('x')`); }, /permission denied/);

console.log(fails ? `\n${fails} FAILED` : '\nall passed');
process.exit(fails ? 1 : 0);
