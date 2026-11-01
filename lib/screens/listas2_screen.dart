import 'package:flutter/material.dart';

import '../theme.dart';
import 'widgets/wide_layout.dart';

/// The store's new lists. Empty for now: the new system's lists come here.
/// The old ones (Abertura, Automáticas, Relatório, Visual) are in
/// `ReplenishmentListsScreen` (Listas Legacy), still used by other stores.
class Listas2Screen extends StatelessWidget {
  const Listas2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listas 2.0')),
      body: SafeArea(
        child: ReadableWidth(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.checklist, size: 56, color: context.faint),
                  const SizedBox(height: 12),
                  const Text(
                    'Em breve',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'As novas listas da loja vão aparecer aqui. As antigas '
                    '(Abertura, Automáticas, Relatório e Visual) continuam '
                    'em Listas Legacy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.muted, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
