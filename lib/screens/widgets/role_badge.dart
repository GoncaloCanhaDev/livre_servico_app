import 'package:flutter/material.dart';

import '../../theme.dart';

/// Small pill for one of a person's roles (see `roleTagsOf`): filled for
/// "Chefe", outlined for tags such as Supervisor or Permanência. With [away]
/// it is a filled orange pill for an ausência (see `awayTagOn`); with
/// [tenure] an outlined blue one for Em formação / Novo (see `tenureTagOf`).
class RoleBadge extends StatelessWidget {
  const RoleBadge(
    this.label, {
    super.key,
    this.away = false,
    this.tenure = false,
  });

  final String label;
  final bool away;
  final bool tenure;

  @override
  Widget build(BuildContext context) {
    final filled = away || label == 'Chefe';
    final color = away
        ? Colors.orange.shade800
        : tenure
        ? Colors.blue.shade700
        : AppColors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: filled ? color : null,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? AppColors.white : color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
