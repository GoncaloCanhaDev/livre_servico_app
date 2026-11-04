import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/auto2_entry.dart';
import 'package:livre_servico_app/models/opening_list.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/widgets/number_row.dart';
import 'package:livre_servico_app/services/auto2_service.dart';
import 'package:livre_servico_app/services/local_db.dart';
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

  Future<void> toTop(WidgetTester tester) async {
    await tester.drag(find.byType(ListView), const Offset(0, 2000));
    await settle(tester);
  }

  Finder field(Auto2Item item) => find.descendant(
    of: find.widgetWithText(NumberRow, item.label),
    matching: find.byType(TextField),
  );

  /// Types [value] into [item], ticks it as done by Ana and returns the
  /// WhatsApp message offered, declining to send it.
  Future<String> tick(WidgetTester tester, Auto2Item item, String value) async {
    await tester.enterText(field(item), value);
    await settle(tester);
    await tapAndSettle(
      tester,
      find.byTooltip('Marcar ${item.label} como feita'),
    );
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

  Future<Map<Auto2Item, Auto2Entry>> today(WidgetTester tester) =>
      dbCall(tester, () => Auto2Service.instance.forDay(currentServiceDay()));

  testWidgets('the items show in order', (tester) async {
    await open(tester);
    final labels = tester
        .widgetList<NumberRow>(find.byType(NumberRow))
        .map((r) => r.label)
        .toList();
    expect(labels, [
      for (final i in Auto2Item.values.take(labels.length)) i.label,
    ]);
    expect(Auto2Item.values.first.label, 'Mercearia');
    expect(Auto2Item.values.last.label, 'Não Sortido');
  });

  testWidgets('ticking an item saves it, by whom, and offers WhatsApp', (
    tester,
  ) async {
    await open(tester);
    final message = await tick(tester, Auto2Item.mercearia, '12');
    expect(message, contains('Automáticas · Mercearia: 12'));
    expect(message, contains('Por: Ana Silva'));

    expect(find.textContaining('Por Ana Silva · '), findsOneWidget);
    await toTop(tester);
    expect(find.text('1/12 feitas'), findsOneWidget);
    expect(
      tester.widget<TextField>(field(Auto2Item.mercearia)).enabled,
      isFalse,
    );

    final entries = await today(tester);
    expect(entries.keys, [Auto2Item.mercearia]);
    final e = entries[Auto2Item.mercearia]!;
    expect(e.value, 12);
    expect(e.byNames, ['Ana Silva']);
    expect(e.isDone, isTrue);
    expect(
      LocalDb.instance.auto2Entries.syncKeyOf(e),
      'mercearia/${dayKey(currentServiceDay())}',
    );
  });

  testWidgets('unticking clears it', (tester) async {
    await open(tester);
    await tick(tester, Auto2Item.petFood, '3');
    await tapAndSettle(tester, find.byTooltip('Desmarcar Pet Food'));
    await tapAndSettle(tester, find.text('Desmarcar'));

    await toTop(tester);
    expect(find.text('0/12 feitas'), findsOneWidget);
    expect(tester.widget<TextField>(field(Auto2Item.petFood)).enabled, isTrue);
    final e = (await today(tester))[Auto2Item.petFood]!;
    expect(e.isDone, isFalse);
    expect(e.value, 0);
    expect(e.byNames, isEmpty);
  });
}
