import 'package:flutter/foundation.dart';

import '../models/aviso.dart';
import 'local_db.dart';
import 'sync_meta.dart';

/// Avisos (in-app notices, see `Aviso`) and their "Visto"s.
class AvisoService extends ChangeNotifier {
  AvisoService._() {
    LocalDb.listenRemote(const {'Aviso', 'AvisoVisto'}, notifyListeners);
  }
  static final AvisoService instance = AvisoService._();

  LocalDb get _db => LocalDb.instance;

  /// Sends [text] to the persons [to] in the name of [fromPersonId]
  /// ([fromName]).
  Future<Aviso> send(
    String text,
    List<String> to, {
    required String fromPersonId,
    required String fromName,
  }) async {
    final a = Aviso()
      ..text = text.trim()
      ..sentAt = DateTime.now()
      ..fromPersonId = fromPersonId
      ..fromName = fromName
      ..toPersonIds = [...to];
    SyncMeta.stamp(a);
    await _db.avisos.put(a);
    notifyListeners();
    return a;
  }

  /// Records that [personId] saw [a] (once).
  Future<void> markSeen(Aviso a, String personId) async {
    final seen = await _db.avisoVistos.firstWhere(
      (v) => v.avisoId == a.syncUuid && v.personId == personId,
    );
    if (seen != null) return;
    final v = AvisoVisto()
      ..avisoId = a.syncUuid
      ..personId = personId
      ..seenAt = DateTime.now();
    SyncMeta.stamp(v);
    await _db.avisoVistos.put(v);
    notifyListeners();
  }

  /// Deletes a sent aviso, for everyone.
  Future<void> delete(Aviso a) async {
    if (await _db.avisos.softDelete(a.id)) notifyListeners();
  }

  Future<List<Aviso>> all() => _db.avisos.all();

  Future<List<AvisoVisto>> vistos() => _db.avisoVistos.all();
}
