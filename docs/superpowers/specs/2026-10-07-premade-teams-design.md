# Premade teams instead of cargo and managers — design

Date: 2026-10-07 · Target version: 0.32.0

## Goal

Replace a person's free-text **cargo** and their **manager links** with membership of one
**premade team**, plus an optional **chefe** role in that team. The Pessoas list becomes a
single view grouped by team, chefes first.

## Decisions (from the user)

- Teams are a fixed list in code, not editable in the app. Order (Livre Serviço first):
  **Livre Serviço, Gerência, Charcutaria, Meal Solutions, Talho, Peixaria, Frente de Loja,
  BemEstar, Padaria**.
- A person is in exactly one team, or none ("Sem equipa").
- Managers become per-team chefes. Each team has one **Chefe**, except Livre Serviço, which has
  two: **Chefe de dia** and **Chefe de noite**. A chefe must be a member of that team.
- On upgrade every existing person goes to "Sem equipa" with no chefe role; the old cargo text
  and manager links are dropped.
- The cargo field is removed entirely (no job title).

## Data

### Team list — `lib/models/teams.dart` (new, plain Dart)

```dart
class Team {
  const Team(this.id, this.name, this.chefeSlots);
  final String id;              // stored on Person, never shown
  final String name;            // shown in the UI
  final List<ChefeSlot> chefeSlots;
}

enum ChefeSlot { chefe, dia, noite }   // labels: Chefe / Chefe de dia / Chefe de noite

const teams = [
  Team('livre_servico', 'Livre Serviço', [ChefeSlot.dia, ChefeSlot.noite]),
  Team('gerencia', 'Gerência', [ChefeSlot.chefe]),
  Team('charcutaria', 'Charcutaria', [ChefeSlot.chefe]),
  Team('meal_solutions', 'Meal Solutions', [ChefeSlot.chefe]),
  Team('talho', 'Talho', [ChefeSlot.chefe]),
  Team('peixaria', 'Peixaria', [ChefeSlot.chefe]),
  Team('frente_de_loja', 'Frente de Loja', [ChefeSlot.chefe]),
  Team('bem_estar', 'BemEstar', [ChefeSlot.chefe]),
  Team('padaria', 'Padaria', [ChefeSlot.chefe]),
];

Team? teamById(String? id);
```

Storing the `id` (not the name) lets a display name change later without touching saved data.
An id that is no longer in the list (e.g. a team removed in a future version) is treated as
"Sem equipa".

### `Person` model

- Remove: `role`, `managerUuids`, `managerUuid` (legacy).
- Add: `String? team` (a `Team.id`, null = Sem equipa) and `String? chefe` (a `ChefeSlot.name`,
  null = member). `chefe` is only meaningful when it is one of the person's team's
  `chefeSlots`; anything else is read as "member".
- Regenerate `person.g.dart`. Isar drops removed properties automatically; new ones start null,
  which gives the "everyone to Sem equipa" upgrade with no migration code.

### `PersonService`

- Remove `migrateManagerUuids` (and its calls in `main.dart` and `BackupService.import`),
  `groupByManager`, `subtreeUuids`, and the manager clean-up in `delete`.
- `save(Person p)` enforces **one person per (team, slot)**: in the same write transaction it
  clears `chefe` on any other non-deleted person holding the same team + slot. The conflict
  search is a pure function in `teams.dart`, so it can be unit-tested:
  `List<Person> chefeConflicts(Person saving, List<Person> all)`.
- Add `Person? chefeHolder(List<Person> all, String teamId, ChefeSlot slot, {Person? except})`
  (pure, in `teams.dart`) for the form's confirmation dialog.

### Backup import

Older backup files contain `role` / `managerUuids` / `managerUuid` on each Person. The plan must
verify Isar's `importJson` ignores unknown keys; if it does not, strip those keys from each
Person map before importing. Imported people without `team` land in "Sem equipa".

## Screens

### Person form (`person_form_screen.dart`)

- Remove the **Cargo** field, the **Reporta a** (manager) picker and `_ManagerPickerDialog`.
- Add **Equipa**: a dropdown of the 9 teams plus "Sem equipa".
- Add **Função na equipa** (hidden for Sem equipa): "Membro" plus the team's slot labels —
  Livre Serviço: Membro / Chefe de dia / Chefe de noite; others: Membro / Chefe.
- Changing the team resets Função to Membro.
- On save, if another person holds the chosen slot, ask:
  *"Ana Martins é Chefe de Talho. Substituir?"* (Cancelar / Substituir). Substituir saves, and
  `PersonService.save` clears the previous holder.

### Pessoas (`people_screen.dart`, `people_sections.dart`)

- One view: remove the Lista/Equipas toggle, `_ViewMode`, `_TeamsList` and `_TeamSection`.
- Sections follow the fixed team order, then "Sem equipa" last; header "Talho (6)". Teams with
  no people (after search) are hidden.
- Inside a section: chefes first in the team's slot order (Chefe de dia before Chefe de noite),
  then members A–Z (case/accent-insensitive, as now).
- A chefe's row subtitle starts with their label: "Chefe · Nº 1234", "Chefe de noite · Nº 88".
- Search matches name, team name or nº de colaborador (case/accent-insensitive), as now with
  cargo replaced by team.

### Person detail (`person_detail_screen.dart`)

Where it showed the cargo, show "Talho · Chefe" / "Talho" (nothing for Sem equipa), then the
nº de colaborador as now.

### Other places

Nothing else shows cargo or managers (`person_picker.dart`, used to claim tasks, does not).

## Testing

Unit tests (no Isar needed — all pure functions):

- `teams.dart`: `teamById` (known, unknown, null); `chefeConflicts` (same team+slot → conflict;
  different slot, other team, member, deleted person, the person themself → none);
  `chefeHolder`.
- `people_sections.dart`: fixed team order with Sem equipa last; unknown team id → Sem equipa;
  chefes first in slot order, members A–Z; empty teams hidden; search by name, team name and nº.

Manual (by the user, on device): create/edit people, assign chefes and the replace prompt,
upgrade from 0.31.0 keeps people (all in Sem equipa), export/import round-trip, importing an
old backup.

## Docs and release

- `CLAUDE.md`: replace the manager/hierarchy notes with the team model.
- `CHANGELOG.md` 0.32.0: Added premade teams and chefes; Removed cargo, managers and the
  manager-grouped view.
- `pubspec.yaml` 0.32.0, annotated tag `v0.32.0`.

## Out of scope

Editing the team list in the app; a person in several teams; chefes from outside the team;
mapping old cargo text to teams.
