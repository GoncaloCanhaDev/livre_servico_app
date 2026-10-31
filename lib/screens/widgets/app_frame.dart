import 'package:flutter/material.dart';

import '../../theme.dart';

/// On a wide screen (a computer's browser), the app in a centred column
/// [maxWidth] wide, on [AppThemeColors.backdrop], instead of stretched
/// across it; on a phone, [child] as it is.
class AppFrame extends StatelessWidget {
  const AppFrame({super.key, required this.child});

  static const maxWidth = 840.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth <= maxWidth + 48) return child;
        return ColoredBox(
          color: context.backdrop,
          child: Center(
            child: Container(
              width: maxWidth,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: context.hairline),
                ),
              ),
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(size: Size(maxWidth, box.maxHeight)),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
