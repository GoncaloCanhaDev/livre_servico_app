import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final instance = SettingsService._();

  late SharedPreferences _prefs;

  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? false;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool('notificationsEnabled', enabled);
    notifyListeners();
  }
}
