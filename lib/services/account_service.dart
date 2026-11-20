import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';

import '../models/feedback_status.dart';
import '../models/privacy_policy.dart';
import '../models/store_access.dart';
import 'demo_mode.dart';
import 'document_service.dart';
import 'local_db.dart';
import 'photo_store.dart';
import 'store_data.dart';
import 'supabase_sync_remote.dart';
import 'sync_engine.dart';
import 'sync_service.dart';

part 'account/account_types.dart';
part 'account/admin_calls.dart';
part 'account/account_errors.dart';
part 'account/feedback_calls.dart';

/// The account on the online database (Supabase) and the store this device
/// syncs with. Optional: signed out, the app works on its own as before.
///
/// The project comes from `--dart-define-from-file=.env` (`SUPABASE_URL`,
/// `SUPABASE_ANON_KEY`); a build without them can't sign in. The session is
/// kept in shared preferences, and restored at startup in the background,
/// so an offline start doesn't wait for the network.
class AccountService extends ChangeNotifier {
  AccountService._();
  static final AccountService instance = AccountService._();

  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const _sessionKey = 'account_session';
  static const _emailKey = 'account_email';
  static const _storeKey = 'account_store';
  static const _redactedPrefix = 'peopleRedacted:';

  static const _releaseNotesKey = 'release_notes_seen';

  late SharedPreferences _prefs;
  SupabaseClient? _client;
  Timer? _retry;
  DateTime? _accessCheckedAt;

  /// Whether this build has an online database to use (never in the demo).
  bool get isConfigured =>
      !DemoMode.active && _url.isNotEmpty && _anonKey.isNotEmpty;

  /// The signed-in account's email; null when signed out.
  String? email;
  bool get isSignedIn => email != null;

  /// The store this device syncs with; null when none is chosen.
  StoreInfo? store;

  /// Whether this device may wipe all data: anyone when not syncing, only
  /// the app's admin when it is (the wipe reaches the whole store).
  bool get canWipeAll => access.canWipeAll;

  /// What this account may do in the current store; everything when there
  /// is none.
  StoreAccess get access => store?.access ?? StoreAccess.full;

  SupabaseClient get _api => _client!;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (!isConfigured) return;
    _client = SupabaseClient(
      _url,
      _anonKey,
      // Implicit: a sign-up confirmed by email needs nothing stored here.
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
    _api.auth.onAuthStateChange.listen((s) {
      if (s.session case final session?) {
        _prefs.setString(_sessionKey, jsonEncode(session.toJson()));
      } else if (s.event == AuthChangeEvent.signedOut) {
        _forget();
      }
    }, onError: (_) {});
    email = _prefs.getString(_emailKey);
    store = storeInfoFromJson(_prefs.getString(_storeKey));
    // Versions before 0.63.1 didn't say which store the data here is from.
    if (store case final s? when _prefs.getString(localDataStoreKey) == null) {
      await _prefs.setString(localDataStoreKey, s.id);
    }
    SyncService.instance.addListener(_checkAccessNowAndThen);
    if (_prefs.getString(_sessionKey) != null) _restoring = _restore();
  }

  /// The first [_restore] at startup, while it runs.
  Future<void>? _restoring;

  /// The newest app version whose "Novidades" this account has seen (on any
  /// device), from its user metadata; null when signed out, offline or
  /// never. Waits a little for the saved session to come back first.
  Future<String?> releaseNotesSeen() async {
    if (!isConfigured) return null;
    try {
      await _restoring?.timeout(const Duration(seconds: 5));
      if (_api.auth.currentSession == null) return null;
      final user =
          (await _api.auth.getUser().timeout(
            const Duration(seconds: 5),
          )).user ??
          _api.auth.currentUser;
      return user?.userMetadata?[_releaseNotesKey] as String?;
    } catch (_) {
      // Offline: what the saved session last said.
      return _api.auth.currentUser?.userMetadata?[_releaseNotesKey] as String?;
    }
  }

