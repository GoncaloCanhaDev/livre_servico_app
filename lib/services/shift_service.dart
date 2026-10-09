import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auto_list.dart';
import '../models/custom_task.dart';
import '../models/daily_tasks.dart';
import '../models/horario_mes.dart';
import '../models/info_entry.dart';
import '../models/inventory.dart';
import '../models/opening_list.dart';
import '../models/pedido.dart';
import '../models/person.dart';
import '../models/report_list.dart';
import '../models/truck_reception.dart';
import '../models/visual_list.dart';
import '../models/weekly_tasks.dart';
import 'sync_meta.dart';

/// Owns the app's single [Isar] instance. The name is historical: it used to
/// also track clock in/out shifts, which have since been removed.
class ShiftService {
  ShiftService._(this._isar);

  static late ShiftService instance;

  final Isar _isar;
  Isar get isar => _isar;

  /// Set once [backfillSync] has run at startup: rows saved since are
  /// stamped when written, so it isn't needed again.
  static const _backfilledKey = 'syncBackfilled';

  /// Opens the database in the app's documents folder, or in [directory]
  /// (tests).
  static Future<void> init({String? directory}) async {
    directory ??= (await getApplicationDocumentsDirectory()).path;
    final isar = await Isar.open(
      [
        TruckReceptionSchema,
        OpeningListSchema,
        AutoListSchema,
        ReportListSchema,
        VisualListSchema,
        DailyTasksSchema,
        WeeklyTasksSchema,
        InventorySchema,
        InfoEntrySchema,
        PedidoSchema,
        PersonSchema,
        CustomTaskSchema,
        CustomTaskEntrySchema,
        HorarioMesSchema,
      ],
      directory: directory,
      name: 'livre_servico',
    );
    instance = ShiftService._(isar);
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_backfilledKey) != true) {
      await instance.backfillSync();
      await prefs.setBool(_backfilledKey, true);
    }
  }

  /// Fills in missing sync fields (UUIDs) on rows from before they existed:
  /// once at the first startup, and after importing a backup, which may be
  /// that old.
  Future<void> backfillSync() async {
    Future<void> backfill<T>(IsarCollection<T> col) async {
      final rows = await col.where().findAll();
      final needsFix = rows.where((r) => SyncMeta.backfillIfNeeded(r)).toList();
      if (needsFix.isEmpty) return;
      await _isar.writeTxn(() => col.putAll(needsFix));
    }

    await backfill(_isar.truckReceptions);
    await backfill(_isar.openingLists);
    await backfill(_isar.autoLists);
    await backfill(_isar.reportLists);
    await backfill(_isar.visualLists);
    await backfill(_isar.dailyTasks);
    await backfill(_isar.weeklyTasks);
    await backfill(_isar.inventorys);
    await backfill(_isar.infoEntrys);
    await backfill(_isar.pedidos);
    await backfill(_isar.persons);
  }
}
