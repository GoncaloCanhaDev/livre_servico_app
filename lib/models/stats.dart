import 'package:intl/intl.dart';

import 'auto2_entry.dart';
import 'auto_mark.dart';
import 'custom_task.dart';
import 'daily_tasks.dart';
import 'inventory.dart';
import 'names.dart';
import 'opening_list.dart';
import 'pedido.dart';
import 'task_window.dart';
import 'truck_reception.dart';
import 'visivel2_entry.dart';
import 'weekly_tasks.dart';

/// Estatísticas look at a service week (Monday to Sunday) or a month.
enum StatsPeriodKind { week, month }

/// The service days [start] (05:00) up to [end] (05:00, not included).
class StatsPeriod {
  StatsPeriod._(this.kind, this.start, this.end);

  /// The week or the month holding the service day of [now].
  factory StatsPeriod.containing(StatsPeriodKind kind, DateTime now) {
    final day = currentServiceDay(now);
    switch (kind) {
      case StatsPeriodKind.week:
        final monday = currentServiceWeek(now);
        return StatsPeriod._(
          kind,
          monday,
          DateTime(monday.year, monday.month, monday.day + 7, 5),
        );
      case StatsPeriodKind.month:
        return StatsPeriod._(
          kind,
          DateTime(day.year, day.month, 1, 5),
          DateTime(day.year, day.month + 1, 1, 5),
        );
    }
  }

  final StatsPeriodKind kind;
  final DateTime start;
  final DateTime end;

  StatsPeriod get previous => StatsPeriod.containing(
    kind,
    DateTime(start.year, start.month, start.day - 1, 12),
  );

  StatsPeriod get next =>
      StatsPeriod.containing(kind, DateTime(end.year, end.month, end.day, 12));

  /// Whether the service day [day] (any time in it) belongs here. [start]
  /// and [end] are both 05:00, so comparing [day] itself is the same as
  /// comparing its service day, without building a date per row.
  bool holds(DateTime day) => !day.isBefore(start) && day.isBefore(end);

  /// Its service days, at 05:00.
  List<DateTime> get days => [
    for (
      var d = start;
      d.isBefore(end);
      d = DateTime(d.year, d.month, d.day + 1, 5)
    )
      d,
  ];

  /// "16 a 22 de novembro", "30 de dezembro a 5 de janeiro" or
  /// "Novembro de 2026".
  String get label {
    switch (kind) {
      case StatsPeriodKind.month:
        final m = DateFormat("MMMM 'de' y", 'pt_PT').format(start);
        return '${m[0].toUpperCase()}${m.substring(1)}';
      case StatsPeriodKind.week:
        final last = days.last;
        final dayMonth = DateFormat("d 'de' MMMM", 'pt_PT');
        if (start.month == last.month) {
          return '${start.day} a ${dayMonth.format(last)}';
        }
        return '${dayMonth.format(start)} a ${dayMonth.format(last)}';
    }
  }
}

/// How one task went over the period: each time it was due, marked done
/// by hand, done by the app ([auto]), não feita, or left with no mark
/// once its hours were over ([unmarked]).
class TaskStat {
  TaskStat(this.key, this.label);

  final String key;
  final String label;
  int byHand = 0;
  int auto = 0;
  int notDone = 0;
  int unmarked = 0;

  int get done => byHand + auto;
  int get due => done + notDone + unmarked;

  /// Done out of due, or null when it was never due.
  double? get rate => due == 0 ? null : done / due;
}

/// The Diárias of one service day: how many were due and done.
class DayStat {
  DayStat(this.day);

  final DateTime day;
  int done = 0;
  int due = 0;

  double? get rate => due == 0 ? null : done / due;
}

/// What one person did in the period, by the names on the rows.
class PersonStat {
  PersonStat(this.name);

  final String name;

  /// Tasks marked done by hand with their name.
  int tasks = 0;

  /// Tasks the app marked with their name (from the horário).
  int autoTasks = 0;
  int auto2 = 0;
  int visivel = 0;
  int trucks = 0;
  int inventories = 0;

