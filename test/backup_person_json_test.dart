import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/services/backup_service.dart';

void main() {
  test('drops the pre-0.32 cargo and manager keys from a Person row', () {
    final old = {
      'id': 3,
      'fullName': 'Ana',
      'role': 'Operadora',
      'managerUuid': 'x',
      'managerUuids': ['x', 'y'],
    };
    expect(personJsonForImport(old), {'id': 3, 'fullName': 'Ana'});
    expect(old.containsKey('role'), isTrue, reason: 'input is not mutated');
  });

  test('leaves current rows untouched', () {
    final row = {'id': 1, 'fullName': 'Rui', 'team': 'talho', 'chefe': null};
    expect(personJsonForImport(row), row);
  });
}
