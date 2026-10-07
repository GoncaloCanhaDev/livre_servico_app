import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final instance = SettingsService._();

  late SharedPreferences _prefs;

  int _visualGoal = 200;
  int get visualGoal => _visualGoal;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _visualGoal = _prefs.getInt('visualGoal') ?? 200;
  }

  Future<void> setVisualGoal(int goal) async {
    _visualGoal = goal;
    await _prefs.setInt('visualGoal', goal);
    notifyListeners();
  }
}
