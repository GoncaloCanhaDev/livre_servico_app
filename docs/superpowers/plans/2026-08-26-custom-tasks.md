# Custom Tasks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let the user create their own ad-hoc checklist items (title, frequency: daily/weekly/one-off, input type: checkbox/checkbox+count), complete them with attribution and backdating like every other task in the app, send a WhatsApp summary, and remove them later.

**Architecture:** Two new Isar collections (`CustomTask` — the definition; `CustomTaskEntry` — one row per completed period) behind a new `CustomTaskService`, surfaced through a new `CustomTasksScreen` reached from `HomeScreen`. Mirrors the existing `DailyTasks`/`WeeklyTasks` UX (checkbox tiles, `pickPersonAndDay` attribution, backdating, WhatsApp long-press) but stores tasks as rows instead of hardcoded fields, since the set of tasks is user-defined and open-ended.

**Tech Stack:** Flutter, Isar (`isar_community`) local DB, no backend, pt_PT-only UI strings.

**Spec:** `docs/superpowers/specs/2026-08-26-custom-tasks-design.md`

## Global Constraints

- No automated test suite exists in this repo (see `CLAUDE.md`) — do not write `flutter test` targets. Every task's "verify" step is `flutter analyze` (must stay at the 3 pre-existing unrelated `info`-level lints, zero new issues) plus manually tracing the code against the spec/plan.
- After creating or editing any `@collection` class, regenerate Isar code with `dart run build_runner build --delete-conflicting-outputs` before analyzing.
- All new user-facing strings are in Portuguese (pt_PT), matching the rest of the app.
- Follow the existing sync-field convention on every new model: `syncUuid`, `syncUpdatedAt`, `syncDeletedAt`, `synced`, stamped via `SyncMeta.stamp()` and soft-deleted via `SyncMeta.softDelete()` — never hard-delete rows.
- Custom tasks do NOT integrate with `TaskTimer`, the Dashboard's daily-completion stats, or missed-day/justification tracking (explicitly out of scope per spec).
- Isar collection getters follow this codebase's existing naming: class name, lowercase-first, plus a literal `s` (e.g. `CustomTask` → `_isar.customTasks`, `CustomTaskEntry` → `_isar.customTaskEntrys` — not smart English pluralization; confirmed against `InfoEntry` → `_isar.infoEntrys` already in this codebase).

---

### Task 1: Data model — `CustomTask` and `CustomTaskEntry`

**Files:**
- Create: `lib/models/custom_task.dart`
- Modify: `lib/services/shift_service.dart:19-55` (add import, register two schemas)

**Interfaces:**
- Produces:
  - `enum CustomTaskFrequency { daily, weekly, oneOff }`
  - `enum CustomTaskInputType { simple, count }`
  - `class CustomTask` — fields `id` (Id), `syncUuid` (String), `syncUpdatedAt` (DateTime), `syncDeletedAt` (DateTime?), `synced` (bool), `title` (String), `frequency` (CustomTaskFrequency), `inputType` (CustomTaskInputType), `createdAt` (DateTime).
  - `class CustomTaskEntry` — fields `id` (Id), `syncUuid` (String), `syncUpdatedAt` (DateTime), `syncDeletedAt` (DateTime?), `synced` (bool), `taskUuid` (String), `periodKey` (DateTime), `done` (bool), `doneBy` (String?), `count` (int?), `doneAt` (DateTime?), `backdated` (bool).
  - `final DateTime oneOffPeriodKey` — top-level constant, the fixed `periodKey` used by every one-off task's single entry.
  - Isar collection getters `_isar.customTasks` (`IsarCollection<CustomTask>`) and `_isar.customTaskEntrys` (`IsarCollection<CustomTaskEntry>`), available once the schemas are registered in `ShiftService.init()`.

- [ ] **Step 1: Write the model file**

Create `lib/models/custom_task.dart`:

