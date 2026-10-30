import 'dart:io';
import 'dart:typed_data';

/// A photo file saved by a version before [PhotoStore] (on the phone);
/// null when it is gone.
Future<Uint8List?> readLegacyPhoto(String path) async {
  try {
    final file = File(path);
    return await file.exists() ? await file.readAsBytes() : null;
  } catch (_) {
    return null;
  }
}

Future<void> deleteLegacyPhoto(String path) async {
  try {
    await File(path).delete();
  } catch (_) {
    // Already gone.
  }
}
