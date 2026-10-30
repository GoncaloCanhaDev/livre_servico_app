import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_db.dart';
import 'sync_engine.dart';

/// Runs [SyncEngine] while a store is connected: right away, a few seconds
/// after the app saves something, and every minute (to pull what other
/// devices saved). Nothing starts it until there is a login (phase 4).
class SyncService extends ChangeNotifier {
  SyncService._();
  static final SyncService instance = SyncService._();

  static const _afterSave = Duration(seconds: 3);
  static const _every = Duration(minutes: 1);

  SyncEngine? _engine;
  StreamSubscription<String>? _writes;
  Timer? _timer;
  Timer? _soon;
  Future<void>? _running;
  bool _again = false;

  bool get isConnected => _engine != null;
  bool get isSyncing => _running != null;

  /// When the last sync finished without an error.
  DateTime? lastSyncedAt;

  /// Why the last sync failed (e.g. no network); null after a good one.
  Object? lastError;

  /// Starts syncing [db] (by default the app's) with [remote], the store
  /// [storeId].
  Future<void> start(SyncRemote remote, String storeId, {LocalDb? db}) async {
    stop();
    _engine = SyncEngine(
      db: db ?? LocalDb.instance,
      remote: remote,
      storeId: storeId,
      prefs: await SharedPreferences.getInstance(),
    );
    _writes = LocalDb.localWrites.listen((_) {
      _soon?.cancel();
      _soon = Timer(_afterSave, syncNow);
    });
    _timer = Timer.periodic(_every, (_) => syncNow());
    notifyListeners();
    await syncNow();
  }

  void stop() {
    _writes?.cancel();
    _timer?.cancel();
    _soon?.cancel();
    _writes = null;
    _timer = null;
    _soon = null;
    _engine = null;
    notifyListeners();
  }

  /// Syncs now; if a sync is running, once more after it.
  Future<void> syncNow() async {
    if (_running case final running?) {
      _again = true;
      return running;
    }
    final engine = _engine;
    if (engine == null) return;
    _running = _run(engine);
    notifyListeners();
    await _running;
  }

  Future<void> _run(SyncEngine engine) async {
    try {
      await engine.run();
      lastSyncedAt = DateTime.now();
      lastError = null;
    } catch (e) {
      // Offline or a server error: the rows stay pending for the next try.
      lastError = e;
    } finally {
      _running = null;
      notifyListeners();
    }
    if (_again) {
      _again = false;
      await syncNow();
    }
  }
}
