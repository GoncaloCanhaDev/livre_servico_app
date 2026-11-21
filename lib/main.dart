import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/start_screen.dart';
import 'screens/widgets/app_frame.dart';
import 'screens/widgets/browser_safe_area.dart';
import 'screens/widgets/demo_banner.dart';
import 'services/account_service.dart';
import 'services/auto_mark_service.dart';
import 'services/browser_stub.dart'
    if (dart.library.js_interop) 'services/browser_web.dart';
import 'services/demo_data.dart';
import 'services/demo_mode.dart';
import 'services/horario_service.dart';
import 'services/local_db.dart';
import 'services/photo_store.dart';
import 'services/server_clock.dart';
import 'services/settings_service.dart';
import 'services/task_window_service.dart';
import 'services/web_loader_stub.dart'
    if (dart.library.js_interop) 'services/web_loader_web.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_PT');

  // The website's loading screen (web/index.html) stays up through the
  // download and the startup below, until the app's first frame is drawn.
  WidgetsBinding.instance.addPostFrameCallback((_) => hideWebLoader());
  // An iPhone's notch and home bar, which Flutter doesn't report on the web.
  watchBrowserSafeArea();

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
      if (takeSentAway()) {
        // A newer tab took the data (see holdDatabaseTab).
        runApp(const _OpenElsewhere());
        return;
      }
      await holdDatabaseTab();
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
    await HorarioService.instance.load();
    await TaskWindowService.instance.load();
    ServerClock.offset = SettingsService.instance.serverClockOffset;
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
  // What the first page reads is decoded as it reads it; the rest of the
  // history once it is drawn.
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => LocalDb.instance.preload(),
  );
  AutoMarkService.instance.start();
}

/// Every page in [AppFrame], but the website's presentation page, which
/// uses the whole width; Home and what opens from it with the side menu.
class _FramedUnlessPresentation extends StatelessWidget {
  const _FramedUnlessPresentation({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final account = AccountService.instance;
    return ListenableBuilder(
      listenable: account,
      builder: (_, _) => switch (firstPage(
        web: kIsWeb,
        configured: account.isConfigured,
        signedIn: account.isSignedIn,
        store: account.store,
        demo: DemoMode.active,
      )) {
        FirstPage.presentation => child,
        FirstPage.account => AppFrame(child: child),
        // In the app proper, a computer gets the side menu.
        FirstPage.home => AppFrame(menu: true, child: child),
      },
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
        navigatorKey: appNavigatorKey,
        navigatorObservers: [_observer, appMenuObserver],
        builder: (context, child) {
          final page = _FramedUnlessPresentation(child: child!);
          // Hours are 24h in Portugal, whatever the phone or browser says:
          // the time pickers' keyboard mode reads only this to accept 18.
          return ValueListenableBuilder(
            valueListenable: browserSafeArea,
            builder: (context, inset, _) => MediaQuery(
              data: withBrowserSafeArea(
                MediaQuery.of(context),
                inset,
              ).copyWith(alwaysUse24HourFormat: true),
              child: DemoMode.active ? DemoBanner(child: page) : page,
            ),
          );
        },
        home: const StartScreen(),
      ),
    );
  }
}

/// Shown instead of the app in a browser tab whose data a newer tab took
/// (see `holdDatabaseTab`): one tab at a time, so neither loses changes.
class _OpenElsewhere extends StatelessWidget {
  const _OpenElsewhere();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: SettingsService.instance.themeMode,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tab, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'A aplicação foi aberta noutro separador',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Só pode estar aberta num separador de cada vez, para não '
                    'se perderem alterações.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: reloadPage,
                    child: const Text('Usar aqui'),
                  ),
                ],
              ),
            ),
          ),
        ),
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
