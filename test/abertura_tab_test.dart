import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/opening_list.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/widgets/number_row.dart';
import 'package:livre_servico_app/services/opening_list_service.dart';
import 'package:livre_servico_app/services/person_service.dart';
import 'package:livre_servico_app/services/sync_meta.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  Future<void> openAbertura(WidgetTester tester) async {
    final ana = Person()
      ..fullName = 'Ana Silva'
      ..collaboratorNumber = ''
      ..createdAt = DateTime(2026, 1, 1);
    SyncMeta.stamp(ana);
    await dbCall(tester, () => PersonService.instance.save(ana));
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.text('Listas'));
  }

  /// Types [value] into [section], sends it as done by Ana and returns the
  /// WhatsApp message offered, declining to send it.
  Future<String> send(
    WidgetTester tester,
    ListSection section,
    String value,
  ) async {
    await tester.enterText(
      find.descendant(
        of: find.widgetWithText(NumberRow, section.label),
        matching: find.byType(TextField),
      ),
      value,
    );
    await settle(tester);
    await tapAndSettle(tester, find.byTooltip('Enviar ${section.label}'));
    expect(find.text('Quem fez ${section.label}?'), findsOneWidget);
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
            matching: find.textContaining('Lista de Abertura'),
          ),
        )
        .data!;
    await tapAndSettle(tester, find.text('Não'));
    return message;
  }

  Future<OpeningList> today(WidgetTester tester) =>
      dbCall(tester, OpeningListService.instance.currentOrCreate);

  testWidgets('a section is sent on its own', (tester) async {
    await openAbertura(tester);
    final message = await send(tester, ListSection.congelados, '12');
    expect(message, contains('Congelados: 12'));
    expect(message, contains('Por: Ana Silva'));
    expect(message, isNot(contains('completa')));

    expect(find.text('Por Ana Silva'), findsOneWidget);
    final list = await today(tester);
    expect(list.valueOf(ListSection.congelados), 12);
    expect(list.namesOf(ListSection.congelados), ['Ana Silva']);
    expect(list.isSectionDone(ListSection.congelados), isTrue);
    expect(list.isSectionDone(ListSection.opls), isFalse);
    expect(list.isFinalized, isFalse);
  });

  testWidgets('the list finalizes once all three are sent', (tester) async {
    await openAbertura(tester);
    await send(tester, ListSection.congelados, '12');
    await send(tester, ListSection.opls, '3');
    final last = await send(tester, ListSection.naoPereciveis, '4');
    expect(last, contains('Lista de Abertura completa · Total: 19'));

    expect(find.textContaining('Finalizada às'), findsOneWidget);
    final list = await today(tester);
    expect(list.isFinalized, isTrue);
    expect(list.total, 19);
  });
}
