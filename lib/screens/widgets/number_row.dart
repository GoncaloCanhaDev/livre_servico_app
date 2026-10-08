import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme.dart';

class NumberRow extends StatelessWidget {
  const NumberRow({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.enabled = true,
    this.trailing,
    this.subtitle,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onChanged;

  /// Shown after the number, e.g. a section's send button.
  final Widget? trailing;

  /// Small text under [label], e.g. who sent the section.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle case final subtitle?)
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: context.muted),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 110,
              child: TextField(
                controller: controller,
                enabled: enabled,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: '0',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
            if (trailing case final trailing?) ...[
              const SizedBox(width: 4),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
}
