import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Off the web, none of this applies (see `browser_web.dart`).

/// The browser's safe area (notch, home bar): always none off the web, where
/// Flutter reports the real insets itself.
final ValueListenable<EdgeInsets> browserSafeArea = ValueNotifier(
  EdgeInsets.zero,
);

void watchBrowserSafeArea() {}

bool takeSentAway() => false;

Future<void> holdDatabaseTab() async {}

void keepBrowserStorage() {}

void reloadPage() {}
