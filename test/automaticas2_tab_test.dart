import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/auto2_entry.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/tabs/automaticas2_tab.dart';
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

  Finder tile(Auto2Item item) => find.widgetWithText(ListTile, item.label);

  /// In the open sheet: 'total', 'porTratar' or 'semStock'.
  Finder field(String count) => find.byKey(ValueKey('auto2:$count'));

  String textOf(WidgetTester tester, String count) =>
      tester.widget<TextField>(field(count)).controller!.text;

  Finder sendButton(Auto2Item item) => find.ancestor(
    of: find.text('Enviar ${item.label}'),
    matching: find.bySubtype<ButtonStyleButton>(),
  );

  /// Opens [item]'s sheet from the list.
  Future<void> pick(WidgetTester tester, Auto2Item item) async {
    await tester.ensureVisible(tile(item));
    await tapAndSettle(tester, tile(item));
    expect(find.byType(BottomSheet), findsOneWidget);
  }

  /// Closes the open sheet without sending.
  Future<void> close(WidgetTester tester) async {
    await tester.tapAt(const Offset(20, 20));
    await settle(tester);
    expect(find.byType(BottomSheet), findsNothing);
  }

  Future<void> type(WidgetTester tester, String count, String value) async {
    await tester.enterText(field(count), value);
    await settle(tester);
  }

  /// Opens [item], types its counts, sends it as done by Ana and returns
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
    await tapAndSettle(tester, sendButton(item));
    expect(find.byType(BottomSheet), findsNothing);
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

  testWidgets('the items are listed in order; each opens its sheet', (
    tester,
  ) async {
    await open(tester);
    final labels = tester
        .widgetList<ListTile>(
          find.descendant(
            of: find.byType(Automaticas2Tab),
            matching: find.byType(ListTile),
          ),
        )
        .map((t) => (t.title! as Text).data)
        .toList();
    expect(labels, [for (final i in Auto2Item.values) i.label]);
    expect(find.text('Enviar Mercearia'), findsNothing);
    await pick(tester, Auto2Item.bebidas);
    expect(find.text('Enviar Bebidas'), findsOneWidget);
    await close(tester);
    expect(Auto2Item.values.first.label, 'Mercearia');
    expect(Auto2Item.values.last.label, 'Não Sortido');
  });

  testWidgets('sending an item saves it to the history and clears it', (
    tester,
  ) async {
    await open(tester);
    await pick(tester, Auto2Item.mercearia);
    expect(
      tester
          .widget<ButtonStyleButton>(sendButton(Auto2Item.mercearia))
          .onPressed,
      isNull,
      reason: 'nothing to send while empty',
    );
    await close(tester);

    final message = await send(tester, Auto2Item.mercearia, '12');
    expect(message, contains('Automáticas · Mercearia: 12 artigos'));
    expect(message, isNot(contains('Por tratar')));
    expect(message, contains('Por: Ana Silva'));
    await pick(tester, Auto2Item.mercearia);
    expect(textOf(tester, 'total'), '');
    await close(tester);

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
    await close(tester);

    final message = await send(
      tester,
      Auto2Item.bebidas,
      '20',
      porTratar: '3',
      semStock: '2',
    );
    expect(message, contains('Bebidas: 20 artigos'));
    expect(message, contains('Tratados: 17 · Por tratar: 3 · Sem stock: 2'));
    await pick(tester, Auto2Item.bebidas);
    expect(textOf(tester, 'porTratar'), '');
    expect(textOf(tester, 'semStock'), '');
    await close(tester);

    final row = (await history(tester)).single;
    expect(
      (row.value, row.porTratar, row.semStock, row.tratados),
      (20, 3, 2, 17),
    );
    expect(row.summary, '20 · 3 por tratar · 2 sem stock');
  });

  testWidgets('counts not sent are listed and kept after leaving', (
    tester,
  ) async {
    await open(tester);
    await pick(tester, Auto2Item.bebidas);
    await type(tester, 'total', '20');
    await type(tester, 'semStock', '1');
    await close(tester);
    expect(
      find.descendant(of: tile(Auto2Item.bebidas), matching: find.text('20')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: tile(Auto2Item.bebidas),
        matching: find.text('1 sem stock'),
      ),
      findsOneWidget,
    );

    // Leaving the app: everything on screen is gone.
    await pumpApp(tester, const SizedBox());
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.text('Listas 2.0'));
    expect(
      find.descendant(of: tile(Auto2Item.bebidas), matching: find.text('20')),
      findsOneWidget,
    );
    await pick(tester, Auto2Item.bebidas);
    expect(textOf(tester, 'total'), '20');
    expect(textOf(tester, 'semStock'), '1');
    await close(tester);

    await pick(tester, Auto2Item.mercearia);
    expect(textOf(tester, 'total'), '');
  });
}
