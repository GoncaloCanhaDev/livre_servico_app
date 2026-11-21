import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/auto2_entry.dart';
import 'package:livre_servico_app/models/auto_mark.dart';
import 'package:livre_servico_app/models/custom_task.dart';
import 'package:livre_servico_app/models/daily_tasks.dart';
import 'package:livre_servico_app/models/inventory.dart';
import 'package:livre_servico_app/models/not_done.dart';
import 'package:livre_servico_app/models/pedido.dart';
import 'package:livre_servico_app/models/stats.dart';
import 'package:livre_servico_app/models/store_access.dart';
import 'package:livre_servico_app/models/truck_reception.dart';
import 'package:livre_servico_app/models/visivel2_entry.dart';
import 'package:livre_servico_app/models/weekly_tasks.dart';
import 'package:livre_servico_app/screens/stats_screen.dart';
import 'package:livre_servico_app/services/daily_tasks_service.dart';
import 'package:livre_servico_app/services/sync_meta.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

DateTime day(int d, [int month = 11]) => DateTime(2026, month, d, 5);

void main() {
  setUpAll(() => initializeDateFormatting('pt_PT'));

  group('StatsPeriod', () {
    test('a week runs Monday to Sunday by service day', () {
      // Friday 20 November 2026, 03:00: still Thursday's service day.
      final p = StatsPeriod.containing(
        StatsPeriodKind.week,
        DateTime(2026, 11, 20, 3),
      );
      expect(p.start, day(16));
      expect(p.end, day(23));
      expect(p.days, hasLength(7));
      expect(p.label, '16 a 22 de novembro');
      expect(p.previous.start, day(9));
      expect(p.next.start, day(23));
      expect(p.holds(DateTime(2026, 11, 23, 4)), isTrue);
      expect(p.holds(DateTime(2026, 11, 23, 5)), isFalse);
    });

    test('a week across two months names both', () {
      final p = StatsPeriod.containing(StatsPeriodKind.week, day(1, 12));
      expect(p.label, '30 de novembro a 6 de dezembro');
    });

    test('a month, and the ones around it', () {
      final p = StatsPeriod.containing(StatsPeriodKind.month, day(20));
      expect(p.start, day(1));
      expect(p.end, day(1, 12));
      expect(p.days, hasLength(30));
      expect(p.label, 'Novembro de 2026');
      expect(p.previous.label, 'Outubro de 2026');
      expect(p.next.next.label, 'Janeiro de 2027');
    });
  });

  group('computeStats', () {
    final week = StatsPeriod.containing(StatsPeriodKind.week, day(16));

    test('the lists: a send ticks them and credits its people once', () {
      final w = StatsPeriod.containing(StatsPeriodKind.week, day(23));
      final visivel = Visivel2Entry()
        ..createdAt = DateTime(2026, 11, 23, 9)
        ..serviceDay = day(23)
        ..itens = 10
        ..byNames = ['Ana'];
      // Ticked by the Visível (by hand, the send counts Ana).
      final mon = DailyTasks()
        ..serviceDay = day(23)
        ..listaVisivel = true
        ..listaVisivelByNames = ['Ana'];
      // Tuesday: a Visível marked by hand with no send.
      final tue = DailyTasks()
        ..serviceDay = day(24)
        ..listaVisivel = true
        ..listaVisivelByNames = ['Rui'];
      final s = computeStats(
        w,
        StatsInput(daily: [mon, tue], visivel: [visivel]),
        now: DateTime(2026, 11, 25, 15),
      );
      final stat = s.tasks.firstWhere((t) => t.key == 'lista_visivel');
      expect(stat.byHand, 2);
      expect(stat.unmarked, 1); // Wednesday, closed at 14:00
      final ana = s.people.firstWhere((p) => p.name == 'Ana');
      expect(ana.tasks, 0);
      expect(ana.visivel, 1);
      expect(s.people.firstWhere((p) => p.name == 'Rui').tasks, 1);
    });

    test('each task counts done, by the app, não feita or unmarked', () {
      final mon = DailyTasks()
        ..serviceDay = day(16)
        ..kiwiAbertura = true
        ..kiwiAberturaByNames = ['Ana'];
      final tue = DailyTasks()
        ..serviceDay = day(17)
        ..kiwiAbertura = true
        ..kiwiAberturaByNames = ['Rui', 'Ana']
        ..autoMarks = {'kiwi_abertura': AutoMark(at: day(17))};
      final wed = DailyTasks()
        ..serviceDay = day(18)
        ..notDone = {
          'kiwi_abertura': NotDone(byNames: ['Bia'], reason: 'Sem sistema'),
        };
      // Thursday nothing; Friday 08:00 the window (05–09) is still open.
      final s = computeStats(
        week,
        StatsInput(daily: [mon, tue, wed]),
        now: DateTime(2026, 11, 20, 8),
      );
      final kiwi = s.tasks.singleWhere((t) => t.key == 'kiwi_abertura');
      expect(kiwi.byHand, 1);
      expect(kiwi.auto, 1);
      expect(kiwi.notDone, 1);
      expect(kiwi.unmarked, 1);
      expect(kiwi.due, 4);
      expect(kiwi.rate, 0.5);
      expect(s.notDone.single.reason, 'Sem sistema');

      final ana = s.people.firstWhere((p) => p.name == 'Ana');
      expect(ana.tasks, 1);
      expect(ana.autoTasks, 1);
      expect(s.people.firstWhere((p) => p.name == 'Rui').autoTasks, 1);
    });

    test('a task never marked anywhere is not counted', () {
      final mon = DailyTasks()
        ..serviceDay = day(16)
        ..kiwiAbertura = true;
      final s = computeStats(
        week,
        StatsInput(daily: [mon]),
        now: DateTime(2026, 11, 23, 12),
      );
      expect(s.tasks.map((t) => t.key), ['kiwi_abertura']);
      // Marked Monday; Tuesday to Sunday nobody did.
      expect(s.tasks.single.unmarked, 6);
      expect(s.days, hasLength(7));
      expect(s.days.first.rate, 1);
      expect(s.days[1].rate, 0);
    });

    test('a task counts from the first day it was ever marked', () {
      final thu = DailyTasks()
        ..serviceDay = day(19)
        ..kiwiFecho = true;
      final s = computeStats(
        week,
        StatsInput(daily: [thu]),
        now: DateTime(2026, 11, 21, 12),
      );
      // Thursday done, Friday unmarked; Saturday's window (19–22) isn't over.
      expect(s.tasks.single.due, 2);
    });

    test('Semanais on their weekday, custom tasks per day and week', () {
      final weekly = WeeklyTasks()
        ..serviceWeek = day(16)
        ..verificar1a = true
        ..verificar1aByNames = ['Ana'];
      final daily = CustomTask()
        ..syncUuid = 'c1'
        ..title = 'Regar'
        ..frequency = CustomTaskFrequency.daily
        ..createdAt = day(21);
      final weeklyCustom = CustomTask()
        ..syncUuid = 'c2'
        ..title = 'Arrumar'
        ..frequency = CustomTaskFrequency.weekly
        ..createdAt = day(1);
      final entry = CustomTaskEntry()
        ..taskUuid = 'c1'
        ..periodKey = day(21)
        ..done = true
        ..doneByNames = ['Rui'];
      final s = computeStats(
        week,
        StatsInput(
          weekly: [weekly],
          customTasks: [daily, weeklyCustom],
          customEntries: [entry],
        ),
        now: DateTime(2026, 11, 23, 6),
      );
      expect(s.tasks.map((t) => t.label), [
        'Verificar 1ª Sheet',
        'Regar',
        'Arrumar',
      ]);
      final regar = s.tasks[1];
      expect(regar.done, 1);
      expect(regar.unmarked, 1); // Sunday
      expect(s.tasks[2].unmarked, 1);
      expect(s.people.map((p) => p.name), ['Ana', 'Rui']);
    });

    test('Validades, Listas 2.0, camiões, inventários and pedidos', () {
      final t = DailyTasks()
        ..serviceDay = day(17)
        ..verificacaoValidades = true
        ..verificacaoValidadesCount = 40
        ..validadesManhaLeft = 5
        ..notDone = {'validades_noite': NotDone(byNames: [], reason: '')}
        ..validadesNoiteCount = 12
        ..validadesNoiteLeft = 12;
      final auto2 = [
        Auto2Entry()
          ..createdAt = DateTime(2026, 11, 17, 10)
          ..item = Auto2Item.bebidas.name
          ..value = 30
          ..porTratar = 4
          ..semStock = 2
          ..byNames = ['Ana'],
        Auto2Entry()
          ..createdAt = DateTime(2026, 11, 18, 10)
          ..item = Auto2Item.bebidas.name
          ..value = 10,
        // The week before.
        Auto2Entry()
          ..createdAt = DateTime(2026, 11, 16, 4)
          ..item = Auto2Item.bazar.name
          ..value = 99,
      ];
      final visivel = Visivel2Entry()
        ..createdAt = day(18)
        ..serviceDay = day(18)
        ..itens = 7
        ..byNames = ['Bia'];
      final truck = TruckReception()
        ..arrivalTime = DateTime(2026, 11, 19, 7)
        ..createdByNames = ['Rui']
        ..pallets = [
          PalletCount()
            ..total = 10
            ..mistas = 2,
        ];
      final inventories = [
        Inventory()
          ..name = 'Bebidas'
          ..valueCents = 0
          ..createdAt = day(10)
          ..finishedAt = DateTime(2026, 11, 18, 12)
          ..createdByNames = ['Ana'],
        Inventory()
          ..name = 'Bazar'
          ..valueCents = 0
          ..createdAt = day(10)
          ..plannedAt = day(10)
          ..dueDate = day(17),
      ];
      final pedidos = [
        Pedido()
          ..createdAt = DateTime(2026, 11, 17, 9)
          ..finishedAt = DateTime(2026, 11, 19, 9),
        Pedido()..createdAt = DateTime(2026, 11, 10, 9),
      ];
      final s = computeStats(
        week,
        StatsInput(
          daily: [t],
          auto2: auto2,
          visivel: [visivel],
          trucks: [truck],
          inventories: inventories,
          pedidos: pedidos,
        ),
        now: DateTime(2026, 11, 20, 12),
      );
      expect(s.validadesWindows, 2);
      expect(s.validadesManhaCount, 40);
      expect(s.validadesManhaLeft, 5);
      expect(s.validadesNoiteLeft, 12);
      expect(s.auto2Sends, 2);
      expect(s.auto2Value, 40);
      expect(s.auto2Items.single.label, 'Bebidas');
      expect(s.visivelItens, 7);
      expect(s.trucks, 1);
      expect(s.pallets, 10);
      expect(s.mistas, 2);
      expect(s.inventoriesDone, 1);
      expect(s.inventoriesLate, 1);
      expect(s.pedidosCreated, 1);
      expect(s.pedidosFinished, 1);
      expect(s.isEmpty, isFalse);

      final text = statsText(s);
      expect(text, contains('16 a 22 de novembro'));
      expect(text, contains('*Camiões:* 1 (10 paletes, 2 mistas'));
      expect(text, contains('2 Automáticas (40 artigos'));
      expect(text, contains('Validades · Noite'));
    });

    test('an empty period', () {
      final s = computeStats(week, StatsInput(), now: day(20));
      expect(s.isEmpty, isTrue);
      expect(s.tasksRate, isNull);
      expect(percentText(s.tasksRate), '—');
    });
  });

  test('Estatísticas are for level 3 and up', () {
    expect(const StoreAccess(admin: false, level: 2).canSeeStats, isFalse);
    expect(const StoreAccess(admin: false, level: 3).canSeeStats, isTrue);
    expect(StoreAccess.full.canSeeStats, isTrue);
  });

  group('screen', () {
    setUp(openAppDb);
    tearDown(closeAppDb);

    testWidgets('shows the week, then the month', (tester) async {
      final t = DailyTasks()
        ..serviceDay = day(17)
        ..kiwiAbertura = true
        ..kiwiAberturaByNames = ['Ana Silva'];
      SyncMeta.stamp(t);
      await pumpApp(tester, const LivreServicoApp());
      await dbCall(tester, () => DailyTasksService.instance.save(t));
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(
              builder: (_) => StatsScreen(now: DateTime(2026, 11, 20, 12)),
            ),
          );
      await settle(tester);

      expect(find.text('16 a 22 de novembro'), findsOneWidget);
      expect(find.text('Resumo'), findsOneWidget);
      expect(find.text('Kiwi Abertura'), findsOneWidget);
      await scrollTo(tester, find.text('Ana Silva'));
      expect(find.text('Ana Silva'), findsOneWidget);

      // Back up to the period buttons, which the lazy list let go.
      await tester.scrollUntilVisible(
        find.text('Mês'),
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      await tapAndSettle(tester, find.text('Mês'));
      expect(find.text('Novembro de 2026'), findsOneWidget);
      await tapAndSettle(tester, find.byTooltip('Anterior'));
      expect(find.text('Outubro de 2026'), findsOneWidget);
      expect(find.text('Nada registado neste período.'), findsOneWidget);
    });
  });
}
