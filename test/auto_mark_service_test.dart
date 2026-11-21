import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/custom_task.dart';
import 'package:livre_servico_app/models/daily_tasks.dart';
import 'package:livre_servico_app/models/not_done.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/task_window.dart';
import 'package:livre_servico_app/models/visivel2_entry.dart';
import 'package:livre_servico_app/services/auto_mark_service.dart';
import 'package:livre_servico_app/services/visivel2_service.dart';
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
    expect(t.kiwiAberturaByNames, hasLength(1)); // one person, in turn
    expect(t.alteracoesPreco, isTrue); // 05–07:30
    expect(t.pendingCounts, contains('alteracoes_preco'));
    expect(t.verificacaoTemperaturas, isFalse); // until 12
    expect(t.kiwiFecho, isFalse);
    expect(t.autoMarks.keys, {'kiwi_abertura', 'alteracoes_preco'});
  });

  test('suggests one person, in turn', () async {
    await SettingsService.instance.setAutoMarkSince(DateTime(2026, 11, 17, 5));
    // Ana was credited by hand the day before.
    final before = DailyTasks()
      ..serviceDay = DateTime(2026, 11, 16, 5)
      ..kiwiAbertura = true
      ..kiwiAberturaByNames = ['Ana Dia'];
    await DailyTasksService.instance.save(before);
    await _run(DateTime(2026, 11, 18, 10));
    final day17 = await DailyTasksService.instance.find(
      DateTime(2026, 11, 17, 5),
    );
    final day18 = await DailyTasksService.instance.find(_day);
    expect(day17!.kiwiAberturaByNames, ['Bruno Noite']);
    expect(day18!.kiwiAberturaByNames, ['Ana Dia']); // 1 each: Ana's longer ago
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

  group('the lists', () {
    // Wednesday 25 November 2026, after the lists became Diárias.
    final day = DateTime(2026, 11, 25, 5);

    test(
      'the Visível after its hours, the Automática when the day ends',
      () async {
        await SettingsService.instance.setAutoMarkSince(
          DateTime(2026, 11, 24, 5),
        );
        await _run(DateTime(2026, 11, 25, 15));
        final t = (await DailyTasksService.instance.find(day))!;
        expect(t.listaVisivel, isTrue); // 05–14
        expect(t.pendingCounts, contains('lista_visivel'));
        expect(t.listaAutomatica, isFalse); // the whole day
        final before = (await DailyTasksService.instance.find(
          DateTime(2026, 11, 24, 5),
        ))!;
        expect(before.listaAutomatica, isTrue);
        expect(before.autoMarks, contains('lista_automatica'));
      },
    );

    test('never for the days before the update', () async {
      await _run(DateTime(2026, 11, 22, 15));
      for (final r in await DailyTasksService.instance.history()) {
        final isNew = !r.serviceDay.isBefore(DateTime(2026, 11, 22, 5));
        expect(r.listaVisivel, isNew, reason: '${r.serviceDay}');
        expect(r.listaAutomatica, isFalse, reason: '${r.serviceDay}');
      }
    });

    test('a Visível already sent ticks it by hand, not by the app', () async {
      await SettingsService.instance.setAutoMarkSince(
        DateTime(2026, 11, 24, 5),
      );
      // As a phone on an older version saves it: the Diária not ticked.
      final v = Visivel2Entry()
        ..createdAt = DateTime(2026, 11, 25, 9)
        ..serviceDay = day
        ..itens = 12
        ..byNames = ['Rita'];
      SyncMeta.stamp(v);
      await LocalDb.instance.visivel2Entries.put(v);
      await _run(DateTime(2026, 11, 25, 15));
      final t = (await DailyTasksService.instance.find(day))!;
      expect(t.listaVisivel, isTrue);
      expect(t.listaVisivelByNames, ['Rita']);
      expect(t.autoMarks, isNot(contains('lista_visivel')));
      expect(t.pendingCounts, isNot(contains('lista_visivel')));
      expect(await Visivel2Service.instance.forServiceDay(day), hasLength(1));
    });
  });
}
