import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('people sort is unset by default and survives a reload', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsService.instance;
    await settings.init();
    expect(settings.peopleSort, isNull);

    await settings.setPeopleSort('role');
    await settings.init();
    expect(settings.peopleSort, 'role');
  });
}
