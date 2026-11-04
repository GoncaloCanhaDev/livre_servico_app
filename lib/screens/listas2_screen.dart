import 'package:flutter/material.dart';

import '../theme.dart';
import 'widgets/wide_layout.dart';

/// The store's new lists: Automáticas and Visível, empty for now.
/// The old ones (Abertura, Automáticas, Relatório, Visual) are in
/// `ReplenishmentListsScreen` (Listas 1.0), still used by other stores.
class Listas2Screen extends StatelessWidget {
  const Listas2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveTabs(
      title: Text('Listas 2.0'),
      minColumnWidth: 360,
      tabs: [
        (
          'Automáticas',
          _ComingSoon(
            icon: Icons.autorenew,
            text: 'A nova lista de Automáticas vai aparecer aqui.',
          ),
        ),
        (
          'Visível',
          _ComingSoon(
            icon: Icons.visibility_outlined,
            text: 'A nova lista do Visível vai aparecer aqui.',
          ),
        ),
      ],
    );
  }
}

/// A section with nothing in it yet.
class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ReadableWidth(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: context.faint),
              const SizedBox(height: 12),
              const Text(
                'Em breve',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.muted, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
