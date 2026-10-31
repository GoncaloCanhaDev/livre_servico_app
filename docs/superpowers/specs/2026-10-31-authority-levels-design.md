# Authority levels — design

The first of three projects, in this order: (1) authority levels, (2) Avisos (in-app
notifications), (3) website presentation page and demo. Avisos and the demo build on the
levels, so this one goes first.

## Intent

Today what an account may do comes from a mix of things: being in the Gerência team, holding a
team's chefe slot, and (for nothing at all) the Supervisor / Segunda Linha tags. The user wants
this replaced with one ladder of authority that matches the store's real hierarchy. Every
person has one role, every role has a level, and each level can do everything the levels below
it can.

| Level | Roles | Adds, on top of the level below |
|---|---|---|
| 1 | Operador | Uses the app, edits their own profile |
| 2 | Segunda Linha, Supervisor | Sends Avisos to their own team (project 2; nothing new in this project) |
| 3 | Chefe de Secção | Adds and removes people in their own team |
| 4 | Gestor de Área, Secretária de Loja | All of the above, in every team except Gerência |
| 5 | Gerente de Loja | All of the above, in every team, Gerência included |

The app's admin (`app_admins`) stays above all levels, unchanged: creates stores, moves people
between stores, wipes all data, deletes anything.

## Goals

- One role per person (`Person.role`), chosen in the person form, shown as their badge.
- Every permission in the app and in the database derives from the account's person's level
  and team, with one rule for "reach" (below).
- Existing stores keep working after the update: everyone gets a role derived from what they
  have today, and nobody loses access they have today without a person with authority choosing
  it.

## Non-goals

- Avisos themselves (project 2). This project only defines who will be able to send them.
- Any change to the teams list, turnos, folgas, ausências, or the tenure/birthday tags.
- Per-feature permissions for everyday data (tasks, lists, camiões, inventários, pedidos):
  every approved member keeps editing those, as now.

## Anti-goals

- A user able to raise someone (or themselves) to their own level or above, or to change
  someone at their own level or above. That would make the ladder meaningless.
- The app and the server disagreeing about a permission (the app offering a button the server
  then refuses, or the server sending data the app was meant to hide). The Dart rules in
  `StoreAccess` and the SQL rules must stay the same, as they are today.

## Roles

A new enum, stored by **name** on `Person.role` (never by index):

| `name` | Label | Level | Allowed in |
|---|---|---|---|
| `operador` | Operador | 1 | every team |
| `segundaLinha` | Segunda Linha | 2 | every team |
| `supervisor` | Supervisor | 2 | every team |
| `chefeSeccao` | Chefe de Secção | 3 | every team |
| `gestorArea` | Gestor de Área | 4 | Gerência only |
| `secretaria` | Secretária de Loja | 4 | Gerência only |
| `gerente` | Gerente de Loja | 5 | Gerência only |

- Null, unknown, or a role not allowed in the person's team reads as Operador (one helper,
  `roleOf(p)`, like `chefeSlotOf` today). "Sem equipa" people are Operador whatever is stored.
- At most one Chefe de Secção per team. Livre Serviço has one per turno, which replaces Chefe de
  dia / Chefe de noite: a Livre Serviço Chefe de Secção's turno is their own `turno` field,
  required for that role there. At most one Gerente de Loja per store. `PersonService.save`
  keeps one holder by clearing the previous holder to Operador in the same transaction, as it
  does for chefe slots now. The other roles have no limit.
- Permanência stays an independent tag anyone can have; it gives no permissions.
- The badges: the role label (not shown for Operador), filled for level 3 and above, outlined
  for level 2, then Permanência as now. Pessoas lists each team by level, highest first, then
  by name, where it now puts chefes first.
- `Team.chefeSlots`, `hasSupervisors` and `hasSegundaLinha` go away (every team now allows
  levels 1–3). `ChefeSlot` stays only to read old rows. `Person.chefe`, `supervisor` and
  `segundaLinha` stay in the model for older backups and rows (never renamed), but nothing
  writes them any more.

### Reading old data

`roleOf(p)` uses `p.role` when set. When it's null (rows saved before this version, old
backups), it derives the role from the old fields:

- Gerência with chefe slot `chefe` → Gerente de Loja
- any other Gerência member → Gestor de Área (so today's Gerência keeps today's powers; the
  Gerente then corrects anyone who should be Secretária or Operador)
- any other chefe slot → Chefe de Secção (Livre Serviço: turno from the old slot, dia/noite)
- `supervisor` → Supervisor; `segundaLinha` → Segunda Linha
- otherwise Operador

