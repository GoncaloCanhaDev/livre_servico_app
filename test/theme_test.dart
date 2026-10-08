import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/theme.dart';

void main() {
  test('the light theme keeps the original colours', () {
    final s = buildAppTheme(Brightness.light).colorScheme;
    expect(s.brightness, Brightness.light);
    expect(s.primary, AppColors.green);
    expect(s.secondary, AppColors.greenDark);
    expect(s.surface, AppColors.white);
    expect(s.onSurface, AppColors.black);
  });

  test('the dark theme has a dark surface and light text', () {
    final t = buildAppTheme(Brightness.dark);
    final s = t.colorScheme;
    expect(s.brightness, Brightness.dark);
    expect(s.surface.computeLuminance(), lessThan(0.05));
    expect(s.onSurface.computeLuminance(), greaterThan(0.7));
    expect(t.scaffoldBackgroundColor, s.surface);
    // The app bar stays black in both.
    expect(t.appBarTheme.backgroundColor, AppColors.black);
  });
}
