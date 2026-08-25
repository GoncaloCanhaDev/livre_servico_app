# Multi-manager reporting & team grouping Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a `Person` report to zero, one, or many managers (instead of exactly one), and let the people screen show a "grouped by team" view (a manager and their direct reports), alongside the existing list and org-chart views.

**Architecture:** Replace `Person.managerUuid` (single nullable string) with `Person.managerUuids` (a list), migrate existing on-device data once at startup, then update every place that reads/writes the single-manager field: `PersonService`'s grouping/cycle-guard/delete logic, the org chart's tree builder (now rendering a dual-report person once per manager), the manager picker in the person form (single-select → multi-select), and the people screen (new grouped-by-team view).

**Tech Stack:** Flutter, Isar (`isar_community`) for local persistence, no state management package (services extend `ChangeNotifier`), no test suite in this repo.

**Spec:** `docs/superpowers/specs/2026-08-25-multi-manager-teams-design.md`

## Global Constraints

- No `Team` model, team leads, or manager ordering/primary-secondary distinction — a "team" is exactly "a manager and their direct reports" (per spec's Scope section).
- Keep the legacy `Person.managerUuid` field in the model, unused by new code except the one-time migration — do not delete it (matches this codebase's existing convention for orphaned legacy fields, e.g. `SettingsService.notificationsEnabled`).
- No automated test suite exists in this repo (confirmed in CLAUDE.md — do not create a `test/` directory or assume `flutter test` targets). Verification per task is `flutter analyze` plus the manual steps each task specifies; Task 6 is a full manual pass through the spec's Testing section.
- After any change to `lib/models/person.dart`, regenerate `lib/models/person.g.dart` via `dart run build_runner build --delete-conflicting-outputs` before relying on persistence.
- UI strings are Portuguese (pt_PT), matching every other screen in this app.

---

### Task 1: `Person.managerUuids` field, migration, and startup wiring

**Files:**
- Modify: `lib/models/person.dart`
- Modify (generated): `lib/models/person.g.dart` (via build_runner — do not hand-edit)
- Modify: `lib/services/person_service.dart`
- Modify: `lib/main.dart`

**Interfaces:**
- Produces: `Person.managerUuids` (`List<String>`, defaults to `[]`); `Person.managerUuid` (`String?`, now legacy/read-only for new code).
- Produces: `PersonService.migrateManagerUuids()` (`Future<void>`), safe to call every startup.

- [ ] **Step 1: Add the new field to the model**

In `lib/models/person.dart`, replace the `managerUuid` field and its doc comment with both fields:

```dart
  /// Legacy single-manager field, superseded by [managerUuids]. Kept only
  /// so [PersonService.migrateManagerUuids] can read pre-upgrade data on
  /// existing on-device databases — nothing else reads or writes it.
  String? managerUuid;

  /// syncUuids of this person's managers (zero, one, or many — no
  /// primary/secondary ordering). Empty means they're at the top of the
  /// hierarchy. Self-referencing rather than Isar Links, same rationale as
  /// the old [managerUuid]: a manager whose row gets soft-deleted just
  /// leaves a dangling uuid here, which readers treat as "not a manager
  /// anymore" rather than as an error.
  List<String> managerUuids = [];
```

- [ ] **Step 2: Regenerate Isar schema code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: completes without error; `lib/models/person.g.dart` now includes a `managerUuids` property in `PersonSchema`.

- [ ] **Step 3: Add the migration method**

In `lib/services/person_service.dart`, add this method to the `PersonService` class (near `deleteAll`, after `delete`):

```dart
  /// One-time upgrade path: pre-multi-manager rows only have the legacy
  /// [Person.managerUuid] populated. Copies it into [Person.managerUuids]
  /// so existing org-chart assignments survive the upgrade. Safe to call
  /// every startup — a person already migrated (or created after the
  /// upgrade) has a non-empty managerUuids and is left alone. Runs over
  /// every row (not just non-deleted ones), mirroring
  /// `ShiftService._backfillSync`.
  Future<void> migrateManagerUuids() async {
    final rows = await _isar.persons.where().findAll();
    final needsFix = rows.where((p) {
      final legacy = p.managerUuid;
      return p.managerUuids.isEmpty && legacy != null && legacy.isNotEmpty;
    }).toList();
    if (needsFix.isEmpty) return;
    for (final p in needsFix) {
      p.managerUuids = [p.managerUuid!];
      SyncMeta.stamp(p);
    }
    await _isar.writeTxn(() => _isar.persons.putAll(needsFix));
  }
```

- [ ] **Step 4: Wire the migration into startup**

In `lib/main.dart`, add the import and call it right after `ShiftService.init()`:

```dart
import 'services/person_service.dart';
```

```dart
    await ShiftService.init();
    await PersonService.instance.migrateManagerUuids();
    await PersonHistoryService.instance.init();
```

- [ ] **Step 5: Verify**

Run: `flutter analyze`
Expected: no new errors (pre-existing behavior unchanged — nothing yet reads `managerUuids`).

Run the app (`flutter run`) far enough to confirm it boots past the startup try/catch without the "Erro ao iniciar a aplicação" screen.

- [ ] **Step 6: Commit**

```bash
git add lib/models/person.dart lib/models/person.g.dart lib/services/person_service.dart lib/main.dart
git commit -m "Add Person.managerUuids with startup migration from managerUuid"
```

---

### Task 2: Multi-manager logic in `PersonService`

**Files:**
- Modify: `lib/services/person_service.dart`

**Interfaces:**
- Consumes: `Person.managerUuids` (from Task 1).
- Produces: `PersonService.groupByManager(List<Person>) -> Map<String?, List<Person>>` — unchanged signature, but a person with several managers is now added under every one of their manager keys (not just one). `PersonService.subtreeUuids(List<Person>, String) -> Set<String>` — unchanged signature, walks all manager links. `PersonService.delete(int)` — unchanged signature, now drops only the removed manager's uuid from each report instead of clearing their whole manager list.

- [ ] **Step 1: Update `delete`**

In `lib/services/person_service.dart`, replace the body of `delete`:

```dart
  Future<void> delete(int id) async {
    final row = await _isar.persons.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    // Anyone reporting to the removed person loses just that reporting
    // line — they keep any other manager they still have, and only drop
    // to the top of the hierarchy if this was their last one.
    final all = await _isar.persons.filter().syncDeletedAtIsNull().findAll();
    final reports = all
        .where((p) => p.managerUuids.contains(row.syncUuid))
        .toList();
    for (final r in reports) {
      r.managerUuids = r.managerUuids
          .where((u) => u != row.syncUuid)
          .toList();
      SyncMeta.stamp(r);
    }
    await _isar.writeTxn(() async {
      await _isar.persons.put(row);
      await _isar.persons.putAll(reports);
    });
    notifyListeners();
  }
```

- [ ] **Step 2: Update `groupByManager`**

Replace its body:

```dart
  /// Groups [all] by manager syncUuid; a person with multiple managers is
  /// added under each one (see `buildForest` in org_chart.dart, which
  /// relies on this to render a dual-report person under every manager).
  /// The `null` key holds the roots — people with no manager, or whose
  /// only manager(s) no longer exist among [all] (e.g. soft-deleted
  /// without going through [delete]).
  Map<String?, List<Person>> groupByManager(List<Person> all) {
    final uuids = all.map((p) => p.syncUuid).toSet();
    final map = <String?, List<Person>>{};
    for (final p in all) {
      final validManagers = p.managerUuids.where(uuids.contains).toList();
      if (validManagers.isEmpty) {
        (map[null] ??= []).add(p);
      } else {
        for (final m in validManagers) {
          (map[m] ??= []).add(p);
        }
      }
    }
    return map;
  }
```

- [ ] **Step 3: Update `subtreeUuids`**

Replace its body:

```dart
  Set<String> subtreeUuids(List<Person> all, String rootUuid) {
    final childrenOf = <String, List<Person>>{};
    for (final p in all) {
      for (final m in p.managerUuids) {
        (childrenOf[m] ??= []).add(p);
      }
    }
    final result = <String>{rootUuid};
    final queue = <String>[rootUuid];
    while (queue.isNotEmpty) {
      final uuid = queue.removeLast();
      for (final child in childrenOf[uuid] ?? const <Person>[]) {
        if (result.add(child.syncUuid)) queue.add(child.syncUuid);
      }
    }
    return result;
  }
```

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: no new errors.

Manual regression check (app still has only the old single-manager form/UI at this point, so this only proves the service logic didn't break existing single-manager data): open the people screen, confirm the org chart and existing manager assignments still render exactly as before this task.

- [ ] **Step 5: Commit**

```bash
git add lib/services/person_service.dart
git commit -m "Support multiple managers per person in PersonService"
```

---

### Task 3: Render dual-report people in the org chart

**Files:**
- Modify: `lib/screens/widgets/org_chart.dart`

**Interfaces:**
- Consumes: `PersonService.groupByManager` output (from Task 2) — a person's `syncUuid` may now be a value under more than one key.
- Produces: `buildForest(Map<String?, List<Person>>) -> List<PersonNode>` — unchanged signature; a person with N managers now appears as N separate `PersonNode`s (one full subtree under each), instead of only the first-visited one.

- [ ] **Step 1: Replace the global visited-set with a per-path one**

In `lib/screens/widgets/org_chart.dart`, replace `buildForest` and its doc comment:

```dart
/// Builds the forest of [PersonNode]s from a manager-uuid grouping (see
/// `PersonService.groupByManager`). A person with several managers gets a
/// full card+subtree rendered once under each of them — this is a
/// deliberate "replicate the node" rendering for dual-reporting, not a
/// bug. The cycle guard tracks visited uuids per root-to-node path (not
/// globally) so a legitimate dual-report isn't mistaken for a repeat
/// visit; the app itself should never create an actual cycle (see
/// `PersonService.subtreeUuids`), but a corrupted/edited-outside-the-app
/// row still shouldn't be able to hang the UI.
List<PersonNode> buildForest(Map<String?, List<Person>> byManager) {
  PersonNode build(Person p, Set<String> pathVisited) {
    if (!pathVisited.add(p.syncUuid)) return PersonNode(p, const []);
    final kids = byManager[p.syncUuid] ?? const <Person>[];
    return PersonNode(
      p,
      kids.map((k) => build(k, {...pathVisited})).toList(),
    );
  }

  final roots = byManager[null] ?? const <Person>[];
  return roots.map((r) => build(r, <String>{})).toList();
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze`
Expected: no new errors.

Manual regression check: people screen's org-chart view still renders existing (single-manager) people exactly as before — this task alone can't be fully exercised with dual managers yet since the form doesn't support assigning a second one until Task 4.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/widgets/org_chart.dart
git commit -m "Render a dual-report person under every manager in the org chart"
```

---

### Task 4: Multi-select manager picker in the person form

**Files:**
- Modify: `lib/screens/person_form_screen.dart`

**Interfaces:**
- Consumes: `PersonService.instance.subtreeUuids` (from Task 2, same signature) to exclude invalid candidates.
- Produces: on save, `person.managerUuids` is set from the form's current multi-selection.

- [ ] **Step 1: Change the selection state field**

In `_PersonFormScreenState`, replace:

```dart
  Person? _manager;
```

with:

```dart
  List<Person> _managers = [];
```

- [ ] **Step 2: Update `_loadPeople` to resolve multiple managers**

Replace the body of `_loadPeople`:

```dart
  Future<void> _loadPeople() async {
    final all = await PersonService.instance.allRaw();
    final managerUuids = widget.existing?.managerUuids ?? const <String>[];
    final managers = all
        .where((p) => managerUuids.contains(p.syncUuid))
        .toList();
    if (!mounted) return;
    setState(() {
      _allPeople = all;
      _managers = managers;
      _loadingPeople = false;
    });
  }
```

- [ ] **Step 3: Rename and update `_pickManager` to open a multi-select dialog**

Replace `_pickManager` with:

```dart
  Future<void> _pickManagers() async {
    final selfUuid = widget.existing?.syncUuid;
    final excluded = selfUuid == null
        ? <String>{}
        : PersonService.instance.subtreeUuids(_allPeople, selfUuid);
    final candidates = _allPeople
        .where((p) => !excluded.contains(p.syncUuid))
        .toList();
    final result = await showDialog<List<Person>>(
      context: context,
      builder: (_) => _ManagerPickerDialog(
        candidates: candidates,
        initiallySelected: _managers,
      ),
    );
    if (result == null) return;
    setState(() => _managers = result);
  }
```

- [ ] **Step 4: Update `_save` to write the list**

In `_save`, replace:

```dart
    person.managerUuid = _manager?.syncUuid;
```

with:

```dart
    person.managerUuids = _managers.map((p) => p.syncUuid).toList();
```

- [ ] **Step 5: Update the "Reporta a" `ListTile`**

Replace:

```dart
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.black26),
                ),
                leading: const Icon(Icons.account_tree_outlined),
                title: const Text('Reporta a'),
                subtitle: Text(
                  _manager?.fullName ?? 'Ninguém (topo da hierarquia)',
                ),
                trailing: _loadingPeople
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _loadingPeople ? null : _pickManager,
              ),
