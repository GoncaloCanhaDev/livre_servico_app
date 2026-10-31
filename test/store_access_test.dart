import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/store_access.dart';
import 'package:livre_servico_app/models/teams.dart';

void main() {
  Person person(String uuid, String? team, [Role role = Role.operador]) =>
      Person()
        ..fullName = uuid
        ..team = team
        ..role = role.name
        ..createdAt = DateTime(2026)
        ..syncUuid = uuid;

  final talho1 = person('t1', 'talho');
  final peixe = person('px', 'peixaria');
  final talhoChefe = person('tc', 'talho', Role.chefeSeccao);
  final ger = person('ger', 'gerencia', Role.gestorArea);
  final gerente = person('gte', 'gerencia', Role.gerente);
  final semEquipa = person('se', null);

  const member = StoreAccess(admin: false, team: 'talho', personId: 't1');
  const seg = StoreAccess(admin: false, level: 2, team: 'talho');
  const chefe = StoreAccess(
    admin: false,
    level: 3,
    team: 'talho',
    personId: 'c',
  );
  const gestor = StoreAccess(admin: false, level: 4, team: 'gerencia');
  const gerenteAcc = StoreAccess(admin: false, level: 5, team: 'gerencia');
  const admin = StoreAccess(admin: true);

  test('reach', () {
    expect(member.reaches(talho1), isFalse);
    expect(seg.reaches(talho1), isTrue);
    expect(seg.reaches(semEquipa), isFalse);
    expect(chefe.reaches(talho1), isTrue);
    expect(chefe.reaches(peixe), isFalse);
    expect(chefe.reaches(ger), isFalse);
    expect(chefe.reaches(semEquipa), isTrue);
    expect(gestor.reaches(talho1), isTrue);
    expect(gestor.reaches(semEquipa), isTrue);
    expect(gestor.reaches(ger), isFalse);
    expect(gerenteAcc.reaches(ger), isTrue);
    expect(admin.reaches(gerente), isTrue);
  });

  test('a member: their own profile only', () {
    expect(member.canSeePersonal(talho1), isTrue);
    expect(member.canSeePersonal(peixe), isFalse);
    expect(member.canEdit(talho1, PersonFieldGroup.self), isTrue);
    expect(member.canEdit(talho1, PersonFieldGroup.schedule), isFalse);
    expect(member.canEdit(talho1, PersonFieldGroup.role), isFalse);
    expect(member.canEdit(peixe, PersonFieldGroup.self), isFalse);
    expect(member.canRequestUpdate(talho1), isFalse);
    expect(member.canAddPeople, isFalse);
    expect(member.canDeletePerson(talho1), isFalse);
  });

  test('only above: no edits at the same level, the Gerente hands over', () {
    expect(chefe.canEdit(talho1, PersonFieldGroup.role), isTrue);
    expect(chefe.canEdit(talhoChefe, PersonFieldGroup.role), isFalse);
    expect(chefe.canEdit(talhoChefe, PersonFieldGroup.schedule), isTrue);
    expect(gestor.canEdit(talhoChefe, PersonFieldGroup.role), isTrue);
    expect(gerenteAcc.canEdit(gerente, PersonFieldGroup.role), isTrue);
    expect(seg.canEdit(talho1, PersonFieldGroup.schedule), isFalse);
    expect(chefe.canEdit(talho1, PersonFieldGroup.other), isFalse);
    expect(admin.canEdit(talho1, PersonFieldGroup.other), isTrue);
  });

  test('level 3 and up may lower their own role', () {
    final me = person('c', 'talho', Role.chefeSeccao);
    expect(chefe.canEdit(me, PersonFieldGroup.role), isTrue);
    expect(chefe.canDeletePerson(me), isFalse);
    expect(
      const StoreAccess(
        admin: false,
        level: 2,
        team: 'talho',
        personId: 's',
      ).canEdit(person('s', 'talho', Role.segundaLinha), PersonFieldGroup.role),
      isFalse,
    );
  });

  test('delete, add, approve, members', () {
    expect(chefe.canDeletePerson(talho1), isTrue);
    expect(chefe.canDeletePerson(peixe), isFalse);
    expect(chefe.canDeletePerson(talhoChefe), isFalse);
    expect(gestor.canDeletePerson(ger), isFalse);
    expect(gerenteAcc.canDeletePerson(ger), isTrue);
    expect(seg.canAddPeople, isFalse);
    expect(chefe.canAddPeople, isTrue);
    expect(chefe.canApprove, isTrue);
    expect(seg.canApprove, isFalse);
    expect(chefe.canManageMembers, isFalse);
    expect(gestor.canManageMembers, isTrue);
    expect(gerenteAcc.canDeleteAll, isFalse);
    expect(admin.canDeleteAll, isTrue);
    expect(gerenteAcc.canWipeAll, isFalse);
  });

  test('assignable roles and teams', () {
    expect(chefe.assignableRoles('talho'), [
      Role.operador,
      Role.segundaLinha,
      Role.supervisor,
    ]);
    expect(gestor.assignableRoles('gerencia'), [
      Role.operador,
      Role.segundaLinha,
      Role.supervisor,
      Role.chefeSeccao,
    ]);
    expect(gerenteAcc.assignableRoles('gerencia'), Role.values);
    expect(admin.assignableRoles('talho'), rolesIn('talho'));
    expect(chefe.assignableTeams, ['talho', null]);
    expect(gestor.assignableTeams, [
      for (final t in teams)
        if (t.id != gerenciaId) t.id,
      null,
    ]);
    expect(gerenteAcc.assignableTeams, [for (final t in teams) t.id, null]);
    expect(member.assignableTeams, isEmpty);
  });

  test('personal data and update requests by reach from level 3', () {
    expect(chefe.canSeePersonal(talho1), isTrue);
    expect(seg.canSeePersonal(talho1), isFalse);
    expect(chefe.canSeePersonal(ger), isFalse);
    expect(gestor.canSeePersonal(talho1), isTrue);
    expect(chefe.canRequestUpdate(talho1), isTrue);
    expect(chefe.canRequestUpdate(peixe), isFalse);
  });

  test('signed out: everything', () {
    expect(StoreAccess.full.canEdit(gerente, PersonFieldGroup.role), isTrue);
    expect(StoreAccess.full.canDeleteAll, isTrue);
    expect(StoreAccess.full.assignableRoles('gerencia'), Role.values);
  });

  test('fromJson reads levels and old cached access', () {
    expect(
      StoreAccess.fromJson({'admin': false, 'level': 4, 'team': 'gerencia'}),
      gestor,
    );
    final old = StoreAccess.fromJson({'admin': false, 'gerencia': true});
    expect((old.level, old.team), (4, 'gerencia'));
    expect(
      StoreAccess.fromJson({
        'admin': false,
        'chefe_team': 'talho',
        'person_id': 'c',
      }),
      chefe,
    );
    expect(StoreAccess.fromJson(chefe.toJson()), chefe);
    expect(StoreAccess.fromJson(const {}).level, 1);
  });
}
