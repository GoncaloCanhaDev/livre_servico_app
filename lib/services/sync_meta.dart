import 'package:uuid/uuid.dart';

/// Mutates Isar-collection rows to keep the sync metadata up to date.
///
/// Every collection has the same four sync fields ([syncUuid],
/// [syncUpdatedAt], [syncDeletedAt], [synced]). Call [stamp] right before
/// any `put` so the row is correctly marked for the next sync run.
class SyncMeta {
  SyncMeta._();
  static const _uuid = Uuid();

  /// Marks [row] as locally dirty. Assigns a new uuid if missing and
  /// bumps the LWW timestamp to now.
  static void stamp(dynamic row) {
    final cur = row.syncUuid as String?;
    if (cur == null || cur.isEmpty) {
      row.syncUuid = _uuid.v4();
    }
    row.syncUpdatedAt = DateTime.now();
    row.synced = false;
  }

  /// Marks [row] as a tombstone (soft delete). The row stays in Isar and
  /// is filtered out by reads, but gets pushed to the server with a
  /// `deleted_at` timestamp so other devices learn about the delete.
  static void softDelete(dynamic row) {
    final now = DateTime.now();
    final cur = row.syncUuid as String?;
    if (cur == null || cur.isEmpty) {
      row.syncUuid = _uuid.v4();
    }
    row.syncDeletedAt = now;
    row.syncUpdatedAt = now;
    row.synced = false;
  }

  /// Backfills missing uuids on rows created before sync was wired in.
  /// Does NOT bump [syncUpdatedAt] beyond the row's existing value — we
  /// want legacy rows to be treated as "old" so a server-side change
  /// wins if there's a conflict during the first sync.
  static bool backfillIfNeeded(dynamic row) {
    final cur = row.syncUuid as String?;
    if (cur != null && cur.isNotEmpty) return false;
    row.syncUuid = _uuid.v4();
    row.synced = false; // needs to be pushed at least once
    return true;
  }
}
