import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../models/justification.dart';
import 'shift_service.dart';
import 'sync_meta.dart';

class JustificationService extends ChangeNotifier {
  JustificationService._();
  static final JustificationService instance = JustificationService._();

  Isar get _isar => ShiftService.instance.isar;

  Future<List<Justification>> all() {
    return _isar.justifications
        .filter()
        .syncDeletedAtIsNull()
        .findAll();
  }

  Future<Justification?> find(DateTime serviceDay, String kind) {
    return _isar.justifications
        .filter()
        .syncDeletedAtIsNull()
        .serviceDayEqualTo(serviceDay)
        .kindEqualTo(kind)
        .findFirst();
  }

  Future<void> upsert({
    required DateTime serviceDay,
    required String kind,
    required String reason,
  }) async {
    final existing = await find(serviceDay, kind);
    final row = existing ?? Justification()
      ..serviceDay = serviceDay
      ..kind = kind;
    row.reason = reason;
    SyncMeta.stamp(row);
    await _isar.writeTxn(() => _isar.justifications.put(row));
    notifyListeners();
  }

  Future<void> remove(DateTime serviceDay, String kind) async {
    final row = await find(serviceDay, kind);
    if (row == null) return;
    SyncMeta.softDelete(row);
    await _isar.writeTxn(() => _isar.justifications.put(row));
    notifyListeners();
  }
}
