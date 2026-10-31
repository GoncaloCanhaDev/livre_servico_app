import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/teams.dart';
import 'package:livre_servico_app/services/local_db.dart';
import 'package:livre_servico_app/services/person_service.dart';

import 'helpers/app_db.dart';

Person _p(String name, String team, Role role, {String? turno}) => Person()
  ..fullName = name
  ..createdAt = DateTime(2026)
  ..team = team
  ..role = role.name
  ..turno = turno;

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  Future<Role> roleNow(Person p) async =>
      roleOf((await LocalDb.instance.persons.get(p.id))!);

  test('a new Gerente demotes the old one', () async {
    final g1 = _p('Ana', 'gerencia', Role.gerente);
    final g2 = _p('Rui', 'gerencia', Role.gerente);
    await PersonService.instance.save(g1);
    await PersonService.instance.save(g2);
    expect(await roleNow(g1), Role.operador);
    expect(await roleNow(g2), Role.gerente);
  });

  test('a new Chefe de Secção demotes an old chefe of the team', () async {
    final old = Person()
      ..fullName = 'Velho'
      ..createdAt = DateTime(2026)
      ..team = 'talho'
      ..chefe = 'chefe';
    await PersonService.instance.save(old);
    await PersonService.instance.save(_p('Novo', 'talho', Role.chefeSeccao));
    final back = (await LocalDb.instance.persons.get(old.id))!;
    expect(roleOf(back), Role.operador);
    expect(back.chefe, isNull);
  });
}
