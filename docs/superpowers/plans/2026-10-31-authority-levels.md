# Authority Levels Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace chefe slots / Gerência-team permissions with one role per person on five authority levels, the same in the app (`StoreAccess`) and on the server (Supabase SQL).

**Architecture:** A `Role` enum in `lib/models/teams.dart` with a level per role, read through `roleOf(p)` (which derives a role from the old `chefe` / `supervisor` / `segundaLinha` fields on rows without one). `StoreAccess` carries the account's level and team and answers every permission from two rules, *reach* and *above*. A new migration adds the same `person_role` / reach / above helpers in SQL and rewrites every function that read `team = 'gerencia'` or `person_chefe_team`.

**Tech Stack:** Flutter/Dart (flutter_test), Supabase Postgres (PL/pgSQL; tests on PGlite with Node).

**Spec:** `docs/superpowers/specs/2026-10-31-authority-levels-design.md`

## Global Constraints

- `Person.role` stores `Role.name` (never an index). Names, labels, levels exactly:
  `operador` Operador 1 · `segundaLinha` Segunda Linha 2 · `supervisor` Supervisor 2 · `chefeSeccao` Chefe de Secção 3 · `gestorArea` Gestor de Área 4 · `secretaria` Secretária de Loja 4 · `gerente` Gerente de Loja 5.
- Levels 1–3 roles are allowed in every team; levels 4–5 only in Gerência (`gerencia`). "Sem equipa" / unknown team: Operador only.
- Never rename or remove `Person.chefe`, `supervisor`, `segundaLinha` (old rows and backups); the app stops relying on them but the person form clears them on save.
- The Dart rules (`StoreAccess`) and the SQL rules must match row for row.
- UI text in Portuguese (pt_PT).
- Every commit is a version (`CLAUDE.md` → Versioning): this feature is **one commit**, `0.68.0+167`, tag `v0.68.0`, CHANGELOG entry. Tasks below verify with tests but do not commit; Task 7 commits.
- No APK builds or installs; verify with `flutter analyze` and `flutter test` (and `npm test` in `supabase/tests`).

## Calls made while planning (spec gaps)

- **Sem equipa is reached by level 3+.** A join request approved by a Chefe de Secção creates a person with no team; without this the chefe could never put them into their team.
- **Self role edits:** the spec allows level 3+ to lower their own role. `canEdit(self, role)` is true for level ≥ 3; the new role must still be assignable (below own level, level 5 any), and the team one they reach.
- **"Remover todas as pessoas"** (bulk) stays admin-only (`canDeleteAll`).
- A demoted single holder (previous Chefe de Secção of that team/turno, previous Gerente) becomes Operador.
- `my_access` keeps returning `gerencia` (level ≥ 4) and `chefe_team` (team when level 3), so older app versions keep working; it adds `level` and `team`.

## Review Focus

1. **Old rows with no `role`** (every existing store on update day): a Gerência member without slot must read as Gestor de Área (level 4) in both Dart and SQL, a Livre Serviço `chefe: 'noite'` as Chefe de Secção with turno Noite. → tests in Task 1 and Task 5.
2. **Stale `role` invalid for the team** (someone moved from Gerência to Talho keeping `gestorArea`): reads as Operador, gives no level 4 power on the server. → Task 1 and Task 5.
3. **Redacted copy pushed back by a level 3** (it lacks personal fields) must not wipe them, and a level 3 pushing a role change on a peer must be ignored, not half-applied. → Task 5.
4. **Gerente hands over** (level 5 sets someone else to Gerente): the old Gerente becomes Operador in the same save; the server accepts the demotion push. → Task 3 (Dart) and Task 5 (SQL).
5. **Deleting a person with a linked account** removes that account's membership, so `member_person` doesn't leave them approved-but-unlinked with stale cached access. → Task 5.

---

### Task 1: Roles model

**Files:**
- Modify: `lib/models/teams.dart`, `lib/models/person.dart`
- Test: `test/teams_test.dart`

