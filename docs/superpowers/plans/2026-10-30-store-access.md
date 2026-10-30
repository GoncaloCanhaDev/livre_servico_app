# Store Access Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. In this repo the user forbids subagents: execute inline with superpowers:executing-plans.

**Goal:** Joining a store needs approval; people's personal data is seen and edited by hierarchy (person, chefe de secção, Gerência, app admin), enforced by the server; Horários is removed.

**Architecture:** Access is derived on the server from the Person each account is linked to (`store_members.person_id` → that Person's JSON in `records`), plus an `app_admins` table. Person rows stay one JSON document; the server redacts them on the way out (a `pull_records` RPC replaces the plain select, and the `records` select policy hides Person rows the caller may not fully see) and merges them field by field on the way in (`push_records`). The app mirrors the same rules in a pure `StoreAccess` model to show or lock fields.

**Tech Stack:** Flutter/Dart, Drift (LocalDb), `supabase` package, Postgres (Supabase) migrations tested on PGlite (`supabase/tests`).

**Spec:** `docs/superpowers/specs/2026-10-30-store-access-design.md`

## Global Constraints

- Follow `CLAUDE.md`: every commit is a version (bump `pubspec.yaml`, `CHANGELOG.md` entry, annotated tag `vX.Y.Z`); a feature added/removed bumps MINOR, anything else PATCH; BUILD +1 per commit. Current: `0.59.2+146`.
- Verify each task with `flutter analyze`, `flutter test` and (for SQL) `cd supabase/tests && npm test`. Never build an APK or install.
- Never use subagents.
- New schema changes go in new, later-timestamped files in `supabase/migrations/`; never edit the applied ones.
- UI strings in Portuguese (pt_PT). Database error messages in Portuguese, errcode `42501` for permission, `P0002` for not found.
- Never rename stored JSON fields or reorder stored enums. New Person fields: `profileUpdateRequestedAt` (date, microseconds like every date) and `profileUpdateRequestedBy` (String?, the requester's name).
- Public Person fields: `fullName`, `photoPath`, `genero`, `dateOfBirth`, `team`, `chefe`, `supervisor`, `segundaLinha`, `permanencia`, `createdAt`, `syncUuid`, `syncUpdatedAt`, `syncDeletedAt`. Every other field is personal.
- Edit groups (server and app must use the same lists):
  - self: `fullName`, `photoPath`, `phoneNumber`, `dateOfBirth`, `genero`, `notes`
  - schedule: `folgas`, `ausencias`
  - role: `team`, `chefe`, `supervisor`, `segundaLinha`, `permanencia`
  - request: `profileUpdateRequestedAt`, `profileUpdateRequestedBy`
  - everything else: admin only.
- Who: **self** = account linked to that person; **chefe of team T** = linked Person has `team = T` and a `chefe` slot T has (`livre_servico`: `dia`/`noite`; `gerencia`, `charcutaria`, `meal_solutions`, `talho`, `peixaria`, `padaria`: `chefe`; others none); **Gerência** = linked Person `team = 'gerencia'`; **admin** = in `app_admins`; the store **owner** keeps owner-only powers (code, members, wipe).
- Signed out (no store): the app sees and edits everything, as today.

## Review Focus

1. A regular member whose device already holds full Person data from before this version: after updating, the next sync must replace those rows with redacted copies (Task 5 test `stale full copies are replaced by redacted ones`).
2. A chefe demoted (or moved team): their device must drop the personal data it can no longer see on the next sync (Task 5 test `access change forgets the cursor`).
3. A device with a redacted Person pushing it back (first sync after a backup import pushes every row): hidden fields must survive (Task 4 test `redacted push keeps hidden fields`).
4. Someone setting their own `team` to `gerencia` or a `chefe` slot from a tampered app: ignored by the server (Task 4 test `self cannot change own role`).
5. A pending member with an old store chosen on the device: sees nothing, the app shows "a aguardar aprovação" and doesn't sync (Task 2 test `pending store does not sync`).

---

## Part 1: Join approval and app admin

### Task 1: Pending members, approvals and admin in the database

**Files:**
- Create: `supabase/migrations/20261031090000_join_approval_admin.sql`
- Modify: `supabase/tests/sync_schema_test.mjs`

**Interfaces:**
- Produces (SQL, all `security definer`, `set search_path = ''`, executable by `authenticated` only):
  - table `public.app_admins (user_id uuid primary key references auth.users on delete cascade)`, RLS on, no policies.
  - `public.is_app_admin() returns boolean`.
  - `store_members.status text not null default 'approved' check (status in ('pending','approved'))`, `store_members.requested_name text`.
  - `public.my_store_role(p_store uuid)`: `'owner'` for an admin; null for a pending member; else the role. `public.my_store_ids(p_role)`: every store for an admin; approved members only otherwise.
  - `public.member_person(p_store uuid, p_user uuid) returns jsonb`: the linked Person's `data` (live, approved member), else null. Internal (not granted).
  - `public.person_chefe_team(p_data jsonb) returns text`: the team T the person is chefe of per Global Constraints, else null. `immutable`.
  - `public.my_access(p_store uuid) returns jsonb`: `{admin, owner, gerencia, chefe_team, person_id, status}` for the caller (status null when not a member).
  - `public.my_stores() returns table (id uuid, name text, role public.store_role, person_id text, status text)`: the caller's memberships (pending included), plus every store (role `owner`, status `approved`) for an admin; by name.
  - `public.join_store(p_code text, p_person text default null, p_name text default null) returns uuid`: inserts a `pending` membership (role `editor`) with `person_id = p_person` or `requested_name = trim(p_name)`; an existing member keeps their row unchanged. Requires exactly one of `p_person`/`p_name` for a new request ('Escolha quem é ou escreva o seu nome.'). A person already taken raises 'Esta pessoa já tem conta.' (`23505`).
  - `public.can_approve(p_store uuid) returns boolean`: admin, owner, Gerência or any chefe (approved).
  - `public.store_join_requests(p_store uuid) returns table (user_id uuid, email text, person_id text, person_name text, requested_name text, created_at timestamptz)`: pending members; raises 'Sem permissão para aprovar pedidos.' (`42501`) unless `can_approve`.
  - `public.approve_join(p_store uuid, p_user uuid) returns void`: sets `approved`; with `requested_name` inserts a Person record (`id = gen_random_uuid()::text`, data `{syncUuid, fullName, createdAt, syncUpdatedAt}` with dates as microseconds since the epoch, `updated_at = now()`) and links it.
  - `public.refuse_join(p_store uuid, p_user uuid) returns void`: deletes the pending row.
  - Data: `update store_members set role = 'editor' where role = 'viewer'`.
  - Policy "members cancel own pending request" on `store_members`: `for delete to authenticated using (user_id = auth.uid() and status = 'pending')`.
  - `join_store_preview` and `unlinked_people` exclude people picked by a pending request too.

- [ ] **Step 1: Update the tests** in `sync_schema_test.mjs`: the existing join block now expects D's `join_store` to give `status = 'pending'` and D to read no records/stores/photos until approved; add (use users D, E, and a new F `f@x.pt` added to the stand-in `auth.users`):
  - `pending member sees nothing`: D after join reads 0 `records`, 0 `stores`, `push_records` raises /permissão/.
  - `editor without chefe cannot list requests`: B → /aprovar/.
  - `chefe approves`: push Person `pc` `{fullName:'Chefe', team:'talho', chefe:'chefe'}`, link B to `pc` (`claim_person`), then B sees D's request (with `person_name`) and `approve_join` makes D approved; D now reads records.
  - `typed name creates the person`: E `join_store(code, null, 'Nova')`; A approves; a Person record with `fullName = 'Nova'` exists and E's `person_id` is its id.
  - `refuse deletes the request`.
  - `admin sees every store`: `insert into app_admins` F (as superuser); F's `my_stores()` lists the store with role owner; F reads its records; `my_access` says `admin: true`.
  - `gerencia access`: a Person `{team:'gerencia'}` linked to a member gives `my_access.gerencia = true`; `{team:'livre_servico', chefe:'dia'}` gives `chefe_team = 'livre_servico'`; `{team:'frente_de_loja', chefe:'chefe'}` gives null.
  - `pending member cancels own request`: D deletes its own `store_members` row while pending → 1 row; an approved member deleting itself → 0 rows.
  - The viewer→editor conversion runs at migration time on existing rows only; it isn't tested (the test database has no rows then).
- [ ] **Step 2:** `cd supabase/tests && npm test` → the new checks FAIL.
- [ ] **Step 3:** Write the migration with the interfaces above (drop and recreate `join_store`, since its signature changes; `create or replace` the others; grant/revoke like the earlier migrations).
- [ ] **Step 4:** `npm test` → `all passed`.
- [ ] **Step 5:** Commit as v0.60.0+147 (`feat: join requests wait for approval; app admin`), CHANGELOG entry, tag.

### Task 2: Join requests in the app

**Files:**
- Create: `lib/models/store_access.dart`, `test/store_access_test.dart`
- Modify: `lib/services/account_service.dart`, `lib/screens/account_screen.dart`, `lib/screens/store_members_screen.dart`, `lib/screens/claim_person_screen.dart`, `lib/screens/home_screen.dart`, `test/claim_person_screen_test.dart`, `test/home_screen_test.dart`, `CLAUDE.md`

**Interfaces:**
- Consumes: Task 1's RPCs.
- Produces:
  - `class StoreAccess { const StoreAccess({required this.admin, required this.owner, required this.gerencia, this.chefeTeam, this.personId}); static const full = StoreAccess(admin: true, owner: true, gerencia: true); factory StoreAccess.fromJson(Map<String, dynamic>); Map<String, dynamic> toJson(); bool get canApprove; }` — `canApprove` = admin || owner || gerencia || chefeTeam != null. (Task 6 adds the per-person methods.)
  - `StoreInfo` gains `bool pending` and `StoreAccess access` (saved in the `account_store` pref; missing → `pending: false`, access from the role: owner → owner only).
  - `AccountService`: `myStores()` calls `my_stores`; `refreshAccess()` calls `my_access` for the current store and saves it; `StoreAccess get access` (`StoreAccess.full` when no store); `joinStore(String code, {String? personId, String? name})`; `typedef JoinRequest = ({String userId, String email, String? personId, String? personName, String? requestedName, DateTime createdAt})`; `Future<List<JoinRequest>> joinRequests()`; `approveJoin(String userId)`; `refuseJoin(String userId)`; `cancelJoinRequest()` (deletes its own pending `store_members` row, allowed by Task 1's policy).
  - `_startSync` does nothing for a pending store; `_refreshStore` starts it once approved (the existing refresh on restore, plus `refreshAccess`, plus a pull-to-refresh/"Verificar" button on the pending card).
  - `StoreRole.viewer` stays for decoding only; no UI offers it.

- [ ] **Step 1: Tests:**
  - `store_access_test.dart`: `fromJson` of `{admin:false, owner:false, gerencia:false, chefe_team:'talho', person_id:'p1'}` → `canApprove` true; all false → false; `full.canApprove` true; `toJson`/`fromJson` round trip.
  - `claim_person_screen_test.dart`: choosing "Não estou na lista" asks for a name (dialog "O seu nome", button "Pedir para entrar") and returns `(personId: null, name: 'Nova Pessoa')`; empty name keeps the dialog open.
  - `home_screen_test.dart`: with `AccountService.instance.store` set to a pending store, Home and Conta open without starting sync (`pending store does not sync`: `SyncService.instance.isRunning` false).
- [ ] **Step 2:** `flutter test` → new tests FAIL.
- [ ] **Step 3:** Implement:
  - `ClaimPersonScreen` returns `({String? personId, String? name})`; `completeProfile` only runs after approval (from `_refreshStore` noticing pending → approved, open the person form for `store.personId` the next time Conta or Home is shown: a `profilePending` pref flag set on join, cleared after the form opens).
  - Conta, pending store: card "Pedido enviado à loja X. Aguarde aprovação de um chefe ou da gerência." with "Verificar" and "Cancelar pedido".
  - Membros: section "Pedidos para entrar" (visible when `access.canApprove`) listing email and "É: <personName>" or "Novo: <requestedName>", with "Aprovar"/"Recusar". Members list role picker removed; owner keeps remove/unlink; "Adicionar pessoa" adds as editor.
  - Home: for `access.canApprove`, a small card "N pedido(s) para entrar" opening Membros (loads on open and on resume; no polling).
  - `CLAUDE.md` "Online database": pending members, approvals, `app_admins` (set by hand: `insert into app_admins select id from auth.users where email = '<admin email>'`), `my_stores`/`my_access`.
- [ ] **Step 4:** `flutter analyze` → no issues; `flutter test` → all pass.
- [ ] **Step 5:** Commit v0.60.1+148 (`feat: ask to join and approve requests in the app`), CHANGELOG, tag.

## Part 2: Remove Horários

### Task 3: Remove the Horários feature

**Files:**
- Delete: `lib/screens/horarios_screen.dart`, `lib/screens/horarios/`, `lib/services/horario_service.dart`, `lib/models/horario.dart`, `lib/models/horario_mes.dart`, `lib/models/horario_codigos.dart`, `test/horario_test.dart`
- Modify: `lib/main.dart`, `lib/services/local_db.dart`, `lib/services/backup_service.dart`, `lib/screens/home_screen.dart`, `lib/screens/people_screen.dart`, `lib/screens/person_detail_screen.dart`, `lib/screens/info_screen.dart`, `lib/screens/people_sections.dart`, `lib/screens/widgets/person_picker.dart`, `lib/screens/widgets/today_card.dart`, `lib/models/today.dart`, `lib/models/planning.dart`, `test/planning_test.dart`, `test/today_test.dart`, `test/local_db_test.dart`, `test/sync_engine_test.dart`, `test/home_screen_test.dart`, `test/helpers/app_db.dart`, `CLAUDE.md`

**Interfaces:**
- Produces: `offLabelOn(Person p, DateTime day)`, `awayTagOn(Person p, DateTime day)`, `offNoteOn(Person p, DateTime day)`, `buildPeopleSections(..., offDay:)` and the `today.dart` helpers lose their `horario:` parameter; shift times come from `Person.shiftStart`/`shiftEnd` only (`onShiftAt` / `shiftCountsOn` count only people with both set). `LocalDb.collections` no longer has `HorarioMes`.

- [ ] **Step 1:** Delete the horário tests and the `horario:` cases in `planning_test.dart` / `today_test.dart`; keep a test that an ausência beats a folga, and add `shift from person only`: a person with `shiftStart = 7*60`, `shiftEnd = 15*60` is on shift at 10:00 and not at 16:00.
- [ ] **Step 2:** `flutter test` → fails to compile (expected until Step 3).
- [ ] **Step 3:** Remove the files and every reference (`grep -rn -i horario lib test` returns nothing but the backup import ignoring a `horarios` section, if `backup_service.dart` reads one, and old shared-preference keys left alone). Remove the Home entry.
- [ ] **Step 4:** `flutter analyze` and `flutter test` → clean and passing.
- [ ] **Step 5:** `CLAUDE.md`: remove the Horários paragraph and references. Commit v0.61.0+149 (`feat: remove Horários`), CHANGELOG under "Removed", tag.

## Part 3: Personal data by hierarchy

### Task 4: Redacted reads and field-level writes in the database

**Files:**
- Create: `supabase/migrations/20261031120000_person_access.sql`
- Modify: `supabase/tests/sync_schema_test.mjs`

**Interfaces:**
- Consumes: `member_person`, `person_chefe_team`, `is_app_admin`, `my_store_role` (Task 1).
- Produces:
  - `public.person_access(p_store uuid, p_person_id text, p_person_data jsonb) returns text`: `'full'` (admin, Gerência, self, chefe of the person's `team`) or `'public'`.
  - `public.redact_person(p_data jsonb) returns jsonb`: only the public keys.
  - `public.person_edit_keys(p_store uuid, p_person_id text, p_server_data jsonb) returns text[]`: the keys the caller may write on that person per the edit groups (admin: null meaning all). Chefe/Gerência get `request`; self gets `self` (+ `request` only to clear, enforced in the merge).
  - `public.pull_records(p_store uuid, p_since timestamptz, p_limit int) returns setof public.records`: the caller's rows of the store with `server_updated_at >= p_since` (all when null), ordered, limited; Person rows with `person_access = 'public'` come with `data = redact_person(data)`. Raises /Não pertence/ for non-members.
  - Policy "members read records" replaced: `store_id in my_store_ids('viewer') and (collection <> 'Person' or person_access(store_id, id, data) = 'full')`. Policies "editors add records"/"editors change records" replaced to exclude `collection = 'Person'` (Person only through `push_records`).
  - `push_records` (`security definer` now, same signature): non-Person rows as before. Person rows:
    - new row: accepted only for admin or Gerência; else skipped.
    - existing row, incoming `updated_at` newer: `data = server.data` with each allowed key taken from incoming (present → set, absent → removed); request keys from self only when incoming value is null; `syncUpdatedAt` from incoming; `deleted_at` changes only for admin; `updated_at` = incoming.
    - returns, redacted per caller, every Person row whose stored data differs from what was pushed, plus (all collections) rows where the server was newer.
- [ ] **Step 1: Tests.** Setup after Task 1's block: B linked to `pc` (chefe of talho); D linked to `p4` (`team:'talho'`); E linked to `pn` (`team:'peixaria'`); a new user G (add `g@x.pt` to the stand-in `auth.users`) joins, is approved and linked to `pg` (`team:'gerencia'`); F is the admin. Give `p4` personal data `{phoneNumber:'900', folgas:[1], notes:'x'}`.
  - `member sees others redacted`: E's `pull_records` gives `p4` without `phoneNumber`/`folgas`/`notes`, with `fullName`, `dateOfBirth`, `team`.
  - `member sees own full`; `chefe sees own team full` (B sees `p4` phone); `chefe does not see other team` (B sees `pn` redacted); `gerencia sees all full` (G); `admin sees all full`.
  - `select policy hides personal rows`: E's plain `select * from records where collection='Person'` has no `p4`.
  - `self cannot change own role`: D pushes `p4` with `team:'gerencia'`, `phoneNumber:'911'` → stored team still `talho`, phone `911`, and the push returns the merged row.
  - `chefe edits team folgas only`: B pushes `p4` with `folgas:[2]`, `phoneNumber:'000'` → folgas `[2]`, phone unchanged.
  - `chefe cannot edit other team`: B pushes `pn` folgas → unchanged.
  - `gerencia changes roles`: G sets `p4.chefe='chefe'` → stored.
  - `redacted push keeps hidden fields`: E pushes redacted `p4` with newer `updated_at` → `phoneNumber`, `folgas`, `notes` still there.
  - `member cannot add or delete people`: E pushes new `px` → absent; E pushes `p4` with `deleted_at` → not deleted; G pushes new `py` → present.
  - `update request`: B sets `profileUpdateRequestedAt`/`By` on `p4` → stored; D clears both → cleared; D setting them → ignored.
  - `non-Person rows unchanged`: E pushes a `DailyTasks` row → stored, any member reads it.
  - `direct Person insert blocked`: E inserts a Person row directly → /row-level security/.
- [ ] **Step 2:** `npm test` → FAIL.
- [ ] **Step 3:** Write the migration per the interfaces (jsonb `?`, `-`, `||`, `jsonb_object_agg` over `jsonb_each`).
- [ ] **Step 4:** `npm test` → `all passed`.
- [ ] **Step 5:** Commit v0.62.0+150 (`feat: people's personal data visible and editable by hierarchy (database)`), CHANGELOG, tag.

### Task 5: Sync through `pull_records`, redacted copies replace stale ones

**Files:**
- Modify: `lib/services/supabase_sync_remote.dart`, `lib/services/sync_engine.dart`, `lib/services/local_db.dart`, `lib/services/account_service.dart`, `test/sync_engine_test.dart`

**Interfaces:**
- Consumes: `pull_records` (Task 4), `AccountService.refreshAccess` / `StoreAccess` (Task 2).
- Produces:
  - `SupabaseSyncRemote.pull` calls `pull_records` (`p_store`, `p_since`, `p_limit`).
  - `LocalCollection.applyRemote(rows, {bool replaceSynced = false})`: with `replaceSynced`, a local row that is `synced` (nothing pending) takes the server copy even when not older. `SyncEngine` passes `replaceSynced: c.name == 'Person'` on pull and on push answers.
  - `AccountService.refreshAccess()`: when the store's `StoreAccess` changed from the saved one, calls `SyncEngine.forgetCursor(prefs, storeId)` (new static, one store) before restarting sync, so every Person row is pulled again with the new redaction.
- [ ] **Step 1: Tests** in `sync_engine_test.dart` (extend `FakeRemote` with an optional `Map<String, dynamic> Function(SyncRecord)? redact` applied on pull):
  - `stale full copies are replaced by redacted ones`: device has synced Person `p1` with `phoneNumber`; remote redacts; after `forgetCursor` + `run()`, local `p1.phoneNumber` is empty and `fullName` kept.
  - `pending local edit survives a redacted pull`: an unsynced newer local Person is not replaced.
  - `access change forgets the cursor`: `forgetCursor` removes only `syncCursor:<store>`.
- [ ] **Step 2:** `flutter test test/sync_engine_test.dart` → FAIL.
- [ ] **Step 3:** Implement per the interfaces; call `refreshAccess()` after each sync in `SyncService` at most once a minute (or from `_refreshStore` on restore and on resume).
- [ ] **Step 4:** `flutter analyze`, `flutter test` → pass.
- [ ] **Step 5:** Commit v0.62.1+151 (`feat: pull people through pull_records, redacted per account`), CHANGELOG, tag.

### Task 6: Permission rules and the update request in the app model

**Files:**
- Modify: `lib/models/store_access.dart`, `lib/models/person.dart`, `lib/services/person_service.dart`, `test/store_access_test.dart`, `test/local_db_test.dart`

**Interfaces:**
- Produces:
  - `enum PersonFieldGroup { self, schedule, role, other }`.
  - `StoreAccess`: `bool isSelf(Person p)` (by `syncUuid == personId`), `bool canSeePersonal(Person p)`, `bool canEdit(Person p, PersonFieldGroup g)`, `bool canRequestUpdate(Person p)` (chefe of `p.team`, Gerência, admin; never self), `bool get canAddPeople` (admin || gerencia), `bool get canDeletePeople` (admin). `StoreAccess.full` allows everything. Rules exactly as the spec's table; `chefeTeam` and `gerencia` come from the server's `my_access` (Task 2), not from the local Person rows.
  - `Person.profileUpdateRequestedAt` (`DateTime?`), `Person.profileUpdateRequestedBy` (`String?`) in `toJson`/`fromJson`.
  - `PersonService.requestUpdate(Person p, String byName)` (stamps and saves); `PersonService.save` clears both fields when `AccountService.instance.access.isSelf(person)`.
- [ ] **Step 1: Tests** (`store_access_test.dart`), with people `ana {team:'talho'}`, `rui {team:'peixaria'}`:
  - member (personId of ana): `canSeePersonal(ana)` true, `(rui)` false; `canEdit(ana, self)` true, `(ana, schedule)` false, `(ana, role)` false; `canRequestUpdate(ana)` false.
  - chefe of talho: `canSeePersonal(ana)` true, `(rui)` false; `canEdit(ana, schedule)` true, `(ana, role)` false, `(rui, schedule)` false; `canRequestUpdate(ana)` true.
  - Gerência: `canSeePersonal(rui)` true; `canEdit(rui, schedule)` and `(rui, role)` true, `(rui, self)` false, `(rui, other)` false; `canAddPeople` true; `canDeletePeople` false.
  - admin and `full`: everything true.
  - `local_db_test.dart`: Person JSON round trip keeps `profileUpdateRequestedAt`/`By`.
- [ ] **Step 2:** FAIL. **Step 3:** implement. **Step 4:** `flutter analyze`, `flutter test` pass.
- [ ] **Step 5:** Commit v0.62.2+152 (`feat: who may see and edit each part of a profile`), CHANGELOG, tag.

### Task 7: Profiles in the UI follow the access rules

**Files:**
- Modify: `lib/screens/person_form_screen.dart`, `lib/screens/person_form/fields.dart`, `lib/screens/person_detail_screen.dart`, `lib/screens/people_screen.dart`, `lib/screens/home_screen.dart`, `lib/screens/widgets/` (new `profile_request_card.dart`), `test/person_form_screen_test.dart`, `test/home_screen_test.dart`, `CLAUDE.md`

**Interfaces:**
- Consumes: `StoreAccess` methods, `PersonService.requestUpdate` (Task 6).
- Produces: `PersonFormScreen` reads `AccountService.instance.access`; each field is enabled only when `canEdit(person, group)` (new person: everything when `canAddPeople`); personal fields are hidden when `!canSeePersonal(person)`. Person page: "Editar" shown when any group is editable; "Pedir atualização" when `canRequestUpdate` (confirm dialog; saves with `byName` = the account's person's `fullName`, else email). Pessoas: add button only when `canAddPeople`; delete only when `canDeletePeople`. Home: `ProfileRequestCard` when the account's own Person has `profileUpdateRequestedAt`: "Atualize o seu perfil — pedido por <By> em <d/M>", opening the form.
- [ ] **Step 1: Tests:**
  - `person_form_screen_test.dart`: with a member access (personId = the person): name and phone fields enabled, Equipa and Folgas disabled; with chefe access on another person of the team: Folgas enabled, name disabled; with no store: everything enabled (the existing test keeps passing).
  - `home_screen_test.dart`: own person with a request shows "Atualize o seu perfil"; saving the form removes it.
- [ ] **Step 2:** FAIL. **Step 3:** implement (pass `access` into the field widgets as `enabled` flags; don't restructure the form).
- [ ] **Step 4:** `flutter analyze`, `flutter test`, `cd supabase/tests && npm test` → all pass.
- [ ] **Step 5:** `CLAUDE.md`: document `StoreAccess`, the field groups, `pull_records`, redaction and the update request. Commit v0.62.3+153 (`feat: profiles show and lock fields by access; ask for a profile update`), CHANGELOG, tag.

## After the plan

Tell the user to run, in order, the migrations `20261030210000_unlinked_people_number.sql`, `20261031090000_join_approval_admin.sql`, `20261031120000_person_access.sql` on Supabase, then add themselves to `app_admins` with the SQL in `CLAUDE.md`, and only then install the new app version on devices (older apps keep pulling with a plain select, which then hides personal Person rows but no longer gives redacted ones).
