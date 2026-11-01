import 'package:flutter/material.dart';

import '../../services/demo_mode.dart';
import 'beta_badge.dart';

/// Across the top of every page in the demo: that nothing is kept, and the
/// way out (Sair) or in (Criar conta, on the presentation page).
class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyle = TextStyle(color: colors.onTertiary, fontSize: 13);
    final buttonStyle = TextButton.styleFrom(
      foregroundColor: colors.onTertiary,
      visualDensity: VisualDensity.compact,
    );
    return Column(
      children: [
        Material(
          color: colors.tertiary,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 4),
              child: Row(
                children: [
                  const BetaBadge(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modo demonstração — nada é guardado',
                      style: textStyle,
                    ),
                  ),
                  TextButton(
                    style: buttonStyle,
                    onPressed: DemoMode.leave,
                    child: const Text('Criar conta'),
                  ),
                  TextButton(
                    style: buttonStyle,
                    onPressed: DemoMode.leave,
                    child: const Text('Sair'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          // The bar takes the top inset; the pages below don't pad it again.
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ],
    );
  }
}
