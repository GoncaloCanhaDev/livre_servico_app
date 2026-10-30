import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/store_access.dart';

void main() {
  StoreAccess read(Map<String, dynamic> j) => StoreAccess.fromJson({
    'admin': false,
    'owner': false,
    'gerencia': false,
    'chefe_team': null,
    'person_id': null,
    ...j,
  });

  test('chefes, Gerência, the owner and the admin approve requests', () {
    expect(read({'chefe_team': 'talho', 'person_id': 'p1'}).canApprove, isTrue);
    expect(read({'gerencia': true}).canApprove, isTrue);
    expect(read({'owner': true}).canApprove, isTrue);
    expect(read({'admin': true}).canApprove, isTrue);
    expect(read({'person_id': 'p1'}).canApprove, isFalse);
    expect(StoreAccess.full.canApprove, isTrue);
  });

  test('round trip through JSON', () {
    final a = read({'chefe_team': 'talho', 'person_id': 'p1', 'owner': true});
    final b = StoreAccess.fromJson(a.toJson());
    expect(b.chefeTeam, 'talho');
    expect(b.personId, 'p1');
    expect(b.owner, isTrue);
    expect(b.admin, isFalse);
    expect(b.gerencia, isFalse);
    expect(b, a);
  });

  test('missing keys read as no access', () {
    final a = StoreAccess.fromJson(const {});
    expect(a.canApprove, isFalse);
    expect(a.personId, isNull);
  });
}
