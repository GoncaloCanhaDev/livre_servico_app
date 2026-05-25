import 'package:isar_community/isar.dart';

part 'inventory.g.dart';

@collection
class Inventory {
  Id id = Isar.autoIncrement;

  @Index()
  String syncUuid = '';
  DateTime syncUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? syncDeletedAt;
  bool synced = true;
  String? createdByInitials;

  late String name;

  /// Value in cents (positive or negative).
  ///
  /// Legacy field: rows created before the session-based redesign store the
  /// total euro value here. New rows leave it at 0 until [finalValueCents] is
  /// set on finalize and mirrored here.
  late int valueCents;

  late DateTime createdAt;

  // --- Session fields (added in v0.3) ------------------------------------

  String? code;

  DateTime? startedAt;

  /// When non-null, the timer is currently running and elapsed time since
  /// this instant should be added to [accumulatedSeconds] for display.
  DateTime? runningSince;

  /// Total seconds spent in the session, excluding the period currently
  /// being accumulated by [runningSince].
  int accumulatedSeconds = 0;

  DateTime? finishedAt;

  int? finalValueCents;

  bool get isLegacy => startedAt == null;
  bool get isFinalized => finishedAt != null;
  bool get isPaused => !isFinalized && runningSince == null && startedAt != null;
  bool get isRunning => !isFinalized && runningSince != null;
}

