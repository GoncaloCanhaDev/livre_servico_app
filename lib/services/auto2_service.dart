import 'package:flutter/foundation.dart';

import '../models/auto2_entry.dart';
import 'local_db.dart';
import 'sync_meta.dart';

/// Listas 2.0 → Automáticas: each item's number and tick per service day.
class Auto2Service extends ChangeNotifier {
  Auto2Service._() {
    LocalDb.listenRemote(const {'Auto2Entry'}, notifyListeners);
  }
  static final Auto2Service instance = Auto2Service._();

  LocalDb get _db => LocalDb.instance;

  /// The rows of [serviceDay], by [Auto2Item]. An item missing has nothing
  /// saved yet.
  Future<Map<Auto2Item, Auto2Entry>> forDay(DateTime serviceDay) async {
    final rows = await _db.auto2Entries.where(
      (e) => e.serviceDay.isAtSameMomentAs(serviceDay),
    );
    return {for (final e in rows) ?Auto2Item.byName(e.item): e};
  }

  /// Ticks [item] on [serviceDay] as [value], done by [names]. Returns
  /// false when it was already ticked there (by another phone, say).
  Future<bool> complete({
    required DateTime serviceDay,
    required Auto2Item item,
    required int value,
    required List<String> names,
    bool backdated = false,
  }) async {
    final existing = (await forDay(serviceDay))[item];
    if (existing != null && existing.isDone) return false;
    final row =
        existing ??
        (Auto2Entry()
          ..serviceDay = serviceDay
          ..item = item.name);
    row
      ..value = value
      ..doneAt = DateTime.now()
      ..byNames = names
      ..backdated = backdated;
    SyncMeta.stamp(row);
    await _db.auto2Entries.put(row);
    notifyListeners();
    return true;
  }

  /// Unticks [entry]: its number can be typed again.
  Future<void> undo(Auto2Entry entry) async {
    entry
      ..value = 0
      ..doneAt = null
      ..byNames = []
      ..backdated = false;
    SyncMeta.stamp(entry);
    await _db.auto2Entries.put(entry);
    notifyListeners();
  }
}
