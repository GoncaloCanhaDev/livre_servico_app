import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/store_access.dart';

void main() {
  StoreAccess read(Map<String, dynamic> j) => StoreAccess.fromJson({
    'admin': false,
    'gerencia': false,
    'chefe_team': null,
    'person_id': null,
    ...j,
  });

  test('chefes, Gerência and the admin approve requests', () {
    expect(read({'chefe_team': 'talho', 'person_id': 'p1'}).canApprove, isTrue);
    expect(read({'gerencia': true}).canApprove, isTrue);
    expect(read({'admin': true}).canApprove, isTrue);
    expect(read({'person_id': 'p1'}).canApprove, isFalse);
    expect(StoreAccess.full.canApprove, isTrue);
  });

  test('round trip through JSON', () {
    final a = read({
      'chefe_team': 'talho',
      'person_id': 'p1',
      'gerencia': true,
    });
    final b = StoreAccess.fromJson(a.toJson());
    expect(b.chefeTeam, 'talho');
    expect(b.personId, 'p1');
    expect(b.gerencia, isTrue);
    expect(b.admin, isFalse);
    expect(b, a);
  });

  test('missing keys read as no access', () {
    final a = StoreAccess.fromJson(const {});
    expect(a.canApprove, isFalse);
    expect(a.personId, isNull);
  });

  group('who sees and edits each part of a profile', () {
    Person person(String uuid, String team) => Person()
      ..fullName = uuid
      ..team = team
      ..createdAt = DateTime(2026)
      ..syncUuid = uuid;
    final ana = person('ana', 'talho');
    final rui = person('rui', 'peixaria');

    test('a member: their own profile only', () {
      final a = read({'person_id': 'ana'});
      expect(a.canSeePersonal(ana), isTrue);
      expect(a.canSeePersonal(rui), isFalse);
      expect(a.canEdit(ana, PersonFieldGroup.self), isTrue);
      expect(a.canEdit(ana, PersonFieldGroup.schedule), isFalse);
      expect(a.canEdit(ana, PersonFieldGroup.role), isFalse);
      expect(a.canEdit(ana, PersonFieldGroup.other), isFalse);
      expect(a.canEdit(rui, PersonFieldGroup.self), isFalse);
      expect(a.canRequestUpdate(ana), isFalse);
      expect(a.canRequestUpdate(rui), isFalse);
      expect(a.canAddPeople, isFalse);
      expect(a.canDeletePeople, isFalse);
    });

    test("a chefe: their team's folgas and ausências", () {
      final a = read({'chefe_team': 'talho', 'person_id': 'chefe'});
      expect(a.canSeePersonal(ana), isTrue);
      expect(a.canSeePersonal(rui), isFalse);
      expect(a.canEdit(ana, PersonFieldGroup.schedule), isTrue);
      expect(a.canEdit(ana, PersonFieldGroup.role), isFalse);
      expect(a.canEdit(ana, PersonFieldGroup.self), isFalse);
      expect(a.canEdit(rui, PersonFieldGroup.schedule), isFalse);
      expect(a.canRequestUpdate(ana), isTrue);
      expect(a.canRequestUpdate(rui), isFalse);
      expect(a.canAddPeople, isFalse);
    });

    test('Gerência: everyone, folgas, ausências and roles', () {
      final a = read({'gerencia': true, 'person_id': 'g'});
      expect(a.canSeePersonal(rui), isTrue);
      expect(a.canEdit(rui, PersonFieldGroup.schedule), isTrue);
      expect(a.canEdit(rui, PersonFieldGroup.role), isTrue);
      expect(a.canEdit(rui, PersonFieldGroup.self), isFalse);
      expect(a.canEdit(rui, PersonFieldGroup.other), isFalse);
      expect(a.canRequestUpdate(rui), isTrue);
      expect(a.canAddPeople, isTrue);
      expect(a.canDeletePeople, isFalse);
    });

    test('the admin and no store: everything', () {
      for (final a in [
        read({'admin': true}),
        StoreAccess.full,
      ]) {
        expect(a.canSeePersonal(rui), isTrue);
        for (final g in PersonFieldGroup.values) {
          expect(a.canEdit(rui, g), isTrue);
        }
        expect(a.canRequestUpdate(rui), isTrue);
        expect(a.canAddPeople, isTrue);
        expect(a.canDeletePeople, isTrue);
      }
    });

    test('nobody asks themselves for an update', () {
      expect(
        read({'gerencia': true, 'person_id': 'rui'}).canRequestUpdate(rui),
        isFalse,
      );
    });
  });

  test('Gerência and the admin manage members; only the admin wipes', () {
    expect(read({'gerencia': true}).canManageMembers, isTrue);
    expect(read({'admin': true}).canManageMembers, isTrue);
    expect(read({'chefe_team': 'talho'}).canManageMembers, isFalse);
    expect(read({}).canManageMembers, isFalse);
    expect(read({'gerencia': true}).canWipeAll, isFalse);
    expect(read({'admin': true}).canWipeAll, isTrue);
    expect(StoreAccess.full.canWipeAll, isTrue);
  });
}
