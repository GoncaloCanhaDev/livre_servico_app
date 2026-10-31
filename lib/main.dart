import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/start_screen.dart';
import 'screens/widgets/app_frame.dart';
import 'screens/widgets/demo_banner.dart';
import 'services/account_service.dart';
import 'services/demo_data.dart';
import 'services/demo_mode.dart';
import 'services/local_db.dart';
import 'services/photo_store.dart';
import 'services/settings_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_PT');

  String? bootError;
  try {
    if (kIsWeb && isDemoUrl(Uri.base)) {
      // The demo: an example store in memory, nothing saved, no network.
      DemoMode.active = true;
      DemoMode.useInMemoryPrefs();
      await SettingsService.instance.init();
      await LocalDb.init(executor: await DemoMode.inMemoryDatabase());
      await AccountService.instance.init();
      await seedDemo();
    } else {
      await SettingsService.instance.init();
      await LocalDb.init();
      try {
        // Once: photo files from earlier versions into the database.
        await PhotoStore.instance.migrateLegacy();
      } catch (_) {
        // Not worth stopping the app over: tried again at the next start.
      }
      // Restores the session in the background: never waits for the network.
      await AccountService.instance.init();
    }
  } catch (e) {
    bootError = '$e';
  }

  if (bootError != null) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Erro ao iniciar a aplicação:\n$bootError',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }
  runApp(const LivreServicoApp());
}

/// Every page in [AppFrame], but the website's presentation page, which
/// uses the whole width.
class _FramedUnlessPresentation extends StatelessWidget {
  const _FramedUnlessPresentation({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final account = AccountService.instance;
    return ListenableBuilder(
      listenable: account,
      builder: (_, _) =>
          firstPage(
                web: kIsWeb,
                configured: account.isConfigured,
                signedIn: account.isSignedIn,
                store: account.store,
                demo: DemoMode.active,
              ) ==
              FirstPage.presentation
          ? child
          : AppFrame(child: child),
    );
  }
}

class LivreServicoApp extends StatelessWidget {
  const LivreServicoApp({super.key});

  static final _observer = _KeyboardDismissObserver();

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;
    return ListenableBuilder(
      listenable: settings,
      builder: (_, _) => MaterialApp(
        title: 'Livre Serviço Companion',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        themeMode: settings.themeMode,
        locale: const Locale('pt', 'PT'),
        supportedLocales: const [Locale('pt', 'PT')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        navigatorObservers: [_observer],
        builder: (_, child) {
          final page = _FramedUnlessPresentation(child: child!);
          return DemoMode.active ? DemoBanner(child: page) : page;
        },
        home: const StartScreen(),
      ),
    );
  }
}

class _KeyboardDismissObserver extends NavigatorObserver {
  void _unfocus() {
    final focus = FocusManager.instance.primaryFocus;
    focus?.unfocus();
  }

  @override
  void didPush(Route route, Route? previousRoute) => _unfocus();

  @override
  void didPop(Route route, Route? previousRoute) => _unfocus();

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _unfocus();
}
