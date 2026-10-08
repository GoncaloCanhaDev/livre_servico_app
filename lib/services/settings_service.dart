import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vasilhame.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final instance = SettingsService._();

  late SharedPreferences _prefs;

  int _visualGoal = 200;
  int get visualGoal => _visualGoal;

  /// The vasilhame list offered on a camião, edited through the backup
  /// file's `"vasilhame"` section; [defaultVasilhame] until a non-empty list
  /// is imported.
  List<VasilhameItem> _vasilhame = const [];
  List<VasilhameItem> get vasilhame =>
      _vasilhame.isEmpty ? defaultVasilhame : _vasilhame;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _visualGoal = _prefs.getInt('visualGoal') ?? 200;
    try {
      _vasilhame = vasilhameFromJson(
        jsonDecode(_prefs.getString('vasilhame') ?? '[]'),
      );
    } on FormatException {
      _vasilhame = const [];
    }
  }

  Future<void> setVasilhame(List<VasilhameItem> items) async {
    _vasilhame = List.unmodifiable(items);
    await _prefs.setString(
      'vasilhame',
      jsonEncode([for (final i in items) i.toJson()]),
    );
    notifyListeners();
  }

  Future<void> setVisualGoal(int goal) async {
    _visualGoal = goal;
    await _prefs.setInt('visualGoal', goal);
    notifyListeners();
  }
}
