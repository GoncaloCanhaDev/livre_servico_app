import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_screen.dart';
import 'services/shift_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_PT');
  try {
    await ShiftService.init();
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Erro ao iniciar a base de dados:\n$e',
              textAlign: TextAlign.center),
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
      home: const HomeScreen(),
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
