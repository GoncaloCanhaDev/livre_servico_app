import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/store_access.dart';
import 'package:livre_servico_app/models/teams.dart';
import 'package:livre_servico_app/screens/person_detail_screen.dart';
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

  Future<void> seed(WidgetTester tester) async {
    for (final (name, team, number) in [
      ('Ana Silva', livreServicoId, '101'),
      ('Rui Costa', livreServicoId, '102'),
      ('Bia Matos', 'talho', '201'),
    ]) {
      final p = Person()
        ..fullName = name
        ..team = team
        ..collaboratorNumber = number
        ..createdAt = DateTime(2026);
      SyncMeta.stamp(p);
      await dbCall(tester, () => PersonService.instance.save(p));
    }
  }

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await settle(tester);
  }

  testWidgets('empty, it says how to add someone', (tester) async {
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.text('Pessoas'));
    expect(find.textContaining('Sem pessoas.'), findsOneWidget);
  });

  testWidgets('search by name or number, and open a person', (tester) async {
    await pumpApp(tester, const LivreServicoApp());
    await seed(tester);
    await tapAndSettle(tester, find.text('Pessoas'));
    expect(
      find.text('3 pessoas · 3 tempo inteiro · 0 tempo parcial'),
      findsOneWidget,
    );

    await search(tester, 'rui');
    expect(find.text('1 de 3 pessoas'), findsOneWidget);
    expect(find.text('Rui Costa'), findsOneWidget);
    expect(find.text('Ana Silva'), findsNothing);

    await search(tester, '201');
    expect(find.text('Bia Matos'), findsOneWidget);

    await search(tester, 'ninguém');
    expect(find.text('Sem resultados.'), findsOneWidget);

    await tapAndSettle(tester, find.byTooltip('Limpar'));
    expect(
      find.text('3 pessoas · 3 tempo inteiro · 0 tempo parcial'),
      findsOneWidget,
    );

    await search(tester, 'Ana');
    await tapAndSettle(tester, find.text('Ana Silva'));
    expect(find.byType(PersonDetailScreen), findsOneWidget);
  });

  testWidgets('a long press removes someone', (tester) async {
    await pumpApp(tester, const LivreServicoApp());
    await seed(tester);
    await tapAndSettle(tester, find.text('Pessoas'));
    await search(tester, 'Bia');
    await tester.longPress(find.text('Bia Matos'));
    await settle(tester);
    await tapAndSettle(tester, find.text('Remover'));
    expect(find.text('Remover pessoa'), findsOneWidget);
    await tapAndSettle(tester, find.widgetWithText(TextButton, 'Remover'));

    final left = await dbCall(tester, PersonService.instance.all);
    expect(
      left.map((p) => p.fullName),
      unorderedEquals(['Ana Silva', 'Rui Costa']),
    );
    expect(find.text('Bia Matos'), findsNothing);
  });

  testWidgets('an operador can\'t add, edit or remove people', (tester) async {
    AccountService.instance.store = (
      id: 's1',
      name: 'Loja',
      role: StoreRole.editor,
      personId: null,
      pending: false,
      access: const StoreAccess(admin: false, level: 1, team: livreServicoId),
    );
    await pumpApp(tester, const LivreServicoApp());
    await seed(tester);
    await tapAndSettle(tester, find.text('Pessoas'));
    expect(find.byIcon(Icons.add), findsNothing);
    expect(find.byTooltip('Remover todas as pessoas'), findsNothing);

    await search(tester, 'Rui');
    await tester.longPress(find.text('Rui Costa'));
    await settle(tester);
    expect(find.text('Remover'), findsNothing);
    expect(find.text('Editar'), findsNothing);
  });
}
