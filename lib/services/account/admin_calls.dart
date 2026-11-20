part of '../account_service.dart';

/// Administração's read-only overview of every store and account, and
/// removing an account: RPCs refusing anyone but the app's admin.
extension AdminCalls on AccountService {
  /// What waits for the admin in every store. The admin only.
  Future<AdminSummary> adminSummary() async {
    final r = await _api.rpc<Map<String, dynamic>>('admin_summary');
    int count(String key) => (r[key] as num?)?.toInt() ?? 0;
    return (
      joinRequests: count('join_requests'),
      transfers: count('transfers'),
      feedback: count('feedback'),
    );
  }

  /// Every request to join, in every store, oldest first. The admin only.
  Future<List<AdminJoinRequest>> adminJoinRequests() async {
    final rows = await _api.rpc<List<dynamic>>('admin_join_requests');
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          storeId: r['store_id'] as String,
          storeName: r['store_name'] as String? ?? '',
          request: (
            userId: r['user_id'] as String,
            email: r['email'] as String? ?? '',
            personId: r['person_id'] as String?,
            personName: r['person_name'] as String?,
            requestedName: r['requested_name'] as String?,
            createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
          ),
        ),
    ];
  }

  /// Every store, by name, with its counts. The admin only.
  Future<List<AdminStore>> adminStores() async {
    final rows = await _api.rpc<List<dynamic>>('admin_stores');
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          id: r['id'] as String,
          name: r['name'] as String? ?? '',
          createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
          members: (r['members'] as num?)?.toInt() ?? 0,
          pending: (r['pending'] as num?)?.toInt() ?? 0,
          people: (r['people'] as num?)?.toInt() ?? 0,
        ),
    ];
  }

  /// Every account, by email, with its store. The admin only.
  Future<List<AdminAccount>> adminAccounts() async {
    final rows = await _api.rpc<List<dynamic>>('admin_accounts');
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          userId: r['user_id'] as String,
          email: r['email'] as String? ?? '',
          createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
          lastSignInAt: switch (r['last_sign_in_at']) {
            final String d => DateTime.parse(d).toLocal(),
            _ => null,
          },
          isAdmin: r['is_admin'] == true,
          storeId: r['store_id'] as String?,
          storeName: r['store_name'] as String?,
          pending: r['status'] == 'pending',
          personName: r['person_name'] as String?,
        ),
    ];
  }

  /// Removes the account [userId] for good: its memberships go with it, the
  /// store's data (its Person too) stays. The admin only, never an admin's
  /// account.
  Future<void> adminDeleteAccount(String userId) =>
      _api.rpc<void>('admin_delete_account', params: {'p_user': userId});

  /// The store [storeId]'s people, by name. The admin only.
  Future<List<AdminPerson>> adminStorePeople(String storeId) async {
    final rows = await _api.rpc<List<dynamic>>(
      'admin_store_people',
      params: {'p_store': storeId},
    );
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          id: r['id'] as String,
          name: r['full_name'] as String? ?? '',
          number: r['collaborator_number'] as String? ?? '',
          team: r['team'] as String?,
          role: r['role'] as String?,
          email: r['email'] as String?,
        ),
    ];
  }
}
