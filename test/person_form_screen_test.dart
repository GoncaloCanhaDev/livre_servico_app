import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/store_access.dart';
import 'package:livre_servico_app/models/teams.dart';
import 'package:livre_servico_app/screens/people_screen.dart';
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

  group('Função', () {
    /// Opens the dropdown showing [current] (mid-screen, clear of the app
    /// bar).
    Future<void> open(WidgetTester tester, String current) async {
      // "Equipa" is both the heading and the field's label.
      await scrollTo(
        tester,
        Role.values.any((r) => r.label == current)
            ? find.text('Função')
            : find.text('Equipa').last,
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 250));
      await settle(tester);
      await tester.tap(find.text(current).last);
      await settle(tester);
    }

    Future<void> pick(
      WidgetTester tester,
      String current,
      String choice,
    ) async {
      await open(tester, current);
      await tester.tap(find.text(choice).last);
      await settle(tester);
    }

    testWidgets('saves the chosen Função', (tester) async {
      await openForm(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome completo'),
        'Zé',
      );
      await pick(tester, 'Sem equipa', 'Talho');
      await pick(tester, 'Operador', 'Chefe de Secção');
      await tapAndSettle(tester, find.text('Adicionar'));

      final p = (await people(tester)).single;
      expect((p.team, p.role, p.chefe), ('talho', 'chefeSeccao', null));
    });

    testWidgets('Gestor de Área only offered in Gerência', (tester) async {
      await openForm(tester);
      await pick(tester, 'Sem equipa', 'Talho');
      await pick(tester, 'Operador', 'Supervisor');
      expect(find.text('Gestor de Área'), findsNothing);
      await pick(tester, 'Talho', 'Gerência');
      await open(tester, 'Supervisor');
      expect(find.text('Gestor de Área'), findsWidgets);
    });

    testWidgets('a chefe only gives roles below their own', (tester) async {
      final rui = await saved(
        tester,
        Person()
          ..fullName = 'Rui'
          ..team = 'talho'
          ..createdAt = DateTime(2026),
      );
      signedInAs(
        const StoreAccess(admin: false, level: 3, team: 'talho', personId: 'c'),
      );
      await openForm(tester, rui);
      await open(tester, 'Operador');
      expect(find.text('Supervisor'), findsWidgets);
      expect(find.text('Chefe de Secção'), findsNothing);
    });
  });

  testWidgets('a birthday is a day and a month, no year', (tester) async {
    await openForm(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome completo'),
      'Ana Silva',
    );
    expect(find.text('Data de nascimento'), findsNothing);
    final birthday = find.byType(DropdownButtonFormField<int?>);
    // Mid-screen, clear of the app bar.
    await scrollTo(tester, birthday.first);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 250));
    await settle(tester);
    await tester.tap(birthday.first);
    await settle(tester);
    await tester.tap(find.text('9').last);
    await settle(tester);
    await tester.tap(birthday.last);
    await settle(tester);
    await tester.tap(find.text('março').last);
    await settle(tester);
    await tapAndSettle(tester, find.text('Adicionar'));

    final p = (await people(tester)).single;
    expect((p.birthDay, p.birthMonth), (9, 3));
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
      ..collaboratorNumber = '900'
      ..createdAt = DateTime(2026);

    testWidgets('a member edits their own name and phone only', (tester) async {
      final ana = await saved(tester, talho('Ana'));
      signedInAs(StoreAccess(admin: false, personId: ana.syncUuid));
      await openForm(tester, ana);
      expect(editable(tester, 'Nome completo'), isTrue);
      expect(editable(tester, 'Aniversário (opcional)'), isTrue);
      expect(find.text('Telefone (opcional)'), findsNothing);
      expect(editable(tester, 'Nº colaborador (opcional)'), isFalse);
      await scrollTo(tester, find.text('Talho'));
      expect(editable(tester, 'Talho'), isFalse);
      await scrollTo(tester, find.text('Seg'));
      expect(editable(tester, 'Seg'), isFalse);
    });

    testWidgets("a chefe edits their team's folgas and roles, not the name", (
      tester,
    ) async {
      final rui = await saved(tester, talho('Rui'));
      signedInAs(
        const StoreAccess(
          admin: false,
          level: 3,
          team: 'talho',
          personId: 'chefe',
        ),
      );
      await openForm(tester, rui);
      expect(editable(tester, 'Nome completo'), isFalse);
      await scrollTo(tester, find.text('Talho'));
      expect(editable(tester, 'Talho'), isTrue);
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
        signedInAs(StoreAccess(admin: false, personId: ana.syncUuid));
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
          level: 3,
          team: 'talho',
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
      signedInAs(const StoreAccess(admin: false));
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

    Future<void> openPessoas(WidgetTester tester) async {
      await pumpApp(tester, const LivreServicoApp());
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(MaterialPageRoute<void>(builder: (_) => const PeopleScreen()));
      await settle(tester);
    }

    testWidgets("the admin sees each person's store under the name", (
      tester,
    ) async {
      await saved(
        tester,
        talho('Ana')
          ..team = 'livre_servico'
          ..turno = 'dia',
      );
      signedInAs(const StoreAccess(admin: true));
      await openPessoas(tester);
      await scrollTo(tester, find.text('Ana'));
      expect(find.textContaining('Loja'), findsOneWidget);
    });

    testWidgets('nobody else sees the store there', (tester) async {
      await saved(
        tester,
        talho('Ana')
          ..team = 'livre_servico'
          ..turno = 'dia',
      );
      signedInAs(const StoreAccess(admin: false, level: 4, team: 'gerencia'));
      await openPessoas(tester);
      await scrollTo(tester, find.text('Ana'));
      expect(find.textContaining('Loja'), findsNothing);
    });
  });
}
