import 'package:flutter/material.dart';

import 'historico_screen.dart';
import 'info_screen.dart';
import 'inventory_screen.dart';
import 'pedidos_screen.dart';
import 'people_screen.dart';
import 'replenishment_lists_screen.dart';
import 'settings_screen.dart';
import 'tasks_screen.dart';
import 'truck_form_screen.dart';
import 'widgets/join_requests_card.dart';
import 'widgets/profile_request_card.dart';
import 'widgets/today_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livre Serviço Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileRequestCard(),
              const JoinRequestsCard(),
              const TodayCard(),
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 76,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _NavButton(
                    icon: Icons.local_shipping,
                    label: 'Camiões',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TruckFormScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.checklist,
                    label: 'Listas',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReplenishmentListsScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.assignment,
                    label: 'Inventários',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const InventoryScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.task_alt,
                    label: 'Tarefas',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TasksScreen()),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.receipt_long,
                    label: 'Pedidos',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PedidosScreen()),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.info_outline,
                    label: 'Informações',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InfoScreen()),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.history,
                    label: 'Histórico',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HistoricoScreen(),
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.people,
                    label: 'Pessoas',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PeopleScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon),
      label: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      onPressed: onPressed,
    );
  }
}
