import 'dart:async';

import 'package:flutter/widgets.dart';

import '../models/auto_mark.dart';
import '../models/custom_task.dart';
import '../models/daily_tasks.dart';
import '../models/opening_list.dart';
import '../models/task_window.dart';
import '../models/weekly_tasks.dart';
import 'account_service.dart';
import 'custom_task_service.dart';
import 'daily_tasks_service.dart';
import 'horario_service.dart';
import 'local_db.dart';
import 'person_service.dart';
import 'server_clock.dart';
import 'settings_service.dart';
import 'sync_service.dart';
import 'task_window_service.dart';
import 'weekly_tasks_service.dart';

/// Marks a task done by itself once its window (see [TaskWindow]) closed
/// and nobody marked it: by the Livre Serviço people working during it
/// ([autoMarkPeople]), with an [AutoMark] so level 2 and up can confirm or
/// correct it. Runs while the app is open (at start, on resume, every
/// minute and after each sync); with a store connected, only once a sync of
/// this session finished, so stale rows never overwrite marks from another
/// phone.
class AutoMarkService extends ChangeNotifier with WidgetsBindingObserver {
  AutoMarkService._();
  static final AutoMarkService instance = AutoMarkService._();

  /// How far back a run looks for windows nobody marked.
  static const catchUpDays = 7;

  Timer? _timer;
  DateTime? _lastSync;
  Future<int>? _running;