```

with:

```dart
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.black26),
                ),
                leading: const Icon(Icons.account_tree_outlined),
                title: const Text('Reporta a'),
                subtitle: Text(
                  _managers.isEmpty
                      ? 'Ninguém (topo da hierarquia)'
                      : _managers.map((p) => p.fullName).join(', '),
                ),
                trailing: _loadingPeople
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _loadingPeople ? null : _pickManagers,
              ),
```

- [ ] **Step 6: Replace `_ManagerChoice`/`_ManagerPickerDialog` with a multi-select dialog**

Delete the `_ManagerChoice` class entirely. Replace the whole `_ManagerPickerDialog` class with:

```dart
class _ManagerPickerDialog extends StatefulWidget {
  const _ManagerPickerDialog({
    required this.candidates,
    required this.initiallySelected,
  });

  final List<Person> candidates;
  final List<Person> initiallySelected;

  @override
  State<_ManagerPickerDialog> createState() => _ManagerPickerDialogState();
}

class _ManagerPickerDialogState extends State<_ManagerPickerDialog> {
  late Set<String> _selectedUuids;

  @override
  void initState() {
    super.initState();
    _selectedUuids = widget.initiallySelected.map((p) => p.syncUuid).toSet();
  }

  void _confirm() {
    final selected = widget.candidates
        .where((p) => _selectedUuids.contains(p.syncUuid))
        .toList();
    Navigator.of(context).pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reporta a'),
      contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.vertical_align_top),
              title: const Text('Ninguém (topo da hierarquia)'),
              onTap: () => Navigator.of(context).pop(const <Person>[]),
            ),
            const Divider(height: 1),
            Flexible(
              child: widget.candidates.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Sem outras pessoas disponíveis.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.candidates.length,
                      itemBuilder: (_, i) {
                        final p = widget.candidates[i];
                        final selected = _selectedUuids.contains(p.syncUuid);
                        return CheckboxListTile(
                          value: selected,
                          onChanged: (checked) {
                            setState(() {
                              if (checked ?? false) {
                                _selectedUuids.add(p.syncUuid);
                              } else {
                                _selectedUuids.remove(p.syncUuid);
                              }
                            });
                          },
                          secondary: PersonInitialsBadge(name: p.fullName),
                          title: Text(p.fullName),
                          subtitle: p.role == null ? null : Text(p.role!),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('Concluído')),
      ],
    );
  }
}
```

- [ ] **Step 7: Verify**

Run: `flutter analyze`
Expected: no new errors, no references to the removed `_ManagerChoice`/`_manager`/`_pickManager` remain.

Manual check: run the app, open "Nova pessoa", tap "Reporta a", select two people via checkboxes, tap "Concluído" — the tile subtitle should list both names joined by ", ". Reopen the same form (edit an existing person saved this way) and confirm both checkboxes are pre-checked. Tap "Ninguém (topo da hierarquia)" and confirm it clears the subtitle back to that text.

- [ ] **Step 8: Commit**

```bash
git add lib/screens/person_form_screen.dart
git commit -m "Support selecting multiple managers in the person form"
```

---

### Task 5: Grouped-by-team view on the people screen

**Files:**
- Modify: `lib/screens/people_screen.dart`

**Interfaces:**
- Consumes: `PersonService.instance.groupByManager` (from Task 2).
- Produces: a third view mode ("equipas") alongside the existing list/chart toggle; no public API changes outside this file.

- [ ] **Step 1: Extract the person row into a reusable `_PersonTile`**

In `lib/screens/people_screen.dart`, replace `_PeopleList`'s body and add `_PersonTile` so the row markup can be reused by the new grouped view:

```dart
class _PeopleList extends StatelessWidget {
  const _PeopleList({
    required this.people,
    required this.onTap,
    required this.onLongPress,
  });