**Interfaces:**
- Produces (in `teams.dart`):
  - `enum Role { operador, segundaLinha, supervisor, chefeSeccao, gestorArea, secretaria, gerente }` with `final String label; final int level;`
  - `const gerenciaId = 'gerencia';`
  - `List<Role> rolesIn(String? teamId)` — known non-Gerência team: the four level 1–3 roles; Gerência: all seven; null/unknown: `[Role.operador]`. Display order = enum order.
  - `Role roleOf(Person p)` — `Role.values.asNameMap()[p.role]` if it is in `rolesIn(p.team)`; if `p.role` is null, the legacy derivation (spec "Reading old data"); otherwise (unknown or not allowed) `Role.operador`.
  - `int levelOf(Person p) => roleOf(p).level;`
  - `bool isSingleHolder(Role r)` — `chefeSeccao`, `gerente`.
  - `List<Person> roleConflicts(Person saving, List<Person> all)` — non-deleted others with the same single-holder role: `gerente` anywhere; `chefeSeccao` in the same team and, for a team with `hasTurnos`, the same `turnoOf`.
  - `Person? roleHolder(List<Person> all, Person saving)` — first of `roleConflicts`, or null.
  - `List<String> roleTagsOf(Person p)` — `[if level ≥ 2 roleOf(p).label, if p.permanencia 'Permanência']`.
  - `Turno? turnoOf(Person p)` — only for a `hasTurnos` team: `p.turno` by name; when `p.role` is null and the legacy chefe slot is dia/noite, that slot's turno (as today).
- Removed: `isSupervisor`, `isSegundaLinha`, `chefeHolder`, `chefeConflicts`, public `chefeSlotOf` (becomes private `_legacyChefeSlot`). `Team.chefeSlots`, `hasSupervisors`, `hasSegundaLinha` stay, documented as "old rows only" (the legacy derivation reads them). `ChefeSlot`, `chefeSlotForTurno` stay for that too.
- Produces (in `person.dart`): `String? role;` (doc: a `Role.name`; read through `roleOf`), in `toJson` (`'role': role`) and `fromJson` (`stringOrNull(j['role'])`).

- [ ] **Step 1: Write the failing tests** in `test/teams_test.dart` (replace the tests of removed helpers). Build people with a small `Person p({String? team, String? role, String? chefe, bool sup = false, bool seg = false, String? turno})` helper.

```dart
test('role by name, level from the role', () {
  expect(roleOf(p(team: 'talho', role: 'chefeSeccao')), Role.chefeSeccao);
  expect(levelOf(p(team: 'gerencia', role: 'gerente')), 5);
  expect(Role.secretaria.label, 'Secretária de Loja');
});
test('role not allowed in the team reads as Operador', () {
  expect(roleOf(p(team: 'talho', role: 'gestorArea')), Role.operador);
  expect(roleOf(p(team: null, role: 'chefeSeccao')), Role.operador);
  expect(roleOf(p(team: 'talho', role: 'rei')), Role.operador);
});
test('old rows: role derived from chefe, Gerência and tags', () {
  expect(roleOf(p(team: 'gerencia', chefe: 'chefe')), Role.gerente);
  expect(roleOf(p(team: 'gerencia')), Role.gestorArea);
  expect(roleOf(p(team: 'livre_servico', chefe: 'noite')), Role.chefeSeccao);
  expect(turnoOf(p(team: 'livre_servico', chefe: 'noite')), Turno.noite);
  expect(roleOf(p(team: 'frente_de_loja', sup: true)), Role.supervisor);
  expect(roleOf(p(team: 'talho', seg: true)), Role.segundaLinha);
  expect(roleOf(p(team: 'frente_de_loja', chefe: 'chefe')), Role.operador);
  expect(roleOf(p(team: 'talho', seg: true, role: 'operador')), Role.operador);
});
test('every team allows levels 1–3; only Gerência 4–5', () {
  expect(rolesIn('bem_estar'), [Role.operador, Role.segundaLinha, Role.supervisor, Role.chefeSeccao]);
  expect(rolesIn('gerencia'), Role.values);
  expect(rolesIn(null), [Role.operador]);
});
test('one Chefe de Secção per team and turno, one Gerente', () {
  final a = p(team: 'livre_servico', role: 'chefeSeccao', turno: 'dia');
  final b = p(team: 'livre_servico', role: 'chefeSeccao', turno: 'noite');
  final c = p(team: 'livre_servico', role: 'chefeSeccao', turno: 'dia');
  expect(roleConflicts(c, [a, b]), [a]);
  final g1 = p(team: 'gerencia', role: 'gerente'), g2 = p(team: 'gerencia', role: 'gerente');
  expect(roleConflicts(g2, [g1]), [g1]);
  expect(roleConflicts(p(team: 'talho', role: 'supervisor'), [p(team: 'talho', role: 'supervisor')]), isEmpty);
});
test('badges: role from level 2, then Permanência', () {
  expect(roleTagsOf(p(team: 'talho')), isEmpty);
  expect(roleTagsOf(p(team: 'talho', role: 'chefeSeccao')..permanencia = true), ['Chefe de Secção', 'Permanência']);
});
```

