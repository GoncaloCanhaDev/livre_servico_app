import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/person.dart';
import 'person_service.dart';
import 'sync_meta.dart';

/// Stores month-end snapshots of per-person points, then resets live points to
/// zero at the start of a new month. Snapshots live in SharedPreferences as
/// JSON; the volume (people × months) stays small.
///
/// Storage shape:
///   `personMonthlyPoints` → List of {yearMonth: int (yyyymm), entries: [{uuid, name, collab, points}]}
///   `personPointsResetYearMonth` → int (yyyymm) — the month `points` currently
///                                  belongs to. When we detect a newer real
///                                  month, we snapshot and reset.
class PersonHistoryService extends ChangeNotifier {
  PersonHistoryService._();
  static final instance = PersonHistoryService._();

  static const _kSnapshotsKey = 'personMonthlyPoints';
  static const _kResetMonthKey = 'personPointsResetYearMonth';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int _yearMonth(DateTime d) => d.year * 100 + d.month;

  /// Called on app startup. If the current month is newer than the last
  /// tracked month, snapshot every person's current [points] into history
  /// (under the *previous* month) and reset live points to 0.
  ///
  /// On first launch (no stored reset month), just records the current month
  /// without snapshotting or resetting.
  Future<void> maybeRollover({DateTime? now}) async {
    final reference = now ?? DateTime.now();
    final currentYm = _yearMonth(reference);
    final storedYm = _prefs.getInt(_kResetMonthKey);
    if (storedYm == null) {
      await _prefs.setInt(_kResetMonthKey, currentYm);
      return;
    }
    if (storedYm >= currentYm) return;

    final people = await PersonService.instance.all();
    final entries = <Map<String, dynamic>>[
      for (final p in people)
        {
          'uuid': p.syncUuid,
          'name': p.fullName,
          'collab': p.collaboratorNumber,
          'points': p.points,
        },
    ];
    await _appendSnapshot(storedYm, entries);

    if (people.isNotEmpty) {
      final isar = PersonService.instance.isar;
      await isar.writeTxn(() async {
        for (final p in people) {
          p.points = 0;
          SyncMeta.stamp(p);
          await isar.persons.put(p);
        }
      });
    }

    await _prefs.setInt(_kResetMonthKey, currentYm);
    notifyListeners();
    PersonService.instance.notifyExternal();
  }

  Future<void> _appendSnapshot(
    int yearMonth,
    List<Map<String, dynamic>> entries,
  ) async {
    final raw = _prefs.getString(_kSnapshotsKey);
    final list = raw == null ? <dynamic>[] : (jsonDecode(raw) as List<dynamic>);
    list.removeWhere(
      (m) => (m as Map<String, dynamic>)['yearMonth'] as int == yearMonth,
    );
    list.add({'yearMonth': yearMonth, 'entries': entries});
    await _prefs.setString(_kSnapshotsKey, jsonEncode(list));
  }

  /// Returns all past-month snapshots, sorted newest first.
  List<PersonMonthlySnapshot> history() {
    final raw = _prefs.getString(_kSnapshotsKey);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    final out = <PersonMonthlySnapshot>[];
    for (final m in list) {
      final map = m as Map<String, dynamic>;
      final ym = map['yearMonth'] as int;
      final entriesRaw = (map['entries'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final entries =
          entriesRaw
              .map(
                (e) => PersonMonthlyEntry(
                  uuid: e['uuid'] as String? ?? '',
                  fullName: e['name'] as String? ?? '',
                  collaboratorNumber: e['collab'] as String? ?? '',
                  points: (e['points'] as num?)?.toInt() ?? 0,
                ),
              )
              .toList()
            ..sort((a, b) => b.points.compareTo(a.points));
      out.add(
        PersonMonthlySnapshot(
          year: ym ~/ 100,
          month: ym % 100,
          entries: entries,
        ),
      );
    }
    out.sort((a, b) {
      final ay = a.year * 100 + a.month;
      final by = b.year * 100 + b.month;
      return by.compareTo(ay);
    });
    return out;
  }

  /// The month the live `points` field currently accumulates into. Used to
  /// label the current-month leaderboard.
  int? currentTrackedYearMonth() => _prefs.getInt(_kResetMonthKey);

  /// For debugging / manual retriggering.
  Future<void> clearAll() async {
    await _prefs.remove(_kSnapshotsKey);
    await _prefs.remove(_kResetMonthKey);
  }
}

class PersonMonthlySnapshot {
  const PersonMonthlySnapshot({
    required this.year,
    required this.month,
    required this.entries,
  });
  final int year;
  final int month;
  final List<PersonMonthlyEntry> entries;
}

class PersonMonthlyEntry {
  const PersonMonthlyEntry({
    required this.uuid,
    required this.fullName,
    required this.collaboratorNumber,
    required this.points,
  });
  final String uuid;
  final String fullName;
  final String collaboratorNumber;
  final int points;
}
