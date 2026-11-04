import 'package:flutter/material.dart';

import 'tabs/automaticas2_tab.dart';
import 'tabs/visivel2_tab.dart';
import 'widgets/wide_layout.dart';

/// The store's new lists: Automáticas, sent item by item all day, and the
/// Visível, once a day after a round of them. Neither is locked.
/// The old ones (Abertura, Automáticas, Relatório, Visual) are in
/// `ReplenishmentListsScreen` (Listas 1.0), still used by other stores.
class Listas2Screen extends StatelessWidget {
  const Listas2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveTabs(
      title: Text('Listas 2.0'),
      minColumnWidth: 360,
      tabs: [('Automáticas', Automaticas2Tab()), ('Visível', Visivel2Tab())],
    );
  }
}
