import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  AuthService._() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((s) {
      _profile = null;
      notifyListeners();
      if (s.event == AuthChangeEvent.signedIn) {
        unawaited(_loadProfile());
      }
    });
  }
  static final instance = AuthService._();

  late final StreamSubscription<AuthState> _sub;
  Map<String, dynamic>? _profile;

  SupabaseClient get _client => Supabase.instance.client;
  GoTrueClient get _auth => _client.auth;

  User? get user => _auth.currentUser;
  bool get isSignedIn => user != null;

  String? get firstName =>
      _profile?['first_name'] as String? ??
      user?.userMetadata?['first_name'] as String?;
  String? get lastName =>
      _profile?['last_name'] as String? ??
      user?.userMetadata?['last_name'] as String?;
  String? get employeeNumber =>
      _profile?['employee_number'] as String? ??
      user?.userMetadata?['employee_number'] as String?;

  String? get fullName {
    final f = firstName?.trim();
    final l = lastName?.trim();
    if ((f == null || f.isEmpty) && (l == null || l.isEmpty)) return null;
    return [f, l].whereType<String>().where((s) => s.isNotEmpty).join(' ');
  }

  /// Two-letter initials, e.g. "Gonçalo Canha" → "GC". Falls back to the
  /// first letter of the email if the user hasn't set a name yet.
  String? get initials {
    final f = firstName?.trim();
    final l = lastName?.trim();
    final fi = (f != null && f.isNotEmpty) ? f[0].toUpperCase() : '';
    final li = (l != null && l.isNotEmpty) ? l[0].toUpperCase() : '';
    final combined = '$fi$li';
    if (combined.isNotEmpty) return combined;
    final email = user?.email;
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();
    return null;
  }

  /// Signs in using either an email address or an employee number. If
  /// [identifier] doesn't contain '@', the email is resolved via the
  /// `email_for_employee_number` RPC.
  Future<void> signIn(String identifier, String password) async {
    final email = await _resolveEmail(identifier);
    if (email == null) {
      throw const AuthException('Número de empregado não encontrado.');
    }
    await _auth.signInWithPassword(email: email, password: password);
  }

  Future<String?> _resolveEmail(String identifier) async {
    final id = identifier.trim();
    if (id.contains('@')) return id;
    try {
      final res = await _client.rpc(
        'email_for_employee_number',
        params: {'empnum': id},
      );
      if (res is String && res.isNotEmpty) return res;
      return null;
    } catch (e) {
      throw AuthException('Erro a procurar utilizador: $e');
    }
  }

  Future<void> signUp(
    String email,
    String password, {
    required String firstName,
    required String lastName,
    required String employeeNumber,
  }) async {
    await _auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'employee_number': employeeNumber,
      },
    );
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String employeeNumber,
  }) async {
    final u = user;
    if (u == null) return;
    await _auth.updateUser(UserAttributes(data: {
      'first_name': firstName,
      'last_name': lastName,
      'employee_number': employeeNumber,
    }));
    await _client.from('profiles').upsert({
      'user_id': u.id,
      'email': u.email,
      'first_name': firstName,
      'last_name': lastName,
      'employee_number': employeeNumber,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
    await _loadProfile();
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    final u = user;
    if (u == null) {
      _profile = null;
      return;
    }
    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('user_id', u.id)
          .maybeSingle();
      if (row == null) {
        // Account predates the on-signup trigger — backfill from metadata.
        final meta = u.userMetadata ?? const {};
        final inserted = await _client.from('profiles').upsert({
          'user_id': u.id,
          'email': u.email,
          'first_name': (meta['first_name'] as String?) ?? '',
          'last_name': (meta['last_name'] as String?) ?? '',
          'employee_number':
              (meta['employee_number'] as String?) ?? '',
        }, onConflict: 'user_id').select().single();
        _profile = Map<String, dynamic>.from(inserted);
      } else {
        _profile = Map<String, dynamic>.from(row);
      }
      notifyListeners();
    } catch (_) {
      // Silent — the user_metadata fallbacks still let the app function.
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
