# Multi-manager reporting & team grouping

Date: 2026-08-25
Status: Approved for implementation

## Problem

`Person.managerUuid` (`lib/models/person.dart`) is a single nullable field, so the org
hierarchy is a strict tree — one manager per person. In practice some people split their
time and answer to two supervisors at once (dual supervision), which the current model
can't represent. Separately, there's no way to see people grouped by team; a "team" in
this app is simply "a manager and their direct reports," which the current single-parent
model would already give for free if multi-manager were supported — no separate `Team`
entity is needed.

## Scope

In scope:
- `Person` can report to zero, one, or many managers, with no primary/secondary
  distinction (co-equal).
- Org chart (`org_chart.dart`) renders a person's card+subtree under every manager they
  report to.
- People list (`people_screen.dart`) gains a grouped-by-team view alongside the existing
  flat list and org chart.
- `person_form_screen.dart`'s manager picker becomes multi-select.
- Existing on-device data (`managerUuid`) is migrated to the new field on first run after
  upgrade, without loss.

Out of scope (YAGNI per brainstorming discussion):
- A separate named `Team` model, team leads, or any team concept independent of the
  manager relationship.
- Primary/secondary manager ordering or weighting.

## Data model

`lib/models/person.dart`:
- Add `List<String> managerUuids = [];` (empty = top of hierarchy).
- Keep `String? managerUuid` in the class, but stop writing/reading it from new code.
  It's kept only so the one-time migration below can read pre-upgrade data — same
  pattern this codebase already uses for other orphaned legacy fields (see
  `SettingsService.notificationsEnabled` per CLAUDE.md). Regenerate `person.g.dart` via
  `dart run build_runner build --delete-conflicting-outputs`.

## Migration

Add `PersonService.migrateManagerUuids()`: for every person with `managerUuids.isEmpty`
and a non-null `managerUuid`, set `managerUuids = [managerUuid]`, stamp via
`SyncMeta.stamp`, and persist. Call it once from `main.dart` immediately after
`ShiftService.init()`, inside the existing startup try/catch. This mirrors
`ShiftService._backfillSync()`'s role (fix up legacy rows at startup) without folding
person-specific migration logic into `ShiftService` itself.

## Service layer (`lib/services/person_service.dart`)

- `groupByManager(List<Person> all) -> Map<String?, List<Person>>`: for each person, add
  them under every one of their `managerUuids` that resolves to another person in `all`;
  if `managerUuids` is empty (or none resolve), add them under the `null` (root) key. A
  person with two valid managers appears under both keys — this is what makes the
  grouped-team view and the multi-parent org chart work without new data structures.
- `delete(id)`: currently nulls `managerUuid` on every direct report. Change to remove
  just the deleted person's uuid from each report's `managerUuids` list (via
  `list.remove(uuid)`), so a dual-reporting person keeps their other manager. A person
  left with an empty list becomes a root, same as today.
- `subtreeUuids(all, rootUuid)`: build `childrenOf` from every entry in each person's
  `managerUuids` (instead of the single field) so the cycle guard still walks the full
  multi-parent graph. Used by the form to exclude invalid manager candidates.

## Org chart (`lib/screens/widgets/org_chart.dart`)

`buildForest` currently tracks a single global `visited` set and returns a childless
`PersonNode` on a repeat visit — this was cycle-safety for a tree, but under multi-manager
it would silently drop a dual-report person from their second manager's subtree. Change
`build()` to track visited uuids per root-to-node path (a new `Set<String>` threaded
through each call, not shared across sibling branches) instead of globally. Net effect: a
person with two managers gets a full card + their own subtree rendered once under each
manager (standard "replicate the node" rendering for dual-reporting charts — no
cross-linking lines, consistent with this widget's existing straight-line style). A
genuine cycle (already prevented at write-time by `subtreeUuids`) still can't hang
rendering, since the guard now applies per path.

## People screen (`lib/screens/people_screen.dart`)

Currently toggles between flat list and org chart. Add a third mode: grouped-by-team —
sections headed by each manager's name (plus a "Topo da hierarquia" section for people
with an empty `managerUuids`), each listing that manager's direct reports using the
existing `_PeopleList` row style. A person with two managers appears in both of their
managers' sections. Reuse `PersonService.groupByManager` for the grouping (same data the
org chart uses). The toggle becomes a 3-way control (lista / equipas / organograma)
instead of the current 2-way icon toggle — use a segmented control or cycling icon button
consistent with the existing AppBar action style.

## Person form (`lib/screens/person_form_screen.dart`)

Replace the single-select `_ManagerPickerDialog` with a multi-select version:
checkboxes per candidate person, plus the existing "Ninguém (topo da hierarquia)" option
now clears the whole selection. `_manager` (single `Person?`) becomes `_managers`
(`List<Person>`), and the "Reporta a" tile's subtitle lists all selected names (or the
existing "Ninguém..." text when empty). Candidate exclusion keeps using
`PersonService.instance.subtreeUuids` unchanged. On save, `person.managerUuids =
_managers.map((p) => p.syncUuid).toList()`.

## Testing

No test suite in this repo (per CLAUDE.md). Verify manually: run the app, confirm
`flutter analyze` is clean, and check: assigning a person to two managers shows them
under both in the org chart and in the grouped people view; deleting one of their two
managers leaves the other reporting line intact; a pre-existing single-manager person's
assignment survives the migration on first launch after upgrade.