The SQL side must derive it in exactly the same way: one `person_role(data jsonb)` function
used everywhere, with the same fallback. A migration can additionally write `role` into the
existing `records` rows; whether it does is left to the builder, as long as the fallback stays.

## The rule: level and reach

The acting account's person has a level `L` and team `T`. A target person `P` is in team `PT`
with level `PL`.

**Reach**: whether the actor's authority covers `P`'s team:
- `L` = 5: every team
- `L` = 4: every team except Gerência
- `L` = 2 or 3: only their own team (`PT` = `T`)
- `L` = 1: nobody (only themselves, through the self rules)

**Above**: the actor is *above* `P` when they reach `P` and `PL < L`. At level 5 they are also
above another level 5, so the Gerente can hand the role over.

| Action | Who | 
|---|---|
| Edit own name, photo, birthday, género, notes | the person themselves (as now) |
| See `P`'s whole profile (personal fields) | level ≥ 3 reaching `P` (today: chefe of P's team, Gerência) |
| Edit `P`'s folgas and ausências; "Pedir atualização" | level ≥ 3 reaching `P` |
| Add a person | level ≥ 3, into a team they reach, with a role below their own level (level 5: any role) |
| Remove (tombstone) a person | level ≥ 3 and above `P` |
| Change `P`'s team, role, turno, Permanência | level ≥ 3 and above `P`; the new team must be one they reach and the new role below their own level (level 5: any) |
| Approve or refuse join requests | level ≥ 3 (as chefes do today) |
| Join code, add a member by email, link/unlink accounts, remove memberships (Membros) | level ≥ 4 (Gerência today) |
| Send Avisos (project 2) | level ≥ 2, to people they reach |
| Edit everything else on a profile (nº de colaborador, dates, hours, shift) | admin only, as now |

Notes:
- "Changing someone at your own level" is refused, so two Chefes de Secção can't edit each other,
  and a Gestor de Área can't edit another Gestor de Área.
- Removing someone today is admin-only; it now opens to level 3+. Removing a person who has a
  linked account also removes that account's membership of the store, so they stop seeing it.
  (My call; without it the account stays approved but unlinked.)
- `claim_person` keeps refusing to link oneself to someone at level 3 or above (today: chefe or
  Gerência); level 4+ links them in Membros.
- A person at level 3+ changing their own role down is allowed, but the form warns that they'll
  lose those permissions.

## Where it changes

- `lib/models/teams.dart`: the role enum, `roleOf`, `levelOf`, the per-team allowed roles,
  `roleTagsOf`, `turnoOf`, the single-holder helper (now per role, per team, per turno).
- `lib/models/store_access.dart`: `StoreAccess` carries the account's level and team (from
  `my_access`) instead of `gerencia` / `chefeTeam`, and gets `reaches(p)`, `isAbove(p)`,
  `canAddPeople` (now team-aware), `canDeletePerson(p)`, and the existing checks rewritten on
  the table above. `StoreAccess.full` stays everything.
- `lib/models/person.dart`: `role` field in `toJson` / `fromJson`.
- `PersonService.save`: single-holder for Chefe de Secção and Gerente.
- Person form: one "Função" dropdown (the roles the team allows and the actor may give)
  replacing the chefe / Supervisor / Segunda Linha controls; the team dropdown limited to
  teams the actor reaches; locks through `EditLock` as now.
- Person page, Pessoas, Home, Membros, Conta: use the new checks. Conta shows the account's role.
- `supabase/migrations/<new>.sql`: `person_role`, `person_level`, a reach helper; rewrite
  `my_access`, `person_access`, `person_edit_keys`, `can_approve`, `can_manage_members`,
  `claim_person`, the person-add / delete checks in `push_records`, and replace `chefe`,
  `supervisor`, `segundaLinha` with `role` in `person_public_keys` (keep the old keys public
  too, so older app versions still show badges). Keep the Dart groups and the SQL key lists the
  same.
- Privacy policy (`lib/models/privacy_policy.dart`): who sees the whole profile changes (level
  3+ by reach instead of chefe / Gerência): update the text and `privacyPolicyVersion`.
- `CLAUDE.md`: the roles and "Personal data" paragraphs.
- Tests: `test/teams_test.dart`, `test/store_access_test.dart`, the person form test, and
  `supabase/tests` for every row of the action table, including the old-data fallback.
- Versioning: a feature, so a MINOR bump.

## Left to the builder

- Exact enum and helper names, and how the reach rule is shared between SQL functions.
- Whether the migration also writes `role` into existing `records` rows.
- The wording of the form's warnings and of the server's refusal messages (Portuguese).