```dart
import 'package:isar_community/isar.dart';

part 'custom_task.g.dart';

enum CustomTaskFrequency { daily, weekly, oneOff }

enum CustomTaskInputType { simple, count }

@collection
class CustomTask {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;

  late String title;

  @enumerated
  CustomTaskFrequency frequency = CustomTaskFrequency.daily;

  @enumerated
  CustomTaskInputType inputType = CustomTaskInputType.simple;

  late DateTime createdAt;
}

@collection
class CustomTaskEntry {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;

  /// The [CustomTask.syncUuid] this entry records a completion for.
  @Index()
  late String taskUuid;

  /// The service day (daily tasks), the service week's Monday (weekly
  /// tasks), or [oneOffPeriodKey] (one-off tasks — they never reset, so
  /// they only ever have a single entry, always keyed to that constant).
  @Index()
  late DateTime periodKey;

  bool done = false;
  String? doneBy;

  /// Only meaningful when the task's [CustomTask.inputType] is `count`.
  int? count;
  DateTime? doneAt;

  /// True when this entry was completed via the backdate flow rather than
  /// on its own period.
  bool backdated = false;
}

/// Fixed period key for one-off custom tasks — see [CustomTaskEntry.periodKey].
final DateTime oneOffPeriodKey = DateTime.fromMillisecondsSinceEpoch(0);
```

- [ ] **Step 2: Regenerate Isar code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: build succeeds, creates `lib/models/custom_task.g.dart` defining `CustomTaskSchema` and `CustomTaskEntrySchema`.

- [ ] **Step 3: Register the new collections**

Modify `lib/services/shift_service.dart`. Add the import alongside the other model imports (alphabetical, after `auto_list.dart`, before `daily_tasks.dart`):

```dart
import '../models/custom_task.dart';
```

Add the two schemas to the `Isar.open` list (after `TaskTimerSchema`, the current last entry):

```dart
        PersonSchema,
        TaskTimerSchema,
        CustomTaskSchema,
        CustomTaskEntrySchema,
      ],
```

- [ ] **Step 4: Verify**

Run: `flutter analyze`
Expected: only the 3 pre-existing `info`-level lints (`historico_screen.dart:951`, `historico_screen.dart:953`, `truck_form_screen.dart:330`) — zero new issues.

Manually confirm `lib/models/custom_task.g.dart` contains both `CustomTaskSchema` and `CustomTaskEntrySchema` top-level `CollectionSchema` constants (grep the file for `final CustomTaskSchema` / `final CustomTaskEntrySchema`).

- [ ] **Step 5: Commit**

```bash
git add lib/models/custom_task.dart lib/models/custom_task.g.dart lib/services/shift_service.dart
git commit -m "Add CustomTask/CustomTaskEntry Isar models"
```

---

### Task 2: Service layer — `CustomTaskService`

**Files:**
- Create: `lib/services/custom_task_service.dart`

**Interfaces:**
- Consumes: `CustomTask`, `CustomTaskEntry`, `CustomTaskFrequency`, `CustomTaskInputType`, `oneOffPeriodKey` from Task 1 (`lib/models/custom_task.dart`); `ShiftService.instance.isar` (`lib/services/shift_service.dart`); `SyncMeta.stamp`/`SyncMeta.softDelete` (`lib/services/sync_meta.dart`).
- Produces: `CustomTaskService.instance` (singleton, `ChangeNotifier`) with:
  - `Future<List<CustomTask>> tasks()` — non-deleted tasks, sorted by `createdAt` ascending (creation order).
  - `Future<CustomTask> addTask({required String title, required CustomTaskFrequency frequency, required CustomTaskInputType inputType})`
  - `Future<void> deleteTask(String taskUuid)` — soft-deletes the `CustomTask` only; existing `CustomTaskEntry` rows are untouched.
  - `Future<CustomTaskEntry?> entryFor(String taskUuid, DateTime periodKey)` — the matching non-deleted entry, or `null`.
  - `Future<void> complete({required String taskUuid, required DateTime periodKey, required String who, int? count, bool backdated = false})` — finds-or-creates the entry for `(taskUuid, periodKey)` and marks it done.

- [ ] **Step 1: Write the service**

