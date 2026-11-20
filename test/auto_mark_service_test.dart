import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/custom_task.dart';
import 'package:livre_servico_app/models/not_done.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/task_window.dart';
import 'package:livre_servico_app/services/auto_mark_service.dart';
import 'package:livre_servico_app/services/custom_task_service.dart';
import 'package:livre_servico_app/services/daily_tasks_service.dart';
import 'package:livre_servico_app/services/local_db.dart';
import 'package:livre_servico_app/services/settings_service.dart';
import 'package:livre_servico_app/services/sync_meta.dart';
import 'package:livre_servico_app/services/task_window_service.dart';
import 'package:livre_servico_app/services/weekly_tasks_service.dart';

import 'helpers/app_db.dart';

/// Wednesday 18 November 2026's service day.
final _day = DateTime(2026, 11, 18, 5);

Future<void> _person(
  String name,
  int start,
  int end, {
  String team = 'livre_servico',
}) async {
  final p = Person()
    ..fullName = name
    ..team = team
    ..createdAt = DateTime(2026)
    ..shiftStart = start
    ..shiftEnd = end;
  SyncMeta.stamp(p);
  await LocalDb.instance.persons.put(p);
}

Future<int> _run(DateTime now) => AutoMarkService.instance.run(now);

void main() {
  setUp(() async {
    await openAppDb();
    await SettingsService.instance.setAutoMarkSince(DateTime(2026, 11, 10, 5));
    await _person('Ana Dia', 6 * 60, 15 * 60);
    await _person('Bruno Noite', 21 * 60, 6 * 60);
    await _person('Rui Talho', 6 * 60, 15 * 60, team: 'talho');
  });
  tearDown(closeAppDb);

  test('marks only the windows already closed', () async {
    await _run(DateTime(2026, 11, 18, 10));
    final t = (await DailyTasksService.instance.find(_day))!;
    expect(t.kiwiAbertura, isTrue); // 05–09
    expect(t.kiwiAberturaByNames, ['Bruno Noite', 'Ana Dia']);
    expect(t.alteracoesPreco, isTrue); // 05–07:30
    expect(t.pendingCounts, contains('alteracoes_preco'));
    expect(t.verificacaoTemperaturas, isFalse); // until 12
    expect(t.kiwiFecho, isFalse);
    expect(t.autoMarks.keys, {'kiwi_abertura', 'alteracoes_preco'});
  });

  test('leaves alone what was marked by hand', () async {
    final t = await DailyTasksService.instance.forDay(_day);
    t
      ..kiwiAbertura = true
      ..kiwiAberturaByNames = ['Rita']
      ..notDone = {
        'alteracoes_preco': NotDone(byNames: ['Rita'], reason: 'Sem tempo'),
      };
    await DailyTasksService.instance.save(t);
    await _run(DateTime(2026, 11, 18, 10));
    final back = (await DailyTasksService.instance.find(_day))!;
    expect(back.kiwiAberturaByNames, ['Rita']);
    expect(back.alteracoesPreco, isFalse);
    expect(back.autoMarks, isEmpty);
  });

  test('a task with auto off is never marked', () async {
    await TaskWindowService.instance.save(
      defaultTaskWindow('kiwi_abertura')..auto = false,
    );
    await _run(DateTime(2026, 11, 18, 10));
    final t = (await DailyTasksService.instance.find(_day))!;
    expect(t.kiwiAbertura, isFalse);
    expect(t.alteracoesPreco, isTrue);
  });

  test('nobody from Livre Serviço working: nothing is marked', () async {
    await TaskWindowService.instance.save(
      TaskWindow(taskKey: 'kiwi_fecho', opensAt: 17 * 60, closesAt: 18 * 60),
    );
    await _run(DateTime(2026, 11, 18, 18, 30));
    final t = (await DailyTasksService.instance.find(_day))!;
    expect(t.kiwiFecho, isFalse);
  });

  test('catches up at most 7 days back', () async {
    await _run(DateTime(2026, 11, 18, 10));
    final rows = await DailyTasksService.instance.history();
    final days = rows.map((r) => r.serviceDay.day).toList()..sort();
    expect(days, [11, 12, 13, 14, 15, 16, 17, 18]);
    expect(rows.firstWhere((r) => r.serviceDay.day == 17).kiwiFecho, isTrue);
  });

  test('never before autoMarkSince', () async {
    await SettingsService.instance.setAutoMarkSince(DateTime(2026, 11, 16, 5));
    await _run(DateTime(2026, 11, 18, 10));
    final rows = await DailyTasksService.instance.history();
    expect(rows.map((r) => r.serviceDay.day).toSet(), {16, 17, 18});
  });

  test('the first run marks no window closed before it', () async {
    await closeAppDb();
    await openAppDb();
    await _person('Ana Dia', 6 * 60, 15 * 60);
    await _run(DateTime(2026, 11, 18, 10));
    expect(await DailyTasksService.instance.history(), isEmpty);
    // Temperaturas closes at 12:00, after the first run.
    await _run(DateTime(2026, 11, 18, 12, 30));
    final t = (await DailyTasksService.instance.find(_day))!;
    expect(t.verificacaoTemperaturas, isTrue);
    expect(t.kiwiAbertura, isFalse);
  });

  test('a Semanal is marked after its weekday', () async {
    await _run(DateTime(2026, 11, 18, 10));
    final w = await WeeklyTasksService.instance.forWeek(
      DateTime(2026, 11, 16, 5),
    );
    expect(w.verificar1a, isTrue); // Tuesday 17
    expect(w.pendingCounts, containsAll(['verificar_1a', 'verificar_4a']));
    expect(w.limpezaMaquinaVoltas, isFalse); // Saturday
    final before = await WeeklyTasksService.instance.forWeek(
      DateTime(2026, 11, 9, 5),
    );
    expect(before.limpezaMaquinaVoltas, isTrue); // Saturday 14
  });

  test('custom tasks: daily per day, weekly per week, one-off never', () async {
    Future<CustomTask> add(String title, CustomTaskFrequency f) async {
      final t = await CustomTaskService.instance.addTask(
        title: title,
        frequency: f,
        inputType: CustomTaskInputType.simple,
      );
      t.createdAt = DateTime(2026, 11, 1);
      SyncMeta.stamp(t);
      await LocalDb.instance.customTasks.put(t);
      return t;
    }

    final daily = await add('Diária', CustomTaskFrequency.daily);
    final weekly = await add('Semanal', CustomTaskFrequency.weekly);
    final once = await add('Pontual', CustomTaskFrequency.oneOff);
    await _run(DateTime(2026, 11, 18, 10));
    final svc = CustomTaskService.instance;
    expect((await svc.entryFor(daily.syncUuid, _day)), isNull);
    final yesterday = (await svc.entryFor(
      daily.syncUuid,
      DateTime(2026, 11, 17, 5),
    ))!;
    expect(yesterday.done, isTrue);
    expect(yesterday.autoMark, isNotNull);
    final lastWeek = await svc.entryFor(
      weekly.syncUuid,
      DateTime(2026, 11, 9, 5),
    );
    expect(lastWeek?.done, isTrue);
    expect(
      await svc.entryFor(weekly.syncUuid, DateTime(2026, 11, 16, 5)),
      isNull,
    );
    expect(await svc.entryFor(once.syncUuid, oneOffPeriodKey), isNull);
  });

  test('unconfirmed counts the marks nobody confirmed', () async {
    await _run(DateTime(2026, 11, 18, 10));
    final n = await AutoMarkService.instance.unconfirmed(
      now: DateTime(2026, 11, 18, 10),
    );
    expect(n, greaterThan(0));
    final t = (await DailyTasksService.instance.find(_day))!;
    for (final m in t.autoMarks.values) {
      m.confirmedAt = DateTime(2026, 11, 18, 11);
    }
    await DailyTasksService.instance.save(t);
    expect(
      await AutoMarkService.instance.unconfirmed(
        now: DateTime(2026, 11, 18, 10),
      ),
      n - 2,
    );
  });
}