  /// Keeps on the account that its "Novidades" were seen up to [version];
  /// offline, nothing (the device's own pref still has it, and the next
  /// popup closed online catches up).
  Future<void> setReleaseNotesSeen(String version) async {
    if (!isConfigured || _api.auth.currentSession == null) return;
    try {
      await _api.auth.updateUser(
        UserAttributes(data: {_releaseNotesKey: version}),
      );
    } catch (_) {
      // Offline or signed out meanwhile.
    }
  }

  /// Brings back the saved session (refreshing it online if it expired),
  /// then reconnects the store. Offline, tries again in a minute.
  Future<void> _restore() async {
    final saved = _prefs.getString(_sessionKey);
    if (saved == null) return;
    try {
      await _api.auth.recoverSession(saved);
    } on AuthRetryableFetchException {
      _retryLater();
      return;
    } on AuthException {
      // The session can't be used any more (expired or revoked).
      await _forget();
      return;
    } catch (_) {
      _retryLater();
      return;
    }
    if (store case final s?) unawaited(_startSync(s));
    unawaited(refreshStore().catchError((_) {}));
  }

  /// After a sync, at most every 10 minutes: whether this account's access
  /// changed (promoted to chefe, moved team, moved to another store or
  /// removed: then the sync fails, so a failed one counts too).
  void _checkAccessNowAndThen() {
    final sync = SyncService.instance;
    if (sync.isSyncing || store == null) return;
    final now = DateTime.now();
    final last = _accessCheckedAt;
    if (last != null && now.difference(last) < const Duration(minutes: 10)) {
      return;
    }
    _accessCheckedAt = now;
    unawaited(refreshStore().catchError((_) {}));
  }

  void _retryLater() {
    if (!isSignedIn) return;
    _retry?.cancel();
    _retry = Timer(const Duration(minutes: 1), _restore);
  }

  /// Takes the store's current name, this account's role and access and
  /// whether its request is still pending from the server; starts syncing
  /// once approved, and leaves the store if this account was removed from
  /// it (or its request refused). Throws when offline.
  Future<void> refreshStore() async {
    final current = store;
    if (current == null) return;
    final mine = await myStores();
    final listed = mine.where((s) => s.id == current.id).firstOrNull;
    if (listed == null) {
      // Moved by the admin to another store: follow, leaving behind what
      // the old store would now refuse. Otherwise, removed.
      if (mine.length == 1 && !current.access.admin) {
        _stopSync();
        await useStore(mine.single, force: true);
      } else {
        await leaveStore();
      }
      return;
    }
    final now = listed.pending
        ? listed
        : (
            id: listed.id,
            name: listed.name,
            role: listed.role,
            personId: listed.personId,
            pending: false,
            access: StoreAccess.fromJson(
              await _api.rpc<Map<String, dynamic>>(
                'my_access',
                params: {'p_store': current.id},
              ),
            ),
          );
    if (now == current) return;
    await _saveStore(now);
    if (now.access != current.access) {
      // People come back as this account may now read them.
      await SyncEngine.forgetCursor(_prefs, now.id);
    }
    // Completes after the first sync once approved.
    if (now.pending != current.pending ||
        now.role != current.role ||
        now.access != current.access) {
      await _startSync(now);
    }
  }

  Future<void> signIn(String email, String password) async {
    await _api.auth.signInWithPassword(email: email.trim(), password: password);
    await _signedIn();
  }