Each test person needs a distinct `syncUuid` (the "same person" check compares it).

- [ ] **Step 2: Run** `flutter test test/teams_test.dart` — Expected: FAIL (`Role` undefined).
- [ ] **Step 3: Implement** the Interfaces above.
- [ ] **Step 4: Run** `flutter test test/teams_test.dart` — Expected: PASS. (`flutter analyze` will still fail in the files Tasks 2–4 change.)

---

### Task 2: StoreAccess on levels

**Files:**
- Modify: `lib/models/store_access.dart`, `lib/services/account_service.dart` (lines ~83, ~97, ~435: the `StoreAccess(...)` constructions)
- Test: `test/store_access_test.dart`, `test/account_service_test.dart` (update constructions)

**Interfaces:**
- Consumes: `Role`, `roleOf`, `levelOf`, `rolesIn`, `gerenciaId`, `teamById`, `teams` (Task 1).
- Produces:
  - `const StoreAccess({required bool admin, int level = 1, String? team, String? personId})`; fields `admin`, `level`, `team`, `personId`. `gerencia` and `chefeTeam` are removed.
  - `StoreAccess.fromJson`: `level` = `j['level'] as int?`, else legacy (`gerencia == true` → 4 with team `gerencia`; `chefe_team` set → 3 with that team; else 1); `team` = `j['team'] ?? (legacy team)`. `toJson` writes `admin, level, team, person_id`. `==`/`hashCode` over the four.
  - `static const full = StoreAccess(admin: true, level: 5);`
  - `bool reaches(Person p)` — admin; level 5: all; 4: `p.team != gerenciaId`; 3: `p.team == team` or `teamById(p.team) == null`; 2: `p.team == team`; 1: false.
  - `bool isAbove(Person p)` — admin, or `reaches(p) && (levelOf(p) < level || level == 5)`.
  - `bool canSeePersonal(Person p)` — admin, self, or level ≥ 3 and reaches.
  - `bool canEdit(Person p, PersonFieldGroup g)` — admin, or: `self` → isSelf; `schedule` → level ≥ 3 && reaches; `role` → level ≥ 3 && (isAbove(p) || isSelf(p)); `other` → false.
  - `bool canRequestUpdate(Person p)` — `!isSelf(p)` and (admin or level ≥ 3 && reaches).
  - `bool get canAddPeople` — admin or level ≥ 3.
  - `bool canDeletePerson(Person p)` — admin, or level ≥ 3 && isAbove(p) && !isSelf(p).
  - `bool get canDeleteAll` — admin (replaces `canDeletePeople`).
  - `bool get canApprove` — admin or level ≥ 3. `canManageMembers` — admin or level ≥ 4. `canWipeAll` — admin.
  - `List<Role> assignableRoles(String? teamId)` — `rolesIn(teamId)` filtered to `admin || level == 5 || r.level < level`.
  - `List<String?> get assignableTeams` — the `teams` ids (in order) whose people this account reaches, then `null` (Sem equipa) when it reaches that; admin: all + null.
- The PersonFieldGroup doc comments change to the new holders (schedule: level 3+ reaching; role: level 3+ above them).

- [ ] **Step 1: Write the failing tests** in `test/store_access_test.dart`, replacing the gerencia/chefe ones. Use people `talho1` (talho, Operador), `talhoChefe` (talho, chefeSeccao, syncUuid not `c`), `ger` (gerencia, gestorArea), `gerente` (gerencia, gerente), `semEquipa` (team null).

