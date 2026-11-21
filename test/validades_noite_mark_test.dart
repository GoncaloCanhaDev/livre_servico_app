import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/opening_list.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/task_window.dart';
import 'package:livre_servico_app/screens/tasks_screen.dart';
import 'package:livre_servico_app/services/daily_tasks_service.dart';
import 'package:livre_servico_app/services/local_db.dart';
import 'package:livre_servico_app/services/sync_meta.dart';
import 'package:livre_servico_app/services/task_window_service.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  testWidgets('marking the Noite done keeps it and carries the rest', (
    tester,
  ) async {
    await dbCall(tester, () async {
      final rita = Person()
        ..fullName = 'Rita Sousa'
        ..createdAt = DateTime(2026);
      SyncMeta.stamp(rita);
      await LocalDb.instance.persons.put(rita);
      // Open all day, so the test runs at any hour.
      await TaskWindowService.instance.save(
        TaskWindow(
          taskKey: 'validades_noite',
          opensAt: 5 * 60,
          closesAt: 5 * 60,
        ),
      );
    });
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, MaterialApp(home: const TasksScreen()));
    await settle(tester);

    await settle(tester);
    await tester.scrollUntilVisible(
      find.text('Validades · Noite'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await settle(tester);
    expect(find.text('Validades · Noite'), findsOneWidget);
    final row = find
        .ancestor(
          of: find.text('Validades · Noite'),
          matching: find.byType(ListTile),
        )
        .first;
    await tapAndSettle(
      tester,
      find.descendant(of: row, matching: find.byTooltip('Feita')),
    );
    await tester.enterText(find.byKey(const Key('validadesLeft')), '7');
    await tapAndSettle(tester, find.text('Continuar'));
    // A sync saves the day while the picker is open: the tab reloads it.
    await dbCall(tester, () async {
      final t = await DailyTasksService.instance.find(currentServiceDay());
      await DailyTasksService.instance.save(t!);
    });
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Procurar'), 'Rita');
    await settle(tester);
    await tapAndSettle(tester, find.text('Rita Sousa'));
    await tapAndSettle(tester, find.text('Confirmar (1)'));
    await settle(tester);

    final day = currentServiceDay();
    final t = await dbCall(tester, () => DailyTasksService.instance.find(day));
    expect(t!.validadesNoite, isTrue);
    expect(t.validadesNoiteByNames, ['Rita Sousa']);
    expect(t.validadesNoiteLeft, 7);
    final next = await dbCall(
      tester,
      () => DailyTasksService.instance.find(
        DateTime(day.year, day.month, day.day + 1, 5),
      ),
    );
    expect(next?.verificacaoValidadesCount, 7);
  });
}
