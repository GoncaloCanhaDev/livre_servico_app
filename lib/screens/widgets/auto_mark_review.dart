import 'package:flutter/material.dart';

import '../../models/auto_mark.dart';
import '../../models/custom_task.dart';
import '../../models/daily_tasks.dart';
import '../../models/not_done.dart';
import '../../models/weekly_tasks.dart';
import '../../services/server_clock.dart';
import '../../services/custom_task_service.dart';
import '../../services/daily_tasks_service.dart';
import '../../services/weekly_tasks_service.dart';
import 'auto_mark_note.dart';
import 'person_picker.dart';
import 'task_markers.dart';

/// How a reviewer settles an automatic mark: who confirmed, the people
/// who really did it, or why it wasn't done. Null when cancelled.
sealed class _Outcome {}

class _Confirmed extends _Outcome {
  _Confirmed(this.by);
  final List<String> by;
}

class _Changed extends _Outcome {
  _Changed(this.who);
  final List<String> who;
}

class _NotDone extends _Outcome {
  _NotDone(this.notDone);
  final NotDone notDone;
}

Future<_Outcome?> _ask(
  BuildContext context, {
  required String label,
  required List<String> names,
  required DateTime day,
}) async {
  final action = await reviewAutoMark(context, taskName: label, names: names);
  if (action == null || !context.mounted) return null;
  switch (action) {
    case AutoMarkAction.confirm:
      final by = await confirmerNames(context);
      return by == null ? null : _Confirmed(by);
    case AutoMarkAction.change:
      final people = await pickPeople(
        context,
        title: 'Quem fez?',
        subtitle: label,
      );
      return people == null
          ? null
          : _Changed([for (final p in people) p.fullName]);
    case AutoMarkAction.notDone:
      final date = DateTime(day.year, day.month, day.day);
      final picked = await pickNotDone(
        context,
        taskName: label,
        initialDay: date,
        selectableDayPredicate: (d) =>
            d.year == date.year && d.month == date.month && d.day == date.day,
      );
      if (picked == null) return null;
      final (result, reason) = picked;
      return _NotDone(
        NotDone(
          byNames: [for (final p in result.people) p.fullName],
          reason: reason,
          at: ServerClock.now(),
        ),
      );
  }
}

AutoMark _confirmed(AutoMark m, List<String> by) =>
    AutoMark(at: m.at, confirmedByNames: by, confirmedAt: DateTime.now());

/// Reviews the automatic mark of [key] on the Diárias row [t] and saves it.
Future<void> reviewDailyMark(
  BuildContext context,
  DailyTasks t,
  String key,
  String label,
) async {
  final mark = t.autoMarks[key];
  if (mark == null) return;
  final outcome = await _ask(
    context,
    label: label,
    names: dailyNames(t, key),
    day: t.serviceDay,
  );
  switch (outcome) {
    case null:
      return;
    case _Confirmed(:final by):
      t.autoMarks = {...t.autoMarks, key: _confirmed(mark, by)};
    case _Changed(:final who):
      setDailyDone(t, key, who);
      t.autoMarks = {...t.autoMarks}..remove(key);
    case _NotDone(:final notDone):
      setDailyDone(t, key, const [], done: false);
      t.autoMarks = {...t.autoMarks}..remove(key);
      t.notDone = {...t.notDone, key: notDone};
      // A Validades window not done still counts its artigos.
      if (key == 'alteracoes_preco' || key == 'lista_visivel') {
        t.pendingCounts = [...t.pendingCounts]..remove(key);
      }
  }
  await DailyTasksService.instance.save(t, edited: key);
}

/// Reviews the automatic mark of [key] on the Semanais row [t].
Future<void> reviewWeeklyMark(
  BuildContext context,
  WeeklyTasks t,
  String key,
  String label,
  DateTime day,
) async {
  final mark = t.autoMarks[key];
  if (mark == null) return;
  final outcome = await _ask(
    context,
    label: label,
    names: weeklyNames(t, key),
    day: day,
  );
  switch (outcome) {
    case null:
      return;
    case _Confirmed(:final by):
      t.autoMarks = {...t.autoMarks, key: _confirmed(mark, by)};
    case _Changed(:final who):
      setWeeklyDone(t, key, who);
      t.autoMarks = {...t.autoMarks}..remove(key);
    case _NotDone(:final notDone):
      setWeeklyDone(t, key, const [], done: false);
      t.autoMarks = {...t.autoMarks}..remove(key);
      t.notDone = {...t.notDone, key: notDone};
      t.pendingCounts = [...t.pendingCounts]..remove(key);
  }
  await WeeklyTasksService.instance.save(t, edited: key);
}

/// Reviews the automatic mark of a custom task's [entry].
Future<void> reviewCustomMark(
  BuildContext context,
  CustomTaskEntry entry,
  String title,
  DateTime day,
) async {
  final mark = entry.autoMark;
  if (mark == null) return;
  final outcome = await _ask(
    context,
    label: title,
    names: resolveNames(entry.doneByNames, entry.doneBy),
    day: day,
  );
  switch (outcome) {
    case null:
      return;
    case _Confirmed(:final by):
      entry.autoMark = _confirmed(mark, by);
    case _Changed(:final who):
      entry
        ..doneByNames = who
        ..autoMark = null;
    case _NotDone(:final notDone):
      entry
        ..done = false
        ..doneByNames = []
        ..autoMark = null
        ..notDone = notDone;
  }
  await CustomTaskService.instance.saveEntry(entry);
}