  /// Starts the runs (from `main()`).
  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => runNow());
    WidgetsBinding.instance.addObserver(this);
    SyncService.instance.addListener(_onSync);
    // The access arrives after start: a Chefe's phone may then run.
    AccountService.instance.addListener(_onAccess);
    runNow();
  }

  void _onAccess() => runNow();

  void _onSync() {
    final at = SyncService.instance.lastSyncedAt;
    if (at != null && at != _lastSync) {
      _lastSync = at;
      runNow();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) runNow();
  }

  /// Whether a run may write: on a phone that sees everyone's schedule
  /// (`StoreAccess.canAutoMark`; signed out, every phone), signed out or
  /// after a sync of this session.
  bool get canRun =>
      AccountService.instance.access.canAutoMark &&
      (!SyncService.instance.isConnected ||
          SyncService.instance.lastSyncedAt != null);

  /// When the last run finished, how many tasks it marked and, if it
  /// failed, why (Diagnóstico).
  DateTime? lastRunAt;
  int lastRunMarked = 0;
  Object? lastRunError;

  /// How many tasks the runs of this session marked.
  int markedThisSession = 0;

  Future<int> runNow() async {
    if (!canRun) return 0;
    return _running ??= _tracked().whenComplete(() => _running = null);
  }

  Future<int> _tracked() async {
    try {
      final marked = await run(DateTime.now());
      lastRunMarked = marked;
      markedThisSession += marked;
      lastRunError = null;
      return marked;
    } catch (e) {
      lastRunError = e;
      rethrow;
    } finally {
      lastRunAt = DateTime.now();
    }
  }

  /// Marks every task whose window closed before [now], from [catchUpDays]
  /// back, but none that closed before `SettingsService.autoMarkSince` (the
  /// first run here). The marks carry the server's time ([ServerClock]).
  /// Returns how many it marked.
  Future<int> run(DateTime now) async {
    final settings = SettingsService.instance;
    final today = currentServiceDay(now);
    var since = settings.autoMarkSince;
    if (since == null) {
      since = now;
      await settings.setAutoMarkSince(now);
    }
    var first = DateTime(today.year, today.month, today.day - catchUpDays, 5);
    final sinceDay = currentServiceDay(since);
    if (first.isBefore(sinceDay)) first = sinceDay;
    final stampAt = ServerClock.now();
    // Closed, and after the first run.
    bool due(({DateTime start, DateTime end}) span) =>
        !span.end.isAfter(now) && !span.end.isBefore(since!);

    final people = await PersonService.instance.all();
    final horario = HorarioService.instance.index;
    final windows = TaskWindowService.instance;
    List<String> who(({DateTime start, DateTime end}) span) =>
        autoMarkPeople(people, span, horario: horario);
    final customs = await CustomTaskService.instance.tasks();
    var marked = 0;

    for (
      var day = first;
      !day.isAfter(today);
      day = DateTime(day.year, day.month, day.day + 1, 5)
    ) {
      // Diárias (a row is only created when something gets marked).
      final daily =
          await DailyTasksService.instance.find(day) ??
          (DailyTasks()..serviceDay = day);
      var dailyChanged = false;
      for (final key in fixedDailyTaskKeys) {
        final w = windows.windowFor(key);
        final span = windowSpan(w, day);
        if (!w.auto || !due(span)) continue;
        if (dailySettled(daily, key)) continue;
        final names = who(span);
        if (names.isEmpty) continue;
        autoMarkDaily(daily, key, names, stampAt);
        dailyChanged = true;
        marked++;
      }
      if (dailyChanged) await DailyTasksService.instance.save(daily);

      // Semanais, on their weekday.
      final week = currentServiceWeek(day);
      for (final key in fixedWeeklyTaskKeys) {
        if (taskDueWeekday[key] != day.weekday) continue;
        final w = windows.windowFor(key);
        final span = windowSpan(w, day);
        if (!w.auto || !due(span)) continue;
        final weekly =
            await _weekly(week) ?? (WeeklyTasks()..serviceWeek = week);
        if (weeklySettled(weekly, key)) continue;
        final names = who(span);
        if (names.isEmpty) continue;
        autoMarkWeekly(weekly, key, names, stampAt);
        await WeeklyTasksService.instance.save(weekly);
        marked++;
      }

      // Custom daily tasks; weekly ones once their week ended (on its
      // last day, Sunday).
      for (final task in customs) {
        final ({DateTime start, DateTime end}) span;
        final DateTime periodKey;
        switch (task.frequency) {
          case CustomTaskFrequency.oneOff:
            continue;
          case CustomTaskFrequency.daily:
            final w = windows.windowFor(task.syncUuid);
            if (!w.auto) continue;
            span = windowSpan(w, day);
            periodKey = day;
          case CustomTaskFrequency.weekly:
            if (day.weekday != DateTime.sunday) continue;
            if (!windows.windowFor(task.syncUuid).auto) continue;
            span = (start: week, end: week.add(const Duration(days: 7)));
            periodKey = week;
        }
        if (!due(span)) continue;
        // Not for periods before the task existed.
        if (task.createdAt.isAfter(span.end)) continue;
        final entry = await CustomTaskService.instance.entryFor(
          task.syncUuid,
          periodKey,
        );
        if (entry != null && (entry.done || entry.notDone != null)) continue;
        final names = who(span);
        if (names.isEmpty) continue;
        await CustomTaskService.instance.autoComplete(
          taskUuid: task.syncUuid,
          periodKey: periodKey,
          who: names,
          at: stampAt,
        );
        marked++;
      }
    }
    if (marked > 0) notifyListeners();
    return marked;
  }

  Future<WeeklyTasks?> _weekly(DateTime week) => LocalDb.instance.weeklyTasks
      .firstWhere((t) => t.serviceWeek.isAtSameMomentAs(week));

  /// The automatic marks of the last [catchUpDays] days nobody confirmed
  /// yet, newest first: Home counts them, `AutoMarksScreen` lists them.
  Future<List<UnconfirmedMark>> unconfirmedMarks({DateTime? now}) async {
    final today = currentServiceDay(now);
    final from = DateTime(today.year, today.month, today.day - catchUpDays, 5);
    final weekFrom = currentServiceWeek(from);
    final db = LocalDb.instance;
    final found = <UnconfirmedMark>[];
    for (final t in await db.dailyTasks.where(
      (t) => !t.serviceDay.isBefore(from) && t.autoMarks.isNotEmpty,
    )) {
      for (final MapEntry(:key, :value) in t.autoMarks.entries) {
        if (value.confirmed) continue;
        found.add(
          UnconfirmedMark(
            day: t.serviceDay,
            label: fixedTaskLabels[key] ?? key,
            names: dailyNames(t, key),
            key: key,
            daily: t,
          ),
        );
      }
    }
    for (final t in await db.weeklyTasks.where(
      (t) => !t.serviceWeek.isBefore(weekFrom) && t.autoMarks.isNotEmpty,
    )) {
      for (final MapEntry(:key, :value) in t.autoMarks.entries) {
        if (value.confirmed) continue;
        found.add(
          UnconfirmedMark(
            day: t.serviceWeek.add(
              Duration(days: (taskDueWeekday[key] ?? DateTime.monday) - 1),
            ),
            label: fixedTaskLabels[key] ?? key,
            names: weeklyNames(t, key),
            key: key,
            weekly: t,
          ),
        );
      }
    }
    final titles = {
      for (final t in await CustomTaskService.instance.tasks())
        t.syncUuid: t.title,
    };
    for (final e in await db.customTaskEntries.where(
      (e) =>
          e.autoMark != null &&
          !e.autoMark!.confirmed &&
          !e.periodKey.isBefore(weekFrom),
    )) {
      final title = titles[e.taskUuid];
      if (title == null) continue; // the task was removed
      found.add(
        UnconfirmedMark(
          day: e.periodKey,
          label: title,
          names: e.doneByNames,
          key: e.taskUuid,
          entry: e,
        ),
      );
    }
    found.sort((a, b) => b.day.compareTo(a.day));
    return found;
  }

  /// How many [unconfirmedMarks] there are.
  Future<int> unconfirmed({DateTime? now}) async =>
      (await unconfirmedMarks(now: now)).length;

  /// Stops the runs (tests).
  @visibleForTesting
  void stop() {
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
    SyncService.instance.removeListener(_onSync);
    AccountService.instance.removeListener(_onAccess);
  }
}

/// An automatic mark waiting for level 2 and up to confirm it: on a
/// Diárias row ([daily]), a Semanais row ([weekly]) or a custom task's
/// [entry], by its task [key].
class UnconfirmedMark {
  UnconfirmedMark({
    required this.day,
    required this.label,
    required this.names,
    required this.key,
    this.daily,
    this.weekly,
    this.entry,
  });

  /// The service day it belongs to (a Semanal's weekday, a custom weekly
  /// task's Monday).
  final DateTime day;
  final String label;
  final List<String> names;
  final String key;
  final DailyTasks? daily;
  final WeeklyTasks? weekly;
  final CustomTaskEntry? entry;
}
