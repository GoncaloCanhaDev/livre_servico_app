import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/auto_mark.dart';
import 'package:livre_servico_app/models/opening_list.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/auto_marks_screen.dart';
import 'package:livre_servico_app/screens/task_windows_screen.dart';
import 'package:livre_servico_app/screens/tasks_screen.dart';
import 'package:livre_servico_app/services/daily_tasks_service.dart';
import 'package:livre_servico_app/services/local_db.dart';
import 'package:livre_servico_app/services/sync_meta.dart';
import 'package:livre_servico_app/services/task_window_service.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

Widget _app(Widget home) => MaterialApp(home: home);

/// Today's Kiwi Abertura marked by the app, by Ana; Alterações de Preço
/// too, with its number left to fill in.
Future<void> _seed(WidgetTester tester) => dbCall(tester, () async {
  final rita = Person()
    ..fullName = 'Rita Sousa'
    ..createdAt = DateTime(2026);
  SyncMeta.stamp(rita);
  await LocalDb.instance.persons.put(rita);
  final t = await DailyTasksService.instance.forDay(currentServiceDay());
  autoMarkDaily(t, 'kiwi_abertura', ['Ana Dia'], DateTime.now());
  autoMarkDaily(t, 'alteracoes_preco', ['Ana Dia'], DateTime.now());
  await DailyTasksService.instance.save(t);
});

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  testWidgets('Tarefas shows the automatic mark and confirms it', (
    tester,
  ) async {
    await pumpApp(tester, _app(const TasksScreen()));
    await _seed(tester);
    await settle(tester);

    expect(find.text('Automática · por confirmar'), findsNWidgets(2));
    expect(find.text('Número por preencher'), findsOneWidget);

    await tapAndSettle(tester, find.text('Rever').first);
    await tapAndSettle(tester, find.text('Confirmar'));
    // Signed out: no linked person, so it asks who confirms.
    await tester.enterText(find.widgetWithText(TextField, 'Procurar'), 'Rita');
    await settle(tester);
    await tapAndSettle(tester, find.text('Rita Sousa'));
    await tapAndSettle(tester, find.text('Confirmar (1)'));

    final t = await dbCall(
      tester,
      () => DailyTasksService.instance.find(currentServiceDay()),
    );
    expect(t!.autoMarks['kiwi_abertura']!.confirmedByNames, ['Rita Sousa']);
    expect(find.text('Automática · confirmada por Rita Sousa'), findsOneWidget);
  });

  testWidgets('a number left empty is filled in later', (tester) async {
    await pumpApp(tester, _app(const TasksScreen()));
    await _seed(tester);
    await settle(tester);

    await tapAndSettle(tester, find.text('Preencher'));
    await tester.enterText(find.byKey(const Key('pendingNumber')), '12');
    await tapAndSettle(tester, find.text('Guardar'));

    final t = await dbCall(
      tester,
      () => DailyTasksService.instance.find(currentServiceDay()),
    );
    expect(t!.alteracoesPrecoCount, 12);
    expect(t.pendingCounts, isNot(contains('alteracoes_preco')));
    expect(find.text('Número por preencher'), findsNothing);
  });

  testWidgets('Por confirmar lists the marks', (tester) async {
    await pumpApp(tester, _app(const AutoMarksScreen()));
    await _seed(tester);
    await settle(tester);
    expect(find.text('Kiwi Abertura'), findsOneWidget);
    expect(find.text('Alterações de Preço'), findsOneWidget);
  });

  testWidgets('Horas das tarefas turns a task to manual', (tester) async {
    await pumpApp(tester, _app(const TaskWindowsScreen()));
    expect(find.text('05:00–09:00'), findsOneWidget);
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.byKey(const Key('window:kiwi_abertura')),
        matching: find.byType(Switch),
      ),
    );
    await settle(tester);
    expect(TaskWindowService.instance.windowFor('kiwi_abertura').auto, isFalse);
    expect(find.text('05:00–09:00 · marcar à mão · alterada'), findsOneWidget);
  });
}
