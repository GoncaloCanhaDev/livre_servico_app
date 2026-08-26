# Multi-Claim Tasks — Design Spec

Date: 2026-08-26

## Problem

Every "who did this" field in the app — checklist tasks (Daily/Weekly/Custom
Tasks), list finalization (Opening/Report/Visual/Auto lists), Truck
Reception, and Inventory sessions — currently records exactly one person's
name. In practice more than one person often works on the same task
together, and the app should let the supervisor credit all of them instead
of picking just one.

## Scope

**In scope:**
- The shared person picker (`pickPerson`/`pickPersonAndDay`) becomes
  multi-select everywhere it's used, so any "who did it?" prompt in the app
  lets the user pick one or more people in a single action.
- Every model field that currently stores a single name gets a new
  `List<String>` sibling field that becomes the source of truth going
  forward. The task/list still completes/finalizes in exactly one action —
  it's just credited to everyone selected, not a multi-step claim-over-time
  workflow.
- Every screen that displays "who did this" (activity feeds, historico,
  WhatsApp confirmation messages, the person detail screen's per-person
  activity feed) is updated to show/join multiple names.
- Old data (rows saved before this change, holding just the legacy single
  name) keeps displaying correctly via a read-time fallback — no write
  migration pass.

**Out of scope (explicitly deferred, not silently dropped):**
- `ShiftEvent.createdByInitials` and `Pedido.createdByInitials` — grepped,
  never actually written by any picker call site today (dead fields). Leave
  them alone.
