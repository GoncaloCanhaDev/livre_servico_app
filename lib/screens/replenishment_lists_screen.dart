import 'package:flutter/material.dart';

import 'tabs/abertura_tab.dart';
import 'tabs/automaticas_tab.dart';
import 'tabs/relatorio_tab.dart';
import 'tabs/visual_tab.dart';
import 'widgets/wide_layout.dart';

class ReplenishmentListsScreen extends StatelessWidget {
  const ReplenishmentListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveTabs(
      title: Text('Listas de Reposição'),
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
