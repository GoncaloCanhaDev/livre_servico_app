import 'package:flutter/foundation.dart';

import '../models/opening_list.dart';
import '../models/visivel2_entry.dart';
import 'local_db.dart';
import 'sync_meta.dart';

/// Listas 2.0 → Visível: each one saved, kept in Histórico.
class Visivel2Service extends ChangeNotifier {
  Visivel2Service._() {
    LocalDb.listenRemote(const {'Visivel2Entry'}, notifyListeners);
  }
  static final Visivel2Service instance = Visivel2Service._();

  LocalDb get _db => LocalDb.instance;

  /// Saves [itens] picked by [names]: now, or on [serviceDay] (at noon,
  /// flagged backdated) when it was an earlier day.
  Future<Visivel2Entry> add({
    required int itens,
    required List<String> names,
    DateTime? serviceDay,
  }) async {
    final now = DateTime.now();
    final entry = Visivel2Entry()
      ..createdAt = serviceDay == null
          ? now
          : DateTime(serviceDay.year, serviceDay.month, serviceDay.day, 12)
      ..serviceDay = serviceDay ?? currentServiceDay(now)
      ..itens = itens
      ..byNames = names
      ..backdated = serviceDay != null;
    SyncMeta.stamp(entry);
    await _db.visivel2Entries.put(entry);
    notifyListeners();
    return entry;
  }

  /// Newest first.
  Future<List<Visivel2Entry>> forServiceDay(DateTime day) async =>
      (await _db.visivel2Entries.where(
        (v) => v.serviceDay.isAtSameMomentAs(day),
      ))..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> delete(int id) async {
    if (await _db.visivel2Entries.softDelete(id)) notifyListeners();
  }

  Future<void> deleteAll() async {
    if (await _db.visivel2Entries.softDeleteAll()) notifyListeners();
  }

  /// Newest first.
  Future<List<Visivel2Entry>> history({bool includeDeleted = false}) async =>
      (await _db.visivel2Entries.all(includeDeleted: includeDeleted))
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
