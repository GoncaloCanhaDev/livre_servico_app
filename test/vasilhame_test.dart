import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/vasilhame.dart';

void main() {
  group('vasilhameFromJson', () {
    test('reads name, code and ean, in order', () {
      final items = vasilhameFromJson([
        {'name': 'Grade Sagres 33cl', 'code': '123456', 'ean': '5601234567890'},
        {'name': ' Palete Euro '},
      ]);
      expect(items.map((i) => i.name), ['Grade Sagres 33cl', 'Palete Euro']);
      expect(items.first.code, '123456');
      expect(items.first.ean, '5601234567890');
      expect(items.last.code, isNull);
      expect(items.last.ean, isNull);
    });

    test('numbers are read as text, blanks as missing', () {
      final item = vasilhameFromJson([
        {'name': 'Barril', 'code': 234567, 'ean': ''},
      ]).single;
      expect(item.code, '234567');
      expect(item.ean, isNull);
    });

    test('says which item is wrong', () {
      expect(
        () => vasilhameFromJson([
          {'name': 'Grade'},
          {'code': '1'},
        ]),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('nº 2'),
          ),
        ),
      );
      expect(() => vasilhameFromJson({'name': 'Grade'}), throwsFormatException);
      expect(() => vasilhameFromJson(['Grade']), throwsFormatException);
    });
  });

  test('toJson leaves out what is missing and reads back the same', () {
    const items = [
      VasilhameItem(name: 'Grade', code: '1', ean: '5601234567890'),
      VasilhameItem(name: 'Palete'),
    ];
    final json = [for (final i in items) i.toJson()];
    expect(json.last, {'name': 'Palete'});
    final back = vasilhameFromJson(json);
    expect(back.map((i) => (i.name, i.code, i.ean)), [
      ('Grade', '1', '5601234567890'),
      ('Palete', null, null),
    ]);
  });

  group('vasilhameFromBackup', () {
    test('null for a backup without the section', () {
      expect(vasilhameFromBackup({'version': 1, 'collections': {}}), isNull);
    });

    test('the list when present, even empty', () {
      expect(vasilhameFromBackup({'vasilhame': []}), isEmpty);
      expect(
        vasilhameFromBackup({
          'vasilhame': [
            {'name': 'Grade'},
          ],
        })!.single.name,
        'Grade',
      );
    });
  });

  test('the built-in list has the 27 items with valid EAN-13s', () {
    expect(defaultVasilhame, hasLength(27));
    expect(defaultVasilhame.map((i) => i.name).toSet(), hasLength(27));
    for (final item in defaultVasilhame) {
      final d = item.ean!.split('').map(int.parse).toList();
      var sum = 0;
      for (var i = 0; i < 12; i++) {
        sum += d[i] * (i.isEven ? 1 : 3);
      }
      expect(d, hasLength(13), reason: item.name);
      expect((10 - sum % 10) % 10, d[12], reason: item.name);
    }
  });
}
