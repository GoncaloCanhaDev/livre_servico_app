import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/custom_task.dart';
import 'package:livre_servico_app/screens/task_windows_screen.dart';
import 'package:livre_servico_app/services/custom_task_service.dart';
import 'package:livre_servico_app/services/task_window_service.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

/// The app (its 24-hour setting included) with Horas das tarefas open.
Future<void> _open(WidgetTester tester) async {
  await pumpApp(tester, const LivreServicoApp());
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .push(MaterialPageRoute<void>(builder: (_) => const TaskWindowsScreen()));
  await settle(tester);
}

/// Types [hour] and [minute] in the time picker's keyboard mode and
/// confirms.
Future<void> _typeTime(WidgetTester tester, int hour, int minute) async {
  await tapAndSettle(tester, find.byIcon(Icons.keyboard_outlined));
  final fields = find.descendant(
    of: find.byType(Dialog).last,
    matching: find.byType(TextField),
  );
  await tester.enterText(fields.at(0), '$hour');
  await tester.enterText(fields.at(1), '$minute'.padLeft(2, '0'));
  await tapAndSettle(tester, find.text('OK'));
}

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  testWidgets('a task\'s hours are changed, then put back', (tester) async {
    await _open(tester);
    await tapAndSettle(tester, find.text('Kiwi Abertura'));
    expect(find.text('Começa às'), findsOneWidget);

    await tapAndSettle(tester, find.text('Acaba às'));
    await _typeTime(tester, 10, 30);
    expect(find.text('10:30'), findsOneWidget);
    await tapAndSettle(tester, find.text('Guardar'));
    await settle(tester);

    final w = TaskWindowService.instance.windowFor('kiwi_abertura');
    expect(w.opensAt, 5 * 60);
    expect(w.closesAt, 10 * 60 + 30);
    expect(find.text('05:00–10:30 · alterada'), findsOneWidget);

    await tapAndSettle(tester, find.text('Kiwi Abertura'));
    await tapAndSettle(tester, find.text('Repor'));
    expect(find.text('09:00'), findsOneWidget);
    await tapAndSettle(tester, find.text('Guardar'));
    await settle(tester);
    expect(
      TaskWindowService.instance.windowFor('kiwi_abertura').closesAt,
      9 * 60,
    );
  });

  testWidgets('a window ending before it starts can\'t be saved', (
    tester,
  ) async {
    await _open(tester);
    await tapAndSettle(tester, find.text('Kiwi Fecho'));
    // 19:00 to 18:30 would end before it starts (the day ends at 05:00).
    // Typing 18 works even where the phone is set to a 12-hour clock.
    await tapAndSettle(tester, find.text('Acaba às'));
    await _typeTime(tester, 18, 30);
    expect(find.text('18:30'), findsOneWidget);
    expect(find.textContaining('Tem de acabar depois de começar'), findsOne);
    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Guardar'),
    );
    expect(save.onPressed, isNull);

    await tapAndSettle(tester, find.text('Cancelar'));
    expect(TaskWindowService.instance.isCustom('kiwi_fecho'), isFalse);
  });

  testWidgets('custom daily and weekly tasks are listed, one-off not', (
    tester,
  ) async {
    await _open(tester);
    Future<void> add(String title, CustomTaskFrequency f) => dbCall(
      tester,
      () => CustomTaskService.instance.addTask(
        title: title,
        frequency: f,
        inputType: CustomTaskInputType.simple,
      ),
    );
    await add('Regar plantas', CustomTaskFrequency.daily);
    await add('Arrumar armazém', CustomTaskFrequency.weekly);
    await add('Pintar parede', CustomTaskFrequency.oneOff);
    await settle(tester);

    await scrollTo(tester, find.text('Regar plantas'));
    expect(find.text('Regar plantas'), findsOneWidget);
    await scrollTo(tester, find.text('Arrumar armazém'));
    expect(find.text('Arrumar armazém'), findsOneWidget);
    expect(find.text('Toda a semana'), findsOneWidget);
    expect(find.text('Pintar parede'), findsNothing);
  });
}
