import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/services/inventory_service.dart';
import 'package:livre_servico_app/services/person_service.dart';
import 'package:livre_servico_app/services/sync_meta.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  Future<void> open(WidgetTester tester) async {
    final ana = Person()
      ..fullName = 'Ana Silva'
      ..collaboratorNumber = ''
      ..createdAt = DateTime(2026, 1, 1);
    SyncMeta.stamp(ana);
    await dbCall(tester, () => PersonService.instance.save(ana));
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.text('Inventários'));
  }

  testWidgets('a planned inventory is to do until marked done', (tester) async {
    await open(tester);
    expect(find.text('Nenhum inventário por fazer.'), findsOneWidget);

    // No store: full access, so it can be planned.
    await tapAndSettle(tester, find.text('Planear inventário'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome'),
      'Conservas',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Código'), '44');
    await tapAndSettle(tester, find.text('Planear'));

    expect(find.text('Conservas'), findsOneWidget);
    expect(find.textContaining('Sem data'), findsOneWidget);
    var toDo = await dbCall(tester, InventoryService.instance.toDo);
    expect([for (final i in toDo) i.name], ['Conservas']);
    expect(await dbCall(tester, InventoryService.instance.history), isEmpty);

    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Feito'));
    await tester.enterText(find.widgetWithText(TextField, 'Procurar'), 'ana');
    await settle(tester);
    await tapAndSettle(
      tester,
      find.widgetWithText(CheckboxListTile, 'Ana Silva'),
    );
    await tapAndSettle(tester, find.text('Confirmar (1)'));
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      '-12,50',
    );
    await tapAndSettle(tester, find.text('Enviar'));
    expect(find.textContaining('Valor: -12,50 €'), findsOneWidget);
    await tapAndSettle(tester, find.text('Não'));

    expect(find.text('Nenhum inventário por fazer.'), findsOneWidget);
    toDo = await dbCall(tester, InventoryService.instance.toDo);
    expect(toDo, isEmpty);
    final done = (await dbCall(
      tester,
      InventoryService.instance.history,
    )).single;
    expect(
      (done.name, done.code, done.finalValueCents, done.createdByNames.join()),
      ('Conservas', '44', -1250, 'Ana Silva'),
    );
    expect(done.isFinalized && !done.isToDo, isTrue);

    await tapAndSettle(tester, find.text('Feitos'));
    expect(find.text('Conservas'), findsOneWidget);
  });
}
