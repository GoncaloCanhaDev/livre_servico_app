part of '../account_service.dart';

/// Erros e sugestões: the online `feedback` table, through admin-checked
/// RPCs (it has no policies).
extension FeedbackCalls on AccountService {
  /// Sends an error report or a suggestion to the app's admin, with the
  /// store in use, the app's [version] and [platform]. Everyone reads its
  /// text and state ([feedbackPublicList]), never who sent it.
  Future<void> sendFeedback(
    FeedbackKind kind,
    String message, {
    required String version,
    required String platform,
  }) => _feedbackChanged(
    _api.rpc<void>(
      'send_feedback',
      params: {
        'p_kind': kind.name,
        'p_message': message.trim(),
        'p_store': store?.id,
        'p_version': version,
        'p_platform': platform,
        'p_public': true,
      },
    ),
  );

  /// Every error report and suggestion, newest first. The admin only.
  Future<List<FeedbackItem>> feedbackList() async {
    final rows = await _api.rpc<List<dynamic>>('feedback_list');
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          id: r['id'] as String,
          kind: FeedbackKind.fromName(r['kind']),
          message: r['message'] as String? ?? '',
          email: r['email'] as String? ?? '',
          storeName: r['store_name'] as String?,
          personName: r['person_name'] as String?,
          appVersion: r['app_version'] as String? ?? '',
          platform: r['platform'] as String? ?? '',
          createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
          doneAt: switch (r['done_at']) {
            final String d => DateTime.parse(d).toLocal(),
            _ => null,
          },
          status: FeedbackStatus.fromName(r['status']),
          isPublic: r['is_public'] == true,
        ),
    ];
  }

  /// The public reports and suggestions and this account's own, newest
  /// first, without who sent them. Anyone signed in.
  Future<List<PublicFeedback>> feedbackPublicList() async {
    final rows = await _api.rpc<List<dynamic>>('feedback_public_list');
    return [
      for (final r in rows.cast<Map<String, dynamic>>())
        (
          id: r['id'] as String,
          kind: FeedbackKind.fromName(r['kind']),
          message: r['message'] as String? ?? '',
          status: FeedbackStatus.fromName(r['status']),
          createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
          mine: r['mine'] == true,
        ),
    ];
  }

  /// Sets a report's or suggestion's state. The admin only.
  Future<void> setFeedbackStatus(String id, FeedbackStatus status) =>
      _feedbackChanged(
        _api.rpc<void>(
          'set_feedback_status',
          params: {'p_id': id, 'p_status': status.dbName},
        ),
      );

  /// Makes every new report and suggestion Visto: the admin opened them.
  Future<void> markFeedbackSeen() =>
      _feedbackChanged(_api.rpc<void>('mark_feedback_seen'));

  /// Removes a report or suggestion. The admin only.
  Future<void> deleteFeedback(String id) =>
      _feedbackChanged(_api.rpc<void>('delete_feedback', params: {'p_id': id}));
}