- `historico_screen.dart`'s `_trailingWithInitials(initials, child) => child`
  — already a no-op today (ignores `initials`, doesn't render it) for the
  truck/opening/auto/report/inventory/pedido tiles that call it. Not this
  feature's concern; don't wire it up.
- The pre-existing gap where `OpeningListService`/`ReportListService`'s
  `backfillFinalized()` doesn't take a "who" parameter at all (backdated
  finalizes don't record who today). Not introduced by this change, not
  fixed by it either.
- Dashboard stats (`dashboard_screen.dart`) — confirmed via grep it only
  reads boolean completion fields (`kiwiAbertura`, etc.), never the "who"
  fields. Untouched.
- No "claim" as an ongoing/independent-over-time concept (e.g. person A
  claims it now, person B claims it again later as a separate event) — this
  is one completion action crediting multiple people at once, per the
  approved design.

## Data model

For every existing single-name field, add a `List<String>` sibling field
with an empty-list default. The legacy field is kept, untouched in type,
and simply never written again after this change — comment it the same way
`Person.managerUuid` is commented ("legacy — kept for historical read
fallback only"). No startup migration pass: history is preserved via a
read-time fallback helper instead (see "Name resolution & display" below).
This mirrors how this codebase already handled a single→multi field change
(`Person.managerUuid` → `managerUuids`), except simpler, since these fields
don't drive any structural logic (like the org chart) that needs a
migrated, canonical value at rest — display-time resolution is enough.

Exact fields to add, one collection at a time:

- **`lib/models/daily_tasks.dart`** (`DailyTasks`): add
  `List<String> kiwiAberturaByNames = [];`,
  `List<String> alteracoesPrecoByNames = [];`,
  `List<String> verificacaoTemperaturasByNames = [];`,
  `List<String> preenchimentoQuadroByNames = [];`,
  `List<String> verificacaoValidadesByNames = [];`,
  `List<String> kiwiFechoByNames = [];` — one per existing `xBy` field.
- **`lib/models/weekly_tasks.dart`** (`WeeklyTasks`): add
  `List<String> limpezaMaquinaVoltasByNames = [];`,
  `List<String> verificar1aByNames = [];`,
  `List<String> verificar4aByNames = [];`.
- **`lib/models/custom_task.dart`** (`CustomTaskEntry`): add
  `List<String> doneByNames = [];` alongside `doneBy`.
- **`lib/models/opening_list.dart`** (`OpeningList`),
  **`lib/models/report_list.dart`** (`ReportList`),
  **`lib/models/visual_list.dart`** (`VisualList`),
  **`lib/models/auto_list.dart`** (`AutoList`),
  **`lib/models/inventory.dart`** (`Inventory`),
  **`lib/models/truck_reception.dart`** (`TruckReception`): all six share
  the same legacy field name `createdByInitials` — each adds
  `List<String> createdByNames = [];`.

After every model edit, regenerate Isar code:
`dart run build_runner build --delete-conflicting-outputs`.

## Name resolution & display

New shared helpers in `lib/screens/widgets/person_picker.dart` (the natural
home — it's already the file that owns person-picking UI):

```dart
/// Names to treat as "who did this": the new list if it has anything,
/// otherwise the single legacy name (wrapped in a list) if there is one,
/// otherwise empty. Read-time fallback — old rows never get rewritten.
List<String> resolveNames(List<String> names, String? legacy) {
  if (names.isNotEmpty) return names;
  if (legacy == null || legacy.isEmpty) return [];
  return [legacy];
}

/// Portuguese-style join for display: "A", "A e B", "A, B e C".
String joinNames(List<String> names) {
  if (names.isEmpty) return '';
  if (names.length == 1) return names.first;
  return '${names.sublist(0, names.length - 1).join(', ')} e ${names.last}';
}
```

Every write site sets only the new list field. Every read/display site
wraps the pair of fields in `resolveNames(...)` before use — this includes
equality/membership checks like `person_detail_screen.dart`'s activity-feed
filter (`x.createdByInitials != name` becomes
`!resolveNames(x.createdByNames, x.createdByInitials).contains(name)`, and
similarly for the `t.xBy == name` checks against the six `DailyTasks`
fields). This is a behavior improvement noted for awareness, not extra
scope: a task/list claimed by multiple people now correctly shows up in
every claimer's own activity feed, not just one.

Badges: anywhere a single `PersonInitialsBadge` is shown for a "who did
this" field (the local `_InitialsBadge` widgets in
`daily_tasks_screen.dart`/`weekly_tasks_screen.dart`, the
`PersonInitialsBadge` calls in `custom_tasks_screen.dart`, and
`historico_screen.dart`'s `_HistoryInitials`), render a `Wrap` of one
badge per name instead of a single badge. No overflow/"+N" handling —
YAGNI for a single small team.

Text ("por ..." labels, WhatsApp messages): use `joinNames(...)` in place
of the single name that's currently interpolated.

## Shared picker widget

`lib/screens/widgets/person_picker.dart`:

- `pickPerson` → `pickPeople`, returns `Future<List<Person>?>` (null on
  cancel, otherwise 1+ people — never an empty list).
- `pickPersonAndDay` → `pickPeopleAndDay`, returns `Future<PeopleAndDay?>`.
- `PersonAndDay(person, day)` → `PeopleAndDay(people: List<Person>, day)`.
- `_PersonPickerDialog`: rows change from tap-to-pop `ListTile`s to
  `CheckboxListTile`s (same leading badge/title/subtitle), selection state
  held as a `Set<Id>` (person `id`, not `Person`, to avoid equality
  surprises). Actions row gains a primary "Confirmar" button, disabled
  while the set is empty, that pops the selected people (resolved back to
  `Person` objects) — plus the existing day (unchanged) when in
  `pickPeopleAndDay` mode. "Cancelar" unchanged.
- One shared day for the whole action (not per-person) — matches current
  behavior, just now crediting multiple names to that one day.

Every current call site is touched (there is no remaining single-select
caller after this change, so the rename is total, not additive):
`daily_tasks_screen.dart`, `weekly_tasks_screen.dart`,
`custom_tasks_screen.dart`, `tabs/abertura_tab.dart`,
`tabs/relatorio_tab.dart`, `tabs/visual_tab.dart`,
`tabs/automaticas_tab.dart`, `truck_form_screen.dart`,
`inventory_screen.dart`.

## Service layer

- **`lib/services/custom_task_service.dart`**: `complete({required String
  who, ...})` → `complete({required List<String> who, ...})`, sets
  `entry.doneByNames = who` (not `doneBy`).
- **`lib/services/visual_list_service.dart`**,
  **`lib/services/auto_list_service.dart`**: `add`/`addForDay(by: String?
  by, ...)` → `(by: List<String>? by, ...)`, sets
  `..createdByNames = by ?? []` (not `createdByInitials`).
- **`lib/services/inventory_service.dart`**: `startSession({String? by})`
  → `startSession({List<String>? by})`, sets
  `..createdByNames = by ?? []`.
- Opening/Report list finalization and Truck Reception's save set
  `createdByInitials` directly in the screen/tab file (not through a
  service method) — those call sites change to set `createdByNames`
  directly instead, same pattern, no new service method needed.

## Screens

For each screen below, the "who" callback/result changes from a single
`Person`/`String` to the picked list, and every read of the old field
becomes `resolveNames(...)`/`joinNames(...)` as described above:

- **`daily_tasks_screen.dart`**: the shared `_completeTask({apply, message,
  ...})` helper's `apply` callback changes from `(task, who) => task.xBy =
  who` to `(task, whoNames) => task.xByNames = whoNames`, across all 6
  manual/count task blocks. `message` callbacks use `joinNames(whoNames)`.
  Local `_InitialsBadge` widget becomes a `Wrap` of badges (see above).
- **`weekly_tasks_screen.dart`**: same shape, 3 blocks, own local
  `_InitialsBadge` gets the same `Wrap` treatment.
- **`custom_tasks_screen.dart`**: `_complete()` passes the picked list to
  `CustomTaskService.complete(who: ...)`; both tile classes'
  `PersonInitialsBadge(name: by)` become a `Wrap` fed by
  `resolveNames(entry.doneByNames, entry.doneBy)`.
- **`tabs/abertura_tab.dart`, `tabs/relatorio_tab.dart`**: `_finalize()`
  sets `list.createdByNames = names` (picked list) instead of
  `list.createdByInitials = person.fullName`; WhatsApp text
  `'Por: ${joinNames(names)}'`.
- **`tabs/visual_tab.dart`, `tabs/automaticas_tab.dart`**: `_finalize()`
  passes the picked list as `by:` to the (now list-typed)
  `VisualListService`/`AutoListService` `add`/`addForDay`; WhatsApp text
  via `joinNames`.
- **`truck_form_screen.dart`**: `_save()` sets
  `..createdByNames = names` from the picked list.
- **`inventory_screen.dart`**: both the session-start call
  (`startSession(by: names)`) and the inline send-only
  `Inventory()..createdByNames = names` construction change.
- **`historico_screen.dart`**: `_HistoryInitials` (single-badge widget)
  becomes a `Wrap`-of-badges widget fed by `resolveNames(...)` at its one
  render call site; the six `_DayItem` construction sites
  (shift/truck/opening/auto/report/visual) pass a resolved name list
  instead of a single `initials` string. `_TaskEntry`'s `by:` parameter
  (6 call sites, the Tasks-tab summary) becomes `byNames: List<String>`,
  rendered the same way `_InitialsBadge` is elsewhere in this spec — read
  `_TaskEntry`'s current render body first (not yet inspected) and match
  its existing style, just pluralized.
- **`person_detail_screen.dart`**: the activity-feed builder's 12
  membership checks (6 `x.createdByInitials != name` for
  opening/auto/report/visual/inventory/truck rows, 6 `t.xBy == name` for
  the `DailyTasks` fields) become `resolveNames(...).contains(name)` /
  `!resolveNames(...).contains(name)` as shown above.

## Testing approach

No automated test suite exists in this repo (per `CLAUDE.md`) — verify via
`flutter analyze` (zero new issues beyond this session's existing 3
pre-existing baseline `info` lints) plus manual reasoning through the flows,
same as the rest of this codebase's change process. If UI verification via
a running app becomes possible in this environment, exercise: complete a
daily task and a weekly task with 2 people selected; complete a custom task
with 1 person (confirms the single-person path still works through the new
multi-select API); finalize an Opening list and a Visual list entry with 2
people; save a Truck Reception and start an Inventory session each with 2
people; confirm the WhatsApp confirmation text joins names correctly for 1,
2, and 3 people; open the person detail screen for one of the two people
credited on a multi-person completion and confirm it shows up in their
activity feed; open historico and confirm a pre-existing (old-format,
single-name) row still displays its one name correctly via the fallback.
