import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/auto_list.dart';
import '../models/daily_tasks.dart';
import '../models/inventory.dart';
import '../models/opening_list.dart';
import '../models/pedido.dart';
import '../models/report_list.dart';
import '../models/truck_reception.dart';
import '../models/validades.dart';
import '../models/visual_list.dart';
import '../services/auto_list_service.dart';
import '../services/daily_tasks_service.dart';
import '../services/inventory_service.dart';
import '../services/opening_list_service.dart';
import '../services/pedido_service.dart';
import '../services/report_list_service.dart';
import '../services/settings_service.dart';
import '../services/truck_service.dart';
import '../services/visual_list_service.dart';
import '../services/whatsapp_service.dart';
import '../theme.dart';
import 'widgets/person_picker.dart';

part 'historico/common.dart';
part 'historico/all_tab.dart';
part 'historico/trucks_tab.dart';
part 'historico/opening_tab.dart';
part 'historico/auto_tab.dart';
part 'historico/report_tab.dart';
part 'historico/visual_tab.dart';
part 'historico/tasks_tab.dart';
part 'historico/inventory_tab.dart';
part 'historico/pedidos_tab.dart';

class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key, this.initialTab = 0});

  final int initialTab;

  static const _tabNames = [
    'Tudo',
    'Camiões',
    'Abertura',
    'Automáticas',
    'Relatório',
    'Visual',
    'Tarefas',
    'Inventários',
    'Pedidos',
  ];

  Future<void> _clearTab(int index) async {
    switch (index) {
      case 0:
        await _clearEverything();
        break;
      case 1:
        await TruckService.instance.deleteAll();
        break;
      case 2:
        await OpeningListService.instance.deleteAll();
        break;
      case 3:
        await AutoListService.instance.deleteAll();
        break;
      case 4:
        await ReportListService.instance.deleteAll();
        break;
      case 5:
        await VisualListService.instance.deleteAll();
        break;
      case 6:
        await DailyTasksService.instance.deleteAll();
        break;
      case 7:
        await InventoryService.instance.deleteAll();
        break;
      case 8:
        await PedidoService.instance.deleteAll();
        break;
    }
  }

  Future<void> _clearEverything() async {
    await TruckService.instance.deleteAll();
    await OpeningListService.instance.deleteAll();
    await AutoListService.instance.deleteAll();
    await ReportListService.instance.deleteAll();
    await VisualListService.instance.deleteAll();
    await DailyTasksService.instance.deleteAll();
    await InventoryService.instance.deleteAll();
    await PedidoService.instance.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabNames.map((n) => Tab(text: n)).toList();
    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialTab.clamp(0, tabs.length - 1),
      child: Builder(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: const Text('Histórico'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (v) async {
                  final controller = DefaultTabController.of(ctx);
                  if (v == 'tab') {
                    final name = _tabNames[controller.index];
                    if (await _confirmHardDelete(
                      ctx,
                      'Apagar histórico de $name?',
                    )) {
                      await _clearTab(controller.index);
                    }
                  } else if (v == 'all') {
                    if (await _confirmHardDelete(
                      ctx,
                      'Apagar TODO o histórico?',
                    )) {
                      await _clearEverything();
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'tab',
                    child: Text('Apagar separador atual'),
                  ),
                  PopupMenuItem(
                    value: 'all',
                    child: Text(
                      'Apagar todo o histórico',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: tabs,
            ),
          ),
          body: const SafeArea(
            child: TabBarView(
              children: [
                _AllTab(),
                _TrucksTab(),
                _OpeningTab(),
                _AutoTab(),
                _ReportTab(),
                _VisualTab(),
                _TasksTab(),
                _InventoryTab(),
                _PedidosTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
