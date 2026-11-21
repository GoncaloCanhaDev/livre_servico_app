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
    // The probe's size is its padding, so this also catches the insets
    // arriving late (once the browser applies viewport-fit) without a
    // resize.
    if (globalContext.has('ResizeObserver')) {
      void observed(JSArray<web.ResizeObserverEntry> _, web.ResizeObserver _) =>
          read();
      web.ResizeObserver(
        observed.toJS,
      ).observe(probe, web.ResizeObserverOptions(box: 'border-box'));
    }
    for (final ms in const [100, 500, 1500]) {
      Timer(Duration(milliseconds: ms), read);
    }
  } catch (_) {
    // Without the insets the page looks as it did before: never worth
    // stopping the app over.
  }
}

double _px(String value) =>
    double.tryParse(value.replaceAll('px', '').trim()) ?? 0;

const _sentAwayKey = 'livre_servico_sent_away';

/// Whether another tab took the data from this one (see [holdDatabaseTab]),
/// which then reloaded to say so: show that instead of opening the data.
/// Read once: a reload, or "Usar aqui", opens the app here again.
bool takeSentAway() {
  try {
    final storage = web.window.sessionStorage;
    if (storage.getItem(_sentAwayKey) == null) return false;
    storage.removeItem(_sentAwayKey);
    return true;
  } catch (_) {
    return false;
  }
}

/// Makes this the one tab using the data: each tab keeps the rows in memory
/// (`LocalDb`) and never hears of another tab's writes, so two would save
/// stale copies over each other's changes (and without SharedWorker, as in
/// Chrome on Android, drift even keeps one copy of the database per tab).
/// The newest tab takes the `livre_servico_db` Web Lock from the one holding
/// it, which reloads into [takeSentAway]: so the tab in front always works,
/// and a link opened in a new tab (an email confirmation) too.
Future<void> holdDatabaseTab() async {
  try {
    final navigator = web.window.navigator;
    if (!navigator.has('locks')) return;
    final granted = Completer<void>();
    // Never completes: the lock stays held until the tab closes, or another
    // takes it.
    final forever = Completer<void>();
    JSPromise<JSAny?> onGranted(web.Lock? lock) {
      if (!granted.isCompleted) granted.complete();
      return forever.future.toJS;
    }

    unawaited(
      navigator.locks
          .request(
            'livre_servico_db',
            web.LockOptions(steal: true),
            onGranted.toJS,
          )
          .toDart
          .then<void>(
            (_) {},
            onError: (Object _) {
              if (!granted.isCompleted) {
                // Refused outright: carry on without it.
                granted.complete();
                return;
              }
              // Held, then taken by a newer tab.
              try {
                web.window.sessionStorage.setItem(_sentAwayKey, '1');
              } catch (_) {}
              web.window.location.reload();
            },
          ),
    );
    await granted.future.timeout(const Duration(seconds: 2), onTimeout: () {});
  } catch (_) {}
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
