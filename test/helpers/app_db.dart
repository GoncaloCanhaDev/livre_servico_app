import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar_community/isar.dart';
import 'package:livre_servico_app/services/horario_service.dart';
import 'package:livre_servico_app/services/settings_service.dart';
import 'package:livre_servico_app/services/shift_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The host build of the Isar core, from isar_community_flutter_libs in the
/// pub cache, so widget tests run against a real (empty) database.
String _isarLibrary() {
  final config = jsonDecode(
    File('.dart_tool/package_config.json').readAsStringSync(),
  );
  final package = (config['packages'] as List).firstWhere(
    (p) => p['name'] == 'isar_community_flutter_libs',
  );
  final root = Uri.parse('${package['rootUri']}/');
  final dir = root.isAbsolute
      ? root
      : Directory.current.uri.resolve('.dart_tool/').resolveUri(root);
  final file = switch (Abi.current()) {
    Abi.linuxX64 => 'linux/libisar.so',
    Abi.macosArm64 || Abi.macosX64 => 'macos/libisar.dylib',
    final abi => throw UnsupportedError('No Isar core for $abi'),
  };
  return dir.resolve(file).toFilePath();
}

/// Starts the app's services the way `main()` does, on a fresh database in
/// a temp folder and empty preferences (plus [prefs]). Call from `setUp`
/// and [closeAppDb] from `tearDown`.
Future<void> openAppDb({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues({
    // A backup "just now", so Home doesn't ask for one.
    'last_backup_at': DateTime.now().toIso8601String(),
    ...prefs,
  });
  await initializeDateFormatting('pt_PT');
  await Isar.initializeIsarCore(libraries: {Abi.current(): _isarLibrary()});
  final dir = await Directory.systemTemp.createTemp('livre_servico_test');
  await SettingsService.instance.init();
  await ShiftService.init(directory: dir.path);
  await HorarioService.instance.init();
}

Future<void> closeAppDb() async {
  await ShiftService.instance.isar.close(deleteFromDisk: true);
}
