import 'package:shared_preferences/shared_preferences.dart';

import 'local_db.dart';
import 'sync_engine.dart';

/// The pref naming the store this phone's data belongs to; missing while it
/// has only data from before any store (which joins the first one).
const localDataStoreKey = 'localDataStore';

/// Switching to another store with changes the previous one never got.
class PendingChangesException implements Exception {
  const PendingChangesException();

  @override
  String toString() =>
      'Há alterações por enviar à loja anterior. Volte a ela e sincronize '
      'antes de mudar de loja.';
}

/// Whether using the store [storeId] removes the data on this phone: it
/// belongs to another store.
bool replacesLocalDataOf(SharedPreferences prefs, String storeId) =>
    switch (prefs.getString(localDataStoreKey)) {
      null => false,
      final current => current != storeId,
    };

/// Makes this phone's data ready to sync with the store [storeId]: another
/// store's rows leave the phone (only the phone: never tombstones, so the
/// server keeps them) and [storeId]'s come down whole on the next sync, so
/// no one sees, or copies, a store they didn't choose. Throws
/// [PendingChangesException], changing nothing, while rows of the other
/// store wait to be pushed.
Future<void> prepareLocalDataFor(
  LocalDb db,
  SharedPreferences prefs,
  String storeId,
) async {
  if (replacesLocalDataOf(prefs, storeId)) {
    for (final c in db.collections) {
      if ((await c.toPush()).isNotEmpty) throw const PendingChangesException();
    }
    await db.transaction(() async {
      for (final c in db.collections) {
        await c.clear();
      }
    });
    await SyncEngine.forgetCursor(prefs, storeId);
    // Every screen reloads, now empty until the sync brings [storeId].
    LocalDb.notifyRemoteChanges({for (final c in db.collections) c.name});
  }
  await prefs.setString(localDataStoreKey, storeId);
}
