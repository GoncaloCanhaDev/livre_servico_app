# Tarefas marcadas sozinhas — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** After a task's time window closes, the app marks it done by the Livre Serviço people
who worked during it; level 2+ confirm or correct it; Chefes edit the windows.

**Architecture:** Automatic marks live in the existing task rows (done flag + names + an
`AutoMark` note per task key). Windows are a new synced collection `TaskWindow` with defaults in
code. `AutoMarkService.run(now)` does the marking, from pure helpers in
`lib/models/auto_mark.dart`.

**Tech Stack:** Flutter, Drift `LocalDb` JSON rows, existing sync engine (no server change).

**Spec:** `docs/superpowers/specs/2026-11-19-auto-task-marking-design.md`

## Global Constraints

- Every save through `SyncMeta.stamp` (the services' `save`); never remove rows for good.
- New JSON fields in both `toJson` and `fromJson`; never rename stored fields.
- UI strings in Portuguese (pt_PT); colours through the `context` helpers.
- Only Livre Serviço people (`Person.team == livreServicoId`) are credited.
- Version 0.95.0+224, CHANGELOG, `releaseNotes`, tutorial `tarefas` version 5, CLAUDE.md.
- Verify with `flutter analyze` and `flutter test -j 2`; no APK builds.

## Review Focus

- A window crossing midnight (Validades Noite 19:00–05:00): the span ends the next date at 05:00
  and a night shift from the day before counts — test in Task 2.
- A task marked by hand (feita or não feita) before the run is never touched — Task 3.
- No Livre Serviço person working → no mark, task stays pending — Task 2/3.
- `autoMarkSince` keeps history from before the version untouched — Task 3.
- While connected to a store, no run before the first sync of the session — Task 3.

---

### Task 1: Models (TaskWindow, AutoMark, new fields)

**Files:**
- Create: `lib/models/task_window.dart`, `lib/models/auto_mark.dart` (AutoMark class part)
- Modify: `lib/models/daily_tasks.dart`, `lib/models/weekly_tasks.dart`,
  `lib/models/custom_task.dart`, `lib/services/local_db.dart`
- Test: `test/task_window_test.dart`, `test/local_db_test.dart`

**Produces:**
- `class TaskWindow with SyncFields { String taskKey; int opensAt; int closesAt; bool auto; }`
  (minutes after midnight); `LocalDb.taskWindows` (`'TaskWindow'`, `syncKey: (w) => w.taskKey`).
- `const fixedDailyTaskKeys`, `const fixedWeeklyTaskKeys`, `taskDueWeekday` (limpeza → Saturday,
  verificar_1a/4a → Tuesday), `TaskWindow defaultTaskWindow(String key)` (table in the spec;
  any other key 05:00–05:00), `({DateTime start, DateTime end}) windowSpan(TaskWindow w,
  DateTime serviceDay)`: a minute before 05:00 (incl. 05:00 as a close) is on the next date.
- `class AutoMark { DateTime at; List<String> confirmedByNames; DateTime? confirmedAt; bool get
  confirmed; }` with JSON; `autoMarks` map + `pendingCounts` list on `DailyTasks`/`WeeklyTasks`;
  `CustomTaskEntry.autoMark`.

- [ ] Tests: `windowSpan` for Kiwi Fecho (19:00–22:00 same date), Validades Noite (end next date
  05:00), Alterações (05:00–07:30); round-trip of the new fields.
- [ ] Implement; run `flutter test test/task_window_test.dart test/local_db_test.dart`.

### Task 2: Who is credited, and marking a row

**Files:** `lib/models/auto_mark.dart`; Test: `test/auto_mark_test.dart`

**Produces:**
- `List<String> autoMarkPeople(List<Person> people, ({DateTime start, DateTime end}) span,
  {HorarioIndex? horario})` — LS people whose working span (each date from `span.start`−1 day to
  `span.end`, skipping `offLabelOn` days) overlaps; full names by earliest overlap shift start,
  then name.
- `bool dailySettled(DailyTasks t, String key)`, `void markDaily(DailyTasks t, String key,
  List<String> who)` (flag + names; count keys also go in `pendingCounts`, Validades adds
  `'$key:left'`), `void unmarkDaily(DailyTasks t, String key)`; same `weekly*` for WeeklyTasks.
- Tests: overlap, no overlap, night shift from day before, folga, other team, empty list.

### Task 3: TaskWindowService, AutoMarkService, access

**Files:** create `lib/services/task_window_service.dart`, `lib/services/auto_mark_service.dart`;
modify `lib/services/sync_service.dart` (reset `lastSyncedAt` on `start`),
`lib/services/settings_service.dart` (`autoMarkSince`), `lib/models/store_access.dart`
(`canConfirmTasks` = admin || level ≥ 2, `canEditTaskWindows` = admin || level ≥ 3),
`lib/main.dart` (`AutoMarkService.instance.start()` after `HorarioService.load`),
`lib/models/validades.dart` (`validadesStateAt(turno, now, {TaskWindow? window})`).
Test: `test/auto_mark_service_test.dart`.

**Produces:**
- `TaskWindowService.instance.windowFor(key) → TaskWindow` (row or default, cached in memory,
  `load()`), `save(TaskWindow)`, `reset(key)`, `all`.
- `AutoMarkService.instance.run(DateTime now) → Future<int>` (marks made), `start()` (run now,
  on resume, every minute, after each SyncService sync), `unconfirmed() → Future<int>` (last 7
  days), `canRun` (not connected, or synced this session).
- Tests: marks after close only; skips settled; `auto` off; `autoMarkSince`; nobody working;
  weekly on due day; custom daily; custom weekly after the week ends; one-off never.

### Task 4: Tarefas UI

**Files:** create `lib/screens/widgets/auto_mark_note.dart`; modify the three task tabs.
Test: `test/auto_mark_tasks_test.dart`.

- `AutoMarkNote(mark, onReview)` (orange "Automática · por confirmar" / muted "Automática ·
  confirmada por X") and `reviewAutoMark(context) → AutoMarkAction?` {confirm, change, notDone}
  for `canConfirmTasks`. Change → `pickPeople`, manual (AutoMark removed); Não feita →
  `pickNotDone`, flag cleared; confirm → linked person's name (or `pickPeople` when none).
- Count fields stay editable while the key is in `pendingCounts` ("Número por preencher");
  filling removes it. Manual mark with an empty field adds the key. Validades `':left'` shows
  "Falta dizer quantos ficaram" → `askValidadesLeft` → carry.
- Test: an auto-marked Kiwi Abertura shows the tag and Confirmar works.

### Task 5: Definições → Horas das tarefas

**Files:** create `lib/screens/task_windows_screen.dart`; modify `settings_screen.dart`.
One tile per task (fixed and custom non-one-off), times via `showTimePicker`, auto switch,
Repor. Test in `test/auto_mark_tasks_test.dart`: opens, toggles auto.

### Task 6: Home, Histórico, demo, docs, version

- Home `AutoMarksCard` (count > 0, `canConfirmTasks`) → TasksScreen.
- Histórico Diárias/Semanais: "· automática" beside names.
- `seedDemo`: two auto marks (one confirmed) and a pending count.
- Tutorial `tarefas` v5 step; `releaseNotes` 0.95.0; CHANGELOG; CLAUDE.md; version
  0.95.0+224 in pubspec and `appVersion`; spec + plan in the commit; tag v0.95.0.
