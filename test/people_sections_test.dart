import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/people_sections.dart';

Person _p(String name, {String? role, String number = '', DateTime? hired}) =>
    Person()
      ..fullName = name
      ..createdAt = DateTime(2026)
      ..role = role
      ..collaboratorNumber = number
      ..hireDate = hired;

List<String> _names(PeopleSection s) =>
    s.people.map((p) => p.fullName).toList();

List<String?> _titles(List<PeopleSection> sections) =>
    sections.map((s) => s.title).toList();

void main() {
  group('foldText', () {
    test('lowercases and strips Portuguese accents', () {
      expect(foldText('ÁÀÂÃ éê Í ÓÔÕ Ú Ç'), 'aaaa ee i ooo u c');
    });
  });

  group('sort by name', () {
    test('orders A–Z under letter headers, ignoring accents', () {
      final sections = buildPeopleSections([
        _p('Bruno Costa'),
        _p('Álvaro Reis'),
        _p('ana Martins'),
      ], sort: PeopleSort.name);

      expect(_titles(sections), ['A', 'B']);
      expect(_names(sections[0]), ['Álvaro Reis', 'ana Martins']);
      expect(_names(sections[1]), ['Bruno Costa']);
    });

    test('puts names not starting with a letter under #', () {
      final sections = buildPeopleSections([
        _p('Zé'),
        _p('1 Temporário'),
      ], sort: PeopleSort.name);

      expect(_titles(sections), ['Z', '#']);
    });
  });

  group('sort by role', () {
    test('groups by cargo A–Z, people A–Z inside, Sem cargo last', () {
      final sections = buildPeopleSections([
        _p('Rui', role: 'Operador'),
        _p('João'),
        _p('Ana', role: 'operador '),
        _p('Bia', role: 'Chefe de Secção'),
        _p('Carla', role: '  '),
      ], sort: PeopleSort.role);

      expect(_titles(sections), ['Chefe de Secção', 'Operador', 'Sem cargo']);
      expect(_names(sections[1]), ['Ana', 'Rui']);
      expect(_names(sections[2]), ['Carla', 'João']);
    });
  });

  group('sort by number', () {
    test('orders numerically in one headerless section, blanks last', () {
      final sections = buildPeopleSections([
        _p('A', number: '120'),
        _p('B'),
        _p('C', number: '9'),
        _p('D', number: 'X7'),
      ], sort: PeopleSort.number);

      expect(_titles(sections), [null]);
      expect(_names(sections.single), ['C', 'A', 'D', 'B']);
    });
  });

  group('sort by seniority', () {
    test('orders by earliest hire date, people without one last', () {
      final sections = buildPeopleSections([
        _p('New', hired: DateTime(2024, 3)),
        _p('Unknown'),
        _p('Old', hired: DateTime(2015, 6)),
      ], sort: PeopleSort.seniority);

      expect(_titles(sections), [null]);
      expect(_names(sections.single), ['Old', 'New', 'Unknown']);
    });
  });

  group('search', () {
    final people = [
      _p('João Pinto', role: 'Operador', number: '3101'),
      _p('Ana Martins', role: 'Chefe de Secção', number: '1234'),
    ];

    List<String> found(String q) => buildPeopleSections(
      people,
      sort: PeopleSort.name,
      query: q,
    ).expand(_names).toList();

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
      final sections = buildPeopleSections(
        people,
        sort: PeopleSort.name,
        query: 'ana',
      );
      expect(_titles(sections), ['A']);
    });

    test('blank query keeps everyone', () {
      expect(found('  '), ['Ana Martins', 'João Pinto']);
    });
  });
}
