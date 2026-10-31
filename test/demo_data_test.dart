import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/aviso.dart';
import 'package:livre_servico_app/models/opening_list.dart';
import 'package:livre_servico_app/models/planning.dart';
import 'package:livre_servico_app/models/teams.dart';
import 'package:livre_servico_app/services/account_service.dart';
import 'package:livre_servico_app/services/demo_data.dart';
import 'package:livre_servico_app/services/local_db.dart';

import 'helpers/app_db.dart';

void main() {
  setUp(openAppDb);
  tearDown(() async {
    AccountService.instance.store = null;
    await closeAppDb();
  });

  final now = DateTime(2026, 10, 31, 11);
  LocalDb db() => LocalDb.instance;

  test('every role is there', () async {
    await seedDemo(now: now);
    final people = await db().persons.all();
    expect(people.length, greaterThanOrEqualTo(15));
    expect(people.map(roleOf).toSet(), Role.values.toSet());
    expect(people.every((p) => p.syncUuid.isNotEmpty), isTrue);
  });

  test('the visitor is the Livre Serviço Chefe de Secção, dia', () async {
    final me = await seedDemo(now: now);
    final p = (await db().persons.firstWhere((p) => p.syncUuid == me))!;
    expect(
      (roleOf(p), p.team, turnoOf(p)),
      (Role.chefeSeccao, livreServicoId, Turno.dia),
    );
    final store = AccountService.instance.store!;
    expect((store.personId, store.access.level, store.pending), (me, 3, false));
  });

  test('today is alive', () async {
    await seedDemo(now: now);
    final people = await db().persons.all();
    final today = currentServiceDay(now);
    expect(people.where((p) => isBirthdayOn(p, today)), isNotEmpty);
    expect(people.where((p) => awayTagOn(p, today) != null), isNotEmpty);
    expect(
      people.where((p) => tenureTagOf(p, today) == 'Em formação'),
      isNotEmpty,
    );
    final daily = await db().dailyTasks.firstWhere(
      (t) => t.serviceDay.isAtSameMomentAs(today),
    );
    expect(daily, isNotNull);
    expect(daily!.verificacaoTemperaturas, isTrue);
    expect(daily.kiwiFecho, isFalse);
    expect(await db().truckReceptions.all(), isNotEmpty);
    expect(await db().inventories.all(), isNotEmpty);
    expect(await db().infoEntries.all(), isNotEmpty);
  });

  test('an unseen aviso waits for the visitor', () async {
    final me = await seedDemo(now: now);
    final avisos = await db().avisos.all();
    expect(
      avisosOnHome(avisos, await db().avisoVistos.all(), me, now),
      isNotEmpty,
    );
    expect(avisosSent(avisos, me, now), isNotEmpty);
  });

  test('a pedido is overdue', () async {
    await seedDemo(now: now);
    final pedidos = await db().pedidos.all();
    expect(
      pedidos.where(
        (p) =>
            p.finishedAt == null &&
            p.expectedDate != null &&
            p.expectedDate!.isBefore(now.subtract(const Duration(days: 1))),
      ),
      isNotEmpty,
    );
  });
}
