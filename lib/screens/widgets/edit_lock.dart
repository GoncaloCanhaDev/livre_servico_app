import 'package:flutter/material.dart';

/// [child] as it is when [enabled]; otherwise faded and not reacting to
/// touch: a part of a form this account may not change.
class EditLock extends StatelessWidget {
  const EditLock({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !enabled,
    child: Opacity(opacity: enabled ? 1 : 0.5, child: child),
  );
}
