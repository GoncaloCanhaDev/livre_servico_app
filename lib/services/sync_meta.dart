import 'package:uuid/uuid.dart';

/// Mutates Isar-collection rows to keep the local metadata up to date.
///
/// The sync fields on every model ([syncUuid], [syncUpdatedAt],
/// [syncDeletedAt], [synced]) are retained for backwards compatibility with
/// existing on-device data, but nothing pushes them anywhere anymore.
class SyncMeta {
  SyncMeta._();
  static const _uuid = Uuid();

  /// Assigns a uuid if the row doesn't have one and bumps the
  /// last-updated timestamp.
  static void stamp(dynamic row) {
    final cur = row.syncUuid as String?;
    if (cur == null || cur.isEmpty) {
      row.syncUuid = _uuid.v4();
    }
    row.syncUpdatedAt = DateTime.now();
    row.synced = true;
  }

  /// Marks [row] as a tombstone (soft delete). The row stays in Isar and
  /// is filtered out by reads, so it can still be "restored" or audited.
  static void softDelete(dynamic row) {
    final now = DateTime.now();
    final cur = row.syncUuid as String?;
    if (cur == null || cur.isEmpty) {
      row.syncUuid = _uuid.v4();
    }
    row.syncDeletedAt = now;
    row.syncUpdatedAt = now;
    row.synced = true;
  }

  /// Backfills missing uuids on legacy rows.
  static bool backfillIfNeeded(dynamic row) {
    final cur = row.syncUuid as String?;
    if (cur != null && cur.isNotEmpty) return false;
    row.syncUuid = _uuid.v4();
    row.synced = true;
    return true;
  }
}
