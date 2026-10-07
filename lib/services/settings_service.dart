import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final instance = SettingsService._();

  late SharedPreferences _prefs;

  int _visualGoal = 200;
  int get visualGoal => _visualGoal;

  int _autoGoal = 1;
  int get autoGoal => _autoGoal;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _visualGoal = _prefs.getInt('visualGoal') ?? 200;
    _autoGoal = _prefs.getInt('autoGoal') ?? 1;
  }

  Future<void> setVisualGoal(int goal) async {
    _visualGoal = goal;
    await _prefs.setInt('visualGoal', goal);
    notifyListeners();
  }

  Future<void> setAutoGoal(int goal) async {
    _autoGoal = goal;
    await _prefs.setInt('autoGoal', goal);
    notifyListeners();
  }
}
