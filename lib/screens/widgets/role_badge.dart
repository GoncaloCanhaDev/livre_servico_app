import 'package:flutter/material.dart';

import '../../theme.dart';

/// Small pill for one of a person's roles (see `roleTagsOf`): filled for
/// "Chefe", outlined for tags such as Supervisor or Permanência.
class RoleBadge extends StatelessWidget {
  const RoleBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final filled = label == 'Chefe';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: filled ? AppColors.green : null,
        border: Border.all(color: AppColors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? AppColors.white : AppColors.green,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
