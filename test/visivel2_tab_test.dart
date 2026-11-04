import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/widgets/number_row.dart';
import 'package:livre_servico_app/services/person_service.dart';
import 'package:livre_servico_app/services/sync_meta.dart';
import 'package:livre_servico_app/services/visivel2_service.dart';

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
    await tapAndSettle(tester, find.text('Listas 2.0'));
    await tapAndSettle(tester, find.text('Visível'));
  }

  Finder field() => find.descendant(
    of: find.widgetWithText(NumberRow, 'Itens Picados'),
    matching: find.byType(TextField),
  );

  /// Types [value], finalizes as Ana and returns the WhatsApp message
  /// offered, declining to send it.
  Future<String> finalize(WidgetTester tester, String value) async {
    await tester.enterText(field(), value);
    await settle(tester);
    await tapAndSettle(tester, find.text('Finalizar'));
    expect(find.text('Quem fez o Visível?'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Procurar'), 'ana');
    await settle(tester);
    await tapAndSettle(
      tester,
      find.widgetWithText(CheckboxListTile, 'Ana Silva'),
    );
    await tapAndSettle(tester, find.text('Confirmar (1)'));
    final message = tester
        .widget<Text>(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.textContaining('Visível'),
          ),
        )
        .data!;
    await tapAndSettle(tester, find.text('Não'));
    return message;
  }

  testWidgets('a Visível is saved, cleared, and never locked', (tester) async {
    await open(tester);
    final message = await finalize(tester, '37');
    expect(message, contains('Itens Picados: 37'));
    expect(message, contains('Por: Ana Silva'));
    expect(message, isNot(contains('Quebra')));
    expect(tester.widget<TextField>(field()).controller!.text, '');
    expect(find.text('Hoje  ·  1 visível'), findsOneWidget);

    await finalize(tester, '5');
    expect(find.text('Hoje  ·  2 visíveis'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    final rows = await dbCall(tester, Visivel2Service.instance.history);
    expect([for (final r in rows) r.itens], [5, 37]);
    expect(rows.every((r) => r.byNames.join() == 'Ana Silva'), isTrue);
  });
}
