import 'package:uuid/uuid.dart';

import '../models/local_row.dart';

/// Keeps the sync fields of a row up to date before it is saved.
///
/// The fields ([SyncedRow.syncUuid], [SyncedRow.syncUpdatedAt],
/// [SyncedRow.syncDeletedAt], [SyncedRow.synced]) are not sent anywhere yet;
/// the online database (see `supabase/`) will sync by them.
class SyncMeta {
  SyncMeta._();
  static const _uuid = Uuid();

  /// Assigns a uuid if the row doesn't have one and bumps the
  /// last-updated timestamp.
  static void stamp(SyncedRow row) {
    if (row.syncUuid.isEmpty) row.syncUuid = _uuid.v4();
    row.syncUpdatedAt = DateTime.now();
    row.synced = true;
  }

  /// Marks [row] as a tombstone (soft delete). The row stays in the
  /// database and is filtered out by reads, so it can still be "restored"
  /// or audited.
  static void softDelete(SyncedRow row) {
    final now = DateTime.now();
    if (row.syncUuid.isEmpty) row.syncUuid = _uuid.v4();
    row.syncDeletedAt = now;
    row.syncUpdatedAt = now;
    row.synced = true;
  }

  /// Backfills missing uuids on legacy rows.
  static bool backfillIfNeeded(SyncedRow row) {
    if (row.syncUuid.isNotEmpty) return false;
    row.syncUuid = _uuid.v4();
    row.synced = true;
    return true;
  }
}
