import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lets the real database calls a screen started finish and its route
/// animation end. A read only completes in [WidgetTester.runAsync] and the
/// code awaiting it only resumes on a pump, so a screen reading several
/// things in turn needs a round each. Not pumpAndSettle: a spinner shown
/// while loading would keep it waiting.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 25; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Runs a database [call] from the test, pumping until it finishes: it may
/// wait for a write the app started, which only moves on a pump. Fails
/// instead of hanging if it never does.
Future<T> dbCall<T>(WidgetTester tester, Future<T> Function() call) async {
  late T result;
  var done = false;
  call().then((v) {
    result = v;
    done = true;
  });
  for (var i = 0; !done; i++) {
    if (i == 500) fail('A database call never finished');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  return result;
}

/// Shows [app] on a phone-sized screen.
Future<void> pumpApp(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  // A save makes open screens read again; closing the database with a read
  // still waiting on a pump would hang, so take the app down first.
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  });
  await tester.pumpWidget(app);
  await settle(tester);
}

/// Brings [finder] on screen, scrolling the page down to build it first
/// if a lazy list hasn't yet.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pump();
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await scrollTo(tester, finder);
  await tester.tap(finder);
  await settle(tester);
}
