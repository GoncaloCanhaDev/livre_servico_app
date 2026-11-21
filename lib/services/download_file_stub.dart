import 'dart:typed_data';

/// Off the web the share sheet always takes files (see
/// `download_file_web.dart`).
bool get browserCanShareFiles => true;

/// Only used in a browser (see `download_file_web.dart`).
void downloadFile(
  Uint8List bytes, {
  required String name,
  required String mimeType,
}) => throw UnsupportedError('Downloads only exist in a browser');
