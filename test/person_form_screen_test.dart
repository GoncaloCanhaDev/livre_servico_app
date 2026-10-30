import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/store_access.dart';
import 'package:livre_servico_app/screens/person_detail_screen.dart';
import 'package:livre_servico_app/screens/person_form_screen.dart';
import 'package:livre_servico_app/screens/widgets/edit_lock.dart';
import 'package:livre_servico_app/services/account_service.dart';
import 'package:livre_servico_app/services/person_service.dart';
import 'package:livre_servico_app/services/sync_meta.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(() async {
    AccountService.instance.store = null;
    await closeAppDb();
  });

  /// Connected to a store as [access] (no network: nothing syncs).
  void signedInAs(StoreAccess access) => AccountService.instance.store = (
    id: 's1',
    name: 'Loja',
    role: StoreRole.editor,
    personId: access.personId,
    pending: false,
    access: access,
  );

  /// Whether the field showing [text] can be changed.
  bool editable(WidgetTester tester, String text) => tester
      .widget<EditLock>(
        find.ancestor(
          of: find.text(text).last,
          matching: find.byType(EditLock),
        ),
      )
      .enabled;

  Future<Person> saved(WidgetTester tester, Person p) async {
    SyncMeta.stamp(p);
    await dbCall(tester, () => PersonService.instance.save(p));
    return p;
  }

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

  group('fields follow the account', () {
    Person talho(String name) => Person()
      ..fullName = name
      ..team = 'talho'
      ..phoneNumber = '900'
      ..createdAt = DateTime(2026);

    testWidgets('a member edits their own name and phone only', (tester) async {
      final ana = await saved(tester, talho('Ana'));
      signedInAs(
        StoreAccess(admin: false, gerencia: false, personId: ana.syncUuid),
      );
      await openForm(tester, ana);
      expect(editable(tester, 'Nome completo'), isTrue);
      expect(editable(tester, 'Telefone (opcional)'), isTrue);
      expect(editable(tester, 'Nº colaborador (opcional)'), isFalse);
      await scrollTo(tester, find.text('Talho'));
      expect(editable(tester, 'Talho'), isFalse);
      await scrollTo(tester, find.text('Seg'));
      expect(editable(tester, 'Seg'), isFalse);
    });

    testWidgets("a chefe edits their team's folgas, not the name", (
      tester,
    ) async {
      final rui = await saved(tester, talho('Rui'));
      signedInAs(
        const StoreAccess(
          admin: false,
          gerencia: false,
          chefeTeam: 'talho',
          personId: 'chefe',
        ),
      );
      await openForm(tester, rui);
      expect(editable(tester, 'Nome completo'), isFalse);
      await scrollTo(tester, find.text('Talho'));
      expect(editable(tester, 'Talho'), isFalse);
      await scrollTo(tester, find.text('Seg'));
      expect(editable(tester, 'Seg'), isTrue);
      await tapAndSettle(tester, find.text('Seg'));
      await tapAndSettle(tester, find.text('Guardar'));
      expect((await people(tester)).single.folgas, [DateTime.monday]);
    });

    testWidgets('no store: everything can be changed', (tester) async {
      final rui = await saved(tester, talho('Rui'));
      await openForm(tester, rui);
      expect(editable(tester, 'Nome completo'), isTrue);
      expect(editable(tester, 'Nº colaborador (opcional)'), isTrue);
      await scrollTo(tester, find.text('Talho'));
      expect(editable(tester, 'Talho'), isTrue);
    });

    testWidgets(
      'a request to update shows on Home until the profile is saved',
      (tester) async {
        final ana = await saved(
          tester,
          talho('Ana')
            ..profileUpdateRequestedAt = DateTime(2026, 10, 30)
            ..profileUpdateRequestedBy = 'Chefe Rui',
        );
        signedInAs(
          StoreAccess(admin: false, gerencia: false, personId: ana.syncUuid),
        );
        await pumpApp(tester, const LivreServicoApp());
        expect(find.text('Atualize o seu perfil'), findsOneWidget);
        expect(find.textContaining('Chefe Rui'), findsOneWidget);

        await tapAndSettle(tester, find.text('Atualize o seu perfil'));
        expect(find.byType(PersonFormScreen), findsOneWidget);
        await tapAndSettle(tester, find.text('Guardar'));

        expect(find.text('Atualize o seu perfil'), findsNothing);
        expect((await people(tester)).single.profileUpdateRequestedAt, isNull);
      },
    );

    testWidgets('a chefe asks a team member to update their profile', (
      tester,
    ) async {
      final chefe = await saved(tester, talho('Rui Chefe')..chefe = 'chefe');
      final ana = await saved(tester, talho('Ana'));
      signedInAs(
        StoreAccess(
          admin: false,
          gerencia: false,
          chefeTeam: 'talho',
          personId: chefe.syncUuid,
        ),
      );
      await pumpApp(tester, const LivreServicoApp());
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(
              builder: (_) => PersonDetailScreen(person: ana),
            ),
          );
      await settle(tester);

      await tapAndSettle(tester, find.byTooltip('Pedir atualização'));
      await tapAndSettle(tester, find.text('Pedir'));

      final asked = (await people(
        tester,
      )).firstWhere((p) => p.fullName == 'Ana');
      expect(asked.profileUpdateRequestedBy, 'Rui Chefe');
      expect(asked.profileUpdateRequestedAt, isNotNull);
    });

    testWidgets('a member cannot add, edit others or remove people', (
      tester,
    ) async {
      final ana = await saved(tester, talho('Ana'));
      signedInAs(const StoreAccess(admin: false, gerencia: false));
      await pumpApp(tester, const LivreServicoApp());
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(
              builder: (_) => PersonDetailScreen(person: ana),
            ),
          );
      await settle(tester);
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byTooltip('Pedir atualização'), findsNothing);
    });
  });
}
