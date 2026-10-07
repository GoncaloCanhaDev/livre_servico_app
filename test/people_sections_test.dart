import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/people_sections.dart';

Person _p(String name, {String? role, String number = ''}) => Person()
  ..fullName = name
  ..createdAt = DateTime(2026)
  ..role = role
  ..collaboratorNumber = number;

List<String> _names(PeopleSection s) =>
    s.people.map((p) => p.fullName).toList();

List<String> _titles(List<PeopleSection> sections) =>
    sections.map((s) => s.title).toList();

void main() {
  group('foldText', () {
    test('lowercases and strips Portuguese accents', () {
      expect(foldText('ÁÀÂÃ éê Í ÓÔÕ Ú Ç'), 'aaaa ee i ooo u c');
    });
  });

  group('grouping', () {
    test('groups by cargo A–Z, people A–Z inside, Sem cargo last', () {
      final sections = buildPeopleSections([
        _p('Rui', role: 'Operador'),
        _p('João'),
        _p('Ana', role: 'operador '),
        _p('Bia', role: 'Chefe de Secção'),
        _p('Carla', role: '  '),
      ]);

      expect(_titles(sections), ['Chefe de Secção', 'Operador', 'Sem cargo']);
      expect(_names(sections[1]), ['Ana', 'Rui']);
      expect(_names(sections[2]), ['Carla', 'João']);
    });

    test('orders people A–Z ignoring case and accents', () {
      final sections = buildPeopleSections([
        _p('Bruno Costa', role: 'Operador'),
        _p('Álvaro Reis', role: 'Operador'),
        _p('ana Martins', role: 'Operador'),
      ]);

      expect(_names(sections.single), [
        'Álvaro Reis',
        'ana Martins',
        'Bruno Costa',
      ]);
    });
  });

  group('search', () {
    final people = [
      _p('João Pinto', role: 'Operador', number: '3101'),
      _p('Ana Martins', role: 'Chefe de Secção', number: '1234'),
    ];

    List<String> found(String q) =>
        buildPeopleSections(people, query: q).expand(_names).toList();

    test('matches name ignoring case and accents', () {
      expect(found('joao'), ['João Pinto']);
    });

    test('matches cargo', () {
      expect(found('seccao'), ['Ana Martins']);
    });

    test('matches nº de colaborador', () {
      expect(found('310'), ['João Pinto']);
    });

    test('drops sections left empty', () {
      expect(_titles(buildPeopleSections(people, query: 'ana')), [
        'Chefe de Secção',
      ]);
    });

    test('blank query keeps everyone', () {
      expect(found('  '), ['Ana Martins', 'João Pinto']);
    });
  });
}
