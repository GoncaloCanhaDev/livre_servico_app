import 'package:uuid/uuid.dart';

import '../models/local_row.dart';

/// Keeps the sync fields of a row up to date before it is saved.
///
/// `SyncEngine` syncs by these fields ([SyncedRow.syncUuid],
/// [SyncedRow.syncUpdatedAt], [SyncedRow.syncDeletedAt]): a stamped row is
/// pending ([SyncedRow.synced] false) until it is pushed.
class SyncMeta {
  SyncMeta._();
  static const _uuid = Uuid();

  /// Assigns a uuid if the row doesn't have one, bumps the last-updated
  /// timestamp and marks the row pending a push.
  static void stamp(SyncedRow row) {
    if (row.syncUuid.isEmpty) row.syncUuid = _uuid.v4();
    row.syncUpdatedAt = DateTime.now();
    row.synced = false;
  }

  /// Marks [row] as a tombstone (soft delete). The row stays in the
  /// database and is filtered out by reads, so it can still be "restored"
  /// or audited.
  static void softDelete(SyncedRow row) {
    final now = DateTime.now();
    if (row.syncUuid.isEmpty) row.syncUuid = _uuid.v4();
    row.syncDeletedAt = now;
    row.syncUpdatedAt = now;
    row.synced = false;
  }

  /// Backfills missing uuids on legacy rows. Whether the row is pending is
  /// left as it is: the first sync with a store pushes every row anyway.
  static bool backfillIfNeeded(SyncedRow row) {
    if (row.syncUuid.isNotEmpty) return false;
    row.syncUuid = _uuid.v4();
    return true;
  }
}
