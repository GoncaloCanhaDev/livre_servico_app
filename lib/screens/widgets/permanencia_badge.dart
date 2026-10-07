import 'package:flutter/material.dart';

import '../../theme.dart';

/// Small "Permanência" pill shown next to a person tagged
/// [Person.permanencia].
class PermanenciaBadge extends StatelessWidget {
  const PermanenciaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Permanência',
        style: TextStyle(
          color: AppColors.green,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
