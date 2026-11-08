import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/auto2_entry.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/widgets/number_row.dart';
import 'package:livre_servico_app/services/auto2_service.dart';
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
    await tapAndSettle(tester, find.text('Listas 2.0'));
  }

  Finder field(Auto2Item item) => find.descendant(
    of: find.widgetWithText(NumberRow, item.label),
    matching: find.byType(TextField),
  );

  /// Picks [item]'s chip, which may also show its count.
  Future<void> pick(WidgetTester tester, Auto2Item item) => tapAndSettle(
    tester,
    find.ancestor(
      of: find.textContaining(item.label),
      matching: find.byType(ChoiceChip),
    ),
  );

  /// Types [value] into [item], sends it as done by Ana and returns the
  /// WhatsApp message offered, declining to send it.

  Future<String> send(WidgetTester tester, Auto2Item item, String value) async {
    await pick(tester, item);
    await tester.enterText(field(item), value);
    await settle(tester);
    await tapAndSettle(tester, find.byTooltip('Enviar ${item.label}'));
    expect(find.text('Quem fez ${item.label}?'), findsOneWidget);
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
            matching: find.textContaining('Automáticas'),
          ),
        )
        .data!;
    await tapAndSettle(tester, find.text('Não'));
    return message;
  }

  Future<List<Auto2Entry>> history(WidgetTester tester) =>
      dbCall(tester, Auto2Service.instance.history);

  testWidgets('the items show in order, one field at a time', (tester) async {
    await open(tester);
    final labels = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .map((c) => (c.label as Text).data)
        .toList();
    expect(labels, [for (final i in Auto2Item.values) i.label]);
    expect(find.byType(NumberRow), findsOneWidget);
    expect(find.widgetWithText(NumberRow, 'Mercearia'), findsOneWidget);
    await pick(tester, Auto2Item.bebidas);
    expect(find.widgetWithText(NumberRow, 'Bebidas'), findsOneWidget);
    expect(Auto2Item.values.first.label, 'Mercearia');
    expect(Auto2Item.values.last.label, 'Não Sortido');
  });

  testWidgets('sending an item saves it to the history and clears it', (
    tester,
  ) async {
    await open(tester);
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send))
          .onPressed,
      isNull,
      reason: 'nothing to send while empty',
    );

    final message = await send(tester, Auto2Item.mercearia, '12');
    expect(message, contains('Automáticas · Mercearia: 12'));
    expect(message, contains('Por: Ana Silva'));
    expect(
      tester.widget<TextField>(field(Auto2Item.mercearia)).controller!.text,
      '',
    );

    await send(tester, Auto2Item.mercearia, '4');
    final rows = await history(tester);
    expect(
      [for (final r in rows) (r.item, r.value, r.byNames.join(', '))],
      [('mercearia', 4, 'Ana Silva'), ('mercearia', 12, 'Ana Silva')],
    );
    expect(rows.every((r) => !r.backdated), isTrue);
  });

  testWidgets('a count not sent is kept after leaving', (tester) async {
    await open(tester);
    await pick(tester, Auto2Item.bebidas);
    await tester.enterText(field(Auto2Item.bebidas), '20');
    await settle(tester);
    // Leaving the app: everything on screen is gone.
    await pumpApp(tester, const SizedBox());
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.text('Listas 2.0'));

    expect(find.text('Bebidas · 20'), findsOneWidget);
    expect(
      tester.widget<TextField>(field(Auto2Item.bebidas)).controller!.text,
      '20',
      reason: 'the first item with a count opens',
    );
    await send(tester, Auto2Item.bebidas, '20');
    expect(find.text('Bebidas · 20'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, 'Bebidas'), findsOneWidget);
  });
}
