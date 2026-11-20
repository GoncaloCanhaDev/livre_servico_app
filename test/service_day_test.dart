import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/opening_list.dart';

void main() {
  test('a service day runs from 05:00 to 05:00', () {
    expect(
      currentServiceDay(DateTime(2026, 11, 20, 5)),
      DateTime(2026, 11, 20, 5),
    );
    expect(
      currentServiceDay(DateTime(2026, 11, 20, 4, 59)),
      DateTime(2026, 11, 19, 5),
    );
    expect(
      currentServiceDay(DateTime(2026, 12, 1, 2)),
      DateTime(2026, 11, 30, 5),
    );
  });

  test('the night the clocks go forward stays on the Sunday', () {
    // 28 March 2027 (Lisbon: 01:00 → 02:00); Monday 00:30 is 23 hours on.
    expect(
      currentServiceDay(DateTime(2027, 3, 29, 0, 30)),
      DateTime(2027, 3, 28, 5),
    );
  });

  test('inServiceDay agrees with currentServiceDay, clock changes too', () {
    // A normal day and the two days the clocks change (Lisbon).
    for (final day in [
      DateTime(2026, 11, 20, 5),
      DateTime(2027, 3, 28, 5),
      DateTime(2026, 10, 25, 5),
    ]) {
      final inDay = inServiceDay(day);
      for (var m = -30 * 60; m < 54 * 60; m += 7) {
        final t = DateTime(day.year, day.month, day.day, 0, m);
        expect(
          inDay(t),
          currentServiceDay(t).isAtSameMomentAs(day),
          reason: '$t',
        );
      }
    }
  });

  test('groupByServiceDay: newest day first, each newest first', () {
    final times = [
      DateTime(2026, 11, 20, 4, 59),
      DateTime(2026, 11, 20, 5),
      DateTime(2026, 11, 21, 2),
      DateTime(2026, 11, 19, 12),
      DateTime(2026, 11, 20, 23),
    ];
    final grouped = groupByServiceDay(times, (t) => t);
    expect(grouped.keys, [
      DateTime(2026, 11, 20, 5),
      DateTime(2026, 11, 19, 5),
    ]);
    expect(grouped[DateTime(2026, 11, 20, 5)], [
      DateTime(2026, 11, 21, 2),
      DateTime(2026, 11, 20, 23),
      DateTime(2026, 11, 20, 5),
    ]);
    expect(grouped[DateTime(2026, 11, 19, 5)], [
      DateTime(2026, 11, 20, 4, 59),
      DateTime(2026, 11, 19, 12),
    ]);
  });
}
