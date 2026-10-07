import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/person.dart';
import '../models/teams.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class PersonService extends ChangeNotifier {
  PersonService._();
  static final PersonService instance = PersonService._();

  Isar get _isar => ShiftService.instance.isar;
  Isar get isar => _isar;

  /// Lets external services (e.g. month rollover) tell listeners the person
  /// data changed after they mutated it directly.
  void notifyExternal() => notifyListeners();

  /// Saves [p]. If [p] is now a chefe, whoever else held that team's slot
  /// loses it in the same transaction (one holder per slot).
  Future<int> save(Person p) async {
    SyncMeta.stamp(p);
    final others = await _isar.persons.filter().syncDeletedAtIsNull().findAll();
    final demoted = chefeConflicts(p, others);
    for (final d in demoted) {
      d.chefe = null;
      SyncMeta.stamp(d);
    }
    late int id;
    await _isar.writeTxn(() async {
      id = await _isar.persons.put(p);
      await _isar.persons.putAll(demoted);
    });
    notifyListeners();
    return id;
  }

  Future<void> delete(int id) async {
    final row = await _isar.persons.get(id);
    if (row == null || row.syncDeletedAt != null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() => _isar.persons.put(row));
    notifyListeners();
  }

  Future<List<Person>> all() => _isar.persons
      .filter()
      .syncDeletedAtIsNull()
      .sortByFullName()
      .findAll();

  Future<void> deleteAll() async {
    final rows = await _isar.persons.filter().syncDeletedAtIsNull().findAll();
    if (rows.isEmpty) return;
    for (final r in rows) {
      SyncMeta.softDelete(r);
    }
    await _isar.writeTxn(() => _isar.persons.putAll(rows));
    notifyListeners();
  }
}