Create `lib/services/custom_task_service.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/custom_task.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class CustomTaskService extends ChangeNotifier {
  CustomTaskService._();
  static final CustomTaskService instance = CustomTaskService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<List<CustomTask>> tasks() => _isar.customTasks
      .filter()
      .syncDeletedAtIsNull()
      .sortByCreatedAt()
      .findAll();

  Future<CustomTask> addTask({
    required String title,
    required CustomTaskFrequency frequency,
    required CustomTaskInputType inputType,
  }) async {
    final task = CustomTask()
      ..title = title
      ..frequency = frequency
      ..inputType = inputType
      ..createdAt = DateTime.now();
    SyncMeta.stamp(task);
    await _isar.writeTxn(() => _isar.customTasks.put(task));
    notifyListeners();
    return task;
  }

  Future<void> deleteTask(String taskUuid) async {
    final task = await _isar.customTasks
        .filter()
        .syncUuidEqualTo(taskUuid)
        .findFirst();
    if (task == null || task.syncDeletedAt != null) return;
    SyncMeta.softDelete(task);
    await _isar.writeTxn(() => _isar.customTasks.put(task));
    notifyListeners();
  }

  Future<CustomTaskEntry?> entryFor(String taskUuid, DateTime periodKey) {
    return _isar.customTaskEntrys
        .filter()
        .taskUuidEqualTo(taskUuid)
        .periodKeyEqualTo(periodKey)
        .syncDeletedAtIsNull()
        .findFirst();
  }

  /// Marks the entry for `(taskUuid, periodKey)` as done by [who]. Finds the
  /// existing entry for that period, or creates one if this is the first
  /// completion.
  Future<void> complete({
    required String taskUuid,
    required DateTime periodKey,
    required String who,
    int? count,
    bool backdated = false,
  }) async {
    var entry = await entryFor(taskUuid, periodKey);
    entry ??= CustomTaskEntry()
      ..taskUuid = taskUuid
      ..periodKey = periodKey;
    entry.done = true;
    entry.doneBy = who;
    entry.doneAt = DateTime.now();
    entry.count = count;
    entry.backdated = backdated;
    SyncMeta.stamp(entry);
    final toSave = entry;
    await _isar.writeTxn(() => _isar.customTaskEntrys.put(toSave));
    notifyListeners();
  }
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze`
Expected: only the 3 pre-existing lints, zero new issues.

Manually trace `complete()` against `entryFor()`: confirm the first call for a given `(taskUuid, periodKey)` takes the `entry ??= CustomTaskEntry()...` branch (creates), and a second call for the same pair finds the row `entryFor` just returned and updates it in place rather than creating a duplicate — `entryFor` filters on `taskUuidEqualTo` + `periodKeyEqualTo` + `syncDeletedAtIsNull`, and nothing about `complete()` ever soft-deletes an entry, so the second call's `entryFor` lookup will find the first call's row.

- [ ] **Step 3: Commit**

```bash
git add lib/services/custom_task_service.dart
git commit -m "Add CustomTaskService"
```

---

### Task 3: Screen — `CustomTasksScreen`

**Files:**
- Create: `lib/screens/custom_tasks_screen.dart`

**Interfaces:**
- Consumes: `CustomTaskService.instance` (Task 2); `CustomTask`, `CustomTaskEntry`, `CustomTaskFrequency`, `CustomTaskInputType`, `oneOffPeriodKey` (Task 1); `currentServiceDay([DateTime? now])` (`lib/models/opening_list.dart`); `currentServiceWeek([DateTime? now])` (`lib/models/weekly_tasks.dart`); `pickPersonAndDay(...)` and `PersonInitialsBadge` (`lib/screens/widgets/person_picker.dart`); `WhatsAppService.sendWithConfirm(context, msg)` (`lib/services/whatsapp_service.dart`); `AppColors` (`lib/theme.dart`).
- Produces: `class CustomTasksScreen extends StatefulWidget` with a `const CustomTasksScreen({super.key})` constructor — a complete, self-contained, working screen (not yet reachable from the UI; Task 4 wires up navigation).

- [ ] **Step 1: Write the screen**

