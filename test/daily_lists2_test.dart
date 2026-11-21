import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/auto2_entry.dart';
import 'package:livre_servico_app/models/auto_mark.dart';
import 'package:livre_servico_app/models/opening_list.dart';
import 'package:livre_servico_app/services/auto2_service.dart';
import 'package:livre_servico_app/services/daily_tasks_service.dart';
import 'package:livre_servico_app/services/visivel2_service.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  Future<void> openDiarias(WidgetTester tester) async {
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.text('Tarefas'));
  }

  testWidgets('sends tick the Lista Visível and the Lista Automática', (
    tester,
  ) async {
    await dbCall(
      tester,
      () => Visivel2Service.instance.add(itens: 37, names: ['Ana Silva']),
    );
    for (final item in [Auto2Item.mercearia, Auto2Item.bebidas]) {
      await dbCall(
        tester,
        () => Auto2Service.instance.send(
          item: item,
          value: 3,
          names: [item == Auto2Item.mercearia ? 'Rui Costa' : 'Ana Silva'],
        ),
      );
    }
    final t = await dbCall(
      tester,
      () => DailyTasksService.instance.find(currentServiceDay()),
    );
    expect(t!.listaVisivel, isTrue);
    expect(t.listaVisivelByNames, ['Ana Silva']);
    expect(t.listaAutomatica, isTrue);
    expect(t.listaAutomaticaByNames, ['Rui Costa']); // the first send
    expect(t.pendingCounts, isEmpty);

    await openDiarias(tester);
    await scrollTo(tester, find.text('2 automáticas enviadas hoje'));
    expect(find.text('37 itens picados'), findsOneWidget);
  });

  testWidgets('a Lista Visível marked without a number is filled in later', (
    tester,
  ) async {
    await dbCall(tester, () async {
      final t = await DailyTasksService.instance.forDay(currentServiceDay());
      autoMarkDaily(t, 'lista_visivel', ['Ana Dia'], DateTime.now());
      autoMarkDaily(t, 'lista_automatica', ['Ana Dia'], DateTime.now());
      await DailyTasksService.instance.save(t);
    });
    await openDiarias(tester);
    // Only the Visível has a number.
    expect(find.text('Número por preencher'), findsOneWidget);

    await scrollTo(tester, find.text('Preencher'));
    await tapAndSettle(tester, find.text('Preencher'));
    await tester.enterText(find.byKey(const Key('pendingNumber')), '20');
    await tapAndSettle(tester, find.text('Guardar'));

    final visiveis = await dbCall(
      tester,
      () => Visivel2Service.instance.forServiceDay(currentServiceDay()),
    );
    expect(visiveis.single.itens, 20);
    expect(visiveis.single.byNames, ['Ana Dia']);
    final t = await dbCall(
      tester,
      () => DailyTasksService.instance.find(currentServiceDay()),
    );
    expect(t!.pendingCounts, isEmpty);
    // Filling the number doesn't confirm the automatic mark.
    expect(t.autoMarks.keys, {'lista_visivel', 'lista_automatica'});
    expect(find.text('20 itens picados'), findsOneWidget);
  });

  testWidgets('a send after the app marked the list makes it the sender\'s', (
    tester,
  ) async {
    await dbCall(tester, () async {
      final t = await DailyTasksService.instance.forDay(currentServiceDay());
      autoMarkDaily(t, 'lista_visivel', ['Ana Dia'], DateTime.now());
      await DailyTasksService.instance.save(t);
      await Visivel2Service.instance.add(itens: 5, names: ['Rui Costa']);
    });
    final t = await dbCall(
      tester,
      () => DailyTasksService.instance.find(currentServiceDay()),
    );
    expect(t!.listaVisivelByNames, ['Rui Costa']);
    expect(t.autoMarks, isEmpty);
    expect(t.pendingCounts, isEmpty);
  });
}