  /// Creates an account; false when the project asks to confirm the email
  /// first (then sign in after following the link).
  /// The account keeps which Política de Privacidade it accepted, and when
  /// (the screen asks before this is called).
  Future<bool> signUp(String email, String password) async {
    final r = await _api.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'privacy_policy': privacyPolicyVersion,
        'privacy_accepted_at': DateTime.now().toUtc().toIso8601String(),
      },
    );
    if (r.session == null) return false;
    await _signedIn();
    return true;
  }

  /// Whether [email] is a disposable one the server refuses
  /// (`email_domain_blocked`). False when it can't ask: the server's
  /// refuse_blocked_email trigger still refuses the account then.
  Future<bool> emailBlocked(String email) async {
    if (!isConfigured) return false;
    try {
      return await _api.rpc(
            'email_domain_blocked',
            params: {'p_email': email.trim()},
          ) ==
          true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _signedIn() async {
    email = _api.auth.currentUser?.email;
    if (email case final e?) await _prefs.setString(_emailKey, e);
    notifyListeners();
  }

  /// Signs out and stops syncing; the data stays on this device.
  Future<void> signOut() async {
    try {
      await _api.auth.signOut();
    } catch (_) {
      // Offline: the session is forgotten here all the same.
    }
    await _forget();
  }

  Future<void> _forget() async {
    _retry?.cancel();
    _stopSync();
    email = null;
    store = null;
    await _prefs.remove(_sessionKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_storeKey);
    notifyListeners();
  }

  /// The stores this account belongs to (or asked to join), by name; every
  /// store for the app's admin. Access is the role's until [refreshStore].
  Future<List<StoreInfo>> myStores() async {
    if (_api.auth.currentUser == null) return const [];
    final rows = await _api.rpc<List<dynamic>>('my_stores');
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          id: r['id'] as String,
          name: r['name'] as String,
          role: StoreRole.fromName(r['role']),
          personId: r['person_id'] as String?,
          pending: r['status'] == 'pending',
          access: _accessOfRole(StoreRole.fromName(r['role'])),
        ),
    ];
  }

  /// Asks the admin to move this account to another store; [note] says
  /// where to (and from when).
  Future<void> requestTransfer(String note) => _api.rpc<void>(
    'request_store_transfer',
    params: {'p_store': store!.id, 'p_note': note},
  );

  /// This account's request to move, if any.
  Future<({String note, DateTime createdAt})?> myTransfer() async {
    final rows = await _api.rpc<List<dynamic>>('my_store_transfer');
    if (rows.isEmpty) return null;
    final r = rows.first as Map<String, dynamic>;
    return (
      note: r['note'] as String? ?? '',
      createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
    );
  }

  Future<void> cancelTransfer() => _api.rpc<void>('cancel_store_transfer');

  /// Every request to move to another store, oldest first. The admin only.
  Future<List<TransferRequest>> transferRequests() async {
    final rows = await _api.rpc<List<dynamic>>('store_transfer_requests');
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          userId: r['user_id'] as String,
          email: r['email'] as String? ?? '',
          fromStore: r['from_store'] as String,
          fromStoreName: r['from_store_name'] as String? ?? '',
          personName: r['person_name'] as String?,
          note: r['note'] as String? ?? '',
          createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
        ),
    ];
  }

  /// Moves [userId] (with their person) from the store [from] to [to]. The
  /// admin only.
  Future<void> transferMember(String userId, String from, String to) =>
      _api.rpc<void>(
        'transfer_member',
        params: {'p_user': userId, 'p_from': from, 'p_to': to},
      );

  /// Goes up after every error report or suggestion this device sends,
  /// changes or removes, so every screen showing them reads them again at
  /// once (the Todos tab, Home's Administração card).
  final feedbackChanges = ValueNotifier(0);

  Future<void> _feedbackChanged(Future<void> change) async {
    await change;
    feedbackChanges.value++;
  }

  /// Whether this account is the app's admin (it creates stores); false
  /// when that can't be asked (offline).
  Future<bool> isAppAdmin() async {
    try {
      return await _api.rpc<bool>('is_app_admin');
    } catch (_) {
      return false;
    }
  }

  /// Creates a store (the app's admin only) and syncs with it.
  Future<void> createStore(String name) async {
    final id = await _api.rpc<String>(
      'create_store',
      params: {'p_name': name.trim()},
    );
    await useStore((
      id: id,
      name: name.trim(),
      role: StoreRole.owner,
      personId: null,
      pending: false,
      access: const StoreAccess(admin: true),
    ));
  }

  /// The store with the join [code] and its people with no account yet.
  Future<JoinPreview> previewJoin(String code) async {
    final r = await _api.rpc<Map<String, dynamic>>(
      'join_store_preview',
      params: {'p_code': code},
    );
    return (
      storeId: r['store_id'] as String,
      storeName: r['store_name'] as String,
      people: _unlinkedFromJson(r['people'] as List<dynamic>),
    );
  }

  /// Asks to join the store with the join [code] as the person [personId],
  /// or as someone new called [name], and chooses it: it syncs once a chefe,
  /// or Gerência approves (see [refreshStore]). A member already
  /// keeps their membership.
  Future<void> joinStore(String code, {String? personId, String? name}) async {
    final id = await _api.rpc<String>(
      'join_store',
      params: {'p_code': code, 'p_person': personId, 'p_name': name},
    );
    final joined = (await myStores()).firstWhere((s) => s.id == id);
    await useStore(joined);
  }

  /// Withdraws this account's pending request to join the current store.
  Future<void> cancelJoinRequest() async {
    await _api
        .from('store_members')
        .delete()
        .eq('store_id', store!.id)
        .eq('user_id', _api.auth.currentUser!.id);
    await leaveStore();
  }

  /// The requests to join the current store, oldest first. For those who
  /// approve them ([StoreAccess.canApprove]).
  Future<List<JoinRequest>> joinRequests() async {
    final rows = await _api.rpc<List<dynamic>>(
      'store_join_requests',
      params: {'p_store': store!.id},
    );
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          userId: r['user_id'] as String,
          email: r['email'] as String? ?? '',
          personId: r['person_id'] as String?,
          personName: r['person_name'] as String?,
          requestedName: r['requested_name'] as String?,
          createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
        ),
    ];
  }

  /// Approves [userId]'s request to join the current store (or the store
  /// [storeId], for the admin).
  Future<void> approveJoin(String userId, {String? storeId}) => _api.rpc<void>(
    'approve_join',
    params: {'p_store': storeId ?? store!.id, 'p_user': userId},
  );

  Future<void> refuseJoin(String userId, {String? storeId}) => _api.rpc<void>(
    'refuse_join',
    params: {'p_store': storeId ?? store!.id, 'p_user': userId},
  );

  /// The current store's people with no account linked yet.
  Future<List<UnlinkedPerson>> unlinkedPeople() async => _unlinkedFromJson(
    await _api.rpc<List<dynamic>>(
      'store_unlinked_people',
      params: {'p_store': store!.id},
    ),
  );

  List<UnlinkedPerson> _unlinkedFromJson(List<dynamic> rows) => [
    for (final r in rows.cast<Map<String, dynamic>>())
      (
        id: r['id'] as String,
        name: r['full_name'] as String? ?? '',
        number: r['collaborator_number'] as String? ?? '',
      ),
  ];

  /// Links this account to the current store's person [personId] (its
  /// profile), unless another account has that person.
  Future<void> claimPerson(String personId) async {
    final s = store!;
    await _api.rpc<void>(
      'claim_person',
      params: {'p_store': s.id, 'p_person': personId},
    );
    await _saveStore((
      id: s.id,
      name: s.name,
      role: s.role,
      personId: personId,
      pending: s.pending,
      access: s.access,
    ));
  }

  /// Whether choosing the store [storeId] removes this phone's data, which
  /// belongs to another store (see [prepareLocalDataFor]).
  bool replacesLocalData(String storeId) =>
      replacesLocalDataOf(_prefs, storeId);

  /// Syncs this device with [s]: data from before any store joins it (the
  /// copy of each row saved last winning); another store's data leaves this
  /// phone first, and [s]'s comes down. Throws [PendingChangesException]
  /// while the other store's changes wait to be sent. Completes after the
  /// first sync.
  Future<void> useStore(StoreInfo s, {bool force = false}) async {
    await prepareLocalDataFor(LocalDb.instance, _prefs, s.id, force: force);
    await _saveStore(s);
    await _startSync(s);
    // The access the role alone doesn't say (chefe, Gerência, admin).
    unawaited(refreshStore().catchError((_) {}));
  }

  /// Stops syncing with the store, after one last try to send what it
  /// hasn't got; the data stays on this device until another store is
  /// chosen.
  Future<void> leaveStore() async {
    if (store case final s? when syncsWith(s)) {
      try {
        await SyncService.instance.syncNow();
      } catch (_) {
        // Offline: what wasn't sent waits for this store to be chosen again.
      }
    }
    _stopSync();
    store = null;
    await _prefs.remove(_storeKey);
    notifyListeners();
  }

  Future<void> _startSync(StoreInfo s) async {
    if (!syncsWith(s)) {
      _stopSync();
      return;
    }
    // Versions before 0.62.1 kept everyone's people whole: pull them all
    // again, once, as this account may read them.
    final redactedKey = '$_redactedPrefix${s.id}';
    if (_prefs.getBool(redactedKey) != true) {
      await SyncEngine.forgetCursor(_prefs, s.id);
      await _prefs.setBool(redactedKey, true);
    }
    PhotoStore.instance.remote = SupabasePhotoRemote(_api, s.id);
    DocumentService.instance
      ..remote = SupabaseDocumentRemote(_api)
      ..canManage = s.access.admin;
    await SyncService.instance.start(
      SupabaseSyncRemote(_api, s.id),
      s.id,
      canPush: s.role != StoreRole.viewer,
    );
  }

  void _stopSync() {
    SyncService.instance.stop();
    PhotoStore.instance.remote = null;
    DocumentService.instance
      ..remote = null
      ..canManage = false;
  }

  Future<void> _saveStore(StoreInfo s) async {
    store = s;
    await _prefs.setString(_storeKey, storeInfoToJson(s));
    notifyListeners();
  }

  /// Everyone in the current store.
  Future<List<StoreMember>> members() async {
    final rows = await _api.rpc<List<dynamic>>(
      'store_member_list',
      params: {'p_store': store!.id},
    );
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          userId: r['user_id'] as String,
          email: r['email'] as String? ?? '',
          role: StoreRole.fromName(r['role']),
          personId: r['person_id'] as String?,
        ),
    ];
  }

  /// The current store's join code, which Gerência shares with the team.
  Future<String> joinCode() =>
      _api.rpc<String>('store_join_code', params: {'p_store': store!.id});

  /// Replaces the join code, so the old one stops working. Owners only.
  Future<String> resetJoinCode() =>
      _api.rpc<String>('reset_store_join_code', params: {'p_store': store!.id});

  /// Adds the account with [email] to the current store, or changes its
  /// role. Owners only; that person must have created their account.
  Future<void> setMember(String email, StoreRole role) => _api.rpc<void>(
    'add_store_member',
    params: {
      'p_store': store!.id,
      'p_email': email.trim(),
      'p_role': role.name,
    },
  );

  /// Links another member's account to the person [personId] (one without
  /// an account). Owners only: the way to link a chefe or Gerência.
  Future<void> linkMember(String userId, String personId) => _api
      .from('store_members')
      .update({'person_id': personId})
      .eq('store_id', store!.id)
      .eq('user_id', userId);

  /// Unlinks another member's account from their person, so it can be
  /// picked again. Owners only.
  Future<void> unlinkMember(String userId) => _api
      .from('store_members')
      .update({'person_id': null})
      .eq('store_id', store!.id)
      .eq('user_id', userId);

  Future<void> removeMember(String userId) => _api
      .from('store_members')
      .delete()
      .eq('store_id', store!.id)
      .eq('user_id', userId);
}
