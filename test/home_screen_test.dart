import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/main.dart';
import 'package:livre_servico_app/screens/historico_screen.dart';
import 'package:livre_servico_app/screens/horarios_screen.dart';
import 'package:livre_servico_app/screens/info_screen.dart';
import 'package:livre_servico_app/screens/inventory_screen.dart';
import 'package:livre_servico_app/screens/pedidos_screen.dart';
import 'package:livre_servico_app/screens/people_screen.dart';
import 'package:livre_servico_app/screens/replenishment_lists_screen.dart';
import 'package:livre_servico_app/screens/settings_screen.dart';
import 'package:livre_servico_app/screens/tasks_screen.dart';
import 'package:livre_servico_app/screens/truck_form_screen.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  testWidgets('Home opens on an empty database', (tester) async {
    await pumpApp(tester, const LivreServicoApp());
    expect(find.text('Livre Serviço Companion'), findsOneWidget);
    expect(find.textContaining('Hoje · '), findsOneWidget);
  });

  // Every screen (and every tab in it) builds on an empty database.
  for (final (label, screen) in [
    ('Camiões', TruckFormScreen),
    ('Listas', ReplenishmentListsScreen),
    ('Inventários', InventoryScreen),
    ('Tarefas', TasksScreen),
    ('Pedidos', PedidosScreen),
    ('Informações', InfoScreen),
    ('Histórico', HistoricoScreen),
    ('Pessoas', PeopleScreen),
    ('Horários', HorariosScreen),
  ]) {
    testWidgets('$label opens from Home', (tester) async {
      await pumpApp(tester, const LivreServicoApp());
      await tapAndSettle(tester, find.text(label));
      expect(find.byType(screen), findsOneWidget);

      final tabs = find.descendant(
        of: find.byType(screen),
        matching: find.byType(Tab),
      );
      for (var i = 0; i < tabs.evaluate().length; i++) {
        await tapAndSettle(tester, tabs.at(i));
      }
    });
  }

  testWidgets('Definições opens from Home', (tester) async {
    await pumpApp(tester, const LivreServicoApp());
    await tapAndSettle(tester, find.byIcon(Icons.settings));
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