```dart
const chefe = StoreAccess(admin: false, level: 3, team: 'talho', personId: 'c');
const seg = StoreAccess(admin: false, level: 2, team: 'talho');
const gestor = StoreAccess(admin: false, level: 4, team: 'gerencia');
const gerenteAcc = StoreAccess(admin: false, level: 5, team: 'gerencia');

test('reach', () {
  expect(chefe.reaches(talho1), isTrue);
  expect(chefe.reaches(ger), isFalse);
  expect(chefe.reaches(semEquipa), isTrue);
  expect(seg.reaches(semEquipa), isFalse);
  expect(gestor.reaches(talho1), isTrue);
  expect(gestor.reaches(ger), isFalse);
  expect(gerenteAcc.reaches(ger), isTrue);
});
test('only above: no edits at the same level, Gerente hands over', () {
  expect(chefe.canEdit(talho1, PersonFieldGroup.role), isTrue);
  expect(chefe.canEdit(talhoChefe, PersonFieldGroup.role), isFalse); // a peer: same level
  expect(gerenteAcc.canEdit(gerente, PersonFieldGroup.role), isTrue);
  expect(seg.canEdit(talho1, PersonFieldGroup.schedule), isFalse);
  expect(chefe.canEdit(talho1, PersonFieldGroup.other), isFalse);
});
test('delete, add, approve, members', () {
  expect(chefe.canDeletePerson(talho1), isTrue);
  expect(gestor.canDeletePerson(ger), isFalse);
  expect(seg.canAddPeople, isFalse);
  expect(chefe.canApprove && !chefe.canManageMembers, isTrue);
  expect(gestor.canManageMembers, isTrue);
  expect(gerenteAcc.canDeleteAll, isFalse);
});
test('assignable roles and teams', () {
  expect(chefe.assignableRoles('talho'), [Role.operador, Role.segundaLinha, Role.supervisor]);
  expect(gestor.assignableRoles('gerencia'), [Role.operador, Role.segundaLinha, Role.supervisor, Role.chefeSeccao]);
  expect(gerenteAcc.assignableRoles('gerencia'), Role.values);
  expect(chefe.assignableTeams, ['talho', null]);
  expect(gestor.assignableTeams.contains('gerencia'), isFalse);
});
test('personal data by reach from level 3', () {
  expect(chefe.canSeePersonal(talho1), isTrue);
  expect(seg.canSeePersonal(talho1), isFalse);
  expect(chefe.canSeePersonal(ger), isFalse);
});
test('fromJson reads levels and old cached access', () {
  expect(StoreAccess.fromJson({'admin': false, 'level': 4, 'team': 'gerencia'}), gestor);
  expect(StoreAccess.fromJson({'admin': false, 'gerencia': true}).level, 4);
  expect(StoreAccess.fromJson({'admin': false, 'chefe_team': 'talho', 'person_id': 'c'}), chefe);
  expect(StoreAccess.fromJson(chefe.toJson()), chefe);
});
```

- [ ] **Step 2: Run** `flutter test test/store_access_test.dart` — Expected: FAIL.
- [ ] **Step 3: Implement** the Interfaces; replace `StoreAccess(admin: …, gerencia: false)` in `account_service.dart` with `StoreAccess(admin: …)`; fix `test/account_service_test.dart` constructions and any `my_access` JSON fixtures there to include `level`/`team`.
- [ ] **Step 4: Run** `flutter test test/store_access_test.dart test/account_service_test.dart` — Expected: PASS.

---

### Task 3: Saving, Pessoas, badges, person page

**Files:**
- Modify: `lib/services/person_service.dart` (`save`), `lib/screens/people_sections.dart` (search + order), `lib/screens/widgets/role_badge.dart`, `lib/screens/people_screen.dart` (lines ~92, ~105, ~191), `lib/screens/person_detail_screen.dart` (only if it uses removed helpers)
- Test: `test/people_sections_test.dart`, `test/local_db_test.dart` or a new `test/person_service_test.dart` for the demotion (use `openAppDb` / `dbCall` helpers)

