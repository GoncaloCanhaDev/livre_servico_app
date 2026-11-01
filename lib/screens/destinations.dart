import 'package:flutter/material.dart';

import 'avisos_screen.dart';
import 'historico_screen.dart';
import 'info_screen.dart';
import 'inventory_screen.dart';
import 'listas2_screen.dart';
import 'pedidos_screen.dart';
import 'people_screen.dart';
import 'replenishment_lists_screen.dart';
import 'settings_screen.dart';
import 'tasks_screen.dart';
import 'truck_form_screen.dart';
import 'tutorial_screen.dart';

/// A page opened from Home's buttons or the computer's side menu.
class Destination {
  const Destination(this.icon, this.label, this.page);

  final IconData icon;
  final String label;
  final Widget Function() page;

  /// The route opening it, named by [label] so the side menu knows which
  /// page is open.
  Route<void> route() => MaterialPageRoute(
    settings: RouteSettings(name: label),
    builder: (_) => page(),
  );
}

/// Home's buttons, in order.
final homeDestinations = [
  Destination(Icons.local_shipping, 'Camiões', () => const TruckFormScreen()),
  Destination(Icons.checklist, 'Listas 2.0', () => const Listas2Screen()),
  Destination(
    Icons.archive_outlined,
    'Listas Legacy',
    () => const ReplenishmentListsScreen(),
  ),
  Destination(Icons.assignment, 'Inventários', () => const InventoryScreen()),
  Destination(Icons.task_alt, 'Tarefas', () => const TasksScreen()),
  Destination(Icons.receipt_long, 'Pedidos', () => const PedidosScreen()),
  Destination(Icons.info_outline, 'Informações', () => const InfoScreen()),
  Destination(Icons.history, 'Histórico', () => const HistoricoScreen()),
  Destination(Icons.people, 'Pessoas', () => const PeopleScreen()),
];

final avisosDestination = Destination(
  Icons.campaign_outlined,
  'Avisos',
  () => const AvisosScreen(),
);

final settingsDestination = Destination(
  Icons.settings,
  'Definições',
  () => const SettingsScreen(),
);

final tutorialDestination = Destination(
  Icons.school_outlined,
  'Tutorial',
  () => const TutorialIndexScreen(),
);