  int get total => tasks + autoTasks + auto2 + visivel + trucks + inventories;
}

/// A task marked não feita, with why.
class NotDoneNote {
  NotDoneNote({
    required this.day,
    required this.label,
    required this.reason,
    required this.byNames,
  });

  final DateTime day;
  final String label;
  final String reason;
  final List<String> byNames;
}

/// One Listas 2.0 Automáticas item over the period.
class Auto2ItemStat {
  Auto2ItemStat(this.label);

  final String label;
  int sends = 0;
  int value = 0;
  int porTratar = 0;
  int semStock = 0;
}

/// Everything Estatísticas shows for one [period] (see [computeStats]).
class StoreStats {
  StoreStats(this.period);

  final StatsPeriod period;

  /// The fixed Diárias, the Semanais, then the custom tasks; only those
  /// due at least once.
  final List<TaskStat> tasks = [];
  final List<DayStat> days = [];
  final List<PersonStat> people = [];
  final List<NotDoneNote> notDone = [];

  int validadesManhaCount = 0;
  int validadesNoiteCount = 0;
  int validadesManhaLeft = 0;
  int validadesNoiteLeft = 0;

  /// Validades windows marked (feita or não feita), whose counts are above.
  int validadesWindows = 0;

  final List<Auto2ItemStat> auto2Items = [];
  int get auto2Sends => auto2Items.fold(0, (s, i) => s + i.sends);
  int get auto2Value => auto2Items.fold(0, (s, i) => s + i.value);
  int get auto2PorTratar => auto2Items.fold(0, (s, i) => s + i.porTratar);
  int get auto2SemStock => auto2Items.fold(0, (s, i) => s + i.semStock);

  int visivelCount = 0;
  int visivelItens = 0;

  int trucks = 0;
  int pallets = 0;
  int mistas = 0;
  int expositores = 0;

  int inventoriesDone = 0;

  /// Inventories planned (Por fazer) whose date passed with no mark.
  int inventoriesLate = 0;

  int pedidosCreated = 0;
  int pedidosFinished = 0;

  int get tasksDone => tasks.fold(0, (s, t) => s + t.done);
  int get tasksAuto => tasks.fold(0, (s, t) => s + t.auto);
  int get tasksDue => tasks.fold(0, (s, t) => s + t.due);
  int get tasksNotDone => tasks.fold(0, (s, t) => s + t.notDone);
  int get tasksUnmarked => tasks.fold(0, (s, t) => s + t.unmarked);

  double? get tasksRate => tasksDue == 0 ? null : tasksDone / tasksDue;

  /// Whether nothing at all happened in the period.
  bool get isEmpty =>
      tasksDue == 0 &&
      auto2Sends == 0 &&
      visivelCount == 0 &&
      trucks == 0 &&
      inventoriesDone == 0 &&
      pedidosCreated == 0 &&
      pedidosFinished == 0;
}

/// The rows Estatísticas read: every one kept (not only the period's), so
/// a task only counts from the first day anyone ever marked it, and days
/// from before the app was used don't show as tasks left unmarked.
class StatsInput {
  StatsInput({
    this.daily = const [],
    this.weekly = const [],
    this.customTasks = const [],
    this.customEntries = const [],
    this.auto2 = const [],
    this.visivel = const [],
    this.trucks = const [],
    this.inventories = const [],
    this.pedidos = const [],
    TaskWindow Function(String key)? windowFor,
  }) : windowFor = windowFor ?? defaultTaskWindow;

  final List<DailyTasks> daily;
  final List<WeeklyTasks> weekly;
  final List<CustomTask> customTasks;
  final List<CustomTaskEntry> customEntries;
  final List<Auto2Entry> auto2;
  final List<Visivel2Entry> visivel;
  final List<TruckReception> trucks;
  final List<Inventory> inventories;
  final List<Pedido> pedidos;

  /// Each task's hours (`TaskWindowService.windowFor`): a task counts as
  /// left unmarked only once they are over.
  final TaskWindow Function(String key) windowFor;
}