**Interfaces:**
- Consumes: Task 1 (`roleConflicts`, `roleOf`, `levelOf`, `roleTagsOf`, `Role`), Task 2 (`canDeletePerson`, `canDeleteAll`).
- `PersonService.save(p)`: demotes `roleConflicts(p, others)` to `role = Role.operador.name` (and clears their legacy `chefe`/`supervisor`/`segundaLinha`) in the same transaction.
- `buildPeopleSections`: within a section, order by `levelOf` descending, then (same level) by `Role` enum order, then A–Z; off-day rule first as now. Search matches `roleOf(p).label` (folded) for level ≥ 2, replacing the Supervisor / Segunda Linha checks. Update the doc comment.
- `RoleBadge`: filled when the label is the label of a role with level ≥ 3 (instead of `== 'Chefe'`).
- People screen: per-person "Remover" when `access.canDeletePerson(p)`; the bulk delete button when `access.canDeleteAll`; the edit/remove sheet opens if either applies.

- [ ] **Step 1: Write the failing tests:**
  - `people_sections_test.dart`: `'a team lists by level, highest first'` — talho with an Operador "Ana", a Segunda Linha "Bruno", a Chefe de Secção "Zé": titles' members are `['Zé', 'Bruno', 'Ana']`. `'search finds a role'` — query `"chefe de seccao"` returns only Zé. Update existing tests that used `chefe:`/`supervisor:` to set `role`.
  - `person_service_test.dart`: `'a new Gerente demotes the old one'` — save `g1` (gerencia, gerente), then `g2` (gerencia, gerente); reading back, `roleOf(g1) == Role.operador` and `roleOf(g2) == Role.gerente`.
- [ ] **Step 2: Run** `flutter test test/people_sections_test.dart test/person_service_test.dart` — Expected: FAIL.
- [ ] **Step 3: Implement** as above.
- [ ] **Step 4: Run** the same — Expected: PASS.

---

### Task 4: Person form — "Função"

**Files:**
- Modify: `lib/screens/person_form_screen.dart`, `lib/screens/person_form/fields.dart` (`_TagsField` keeps only Permanência)
- Test: `test/person_form_screen_test.dart`

**Interfaces:**
- Consumes: `access.assignableRoles`, `access.assignableTeams`, `roleOf`, `roleHolder`, `isSingleHolder`, `Role` (Tasks 1–2).
- State: `_isChefe`, `_supervisor`, `_segundaLinha` and `_chefeSlot` are replaced by `Role _role` (init `roleOf(existing)` or `Role.operador`).
- "Equipa" dropdown: items are `access.assignableTeams`, plus the person's current team if not in it (so an existing value always shows). Changing team resets `_role` to Operador if it isn't in `rolesIn(newTeam)`.
- "Função" dropdown (label `Função`), shown for every team incl. Sem equipa: items `access.assignableRoles(_team)`, plus the current `_role` if missing (shown, but the field is locked by `EditLock(enabled: role)` then). Turno stays required for Livre Serviço.
- Save: if `isSingleHolder(_role)` and `roleHolder(_allPeople, person)` (computed on a copy with the new team/role/turno) is someone else, the existing "Substituir?" dialog with `'${holder.fullName} é ${_role.label}${team de...}. Substituir?'` — keep today's wording shape: `'<nome> é Chefe de Secção de Talho. Substituir?'`, Gerente: `'<nome> é Gerente de Loja. Substituir?'`. If the person edits their own role to a lower level, a confirm: `'Vai deixar de ter as permissões de <role antigo>. Continuar?'`.
- Writes `person.role = _role.name`, clears `person.chefe = null`, `supervisor = false`, `segundaLinha = false`.

- [ ] **Step 1: Write the failing tests** in `test/person_form_screen_test.dart` (signed out = `StoreAccess.full`): `'saves the chosen Função'` — new person, team Talho, Função "Chefe de Secção", save; the saved row has `role == 'chefeSeccao'` and `chefe == null`. `'Gestor de Área only offered in Gerência'` — with team Talho the Função menu has no "Gestor de Área"; with Gerência it does. Update existing tests that tapped "Chefe"/"Supervisor" chips.
- [ ] **Step 2: Run** `flutter test test/person_form_screen_test.dart` — Expected: FAIL.
- [ ] **Step 3: Implement** as above.
- [ ] **Step 4: Run** `flutter analyze && flutter test` — Expected: no issues; all tests PASS (the whole app compiles again here).

