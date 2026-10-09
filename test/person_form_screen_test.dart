import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/person_form_screen.dart';
import 'package:livre_servico_app/services/person_service.dart';
import 'package:livre_servico_app/services/sync_meta.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  Future<void> openForm(WidgetTester tester, [Person? existing]) async {
    await pumpApp(tester, const LivreServicoApp());
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(
          MaterialPageRoute<void>(
            builder: (_) => PersonFormScreen(existing: existing),
          ),
        );
    await settle(tester);
  }

  Future<List<Person>> people(WidgetTester tester) =>
      dbCall(tester, PersonService.instance.all);

  testWidgets('a new person is saved with what was filled in', (tester) async {
    await openForm(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome completo'),
      'Ana Silva',
    );
    await tapAndSettle(tester, find.text('Permanência'));
    await tapAndSettle(tester, find.text('Seg'));
    await tapAndSettle(tester, find.text('Qui'));
    await tapAndSettle(tester, find.text('Qui')); // ticked off again
    await tapAndSettle(tester, find.text('Dom'));

    // The ausência dialog can't be saved without dates.
    await tapAndSettle(tester, find.text('Adicionar ausência'));
    expect(find.text('Nova ausência'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Guardar'))
          .onPressed,
      isNull,
    );
    await tapAndSettle(tester, find.text('Cancelar'));

    final newNote = find.widgetWithText(TextField, 'Nova nota');
    await scrollTo(tester, newNote);
    await tester.enterText(newNote, 'Chaves do armazém');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    await tester.enterText(newNote, 'Sem pesados');

    await tapAndSettle(tester, find.text('Adicionar'));
    expect(find.byType(PersonFormScreen), findsNothing);

    final saved = await people(tester);
    expect(saved, hasLength(1));
    final p = saved.single;
    expect(p.fullName, 'Ana Silva');
    expect(p.permanencia, isTrue);
    expect(p.folgas, [DateTime.monday, DateTime.sunday]);
    expect(p.notes, ['Chaves do armazém', 'Sem pesados']);
    expect(p.team, isNull);
  });

  testWidgets('a name is required', (tester) async {
    await openForm(tester);
    await tapAndSettle(tester, find.text('Adicionar'));
    expect(find.text('Obrigatório'), findsOneWidget);
    expect(find.byType(PersonFormScreen), findsOneWidget);
    expect(await people(tester), isEmpty);
  });

  testWidgets('editing removes a note and a folga', (tester) async {
    final existing = Person()
      ..fullName = 'Rui Costa'
      ..collaboratorNumber = ''
      ..createdAt = DateTime(2026, 1, 1)
      ..folgas = [DateTime.tuesday, DateTime.saturday]
      ..notes = ['Primeira', 'Segunda'];
    SyncMeta.stamp(existing);
    await dbCall(tester, () => PersonService.instance.save(existing));

    await openForm(tester, existing);
    expect(find.text('Editar pessoa'), findsOneWidget);

    await tapAndSettle(tester, find.text('Sáb'));
    final first = find.byWidgetPredicate(
      (w) => w is TextField && w.controller?.text == 'Primeira',
    );
    await scrollTo(tester, first);
    await tapAndSettle(
      tester,
      find.descendant(of: first, matching: find.byIcon(Icons.close)),
    );
    await tapAndSettle(tester, find.text('Guardar'));

    final p = (await people(tester)).single;
    expect(p.notes, ['Segunda']);
    expect(p.folgas, [DateTime.tuesday]);
  });
}
