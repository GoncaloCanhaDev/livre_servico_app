import 'package:flutter/material.dart';

import 'tabs/abertura_tab.dart';
import 'tabs/automaticas_tab.dart';
import 'tabs/relatorio_tab.dart';
import 'tabs/visual_tab.dart';

class ReplenishmentListsScreen extends StatelessWidget {
  const ReplenishmentListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      Tab(text: 'Abertura'),
      Tab(text: 'Automáticas'),
      Tab(text: 'Relatório Dia Anterior'),
      Tab(text: 'Visual'),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Listas de Reposição'),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: tabs,
          ),
        ),
        body: const TabBarView(
          children: [
            AberturaTab(),
            AutomaticasTab(),
            RelatorioTab(),
            VisualTab(),
          ],
        ),
      ),
    );
  }
}