---

### Task 5: Server migration

**Files:**
- Create: `supabase/migrations/20261031220000_authority_levels.sql`
- Test: `supabase/tests/sync_schema_test.mjs`

**Interfaces (SQL, all `set search_path = ''`, `security definer` where they read `store_members`/`records`, execute granted to `authenticated` only):**
- `person_role(p_data jsonb) returns text` (immutable) — same as Dart `roleOf`, including the legacy derivation and the per-team allowed lists (the 10 team ids from `lib/models/teams.dart`; old slot teams: livre_servico dia/noite; gerencia, charcutaria, meal_solutions, talho, peixaria, padaria, fruta `chefe`; supervisor only frente_de_loja; segundaLinha only charcutaria, meal_solutions, talho, peixaria, padaria, fruta).
- `role_level(p_role text) returns int` (immutable).
- `person_level(p_data jsonb) returns int` = `role_level(person_role(p_data))`.
- `my_level(p_store uuid) returns int` — `person_level(member_person(p_store, auth.uid()))`, 0 with no linked person. The admin is checked separately by each caller (`is_app_admin()`).
- `reaches(p_store uuid, p_team text) returns boolean` — admin true; else by `my_level` and my person's team, exactly as Dart `reaches` (level 3: own team, or `p_team` null / not one of the 10 ids).
- `is_above(p_store uuid, p_data jsonb) returns boolean` — admin, or `reaches(p_store, p_data->>'team') and (person_level(p_data) < my_level or my_level = 5)`.
- `can_assign(p_store uuid, p_data jsonb) returns boolean` — admin, or `reaches(p_store, p_data->>'team') and (my_level = 5 or person_level(p_data) < my_level)`.
- Rewritten (create or replace): `my_access` (adds `level`, `team`; `gerencia` = level ≥ 4; `chefe_team` = team when level = 3), `can_manage_members` (level ≥ 4), `can_approve` (level ≥ 3), `person_access` (`full` for self, admin, or level ≥ 3 and reaches), `can_request_update` (level ≥ 3 and reaches), `person_edit_keys` (self keys as now; schedule keys `folgas, ausencias` + request keys when level ≥ 3 and reaches; role keys `team, role, chefe, turno, supervisor, segundaLinha, permanencia` when level ≥ 3 and (`is_above` or self)), `claim_person` (refuse when `person_level(v_data) >= 3`, message `'Uma pessoa com função de chefia só é ligada pela gerência (Membros).'`), `person_public_keys` (add `role`, keep the old keys).
- `push_records` (create or replace, based on `20261031120000_person_access.sql`):
  - New Person row: insert when admin, or `my_level >= 3 and can_assign(p_store, data)`; `deleted_at` only for admin (as now).
  - Existing row, incoming `deleted_at` not null and server's null: when admin or (`my_level >= 3 and is_above(server data)` and it's not the caller's own person) → tombstone it and `delete from store_members where store_id = p_store and person_id = v_row.id`; otherwise ignore the delete (keep merging the rest as now).
  - After the per-key merge: if `person_role` or `team` of the merged data differs from the server's and not `can_assign(p_store, merged)`, put the server's values back for all role keys.

