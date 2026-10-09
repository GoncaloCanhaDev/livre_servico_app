import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/truck_reception.dart';
import 'package:livre_servico_app/screens/truck_form_screen.dart';
import 'package:livre_servico_app/services/person_service.dart';
import 'package:livre_servico_app/services/sync_meta.dart';
import 'package:livre_servico_app/services/truck_service.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  Future<void> openForm(WidgetTester tester) async {
    final ana = Person()
      ..fullName = 'Ana Silva'
      ..collaboratorNumber = ''
      ..createdAt = DateTime(2026, 1, 1);
    SyncMeta.stamp(ana);
    await dbCall(tester, () => PersonService.instance.save(ana));
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.text('Camiões'));
    await tapAndSettle(tester, find.text('Perecíveis'));
  }

  Future<void> addDepartment(WidgetTester tester, String label) async {
    // The first "Adicionar" is the Paletes one, the second Expositores.
    await tapAndSettle(tester, find.text('Adicionar').first);
    await tapAndSettle(tester, find.text(label));
  }

  Future<void> enterPallets(
    WidgetTester tester,
    String field,
    String value,
  ) async {
    await tester.enterText(find.widgetWithText(TextFormField, field), value);
    await settle(tester);
  }

  Future<List<TruckReception>> trucks(WidgetTester tester) =>
      dbCall(tester, TruckService.instance.all);

  testWidgets('a camião is saved with who received it', (tester) async {
    await openForm(tester);
    await addDepartment(tester, 'Mercearia');
    await enterPallets(tester, 'Total', '5');
    await enterPallets(tester, 'Mistas', '2');
    await tapAndSettle(tester, find.text('Detalhes adicionais'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Matrícula'),
      'aa-11-bb ',
    );

    await tapAndSettle(tester, find.text('Guardar'));
    expect(find.text('Quem recebeu o camião?'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Procurar'), 'ana');
    await settle(tester);
    await tapAndSettle(
      tester,
      find.widgetWithText(CheckboxListTile, 'Ana Silva'),
    );
    await tapAndSettle(tester, find.text('Confirmar (1)'));

    expect(find.text('Enviar por WhatsApp?'), findsOneWidget);
    expect(find.textContaining('Ana Silva'), findsWidgets);
    await tapAndSettle(tester, find.text('Não'));
    expect(find.byType(TruckFormScreen), findsNothing);

    final t = (await trucks(tester)).single;
    expect(t.type, TruckType.pereciveis);
    expect(t.createdByNames, ['Ana Silva']);
    expect(t.licensePlate, 'AA-11-BB');
    expect(t.supplier, isNull);
    expect(t.pallets.single.department, 'mercearia');
    expect(t.pallets.single.total, 5);
    expect(t.pallets.single.mistas, 2);
    expect(t.expositores, isEmpty);
    expect(t.sentVasilhame, isEmpty);
  });

  testWidgets('an empty camião is not saved', (tester) async {
    await openForm(tester);
    await tapAndSettle(tester, find.text('Guardar'));
    expect(
      find.text('Indique pelo menos uma palete, expositor ou vasilhame.'),
      findsOneWidget,
    );
    expect(find.text('Quem recebeu o camião?'), findsNothing);
    expect(await trucks(tester), isEmpty);
  });

  testWidgets('more mistas than paletes is not saved', (tester) async {
    await openForm(tester);
    await addDepartment(tester, 'Bebidas');
    await enterPallets(tester, 'Total', '1');
    await enterPallets(tester, 'Mistas', '3');
    await tapAndSettle(tester, find.text('Guardar'));
    // The departamento is back at the top of the form.
    await tester.scrollUntilVisible(
      find.text('Mistas > total'),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Quem recebeu o camião?'), findsNothing);
    expect(await trucks(tester), isEmpty);
  });
}
