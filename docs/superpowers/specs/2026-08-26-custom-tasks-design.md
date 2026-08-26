# Custom Tasks — Design Spec

Date: 2026-08-26

## Problem

The app's checklists (`DailyTasks`, `WeeklyTasks`) are fixed-schema: every
task is a hardcoded field on a wide Isar row, added by editing the model and
regenerating code. The supervisor using the app wants to add their own
ad-hoc checklist items — things this codebase doesn't know about in
advance — choose how each one repeats, and remove one later if it's no
longer needed.

## Scope

**In scope:**
- A user can create a custom task: a title, a frequency (daily / weekly /
  one-off), and an input type (simple checkbox / checkbox + number count).
- Custom tasks appear on their own screen, grouped by frequency, and reset
  on the same day/week boundary the rest of the app already uses
  (`currentServiceDay`, `currentServiceWeek`).
- Completing a task asks "who completed it" (reusing `pickPersonAndDay`),
  locks once checked for that period, and supports backdating to an earlier
  day, same as every other task in the app.
- Completing a task can send a WhatsApp message via the existing
  `WhatsAppService.sendWithConfirm` long-press pattern.
- A user can remove a custom task (soft delete — it stops appearing, past
  completions stay in the database, consistent with every other delete in
  this app).

**Out of scope (explicitly deferred, not silently dropped):**
- No `TaskTimer` integration (no start/stop timer badge on custom tasks).
- Custom tasks do **not** feed the Dashboard's daily-completion stats,
  weekday charts, or missed-day/justification tracking — those stay scoped
  to the existing fixed 10 daily / 3 weekly tasks.
- No editing an existing task's title/frequency/input type after creation —
  only add and remove. (If a task needs to change, remove it and add a new
  one.)
- No reordering/drag-to-sort — tasks list in creation order within their
  frequency section.

## Data model

Two new Isar collections, in `lib/models/custom_task.dart`, following this
codebase's existing sync-field convention (`syncUuid`, `syncUpdatedAt`,
`syncDeletedAt`, `synced`, stamped/soft-deleted via `SyncMeta`).

```dart
enum CustomTaskFrequency { daily, weekly, oneOff }
enum CustomTaskInputType { simple, count }

@collection
class CustomTask {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = ...;
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
  DateTime syncUpdatedAt = ...;
  DateTime? syncDeletedAt;
  bool synced = true;

  /// The CustomTask.syncUuid this entry belongs to.
  @Index()
  late String taskUuid;

  /// The service day (daily), the service week's Monday (weekly), or a
  /// fixed epoch constant (one-off, which never resets — one entry ever).
  @Index()
  late DateTime periodKey;

  bool done = false;
  String? doneBy;
  int? count; // only meaningful when the task's inputType is `count`
  DateTime? doneAt;
  bool backdated = false;
}
```

Rationale for two collections instead of one wide row per period (like
`DailyTasks`): the set of custom tasks is open-ended and user-defined, so a
wide row with one column per task doesn't work. `CustomTaskEntry` mirrors
the existing `VisualList`/`InventoryLine` pattern of one lightweight row per
occurrence instead.

One-off tasks use a fixed constant `periodKey`
(`DateTime.fromMillisecondsSinceEpoch(0)`) so the existing
"find-or-create the entry for this period" logic doesn't need a separate
code path for "never resets" — it's just a period that only ever has one
value.

Both schemas are registered in `ShiftService.init()`'s `Isar.open` schema
list, next to the other collections.

## Service layer

New `lib/services/custom_task_service.dart`, `CustomTaskService` (singleton,
`ChangeNotifier`, same shape as `PersonService`):

- `tasks()` → non-deleted `CustomTask`s, sorted by `createdAt`.
- `addTask({title, frequency, inputType})` → creates + saves a `CustomTask`.
- `deleteTask(uuid)` → soft-deletes the `CustomTask` (does **not** touch its
  entries — history stays queryable if ever needed).