- [ ] **Step 1: Write the failing tests** — update the existing role assertions that change meaning, then add a `// Authority levels` section. Existing to update: line ~181 `member access` expected object → `{ admin: false, level: 1, team: <p4's team>, gerencia: false, chefe_team: null, person_id: 'p4', status: 'approved' }`; line ~257 `gerencia cannot delete people` → `gestor deletes an Operador` expecting `deleted_at` set. New (use the existing users; give people `role` explicitly unless testing the fallback):
  - `old Gerência row is level 4` — `person_level({team:'gerencia'}) = 4`; `{team:'gerencia', chefe:'chefe'}` → 5; `{team:'livre_servico', chefe:'noite'}` → 3; `{team:'talho', role:'gestorArea'}` → 1.
  - `my_access has level and team` for B (Chefe de Secção of talho): `level === 3 && team === 'talho' && chefe_team === 'talho'`.
  - `chefe cannot promote to own level` — B pushes p4 (talho Operador) with `role:'chefeSeccao'`: stored role unchanged; with `role:'segundaLinha'`: stored `segundaLinha`.
  - `chefe cannot move someone to another team` — B pushes p4 with `team:'peixaria'`: unchanged.
  - `chefe cannot edit a peer` — another talho Chefe de Secção row: B's push of its folgas is ignored.
  - `chefe adds into own team only` — B inserts `{team:'talho', role:'operador'}` → stored; `{team:'peixaria'}` → not stored; `{team:'talho', role:'chefeSeccao'}` → not stored.
  - `chefe deletes in own team, membership goes` — link H to a talho Operador, B tombstones it: `deleted_at` set and `store_members` has no H row.
  - `segunda linha sees only public fields` — a level-2 account pulls p4: no `weeklyHours`.
  - `gestor cannot touch Gerência; gerente can` — E as Gestor de Área pushes a change to a Gerência person's folgas: ignored; with E's person set to `role:'gerente'` (by A): applied.
  - `redacted copy from a chefe wipes nothing` — B pushes p4 without `weeklyHours`: stored still has it.
- [ ] **Step 2: Run** `cd supabase/tests && npm test` — Expected: FAIL lines for the new tests.
- [ ] **Step 3: Write the migration** per the Interfaces, with a header comment in the style of the other migrations.
- [ ] **Step 4: Run** `cd supabase/tests && npm test` — Expected: every line `ok`, exit code 0.

---

### Task 6: Texts — Membros, Conta, privacy policy, docs

**Files:**
- Modify: `lib/screens/account_screen.dart` (~319, ~690: "um chefe de secção ou a gerência"), `lib/screens/store_members_screen.dart` (~10, ~390), `lib/screens/widgets/join_requests_card.dart`, `lib/screens/widgets/profile_request_card.dart` (doc comments), `lib/models/privacy_policy.dart`, `CLAUDE.md`
- Test: `test/privacy_policy_screen_test.dart` (if it asserts the version or text)

- [ ] **Step 1:** Conta shows the account's role under the store name: `'<Role.label> · <team name>'` from the linked person (nothing when unlinked or signed out).
- [ ] **Step 2:** Replace user-facing "chefe ou a gerência" wording: approvals → `'um Chefe de Secção ou a gerência'`; members management → `'a gerência (Gestor de Área, Secretária ou Gerente)'`.
- [ ] **Step 3:** Privacy policy: who reads the whole profile becomes "a própria pessoa, quem tem função de chefia sobre a sua equipa (Chefe de Secção da equipa, Gestor de Área, Secretária de Loja, Gerente de Loja) e o administrador"; the public fields list "função" instead of "chefe, supervisor, segunda linha"; folgas/ausências edited by "a chefia da sua equipa". Set `privacyPolicyVersion` to the commit's date (`YYYY-MM-DD`; `test/privacy_policy_screen_test.dart` requires that format). If that is still `2026-10-31`, it stays as is.
- [ ] **Step 4:** `CLAUDE.md`: rewrite the paragraphs on teams/roles (data layer, "People belong to one of the fixed teams") and "Personal data" / `StoreAccess` for levels, reach and above; mention the new migration helpers.
- [ ] **Step 5: Run** `flutter analyze && flutter test` — Expected: no issues, all PASS.

---

### Task 7: Version and commit

**Files:** `pubspec.yaml`, `CHANGELOG.md`

- [ ] **Step 1:** `version: 0.68.0+167`; CHANGELOG `## [0.68.0] — 2026-10-31` with **Changed** (roles on five levels; who sees, edits, adds and removes people), **Added** (Função in the person form; Chefes de Secção remove people in their team), and the migration name, in the style of earlier entries.
- [ ] **Step 2: Run** `flutter analyze && flutter test && (cd supabase/tests && npm test)` — Expected: all pass.
- [ ] **Step 3: Commit and tag**

```bash
git add -A
git commit -m "feat: authority levels instead of chefe and Gerência

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
git tag -a v0.68.0 -m "v0.68.0"
```

- [ ] **Step 4:** Tell the user the migration must be run in the Supabase SQL Editor (or `supabase db push`) before the new app version is used with a store.
