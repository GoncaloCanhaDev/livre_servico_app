import 'package:flutter/material.dart';

import 'tabs/abertura_tab.dart';
import 'tabs/automaticas_tab.dart';
import 'tabs/relatorio_tab.dart';
import 'tabs/visual_tab.dart';
import 'widgets/wide_layout.dart';

/// Listas 1.0: the old Abertura, Automáticas, Relatório and Visual lists,
/// kept for the stores still using them (the new ones are in Listas 2.0).
class ReplenishmentListsScreen extends StatelessWidget {
  const ReplenishmentListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveTabs(
      title: Text('Listas 1.0'),
      scrollable: true,
      minColumnWidth: 360,
      tabs: [
        ('Abertura', AberturaTab()),
        ('Automáticas', AutomaticasTab()),
        ('Relatório Dia Anterior', RelatorioTab()),
        ('Visual', VisualTab()),
      ],
    );
  }
}
