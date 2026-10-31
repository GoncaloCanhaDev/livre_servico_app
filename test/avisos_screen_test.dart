import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/store_access.dart';
import 'package:livre_servico_app/models/teams.dart';
import 'package:livre_servico_app/screens/aviso_form_screen.dart';
import 'package:livre_servico_app/screens/avisos_screen.dart';
import 'package:livre_servico_app/services/account_service.dart';
import 'package:livre_servico_app/services/aviso_service.dart';
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

  void signedInAs(StoreAccess access) => AccountService.instance.store = (
    id: 's1',
    name: 'Loja',
    role: StoreRole.editor,
    personId: access.personId,
    pending: false,
    access: access,
  );

  Future<Person> saved(
    WidgetTester tester,
    String name,
    String team, [
    Role role = Role.operador,
  ]) async {
    final p = Person()
      ..fullName = name
      ..team = team
      ..role = role.name
      ..createdAt = DateTime(2026);
    SyncMeta.stamp(p);
    await dbCall(tester, () => PersonService.instance.save(p));
    return p;
  }

  Future<void> open(WidgetTester tester, Widget screen) async {
    await pumpApp(tester, const LivreServicoApp());
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute<void>(builder: (_) => screen));
    await settle(tester);
  }

  testWidgets('a chefe sends an aviso to their team', (tester) async {
    final chefe = await saved(tester, 'Rui', 'talho', Role.chefeSeccao);
    final t1 = await saved(tester, 'Ana', 'talho');
    final t2 = await saved(tester, 'Bia', 'talho');
    await saved(tester, 'Pedro', 'peixaria');
    signedInAs(
      StoreAccess(
        admin: false,
        level: 3,
        team: 'talho',
        personId: chefe.syncUuid,
      ),
    );
    await open(tester, const AvisoFormScreen());
    expect(find.text('Peixaria'), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Aviso'),
      'Falta a validade da noite',
    );
    await tapAndSettle(tester, find.text('Talho'));
    expect(find.text('2 pessoas'), findsOneWidget);
    await tapAndSettle(tester, find.text('Enviar'));

    final sent = (await dbCall(tester, AvisoService.instance.all)).single;
    expect(sent.text, 'Falta a validade da noite');
    expect(sent.toPersonIds, [t1.syncUuid, t2.syncUuid]);
    expect((sent.fromPersonId, sent.fromName), (chefe.syncUuid, 'Rui'));
  });

  testWidgets('the recipient sees it on Home and clears it with Visto', (
    tester,
  ) async {
    final ana = await saved(tester, 'Ana', 'talho');
    await dbCall(
      tester,
      () => AvisoService.instance.send(
        'Atualizem as folgas',
        [ana.syncUuid],
        fromPersonId: 'chefe',
        fromName: 'Rui',
      ),
    );
    signedInAs(StoreAccess(admin: false, personId: ana.syncUuid));
    await pumpApp(tester, const LivreServicoApp());
    expect(find.text('Atualizem as folgas'), findsOneWidget);
    expect(find.textContaining('De Rui'), findsOneWidget);

    await tapAndSettle(tester, find.text('Visto'));
    expect(find.text('Atualizem as folgas'), findsNothing);
    expect(await dbCall(tester, AvisoService.instance.vistos), hasLength(1));
  });

  testWidgets('a level 1 member has no Novo aviso', (tester) async {
    final ana = await saved(tester, 'Ana', 'talho');
    signedInAs(StoreAccess(admin: false, personId: ana.syncUuid));
    await open(tester, const AvisosScreen());
    expect(find.text('Recebidos'), findsOneWidget);
    expect(find.text('Enviados'), findsNothing);
    expect(find.text('Novo aviso'), findsNothing);
  });

  testWidgets('the sender sees who has seen it', (tester) async {
    final chefe = await saved(tester, 'Rui', 'talho', Role.chefeSeccao);
    final ana = await saved(tester, 'Ana', 'talho');
    final bia = await saved(tester, 'Bia', 'talho');
    final a = await dbCall(
      tester,
      () => AvisoService.instance.send(
        'Arrumar o armazém',
        [ana.syncUuid, bia.syncUuid],
        fromPersonId: chefe.syncUuid,
        fromName: 'Rui',
      ),
    );
    await dbCall(tester, () => AvisoService.instance.markSeen(a, ana.syncUuid));
    signedInAs(
      StoreAccess(
        admin: false,
        level: 3,
        team: 'talho',
        personId: chefe.syncUuid,
      ),
    );
    await open(tester, const AvisosScreen());
    await tapAndSettle(tester, find.text('Enviados'));
    expect(find.textContaining('Visto por 1 de 2'), findsOneWidget);
    await tapAndSettle(tester, find.text('Arrumar o armazém'));
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Por ver'), findsOneWidget);
    expect(find.text('Bia'), findsOneWidget);
  });
}
