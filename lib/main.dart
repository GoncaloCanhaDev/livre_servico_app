import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/shift_service.dart';
import 'services/sync_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_PT');

  String? bootError;
  try {
    await dotenv.load(fileName: '.env');
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw Exception(
          'SUPABASE_URL ou SUPABASE_ANON_KEY em falta no ficheiro .env');
    }
    await Supabase.initialize(url: url, anonKey: anonKey);
    await SettingsService.instance.init();
    await NotificationService.instance.init();
    await ShiftService.init();
  } catch (e) {
    bootError = '$e';
  }

  if (bootError != null) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Erro ao iniciar a aplicação:\n$bootError',
                textAlign: TextAlign.center),
          ),
        ),
      ),
    ));
    return;
  }
  runApp(const LivreServicoApp());
}

class LivreServicoApp extends StatelessWidget {
  const LivreServicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livre Serviço Companion',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('pt', 'PT'),
      supportedLocales: const [Locale('pt', 'PT')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorObservers: [_KeyboardDismissObserver()],
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _syncStarted = false;

  @override
  void initState() {
    super.initState();
    AuthService.instance.addListener(_onChange);
    _syncWithAuth();
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    _syncWithAuth();
    if (mounted) setState(() {});
  }

  void _syncWithAuth() {
    final signedIn = AuthService.instance.isSignedIn;
    if (signedIn && !_syncStarted) {
      SyncService.instance.start();
      _syncStarted = true;
    } else if (!signedIn && _syncStarted) {
      SyncService.instance.stop();
      _syncStarted = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AuthService.instance.isSignedIn) {
      return const HomeScreen();
    }
    return const LoginScreen();
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
