import '../models/stats.dart';
import 'local_db.dart';
import 'task_window_service.dart';

/// The collections Estatísticas read: a change to any reloads them.
const statsCollections = {
  'DailyTasks',
  'WeeklyTasks',
  'CustomTask',
  'CustomTaskEntry',
  'Auto2Entry',
  'Visivel2Entry',
  'TruckReception',
  'Inventory',
  'Pedido',
  'TaskWindow',
};

/// Every row Estatísticas need, read from the app's database, with the
/// tasks' hours as set in Definições → Horas das tarefas. The rows are
/// shared with the database's cache ([LocalCollection.allReadOnly]): never
/// change them.
Future<StatsInput> loadStatsInput() async {
  final db = LocalDb.instance;
  return StatsInput(
    daily: await db.dailyTasks.allReadOnly(),
    weekly: await db.weeklyTasks.allReadOnly(),
    customTasks: await db.customTasks.allReadOnly(),
    customEntries: await db.customTaskEntries.allReadOnly(),
    auto2: await db.auto2Entries.allReadOnly(),
    visivel: await db.visivel2Entries.allReadOnly(),
    trucks: await db.truckReceptions.allReadOnly(),
    inventories: await db.inventories.allReadOnly(),
    pedidos: await db.pedidos.allReadOnly(),
    windowFor: TaskWindowService.instance.windowFor,
  );
}
