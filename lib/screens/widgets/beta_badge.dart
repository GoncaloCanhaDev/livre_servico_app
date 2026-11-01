import 'package:flutter/material.dart';

import '../../theme.dart';

/// The "BETA" pill shown beside the app's name (Home, the side menu, the
/// presentation page and the demo banner) while the app is still in beta.
/// Amber with black text, so it stands out on the black app bar, on the page
/// and on the demo banner, in both themes.
class BetaBadge extends StatelessWidget {
  const BetaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.amber.shade600,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'BETA',
        style: TextStyle(
          color: AppColors.black,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          height: 1.3,
        ),
      ),
    );
  }
}
