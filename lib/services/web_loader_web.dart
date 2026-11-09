import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Hides the loading screen `web/index.html` shows while the app downloads
/// and starts (`hideLoader` there).
void hideWebLoader() {
  if (globalContext.has('hideLoader')) {
    globalContext.callMethod('hideLoader'.toJS);
  }
}