/// Works out [StoreStats] for [period] from [input], as it stands at [now]
/// (a task whose hours aren't over yet and has no mark isn't counted).
StoreStats computeStats(
  StatsPeriod period,
  StatsInput input, {
  required DateTime now,
}) {
  final stats = StoreStats(period);
  final people = <String, PersonStat>{};
  PersonStat person(String name) =>
      people.putIfAbsent(name, () => PersonStat(name));
  final today = currentServiceDay(now);
  final days = [
    for (final d in period.days)
      if (!d.isAfter(today)) d,
  ];
  final dayStats = {for (final d in days) d: DayStat(d)};
  bool closed(String key, DateTime day) =>
      !windowSpan(input.windowFor(key), day).end.isAfter(now);

  // ---- Diárias ----
  final dailyByDay = {
    for (final t in input.daily) currentServiceDay(t.serviceDay): t,
  };
  // From the first day each task was ever marked.
  final dailySince = <String, DateTime>{};
  for (final t in input.daily) {
    for (final key in fixedDailyTaskKeys) {
      if (!dailySettled(t, key)) continue;
      final d = currentServiceDay(t.serviceDay);
      final was = dailySince[key];
      if (was == null || d.isBefore(was)) dailySince[key] = d;
    }
  }
  for (final key in fixedDailyTaskKeys) {
    final stat = TaskStat(key, fixedTaskLabels[key] ?? key);
    final since = dailySince[key];
    for (final day in days) {
      if (since == null || day.isBefore(since)) continue;
      final t = dailyByDay[day];
      final settled = t != null && dailySettled(t, key);
      if (!settled && !closed(key, day)) continue;
      final dayStat = dayStats[day]!..due += 1;
      if (t?.notDone[key] case final nd?) {
        stat.notDone++;
        stats.notDone.add(
          NotDoneNote(
            day: day,
            label: stat.label,
            reason: nd.reason,
            byNames: nd.byNames,
          ),
        );
      } else if (t != null && dailyDone(t, key)) {
        dayStat.done++;
        final isAuto = t.autoMarks.containsKey(key);
        isAuto ? stat.auto++ : stat.byHand++;
        for (final n in dailyNames(t, key)) {
          isAuto ? person(n).autoTasks++ : person(n).tasks++;
        }
      } else {
        stat.unmarked++;
      }
    }
    if (stat.due > 0) stats.tasks.add(stat);
  }

  // Validades.
  for (final day in days) {
    final t = dailyByDay[day];
    if (t == null) continue;
    if (t.notDone.containsKey('verificacao_validades') ||
        t.verificacaoValidades) {
      stats.validadesWindows++;
      stats.validadesManhaCount += t.verificacaoValidadesCount;
      stats.validadesManhaLeft += t.validadesManhaLeft;
    }
    if (t.notDone.containsKey('validades_noite') || t.validadesNoite) {
      stats.validadesWindows++;
      stats.validadesNoiteCount += t.validadesNoiteCount;
      stats.validadesNoiteLeft += t.validadesNoiteLeft;
    }
  }

  // ---- Semanais, on their weekday ----
  final weeklyByWeek = {
    for (final t in input.weekly) currentServiceWeek(t.serviceWeek): t,
  };
  final weeklySince = <String, DateTime>{};
  for (final t in input.weekly) {
    for (final key in fixedWeeklyTaskKeys) {
      if (!weeklySettled(t, key)) continue;
      final w = currentServiceWeek(t.serviceWeek);
      final was = weeklySince[key];
      if (was == null || w.isBefore(was)) weeklySince[key] = w;
    }
  }
  for (final key in fixedWeeklyTaskKeys) {
    final stat = TaskStat(key, fixedTaskLabels[key] ?? key);
    final since = weeklySince[key];
    for (final day in days) {
      if (taskDueWeekday[key] != day.weekday) continue;
      final week = currentServiceWeek(day);
      if (since == null || week.isBefore(since)) continue;
      final t = weeklyByWeek[week];
      final settled = t != null && weeklySettled(t, key);
      if (!settled && !closed(key, day)) continue;
      if (t?.notDone[key] case final nd?) {
        stat.notDone++;
        stats.notDone.add(
          NotDoneNote(
            day: day,
            label: stat.label,
            reason: nd.reason,
            byNames: nd.byNames,
          ),
        );
      } else if (t != null && weeklyDone(t, key)) {
        final isAuto = t.autoMarks.containsKey(key);
        isAuto ? stat.auto++ : stat.byHand++;
        for (final n in weeklyNames(t, key)) {
          isAuto ? person(n).autoTasks++ : person(n).tasks++;
        }
      } else {
        stat.unmarked++;
      }
    }
    if (stat.due > 0) stats.tasks.add(stat);
  }

  // ---- Custom tasks: daily ones each day, weekly ones on Sunday ----
  final entries = <String, CustomTaskEntry>{
    for (final e in input.customEntries)
      '${e.taskUuid}|${e.periodKey.millisecondsSinceEpoch}': e,
  };
  for (final task in input.customTasks) {
    if (task.frequency == CustomTaskFrequency.oneOff) continue;
    final stat = TaskStat(task.syncUuid, task.title);
    final firstDay = currentServiceDay(task.createdAt);
    for (final day in days) {
      final DateTime periodKey;
      final bool isOver;
      switch (task.frequency) {
        case CustomTaskFrequency.oneOff:
          continue;
        case CustomTaskFrequency.daily:
          if (day.isBefore(firstDay)) continue;
          periodKey = day;
          isOver = closed(task.syncUuid, day);
        case CustomTaskFrequency.weekly:
          if (day.weekday != DateTime.sunday) continue;
          periodKey = currentServiceWeek(day);
          if (periodKey.isBefore(currentServiceWeek(task.createdAt))) {
            continue;
          }
          isOver = !DateTime(day.year, day.month, day.day + 1, 5).isAfter(now);
      }
      final e = entries['${task.syncUuid}|${periodKey.millisecondsSinceEpoch}'];
      final settled = e != null && (e.done || e.notDone != null);
      if (!settled && !isOver) continue;
      final dayStat = task.frequency == CustomTaskFrequency.daily
          ? (dayStats[day]!..due += 1)
          : null;
      if (e?.notDone case final nd?) {
        stat.notDone++;
        stats.notDone.add(
          NotDoneNote(
            day: day,
            label: task.title,
            reason: nd.reason,
            byNames: nd.byNames,
          ),
        );
      } else if (e != null && e.done) {
        dayStat?.done++;
        final isAuto = e.autoMark != null;
        isAuto ? stat.auto++ : stat.byHand++;
        for (final n in resolveNames(e.doneByNames, e.doneBy)) {
          isAuto ? person(n).autoTasks++ : person(n).tasks++;
        }
      } else {
        stat.unmarked++;
      }
    }
    if (stat.due > 0) stats.tasks.add(stat);
  }

  stats.days.addAll([
    for (final d in days)
      if (dayStats[d]!.due > 0) dayStats[d]!,
  ]);
  stats.notDone.sort((a, b) => a.day.compareTo(b.day));

  // ---- Listas 2.0 ----
  final items = <String, Auto2ItemStat>{};
  for (final e in input.auto2) {
    if (!period.holds(e.createdAt)) continue;
    items.putIfAbsent(e.label, () => Auto2ItemStat(e.label))
      ..sends += 1
      ..value += e.value
      ..porTratar += e.porTratar
      ..semStock += e.semStock;
    for (final n in e.byNames) {
      person(n).auto2++;
    }
  }
  stats.auto2Items.addAll(
    items.values.toList()..sort((a, b) => b.value.compareTo(a.value)),
  );
  for (final v in input.visivel) {
    if (!period.holds(v.serviceDay)) continue;
    stats.visivelCount++;
    stats.visivelItens += v.itens;
    for (final n in v.byNames) {
      person(n).visivel++;
    }
  }

  // ---- Camiões, inventários, pedidos ----
  for (final t in input.trucks) {
    if (!period.holds(t.arrivalTime)) continue;
    stats.trucks++;
    stats.pallets += t.totalPallets;
    stats.mistas += t.totalMistas;
    stats.expositores += t.totalExpositores;
    for (final n in resolveNames(t.createdByNames, t.createdByInitials)) {
      person(n).trucks++;
    }
  }
  for (final i in input.inventories) {
    if (i.finishedAt case final f? when period.holds(f)) {
      stats.inventoriesDone++;
      for (final n in resolveNames(i.createdByNames, i.createdByInitials)) {
        person(n).inventories++;
      }
    }
    if (i.dueDate case final due? when i.isToDo) {
      if (period.holds(due) && currentServiceDay(due).isBefore(today)) {
        stats.inventoriesLate++;
      }
    }
  }
  for (final p in input.pedidos) {
    if (period.holds(p.createdAt)) stats.pedidosCreated++;
    if (p.finishedAt case final f? when period.holds(f)) {
      stats.pedidosFinished++;
    }
  }

  stats.people.addAll(
    people.values.toList()..sort((a, b) {
      final byTotal = b.total.compareTo(a.total);
      return byTotal != 0 ? byTotal : a.name.compareTo(b.name);
    }),
  );
  return stats;
}

