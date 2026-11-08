import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/auto2_entry.dart';
import 'package:livre_servico_app/models/person.dart';
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

  /// The selected item's field: 'total', 'porTratar' or 'semStock'.
  Finder field(String count) => find.byKey(ValueKey('auto2:$count'));

  String textOf(WidgetTester tester, String count) =>
      tester.widget<TextField>(field(count)).controller!.text;

  Finder sendButton(Auto2Item item) => find.ancestor(
    of: find.text('Enviar ${item.label}'),
    matching: find.bySubtype<ButtonStyleButton>(),
  );

  /// Picks [item]'s chip, which may also show its count.
  Future<void> pick(WidgetTester tester, Auto2Item item) => tapAndSettle(
    tester,
    find.ancestor(
      of: find.textContaining(item.label),
      matching: find.byType(ChoiceChip),
    ),
  );

  Future<void> type(WidgetTester tester, String count, String value) async {
    await tester.enterText(field(count), value);
    await settle(tester);
  }

  /// Picks [item], types its counts, sends it as done by Ana and returns
  /// the WhatsApp message offered, declining to send it.
  Future<String> send(
    WidgetTester tester,
    Auto2Item item,
    String value, {
    String porTratar = '',
    String semStock = '',
  }) async {
    await pick(tester, item);
    await type(tester, 'total', value);
    if (porTratar.isNotEmpty) await type(tester, 'porTratar', porTratar);
    if (semStock.isNotEmpty) await type(tester, 'semStock', semStock);
    await tester.ensureVisible(sendButton(item));
    await tapAndSettle(tester, sendButton(item));
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

  testWidgets('the items show in order, one at a time', (tester) async {
    await open(tester);
    final labels = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .map((c) => (c.label as Text).data)
        .toList();
    expect(labels, [for (final i in Auto2Item.values) i.label]);
    expect(find.text('Enviar Mercearia'), findsOneWidget);
    await pick(tester, Auto2Item.bebidas);
    expect(find.text('Enviar Bebidas'), findsOneWidget);
    expect(Auto2Item.values.first.label, 'Mercearia');
    expect(Auto2Item.values.last.label, 'Não Sortido');
  });

  testWidgets('sending an item saves it to the history and clears it', (
    tester,
  ) async {
    await open(tester);
    expect(
      tester
          .widget<ButtonStyleButton>(sendButton(Auto2Item.mercearia))
          .onPressed,
      isNull,
      reason: 'nothing to send while empty',
    );

    final message = await send(tester, Auto2Item.mercearia, '12');
    expect(message, contains('Automáticas · Mercearia: 12 artigos'));
    expect(message, isNot(contains('Por tratar')));
    expect(message, contains('Por: Ana Silva'));
    expect(textOf(tester, 'total'), '');

    await send(tester, Auto2Item.mercearia, '4');
    final rows = await history(tester);
    expect(
      [for (final r in rows) (r.item, r.value, r.byNames.join(', '))],
      [('mercearia', 4, 'Ana Silva'), ('mercearia', 12, 'Ana Silva')],
    );
    expect(rows.every((r) => !r.backdated), isTrue);
  });

  testWidgets('por tratar and sem stock are sent with the total', (
    tester,
  ) async {
    await open(tester);
    await pick(tester, Auto2Item.bebidas);
    await type(tester, 'total', '20');
    await type(tester, 'porTratar', '25');
    expect(
      find.text('Por tratar não pode ser mais do que os artigos na lista.'),
      findsOneWidget,
    );
    expect(
      tester.widget<ButtonStyleButton>(sendButton(Auto2Item.bebidas)).onPressed,
      isNull,
    );

    final message = await send(
      tester,
      Auto2Item.bebidas,
      '20',
      porTratar: '3',
      semStock: '2',
    );
    expect(message, contains('Bebidas: 20 artigos'));
    expect(message, contains('Tratados: 17 · Por tratar: 3 · Sem stock: 2'));
    expect(textOf(tester, 'porTratar'), '');
    expect(textOf(tester, 'semStock'), '');

    final row = (await history(tester)).single;
    expect(
      (row.value, row.porTratar, row.semStock, row.tratados),
      (20, 3, 2, 17),
    );
    expect(row.summary, '20 · 3 por tratar · 2 sem stock');
  });

  testWidgets('counts not sent are kept after leaving', (tester) async {
    await open(tester);
    await pick(tester, Auto2Item.bebidas);
    await type(tester, 'total', '20');
    await type(tester, 'semStock', '1');
    // Leaving the app: everything on screen is gone.
    await pumpApp(tester, const SizedBox());
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.text('Listas 2.0'));

    expect(find.text('Bebidas · 20'), findsOneWidget);
    expect(
      find.text('Enviar Bebidas'),
      findsOneWidget,
      reason: 'the first item with a count opens',
    );
    expect(textOf(tester, 'total'), '20');
    expect(textOf(tester, 'semStock'), '1');

    await pick(tester, Auto2Item.mercearia);
    expect(textOf(tester, 'total'), '');
  });
}
