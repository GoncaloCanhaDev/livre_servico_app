import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/shift_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ShiftService.init();
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
      home: AnimatedBuilder(
        animation: ShiftService.instance,
        builder: (_, _) => const HomeScreen(),
      ),
    );
  }
}
