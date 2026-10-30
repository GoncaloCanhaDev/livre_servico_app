import 'package:flutter/foundation.dart';

import '../models/person.dart';
import '../models/teams.dart';
import 'account_service.dart';
import 'local_db.dart';
import 'sync_meta.dart';

class PersonService extends ChangeNotifier {
  PersonService._() {
    LocalDb.listenRemote(const {'Person'}, notifyListeners);
  }
  static final PersonService instance = PersonService._();

  LocalDb get _db => LocalDb.instance;

  /// Lets external services (e.g. month rollover) tell listeners the person
  /// data changed after they mutated it directly.
  void notifyExternal() => notifyListeners();

  /// Saves [p]. If [p] is now a chefe, whoever else held that team's slot
  /// loses it in the same transaction (one holder per slot). Someone saving
  /// their own profile answers a request to update it.
  Future<int> save(Person p) async {
    if (AccountService.instance.access.isSelf(p)) {
      p
        ..profileUpdateRequestedAt = null
        ..profileUpdateRequestedBy = null;
    }
    SyncMeta.stamp(p);
    final others = await _db.persons.all();
    final demoted = chefeConflicts(p, others);
    for (final d in demoted) {
      d.chefe = null;
      SyncMeta.stamp(d);
    }
    final id = await _db.transaction(() async {
      final id = await _db.persons.put(p);
      await _db.persons.putAll(demoted);
      return id;
    });
    notifyListeners();
    return id;
  }

  /// Asks [p] to update their profile, in the name of [byName].
  Future<void> requestUpdate(Person p, String byName) async {
    p
      ..profileUpdateRequestedAt = DateTime.now()
      ..profileUpdateRequestedBy = byName;
    SyncMeta.stamp(p);
    await _db.persons.put(p);
    notifyListeners();
  }

  Future<void> delete(int id) async {
    if (await _db.persons.softDelete(id)) notifyListeners();
  }

  Future<List<Person>> all() async =>
      (await _db.persons.all())
        ..sort((a, b) => a.fullName.compareTo(b.fullName));

  Future<void> deleteAll() async {
    if (await _db.persons.softDeleteAll()) notifyListeners();
  }
}
