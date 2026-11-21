import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Whether this browser can share files (`navigator.canShare`). Desktop
/// Firefox and Chrome on Linux have no Web Share, and share_plus only falls
/// back to a download for the error dart2js gives then, not the WebAssembly
/// build's ("canShare is not a function").
bool get browserCanShareFiles =>
    web.window.navigator.has('canShare') && web.window.navigator.has('share');

/// Saves [bytes] as a download called [name].
void downloadFile(
  Uint8List bytes, {
  required String name,
  required String mimeType,
}) {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = name
    ..style.display = 'none';
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  // Let the browser start the download before freeing the file.
  Future.delayed(
    const Duration(seconds: 30),
    () => web.URL.revokeObjectURL(url),
  );
}
