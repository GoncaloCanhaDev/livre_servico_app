import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/auto2_entry.dart';
import 'package:livre_servico_app/services/auto2_service.dart';
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

  CheckboxListTile visivel(WidgetTester tester) =>
      tester.widget(find.widgetWithText(CheckboxListTile, 'Lista Visível'));

  testWidgets('with nothing sent, Visível is to do and Automáticas is 0', (
    tester,
  ) async {
    await openDiarias(tester);
    await scrollTo(tester, find.text('0 automáticas enviadas hoje'));
    expect(visivel(tester).value, isFalse);
    expect(find.text('Faz-se em Listas 2.0 → Visível'), findsOneWidget);
  });

  testWidgets('a Visível ticks it and each Automática is counted', (
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
          names: ['Ana Silva'],
        ),
      );
    }
    await openDiarias(tester);
    await scrollTo(tester, find.text('2 automáticas enviadas hoje'));
    expect(visivel(tester).value, isTrue);
    expect(find.text('37 itens picados · por Ana Silva'), findsOneWidget);
  });
}
