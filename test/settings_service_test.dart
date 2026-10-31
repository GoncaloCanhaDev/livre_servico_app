import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('the light theme is the default', () async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();
    expect(SettingsService.instance.themeMode, ThemeMode.light);
  });

  test('a theme chosen before is kept', () async {
    SharedPreferences.setMockInitialValues({'themeMode': 'system'});
    await SettingsService.instance.init();
    expect(SettingsService.instance.themeMode, ThemeMode.system);
  });
}