  final List<Person> people;
  final void Function(Person) onTap;
  final void Function(Person) onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: people.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => _PersonTile(
        person: people[i],
        onTap: () => onTap(people[i]),
        onLongPress: () => onLongPress(people[i]),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.person,
    required this.onTap,
    required this.onLongPress,
  });

  final Person person;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final p = person;
    final hasPhoto = p.photoPath != null && File(p.photoPath!).existsSync();
    return ListTile(
      leading: hasPhoto
          ? CircleAvatar(backgroundImage: FileImage(File(p.photoPath!)))
          : PersonInitialsBadge(name: p.fullName),
      title: Text(
        p.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        [
          if (p.role != null && p.role!.isNotEmpty) p.role!,
          if (p.collaboratorNumber.isNotEmpty) 'Nº ${p.collaboratorNumber}',
        ].join(' · '),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, size: 14, color: AppColors.greenDark),
            const SizedBox(width: 4),
            Text(
              '${p.points}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.greenDark,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
```

- [ ] **Step 2: Verify the refactor alone didn't change behavior**

Run: `flutter analyze`
Expected: no new errors.

Run the app, open the people screen's list view, confirm rows look identical to before (photo/initials, name, role/number subtitle, points chip).

- [ ] **Step 3: Commit the refactor separately**

```bash
git add lib/screens/people_screen.dart
git commit -m "Extract person row into _PersonTile for reuse"
```

- [ ] **Step 4: Add the `_TeamSection`/`_TeamsList` widgets**

Add these two classes to `lib/screens/people_screen.dart` (after `_PersonTile`):

```dart
class _TeamSection extends StatelessWidget {
  const _TeamSection({
    required this.title,
    required this.people,
    required this.onTap,
    required this.onLongPress,
  });

  final String title;
  final List<Person> people;
  final void Function(Person) onTap;
  final void Function(Person) onLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        for (final p in people)
          _PersonTile(
            person: p,
            onTap: () => onTap(p),
            onLongPress: () => onLongPress(p),
          ),
        const Divider(height: 1),
      ],
    );
  }
}

