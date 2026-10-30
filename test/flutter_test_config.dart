import 'dart:async';
import 'dart:ffi';

import 'package:sqlite3/open.dart';

/// Runs before every test file. Without the -dev package, Linux only has the
/// versioned libsqlite3.so.0, which sqlite3 doesn't look for on its own.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  open.overrideFor(OperatingSystem.linux, () {
    try {
      return DynamicLibrary.open('libsqlite3.so');
    } on ArgumentError {
      return DynamicLibrary.open('libsqlite3.so.0');
    }
  });
  await testMain();
}
