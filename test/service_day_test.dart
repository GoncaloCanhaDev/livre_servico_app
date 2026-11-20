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
}
