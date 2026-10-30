import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';

import 'supabase_sync_remote.dart';
import 'sync_service.dart';

/// A member's role in a store, as `store_role` in `supabase/migrations`
/// (by name: viewer < editor < owner).
enum StoreRole {
  viewer('Só leitura'),
  editor('Edição'),
  owner('Dono');

  const StoreRole(this.label);
  final String label;

  static StoreRole fromName(Object? name) => StoreRole.values.firstWhere(
    (r) => r.name == name,
    orElse: () => StoreRole.viewer,
  );
}

typedef StoreInfo = ({String id, String name, StoreRole role});
typedef StoreMember = ({String userId, String email, StoreRole role});

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

  late SharedPreferences _prefs;
  SupabaseClient? _client;
  Timer? _retry;

  bool get isConfigured => _url.isNotEmpty && _anonKey.isNotEmpty;

  /// The signed-in account's email; null when signed out.
  String? email;
  bool get isSignedIn => email != null;

  /// The store this device syncs with; null when none is chosen.
  StoreInfo? store;

  /// Whether this device may wipe all data: anyone when not syncing, only
  /// the owner when it is (the wipe reaches the whole store).
  bool get canWipeAll => store == null || store!.role == StoreRole.owner;

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
    store = _storeFromJson(_prefs.getString(_storeKey));
    if (_prefs.getString(_sessionKey) != null) unawaited(_restore());
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
    if (store case final s?) _startSync(s);
    unawaited(_refreshStore());
  }

  void _retryLater() {
    if (!isSignedIn) return;
    _retry?.cancel();
    _retry = Timer(const Duration(minutes: 1), _restore);
  }

  /// Takes the store's current name and this account's role from the
  /// server; leaves the store if this account was removed from it.
  Future<void> _refreshStore() async {
    final current = store;
    if (current == null) return;
    try {
      final mine = await myStores();
      final now = mine.where((s) => s.id == current.id).firstOrNull;
      if (now == null) {
        await leaveStore();
      } else if (now != current) {
        await _saveStore(now);
        _startSync(now);
      }
    } catch (_) {
      // Offline: keep what was saved.
    }
  }

  Future<void> signIn(String email, String password) async {
    await _api.auth.signInWithPassword(email: email.trim(), password: password);
    await _signedIn();
  }

  /// Creates an account; false when the project asks to confirm the email
  /// first (then sign in after following the link).
  Future<bool> signUp(String email, String password) async {
    final r = await _api.auth.signUp(email: email.trim(), password: password);
    if (r.session == null) return false;
    await _signedIn();
    return true;
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
    SyncService.instance.stop();
    email = null;
    store = null;
    await _prefs.remove(_sessionKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_storeKey);
    notifyListeners();
  }

  /// The stores this account belongs to, by name.
  Future<List<StoreInfo>> myStores() async {
    final uid = _api.auth.currentUser?.id;
    if (uid == null) return const [];
    final rows = await _api
        .from('store_members')
        .select('role, stores(id, name)')
        .eq('user_id', uid);
    return [
      for (final r in rows)
        if (r['stores'] case {'id': final String id, 'name': final String n})
          (id: id, name: n, role: StoreRole.fromName(r['role'])),
    ]..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Creates a store owned by this account and syncs with it.
  Future<void> createStore(String name) async {
    final id = await _api.rpc<String>(
      'create_store',
      params: {'p_name': name.trim()},
    );
    await useStore((id: id, name: name.trim(), role: StoreRole.owner));
  }

  /// Syncs this device with [s]: its rows and this device's are merged, the
  /// copy of each row saved last winning.
  Future<void> useStore(StoreInfo s) async {
    await _saveStore(s);
    _startSync(s);
  }

  /// Stops syncing with the store; the data stays on this device.
  Future<void> leaveStore() async {
    SyncService.instance.stop();
    store = null;
    await _prefs.remove(_storeKey);
    notifyListeners();
  }

  void _startSync(StoreInfo s) => unawaited(
    SyncService.instance.start(
      SupabaseSyncRemote(_api, s.id),
      s.id,
      canPush: s.role != StoreRole.viewer,
    ),
  );

  Future<void> _saveStore(StoreInfo s) async {
    store = s;
    await _prefs.setString(
      _storeKey,
      jsonEncode({'id': s.id, 'name': s.name, 'role': s.role.name}),
    );
    notifyListeners();
  }

  StoreInfo? _storeFromJson(String? raw) {
    if (raw == null) return null;
    try {
      if (jsonDecode(raw) case {
        'id': final String id,
        'name': final String name,
        'role': final String role,
      }) {
        return (id: id, name: name, role: StoreRole.fromName(role));
      }
    } on FormatException {
      // Unreadable: as if no store was chosen.
    }
    return null;
  }

  /// Everyone in the current store, owners first.
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
        ),
    ];
  }

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

  Future<void> removeMember(String userId) => _api
      .from('store_members')
      .delete()
      .eq('store_id', store!.id)
      .eq('user_id', userId);
}

/// What went wrong with an account or store action, in words for the
/// person using the app.
String accountErrorText(Object e) {
  if (e is AuthRetryableFetchException) return 'Sem ligação à internet.';
  if (e is AuthException) {
    final m = e.message.toLowerCase();
    if (m.contains('invalid login')) return 'Email ou palavra-passe errados.';
    if (m.contains('not confirmed')) {
      return 'Confirme primeiro o email, com a ligação que lhe foi enviada.';
    }
    if (m.contains('already registered')) {
      return 'Já existe uma conta com este email.';
    }
    if (m.contains('password')) {
      return 'A palavra-passe tem de ter pelo menos 6 caracteres.';
    }
    return e.message;
  }
  // The database's own errors (see supabase/migrations) are in Portuguese.
  if (e is PostgrestException) return e.message;
  final text = '$e';
  if (text.contains('SocketException') ||
      text.contains('ClientException') ||
      text.contains('Failed host lookup')) {
    return 'Sem ligação à internet.';
  }
  return text;
}
