import 'package:drift/drift.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';

import 'demo_db_web.dart' if (dart.library.io) 'demo_db_io.dart';

/// Whether the website was opened at [u] to show the demo (`?demo`).
bool isDemoUrl(Uri u) => u.queryParameters.containsKey('demo');

/// The website's address [base] in the demo (`?demo=1`) or out of it, on
/// its first page.
Uri demoAddress(Uri base, {required bool demo}) => Uri(
  scheme: base.scheme,
  host: base.host,
  port: base.hasPort ? base.port : null,
  path: base.path,
  queryParameters: demo ? const {'demo': '1'} : null,
);

/// The website's demo: the real app on an example store (`seedDemo`) kept
/// only in memory — a fresh database and preferences, never the browser's
/// saved ones, and no online database. Reloading starts it afresh; closing
/// the tab leaves nothing behind.
class DemoMode {
  DemoMode._();

  /// Whether the app runs as the demo (set by `main()` from the address).
  static bool active = false;

  /// A fresh database in memory.
  static Future<QueryExecutor> inMemoryDatabase() => openDemoDatabase();

  /// Preferences kept in memory from now on. Call before anything reads
  /// them.
  static void useInMemoryPrefs() => SharedPreferencesStorePlatform.instance =
      InMemorySharedPreferencesStore.empty();

  /// Reloads the website as the demo.
  static Future<void> enter() => _reload(demo: true);

  /// Reloads the website out of the demo, on the presentation page.
  static Future<void> leave() => _reload(demo: false);

  static Future<void> _reload({required bool demo}) =>
      launchUrl(demoAddress(Uri.base, demo: demo), webOnlyWindowName: '_self');
}