- `entryFor(taskUuid, periodKey)` → the matching `CustomTaskEntry`, or
  `null` if that period hasn't been touched yet (read as "not done").
- `complete({task, periodKey, who, count, backdated})` → finds-or-creates
  the entry for `(taskUuid, periodKey)`, sets `done = true`, `doneBy`,
  `doneAt = DateTime.now()`, `count`, `backdated`; saves; notifies
  listeners.

Period-key helpers live alongside the screen (not the service): for
`daily`, `currentServiceDay()`; for `weekly`, `currentServiceWeek()`; for
`oneOff`, the fixed constant — mirroring how `daily_tasks_screen.dart` and
`weekly_tasks_screen.dart` already compute these locally rather than in
their services.

## Screen

New `lib/screens/custom_tasks_screen.dart`, `CustomTasksScreen`, reached
from `HomeScreen` the same way `DailyTasksScreen`/`WeeklyTasksScreen` are
(a new tile below "Tarefas Semanais").

Layout: a single scrollable list with three sections — "Diárias",
"Semanais", "Pontuais" — each showing that frequency's non-deleted tasks
for the current period. Empty state per section: nothing rendered (no
"section with 0 items" clutter) unless every section is empty, in which
case a single centered "Sem tarefas personalizadas. Usa o + para
adicionar." message, matching `_emptyMsg` in `historico_screen.dart`.

Each task renders as one of two tile widgets (visually identical to
`_ManualTask`/`_CountTask` in `daily_tasks_screen.dart`, minus the
`TaskTimerControl` row):
- `_CustomManualTile` — checkbox + title.
- `_CustomCountTile` — checkbox + title + number field, same
  `TextEditingController` pattern as the existing count tasks.

Tapping an unchecked checkbox opens `pickPersonAndDay` ("Quem concluiu?"),
same subtitle convention ("Depois de concluída, não poderá ser
desmarcada..."). If the picked day maps to the current period, complete in
place; otherwise resolve/create the entry for that other period and mark
`backdated = true`, matching `_completeTask` in `daily_tasks_screen.dart`.
A completed+backdated tile shows the existing `_BackdatedNote` widget.

Long-press on a completed tile shows the WhatsApp send option (same
bottom-sheet pattern as `_HistoryDismissible` in `historico_screen.dart`):
`✅ Tarefa concluída: <title>` (+ ` (<count>)` when `inputType == count`,
+ ` (por <who>)`).

**Adding a task:** a `+` `IconButton` in the `AppBar` opens a `showDialog`
form: a text field (title, required, non-empty after trim), a
`SegmentedButton<CustomTaskFrequency>` (Diária / Semanal / Pontual), a
`SegmentedButton<CustomTaskInputType>` (Simples / Com contagem). "Criar"
calls `CustomTaskService.instance.addTask(...)` and pops.

**Removing a task:** each tile's trailing area (the `secondary` slot of its
`CheckboxListTile`, the same slot the existing tiles use for the initials
badge) holds a small trash `IconButton` alongside the initials badge when
one is showing. Tapping it opens a confirm dialog ("Remover tarefa? Queres
remover '<title>'? O histórico não é apagado." / Cancelar / Remover)
matching `_confirmDelete` in `historico_screen.dart`, then calls
`deleteTask`. This is a plain tap, independent of the long-press-to-send
WhatsApp gesture on completed tiles.

## Testing approach

No automated test suite exists in this repo (per `CLAUDE.md`) — verified
via `flutter analyze` plus manual reasoning through the flows above, same
as the rest of this codebase's change process. If UI verification via a
running app becomes possible in this environment, exercise: create a daily
+ a count-weekly + a one-off task; complete one of each (including a
backdated one); confirm the WhatsApp long-press message; remove a task and
confirm it disappears but doesn't error on next launch (soft-delete
respected everywhere `tasks()` is read).
