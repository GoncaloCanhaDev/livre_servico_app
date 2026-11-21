import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

final _safeArea = ValueNotifier<EdgeInsets>(EdgeInsets.zero);

/// The browser's safe area: on an iPhone, the notch and the home bar
/// (`env(safe-area-inset-*)`). Flutter's web engine never reports them, so
/// `MaterialApp.builder` adds them to the [MediaQuery] (see
/// `withBrowserSafeArea`) and every `SafeArea` works as on the phone app.
ValueListenable<EdgeInsets> get browserSafeArea => _safeArea;

/// Starts [browserSafeArea]: lets the page use the whole screen
/// (`viewport-fit=cover`, added to the viewport tag Flutter writes at
/// startup), then reads the insets now and on every resize or rotation.
void watchBrowserSafeArea() {
  try {
    final meta = web.document.querySelector('meta[name="viewport"]');
    if (meta != null) {
      final content = meta.getAttribute('content') ?? '';
      if (!content.contains('viewport-fit')) {
        meta.setAttribute(
          'content',
          content.isEmpty
              ? 'viewport-fit=cover'
              : '$content, viewport-fit=cover',
        );
      }
    }
    final probe = web.document.createElement('div') as web.HTMLDivElement;
    probe.setAttribute('aria-hidden', 'true');
    probe.style.cssText =
        'position:fixed;top:0;left:0;width:0;height:0;visibility:hidden;'
        'pointer-events:none;padding:env(safe-area-inset-top,0px) '
        'env(safe-area-inset-right,0px) env(safe-area-inset-bottom,0px) '
        'env(safe-area-inset-left,0px)';
    web.document.body!.append(probe);
    void read() {
      final style = web.window.getComputedStyle(probe);
      final inset = EdgeInsets.fromLTRB(
        _px(style.paddingLeft),
        _px(style.paddingTop),
        _px(style.paddingRight),
        _px(style.paddingBottom),
      );
      if (inset != _safeArea.value) _safeArea.value = inset;
    }

    void readSoon(web.Event _) {
      read();
      // iOS settles the insets a moment after a rotation.
      Timer(const Duration(milliseconds: 300), read);
    }

    read();
    web.window.addEventListener('resize', readSoon.toJS);
    web.window.addEventListener('orientationchange', readSoon.toJS);
  } catch (_) {
    // Without the insets the page looks as it did before: never worth
    // stopping the app over.
  }
}

double _px(String value) =>
    double.tryParse(value.replaceAll('px', '').trim()) ?? 0;

/// Whether this tab may open the database. Where the browser has no
/// SharedWorker (Chrome on Android), drift keeps the data in IndexedDB with
/// one copy per tab, and two tabs would overwrite each other's changes; so
/// only one tab at a time holds the `livre_servico_db` Web Lock, until it
/// closes. Elsewhere (and with no Web Locks) every tab may.
Future<bool> claimSingleTab() async {
  try {
    if (globalContext.has('SharedWorker')) return true;
    final navigator = web.window.navigator;
    if (!navigator.has('locks')) return true;
    final held = Completer<bool>();
    // Never completes: the lock stays held until the tab closes.
    final forever = Completer<void>();
    JSPromise<JSAny?> granted(web.Lock? lock) {
      held.complete(lock != null);
      return lock == null ? Future<void>.value().toJS : forever.future.toJS;
    }

    navigator.locks.request(
      'livre_servico_db',
      web.LockOptions(ifAvailable: true),
      granted.toJS,
    );
    return await held.future;
  } catch (_) {
    return true;
  }
}

/// Asks the browser to keep this site's data (`navigator.storage.persist`):
/// otherwise Safari erases it after a week without a visit, and any browser
/// may when the phone is short of space. Nothing to ask once it's kept.
void keepBrowserStorage() {
  unawaited(() async {
    try {
      final navigator = web.window.navigator;
      if (!navigator.has('storage')) return;
      final storage = navigator.storage;
      if ((await storage.persisted().toDart).toDart) return;
      await storage.persist().toDart;
    } catch (_) {}
  }());
}

/// Loads the page again.
void reloadPage() => web.window.location.reload();
