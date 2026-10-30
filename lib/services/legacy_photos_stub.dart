import 'dart:typed_data';

/// In the browser there were never photo files: see `legacy_photos_io.dart`.
Future<Uint8List?> readLegacyPhoto(String path) async => null;

Future<void> deleteLegacyPhoto(String path) async {}
