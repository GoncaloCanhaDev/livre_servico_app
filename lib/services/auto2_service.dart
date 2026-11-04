import 'package:flutter/foundation.dart';

import '../models/auto2_entry.dart';
import '../models/opening_list.dart';
import 'local_db.dart';
import 'sync_meta.dart';

/// Listas 2.0 → Automáticas: each send of an item, kept in Histórico.
class Auto2Service extends ChangeNotifier {
  Auto2Service._() {
    LocalDb.listenRemote(const {'Auto2Entry'}, notifyListeners);
  }
  static final Auto2Service instance = Auto2Service._();

  LocalDb get _db => LocalDb.instance;

  /// Saves [item] as [value], done by [names]: now, or on [serviceDay]
  /// (then at noon, flagged backdated) when it was an earlier day.
  Future<Auto2Entry> send({
    required Auto2Item item,
    required int value,
    required List<String> names,
    DateTime? serviceDay,
  }) async {
    final entry = Auto2Entry()
      ..createdAt = serviceDay == null
          ? DateTime.now()
          : DateTime(serviceDay.year, serviceDay.month, serviceDay.day, 12)
      ..item = item.name
      ..value = value
      ..byNames = names
      ..backdated = serviceDay != null;
    SyncMeta.stamp(entry);
    await _db.auto2Entries.put(entry);
    notifyListeners();
    return entry;
  }

  /// The sends of service [day] (one backdated to it included).
  Future<List<Auto2Entry>> forServiceDay(DateTime day) => _db.auto2Entries
      .where((e) => currentServiceDay(e.createdAt).isAtSameMomentAs(day));

  Future<void> delete(int id) async {
    if (await _db.auto2Entries.softDelete(id)) notifyListeners();
  }

  Future<void> deleteAll() async {
    if (await _db.auto2Entries.softDeleteAll()) notifyListeners();
  }

  /// Newest first.
  Future<List<Auto2Entry>> history({bool includeDeleted = false}) async =>
      (await _db.auto2Entries.all(includeDeleted: includeDeleted))
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
