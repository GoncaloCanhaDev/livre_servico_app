import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// [data] with the browser's safe area ([inset], `browserSafeArea`) added
/// where Flutter reports less, as the phone app gets it: in `viewPadding`
/// always, in `padding` less whatever the keyboard covers (`viewInsets`).
MediaQueryData withBrowserSafeArea(MediaQueryData data, EdgeInsets inset) {
  if (inset == EdgeInsets.zero) return data;
  EdgeInsets atLeast(EdgeInsets a, EdgeInsets b) => EdgeInsets.fromLTRB(
    math.max(a.left, b.left),
    math.max(a.top, b.top),
    math.max(a.right, b.right),
    math.max(a.bottom, b.bottom),
  );
  final keyboard = data.viewInsets;
  final uncovered = EdgeInsets.fromLTRB(
    math.max(0, inset.left - keyboard.left),
    math.max(0, inset.top - keyboard.top),
    math.max(0, inset.right - keyboard.right),
    math.max(0, inset.bottom - keyboard.bottom),
  );
  return data.copyWith(
    viewPadding: atLeast(data.viewPadding, inset),
    padding: atLeast(data.padding, uncovered),
  );
}
