import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final instance = SettingsService._();

  late SharedPreferences _prefs;

  int _visualGoal = 200;
  int get visualGoal => _visualGoal;

  /// Name of the Pessoas list's last sort mode (a `PeopleSort` value), or
  /// null if it was never changed.
  String? _peopleSort;
  String? get peopleSort => _peopleSort;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _visualGoal = _prefs.getInt('visualGoal') ?? 200;
    _peopleSort = _prefs.getString('peopleSort');
  }

  Future<void> setVisualGoal(int goal) async {
    _visualGoal = goal;
    await _prefs.setInt('visualGoal', goal);
    notifyListeners();
  }

  Future<void> setPeopleSort(String sort) async {
    _peopleSort = sort;
    await _prefs.setString('peopleSort', sort);
  }
}