/// "87 %" or "—".
String percentText(double? rate) =>
    rate == null ? '—' : '${(rate * 100).round()} %';

/// The period's summary as text, for WhatsApp or a file.
String statsText(StoreStats s) {
  final out = StringBuffer()
    ..writeln('*Estatísticas — ${s.period.label}*')
    ..writeln();
  if (s.tasksDue > 0) {
    out
      ..writeln(
        '*Tarefas:* ${s.tasksDone} de ${s.tasksDue} feitas '
        '(${percentText(s.tasksRate)})',
      )
      ..writeln(
        'Automáticas: ${s.tasksAuto} · Não feitas: ${s.tasksNotDone} '
        '· Sem registo: ${s.tasksUnmarked}',
      );
    for (final t in s.tasks) {
      out.writeln('• ${t.label}: ${t.done}/${t.due} (${percentText(t.rate)})');
    }
    out.writeln();
  }
  if (s.validadesWindows > 0) {
    out
      ..writeln(
        '*Validades:* Manhã ${s.validadesManhaCount} artigos, '
        '${s.validadesManhaLeft} por fazer · Noite '
        '${s.validadesNoiteCount} artigos, ${s.validadesNoiteLeft} por '
        'fazer',
      )
      ..writeln();
  }
  if (s.auto2Sends > 0 || s.visivelCount > 0) {
    out.writeln(
      '*Listas 2.0:* ${s.auto2Sends} Automáticas '
      '(${s.auto2Value} artigos, ${s.auto2PorTratar} por tratar, '
      '${s.auto2SemStock} sem stock) · ${s.visivelCount} Visível '
      '(${s.visivelItens} itens)',
    );
    out.writeln();
  }
  if (s.trucks > 0) {
    out.writeln(
      '*Camiões:* ${s.trucks} (${s.pallets} paletes, '
      '${s.mistas} mistas, ${s.expositores} expositores)',
    );
  }
  if (s.inventoriesDone > 0 || s.inventoriesLate > 0) {
    out.writeln(
      '*Inventários:* ${s.inventoriesDone} feitos'
      '${s.inventoriesLate > 0 ? ', ${s.inventoriesLate} em atraso' : ''}',
    );
  }
  if (s.pedidosCreated > 0 || s.pedidosFinished > 0) {
    out.writeln(
      '*Pedidos:* ${s.pedidosCreated} criados, '
      '${s.pedidosFinished} finalizados',
    );
  }
  if (s.notDone.isNotEmpty) {
    final fmt = DateFormat('dd/MM', 'pt_PT');
    out
      ..writeln()
      ..writeln('*Não feitas:*');
    for (final n in s.notDone) {
      out.writeln(
        '• ${fmt.format(n.day)} ${n.label}'
        '${n.reason.isEmpty ? '' : ': ${n.reason}'}',
      );
    }
  }
  return out.toString().trimRight();
}
