import 'dart:convert';

import 'package:flutter/material.dart' show ChangeNotifier, ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/release_notes.dart';
import '../models/vasilhame.dart';

/// The tutorial's sections before it had versions (0.74.0), all version 1.
const _tutorialSectionsBefore074 = [
  'inicio',
  'tarefas',
  'listas',
  'camioes',
  'inventarios',
  'pessoas',
  'informacoes',
  'historico',
  'avisos',
  'conta',
];

class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final instance = SettingsService._();

  late SharedPreferences _prefs;

  int _visualGoal = 200;
  int get visualGoal => _visualGoal;

  /// Claro (the default), Escuro or Automático (follows the device).
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  /// The version of each tutorial section last seen (finished, skipped or
  /// its card on Home closed), by section id; 0 when never seen. A section
  /// whose version went up since shows again on Home.
  Map<String, int> _tutorialSeen = const {};
  int tutorialSeenVersion(String section) => _tutorialSeen[section] ?? 0;

  /// The vasilhame list offered on a camião, edited through the backup
  /// file's `"vasilhame"` section; [defaultVasilhame] until a non-empty list
  /// is imported.
  List<VasilhameItem> _vasilhame = const [];
  List<VasilhameItem> get vasilhame =>
      _vasilhame.isEmpty ? defaultVasilhame : _vasilhame;

  /// The newest app version whose "Novidades" this device has seen; null on
  /// a first install (nothing to tell yet).
  String? _releaseNotesSeen;
  String? get releaseNotesSeen => _releaseNotesSeen;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _visualGoal = _prefs.getInt('visualGoal') ?? 200;
    _tutorialSeen = _readTutorialSeen();
    _releaseNotesSeen =
        _prefs.getString('releaseNotesSeen') ??
        // Used before the popup existed (read before `LocalDb.init` sets
        // `syncBackfilled` on a first start): seen up to then.
        ((_prefs.getBool('syncBackfilled') ?? false) || _tutorialSeen.isNotEmpty
            ? releaseNotesBaseline
            : null);
    _themeMode =
        ThemeMode.values.asNameMap()[_prefs.getString('themeMode')] ??
        ThemeMode.light;
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

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString('themeMode', mode.name);
    notifyListeners();
  }

  /// Marks these tutorial sections (id → version) as seen.
  Future<void> setTutorialSeen(Map<String, int> versions) async {
    _tutorialSeen = {..._tutorialSeen, ...versions};
    await _prefs.setString('tutorialSeenVersions', jsonEncode(_tutorialSeen));
    notifyListeners();
  }

  Future<void> setReleaseNotesSeen(String version) async {
    _releaseNotesSeen = version;
    await _prefs.setString('releaseNotesSeen', version);
  }

  Map<String, int> _readTutorialSeen() {
    try {
      final saved = _prefs.getString('tutorialSeenVersions');
      if (saved != null) {
        return {
          for (final MapEntry(:key, :value)
              in (jsonDecode(saved) as Map<String, dynamic>).entries)
            if (value is int) key: value,
        };
      }
    } on FormatException {
      // Read as never seen.
    }
    // Before 0.74.0 the tutorial was one whole, seen or not: seen means
    // every section it had then, at version 1.
    if (_prefs.getBool('tutorialSeen') ?? false) {
      return {for (final id in _tutorialSectionsBefore074) id: 1};
    }
    return const {};
  }

  Future<void> setVisualGoal(int goal) async {
    _visualGoal = goal;
    await _prefs.setInt('visualGoal', goal);
    notifyListeners();
  }
}