/// Renders [byManager] (see `PersonService.groupByManager`) as sections —
/// one per manager who has direct reports, plus "Topo da hierarquia" for
/// the `null` key. A person reporting to two managers appears in both
/// their sections, same as they'd appear twice in the org chart.
class _TeamsList extends StatelessWidget {
  const _TeamsList({
    required this.byManager,
    required this.onTap,
    required this.onLongPress,
  });

  final Map<String?, List<Person>> byManager;
  final void Function(Person) onTap;
  final void Function(Person) onLongPress;

  @override
  Widget build(BuildContext context) {
    final allPeople = {
      for (final list in byManager.values)
        for (final p in list) p.syncUuid: p,
    };
    final sections =
        byManager.keys.whereType<String>().map((uuid) {
          final name = allPeople[uuid]?.fullName ?? '—';
          return MapEntry(name, byManager[uuid]!);
        }).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final roots = byManager[null] ?? const <Person>[];

    return ListView(
      children: [
        if (roots.isNotEmpty)
          _TeamSection(
            title: 'Topo da hierarquia',
            people: roots,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        for (final section in sections)
          _TeamSection(
            title: section.key,
            people: section.value,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
      ],
    );
  }
}
```

- [ ] **Step 5: Replace the 2-way toggle with a 3-way view mode**

At the top of the file (outside the `PeopleScreen` class), add:

```dart
enum _ViewMode { list, teams, chart }
```

In `_PeopleScreenState`, replace:

```dart
  bool _listView = false;
```

with:

```dart
  _ViewMode _viewMode = _ViewMode.chart;

  static const _viewModeOrder = [
    _ViewMode.chart,
    _ViewMode.list,
    _ViewMode.teams,
  ];

  static const _viewModeLabel = {
    _ViewMode.list: 'Ver lista',
    _ViewMode.teams: 'Ver equipas',
    _ViewMode.chart: 'Ver organograma',
  };

  static const _viewModeIcon = {
    _ViewMode.list: Icons.list,
    _ViewMode.teams: Icons.groups_outlined,
    _ViewMode.chart: Icons.account_tree_outlined,
  };

  _ViewMode get _nextViewMode {
    final i = _viewModeOrder.indexOf(_viewMode);
    return _viewModeOrder[(i + 1) % _viewModeOrder.length];
  }
```

- [ ] **Step 6: Update the AppBar toggle button**

Replace:

```dart
          IconButton(
            tooltip: _listView ? 'Ver organograma' : 'Ver lista',
            icon: Icon(_listView ? Icons.account_tree_outlined : Icons.list),
            onPressed: () => setState(() => _listView = !_listView),
          ),
```

with:

```dart
          IconButton(
            tooltip: _viewModeLabel[_nextViewMode],
            icon: Icon(_viewModeIcon[_nextViewMode]),
            onPressed: () => setState(() => _viewMode = _nextViewMode),
          ),
```

- [ ] **Step 7: Update the body switch**

Replace:

```dart
            if (_listView) {
              return _PeopleList(
                people: items,
                onTap: _openDetail,
                onLongPress: _showActions,
              );
            }
            final byManager = PersonService.instance.groupByManager(items);
            final roots = buildForest(byManager);
            return OrgChart(
              roots: roots,
              onTap: _openDetail,
              onLongPress: _showActions,
            );
```

with:

```dart
            if (_viewMode == _ViewMode.list) {
              return _PeopleList(
                people: items,
                onTap: _openDetail,
                onLongPress: _showActions,
              );
            }
            final byManager = PersonService.instance.groupByManager(items);
            if (_viewMode == _ViewMode.teams) {
              return _TeamsList(
                byManager: byManager,
                onTap: _openDetail,
                onLongPress: _showActions,
              );
            }
            final roots = buildForest(byManager);
            return OrgChart(
              roots: roots,
              onTap: _openDetail,
              onLongPress: _showActions,
            );
```

- [ ] **Step 8: Verify**

Run: `flutter analyze`
Expected: no new errors, no leftover references to `_listView`.

Manual check: on the people screen, tap the toggle button repeatedly and confirm it cycles organograma → lista → equipas → organograma, with the icon/tooltip each time showing the mode you're about to switch *to*. In "equipas" mode, confirm each manager with direct reports gets a named section, people with no manager land under "Topo da hierarquia", and (using a person assigned to two managers via Task 4's form) that person appears in both of their managers' sections.

- [ ] **Step 9: Commit**

```bash
git add lib/screens/people_screen.dart
git commit -m "Add grouped-by-team view to the people screen"
```

---

### Task 6: Full verification pass

**Files:** none (verification only).

- [ ] **Step 1: Static analysis**

Run: `flutter analyze`
Expected: zero issues.

- [ ] **Step 2: End-to-end manual walkthrough**

Run the app (`flutter run`) and, on the people screen:

1. Create three people: A (no manager), B (reports to A), C (reports to both A and B).
2. Chart view: confirm C's card+subtree appears once under A and once under B.
3. Equipas view: confirm C appears in both A's and B's sections.
4. Edit C, remove B as a manager via the checkbox dialog, save: confirm C now appears only under A in both views.
5. Delete B: confirm B's own reports (if any) move up correctly and no crash occurs; confirm C (who no longer reported to B) is unaffected.
6. Create a person D reporting only to A, then delete A: confirm D moves to "Topo da hierarquia" (empty `managerUuids`), matching the existing single-manager delete behavior.

- [ ] **Step 3: Confirm no orphan references remain**

Run: `grep -rn "managerUuid\b" lib --include=*.dart | grep -v '\.g\.dart'`
Expected: only `lib/models/person.dart` (the legacy field declaration + its doc comment) and `lib/services/person_service.dart` (inside `migrateManagerUuids`) appear — every other match should be `managerUuids` (plural), not the legacy singular field.

- [ ] **Step 4: Final commit (only if Task 6 itself touched anything)**

If steps 1–3 required no code changes, there is nothing to commit — the plan is complete as of Task 5's commit. If a regression fix was needed, commit it separately with a message describing the fix.