Create `lib/screens/custom_tasks_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/custom_task.dart';
import '../models/opening_list.dart';
import '../models/weekly_tasks.dart';
import '../services/custom_task_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import 'widgets/person_picker.dart';

DateTime _periodKeyFor(CustomTaskFrequency frequency) {
  switch (frequency) {
    case CustomTaskFrequency.daily:
      return currentServiceDay();
    case CustomTaskFrequency.weekly:
      return currentServiceWeek();
    case CustomTaskFrequency.oneOff:
      return oneOffPeriodKey;
  }
}

class _TaskRow {
  _TaskRow({required this.task, required this.periodKey, this.entry});
  final CustomTask task;
  final DateTime periodKey;
  final CustomTaskEntry? entry;

  bool get done => entry?.done ?? false;
}

class CustomTasksScreen extends StatefulWidget {
  const CustomTasksScreen({super.key});

  @override
  State<CustomTasksScreen> createState() => _CustomTasksScreenState();
}

class _CustomTasksScreenState extends State<CustomTasksScreen> {
  late Future<List<_TaskRow>> _future;

  @override
  void initState() {
    super.initState();
    CustomTaskService.instance.addListener(_reload);
    _future = _load();
  }

  @override
  void dispose() {
    CustomTaskService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<List<_TaskRow>> _load() async {
    final svc = CustomTaskService.instance;
    final tasks = await svc.tasks();
    final rows = <_TaskRow>[];
    for (final t in tasks) {
      final periodKey = _periodKeyFor(t.frequency);
      final entry = await svc.entryFor(t.syncUuid, periodKey);
      rows.add(_TaskRow(task: t, periodKey: periodKey, entry: entry));
    }
    return rows;
  }

  Future<void> _sendMsg(String msg) async {
    if (!mounted) return;
    await WhatsAppService.sendWithConfirm(context, msg);
  }

  Future<void> _complete(_TaskRow row, {int? count}) async {
    final today = DateTime.now();
    final result = await pickPersonAndDay(
      context,
      title: 'Quem concluiu?',
      subtitle:
          '${row.task.title}\n\nDepois de concluída, não poderá ser desmarcada neste período.',
      initialDay: DateTime(today.year, today.month, today.day),
    );
    if (result == null) return;
    final who = result.person.fullName;

    late final DateTime targetPeriodKey;
    late final bool backdated;
    switch (row.task.frequency) {
      case CustomTaskFrequency.daily:
        targetPeriodKey = DateTime(
          result.day.year,
          result.day.month,
          result.day.day,
          5,
        );
        backdated = targetPeriodKey != row.periodKey;
      case CustomTaskFrequency.weekly:
        targetPeriodKey = currentServiceWeek(
          DateTime(result.day.year, result.day.month, result.day.day, 12),
        );
        backdated = targetPeriodKey != row.periodKey;
      case CustomTaskFrequency.oneOff:
        targetPeriodKey = oneOffPeriodKey;
        backdated = false;
    }

    await CustomTaskService.instance.complete(
      taskUuid: row.task.syncUuid,
      periodKey: targetPeriodKey,
      who: who,
      count: count,
      backdated: backdated,
    );
    final countSuffix = count == null ? '' : ' ($count)';
    _sendMsg('✅ Tarefa concluída: ${row.task.title}$countSuffix (por $who)');
  }

  Future<void> _confirmDelete(CustomTask task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover tarefa'),
        content: Text(
          'Queres remover "${task.title}"? O histórico não é apagado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await CustomTaskService.instance.deleteTask(task.syncUuid);
    }
  }

  Future<void> _openAddDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (_) => const _AddCustomTaskDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas Personalizadas'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _openAddDialog),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<_TaskRow>>(
          future: _future,
          builder: (_, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final rows = snap.data!;
            if (rows.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Sem tarefas personalizadas.\nUsa o + para adicionar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }
            final daily = rows
                .where((r) => r.task.frequency == CustomTaskFrequency.daily)
                .toList();
            final weekly = rows
                .where((r) => r.task.frequency == CustomTaskFrequency.weekly)
                .toList();
            final oneOff = rows
                .where((r) => r.task.frequency == CustomTaskFrequency.oneOff)
                .toList();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._section('Diárias', daily),
                ..._section('Semanais', weekly),
                ..._section('Pontuais', oneOff),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _section(String title, List<_TaskRow> rows) {
    if (rows.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
      ),
      for (final row in rows) _tileFor(row),
      const SizedBox(height: 8),
    ];
  }

  Widget _tileFor(_TaskRow row) {
    final by = row.entry?.doneBy ?? '';
    final byStr = by.isEmpty ? '' : ' (por $by)';
    if (row.task.inputType == CustomTaskInputType.count) {
      final count = row.entry?.count;
      final countStr = count == null ? '' : ' ($count)';
      return _CustomCountTile(
        key: ValueKey(row.task.syncUuid),
        row: row,
        onComplete: (count) => _complete(row, count: count),
        onDelete: () => _confirmDelete(row.task),
        onSendWhatsApp: row.done
            ? () => _sendMsg(
                '✅ Tarefa concluída: ${row.task.title}$countStr$byStr',
              )
            : null,
      );
    }
    return _CustomManualTile(
      key: ValueKey(row.task.syncUuid),
      row: row,
      onComplete: () => _complete(row),
      onDelete: () => _confirmDelete(row.task),
      onSendWhatsApp: row.done
          ? () => _sendMsg('✅ Tarefa concluída: ${row.task.title}$byStr')
          : null,
    );
  }
}

class _BackdatedNote extends StatelessWidget {
  const _BackdatedNote();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Preenchido a posteriori',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.history_toggle_off, size: 14, color: Colors.black45),
          SizedBox(width: 4),
          Text(
            'Preenchido a posteriori',
            style: TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class _CustomManualTile extends StatelessWidget {
  const _CustomManualTile({
    super.key,
    required this.row,
    required this.onComplete,
    required this.onDelete,
    this.onSendWhatsApp,
  });

  final _TaskRow row;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback? onSendWhatsApp;

  @override
  Widget build(BuildContext context) {
    final done = row.done;
    final by = row.entry?.doneBy ?? '';
    return GestureDetector(
      onLongPress: onSendWhatsApp,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: CheckboxListTile(
          value: done,
          onChanged: (v) {
            if (done) return;
            if (v == true) onComplete();
          },
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.green,
          title: Text(
            row.task.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: (done && row.entry!.backdated)
              ? const _BackdatedNote()
              : null,
          secondary: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (done && by.isNotEmpty) ...[
                PersonInitialsBadge(name: by),
                const SizedBox(width: 4),
              ],
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                tooltip: 'Remover tarefa',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomCountTile extends StatefulWidget {
  const _CustomCountTile({
    super.key,
    required this.row,
    required this.onComplete,
    required this.onDelete,
    this.onSendWhatsApp,
  });

  final _TaskRow row;
  final ValueChanged<int> onComplete;
  final VoidCallback onDelete;
  final VoidCallback? onSendWhatsApp;

  @override
  State<_CustomCountTile> createState() => _CustomCountTileState();
}

class _CustomCountTileState extends State<_CustomCountTile> {
  late final TextEditingController _countCtrl;

  @override
  void initState() {
    super.initState();
    final existing = widget.row.entry?.count;
    _countCtrl = TextEditingController(
      text: (existing == null || existing == 0) ? '' : '$existing',
    );
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final done = row.done;
    final by = row.entry?.doneBy ?? '';
    return GestureDetector(
      onLongPress: widget.onSendWhatsApp,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: CheckboxListTile(
          value: done,
          onChanged: (v) {
            if (done) return;
            if (v != true) return;
            final count = int.tryParse(_countCtrl.text) ?? 0;
            widget.onComplete(count);
          },
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.green,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  row.task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (done && by.isNotEmpty) ...[
                const SizedBox(width: 8),
                PersonInitialsBadge(name: by),
              ],
            ],
          ),
          subtitle: (done && row.entry!.backdated)
              ? const _BackdatedNote()
              : null,
          secondary: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _countCtrl,
                  enabled: !done,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                tooltip: 'Remover tarefa',
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCustomTaskDialog extends StatefulWidget {
  const _AddCustomTaskDialog();

  @override
  State<_AddCustomTaskDialog> createState() => _AddCustomTaskDialogState();
}

class _AddCustomTaskDialogState extends State<_AddCustomTaskDialog> {
  final _titleCtrl = TextEditingController();
  CustomTaskFrequency _frequency = CustomTaskFrequency.daily;
  CustomTaskInputType _inputType = CustomTaskInputType.simple;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Indica um título para a tarefa.');
      return;
    }
    await CustomTaskService.instance.addTask(
      title: title,
      frequency: _frequency,
      inputType: _inputType,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova tarefa'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Título',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Frequência',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<CustomTaskFrequency>(
              segments: const [
                ButtonSegment(
                  value: CustomTaskFrequency.daily,
                  label: Text('Diária'),
                ),
                ButtonSegment(
                  value: CustomTaskFrequency.weekly,
                  label: Text('Semanal'),
                ),
                ButtonSegment(
                  value: CustomTaskFrequency.oneOff,
                  label: Text('Pontual'),
                ),
              ],
              selected: {_frequency},
              onSelectionChanged: (sel) =>
                  setState(() => _frequency = sel.first),
            ),
            const SizedBox(height: 16),
            const Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<CustomTaskInputType>(
              segments: const [
                ButtonSegment(
                  value: CustomTaskInputType.simple,
                  label: Text('Simples'),
                ),
                ButtonSegment(
                  value: CustomTaskInputType.count,
                  label: Text('Com contagem'),
                ),
              ],
              selected: {_inputType},
              onSelectionChanged: (sel) =>
                  setState(() => _inputType = sel.first),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _create, child: const Text('Criar')),
      ],
    );
  }
}
```

