import 'package:flutter/material.dart';

import '../../theme.dart';

/// A list section's title (e.g. "Talho (6)"), tappable with an open/closed
/// chevron when [onTap] is set. [note] (e.g. "2 ✓") is shown before the
/// chevron.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    required this.open,
    this.onTap,
    this.note,
  });

  final String title;
  final bool open;
  final VoidCallback? onTap;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            if (note != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  note!,
                  style: TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (onTap != null)
              Icon(open ? Icons.expand_less : Icons.expand_more),
          ],
        ),
      ),
    );
  }
}
