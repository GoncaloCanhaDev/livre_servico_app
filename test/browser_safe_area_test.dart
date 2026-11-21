import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/screens/widgets/browser_safe_area.dart';

void main() {
  const iphone = EdgeInsets.fromLTRB(0, 0, 0, 34);

  test('no inset leaves the data as it is', () {
    const data = MediaQueryData(padding: EdgeInsets.only(top: 10));
    expect(withBrowserSafeArea(data, EdgeInsets.zero), same(data));
  });

  test('adds the home bar to padding and viewPadding', () {
    final out = withBrowserSafeArea(const MediaQueryData(), iphone);
    expect(out.padding, iphone);
    expect(out.viewPadding, iphone);
  });

  test('the keyboard covers the home bar', () {
    final out = withBrowserSafeArea(
      const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 300)),
      iphone,
    );
    expect(out.padding.bottom, 0);
    expect(out.viewPadding.bottom, 34);
  });

  test('keeps a larger inset Flutter already reports', () {
    final out = withBrowserSafeArea(
      const MediaQueryData(
        padding: EdgeInsets.only(bottom: 40),
        viewPadding: EdgeInsets.only(bottom: 40),
      ),
      const EdgeInsets.fromLTRB(44, 0, 44, 21),
    );
    expect(out.padding, const EdgeInsets.fromLTRB(44, 0, 44, 40));
    expect(out.viewPadding, const EdgeInsets.fromLTRB(44, 0, 44, 40));
  });
}