- [ ] **Step 2: Verify**

Run: `flutter analyze`
Expected: only the 3 pre-existing lints, zero new issues.

Manually trace these flows against the spec:
- Creating a task via `_AddCustomTaskDialog` calls `CustomTaskService.instance.addTask`, which calls `notifyListeners()`; `_CustomTasksScreenState.initState` subscribed `_reload` to that same listener, so the list behind `_future` refreshes automatically — the dialog itself doesn't need to call `_reload()`.
- Completing a daily task on its own day: `pickPersonAndDay` returns `result.day == today`; `targetPeriodKey` is built as `DateTime(day.year, day.month, day.day, 5)`, which equals `row.periodKey` (`currentServiceDay()` for "now" during today's service day) — so `backdated` is `false`.
- Completing a daily task backdated to yesterday: `targetPeriodKey` is yesterday's 5am `DateTime`, which is `!=` today's `row.periodKey` — `backdated` is `true`, and `CustomTaskService.complete` creates a *new* entry keyed to yesterday (today's entry is untouched and stays undone).
- A one-off task's checkbox, once checked, can never be checked again for a "different period" — `_periodKeyFor` always returns the same `oneOffPeriodKey`, and `_complete`'s `oneOff` case always targets `oneOffPeriodKey` too, so there's exactly one entry, ever.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/custom_tasks_screen.dart
git commit -m "Add CustomTasksScreen"
```

---

### Task 4: Wire up navigation

**Files:**
- Modify: `lib/screens/home_screen.dart:10-21` (import), `lib/screens/home_screen.dart:253-261` (nav button)

**Interfaces:**
- Consumes: `CustomTasksScreen` (Task 3).
- Produces: nothing further downstream — this is the last task.

- [ ] **Step 1: Add the import**

Modify `lib/screens/home_screen.dart`. Add, alphabetically among the existing screen imports (after `'daily_tasks_screen.dart'`, before `'dashboard_screen.dart'`):

```dart
import 'custom_tasks_screen.dart';
```

- [ ] **Step 2: Add the nav button**

In the same file, insert a new `_NavButton` right after the existing "Tarefas Semanais" button and before "Estatísticas" (currently `lib/screens/home_screen.dart:253-261`):

```dart
                  _NavButton(
                    icon: Icons.event_repeat,
                    label: 'Tarefas Semanais',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WeeklyTasksScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.playlist_add_check,
                    label: 'Tarefas Personalizadas',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CustomTasksScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.insights,
                    label: 'Estatísticas',
```

- [ ] **Step 3: Verify**

Run: `flutter analyze`
Expected: only the 3 pre-existing lints, zero new issues — confirms `CustomTasksScreen` resolves and the new button compiles.

Manually confirm by reading the file: `HomeScreen`'s button grid now has a "Tarefas Personalizadas" tile between "Tarefas Semanais" and "Estatísticas", following the exact same `_NavButton(icon:..., label:..., onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const XScreen())))` shape as every other tile in that grid.

This is the last task in the plan — also re-run `flutter analyze` once more here as the whole-feature check (models + service + screen + navigation together), confirming the full vertical slice (Task 1 → Task 4) compiles clean end to end.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "Add Tarefas Personalizadas entry to home screen"
```
