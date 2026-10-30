import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:livre_servico_app/services/account_service.dart';
import 'package:livre_servico_app/services/horario_service.dart';
import 'package:livre_servico_app/services/local_db.dart';
import 'package:livre_servico_app/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Starts the app's services the way `main()` does, on a fresh in-memory
/// SQLite database and empty preferences (plus [prefs]). Call from `setUp`
/// and [closeAppDb] from `tearDown`.
Future<void> openAppDb({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues({
    // A backup "just now", so Home doesn't ask for one.
    'last_backup_at': DateTime.now().toIso8601String(),
    ...prefs,
  });
  await initializeDateFormatting('pt_PT');
  await SettingsService.instance.init();
  await LocalDb.init(executor: NativeDatabase.memory());
  await HorarioService.instance.init();
  await AccountService.instance.init();
}

Future<void> closeAppDb() => LocalDb.instance.close();
