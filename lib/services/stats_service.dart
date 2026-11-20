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
/// tasks' hours as set in Definições → Horas das tarefas.
Future<StatsInput> loadStatsInput() async {
  final db = LocalDb.instance;
  return StatsInput(
    daily: await db.dailyTasks.all(),
    weekly: await db.weeklyTasks.all(),
    customTasks: await db.customTasks.all(),
    customEntries: await db.customTaskEntries.all(),
    auto2: await db.auto2Entries.all(),
    visivel: await db.visivel2Entries.all(),
    trucks: await db.truckReceptions.all(),
    inventories: await db.inventories.all(),
    pedidos: await db.pedidos.all(),
    windowFor: TaskWindowService.instance.windowFor,
  );
}
