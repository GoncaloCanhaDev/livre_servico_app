import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_db.dart';
import 'photo_store.dart';
import 'sync_engine.dart';

/// Runs [SyncEngine] while a store is connected: right away, a few seconds
/// after the app saves something, a moment after the server says another
/// device saved something (Realtime), when the app comes back to the
/// foreground, and every minute in case a Realtime event was missed.
class SyncService extends ChangeNotifier with WidgetsBindingObserver {
  SyncService._();
  static final SyncService instance = SyncService._();

  static const _afterSave = Duration(seconds: 3);

  /// Short, but enough to take a burst of rows written together in one go.
  static const _afterRemote = Duration(seconds: 1);
  static const _every = Duration(minutes: 1);

  SyncEngine? _engine;
  StreamSubscription<String>? _writes;
  StreamSubscription<void>? _remoteChanges;
  Timer? _timer;
  Timer? _soon;
  Future<void>? _running;
  bool _again = false;

  bool get isConnected => _engine != null;
  bool get isSyncing => _running != null;

  /// Whether this device sends its changes (false for an account that may
  /// only read, whose saved rows never leave the device).
  bool get canPush => _engine?.canPush ?? false;

  /// How many changes saved here still wait to be sent; 0 when this device
  /// doesn't send (not connected, or [canPush] false).
  int get pendingCount => switch (_engine) {
    final e? when e.canPush => e.db.pendingCount,
    _ => 0,
  };

  int _pendingPhotos = 0;

  /// How many photos taken here still wait to be uploaded; 0 when this
  /// device doesn't send. Counted after each sync and each save.
  int get pendingPhotos => canPush ? _pendingPhotos : 0;

  Future<void> _countPhotos() async {
    final engine = _engine;
    if (engine == null) return;
    final count = (await engine.db.photosToUpload()).length;
    if (_engine != engine || count == _pendingPhotos) return;
    _pendingPhotos = count;
    notifyListeners();
  }

  /// When the last sync finished without an error.
  DateTime? lastSyncedAt;

  /// Why the last sync failed (e.g. no network); null after a good one.
  Object? lastError;

  /// Starts syncing [db] (by default the app's) with [remote], the store
  /// [storeId]; pulling only unless [canPush].
  Future<void> start(
    SyncRemote remote,
    String storeId, {
    bool canPush = true,
    LocalDb? db,
  }) async {
    stop();
    // A new connection: nothing synced yet (`AutoMarkService` waits for it).
    lastSyncedAt = null;
    _engine = SyncEngine(
      db: db ?? LocalDb.instance,
      remote: remote,
      storeId: storeId,
      prefs: await SharedPreferences.getInstance(),
      canPush: canPush,
    );
    _writes = LocalDb.localWrites.listen((_) {
      _syncIn(_afterSave);
      _countPhotos();
    });
    _remoteChanges = remote.changes.listen(
      (_) => _syncIn(_afterRemote),
      // Realtime down: the minute timer still syncs.
      onError: (_) {},
    );
    _timer = Timer.periodic(_every, (_) => syncNow());
    WidgetsBinding.instance.addObserver(this);
    notifyListeners();
    await syncNow();
  }

  void _syncIn(Duration delay) {
    _soon?.cancel();
    _soon = Timer(delay, syncNow);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) syncNow();
  }

  void stop() {
    if (_engine != null) WidgetsBinding.instance.removeObserver(this);
    _writes?.cancel();
    _remoteChanges?.cancel();
    _remoteChanges = null;
    _timer?.cancel();
    _soon?.cancel();
    _writes = null;
    _timer = null;
    _soon = null;
    _engine = null;
    _pendingPhotos = 0;
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
      if (engine.canPush) await PhotoStore.instance.uploadPending();
      lastSyncedAt = DateTime.now();
      lastError = null;
    } catch (e) {
      // Offline or a server error: the rows stay pending for the next try.
      lastError = e;
    } finally {
      _running = null;
      notifyListeners();
    }
    await _countPhotos();
    if (_again) {
      _again = false;
      await syncNow();
    }
  }
}
