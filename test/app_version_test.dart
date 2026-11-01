import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/app_version.dart';

void main() {
  test('appVersion is pubspec.yaml\'s version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*([^+\s]+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(appVersion, version);
  });
}
