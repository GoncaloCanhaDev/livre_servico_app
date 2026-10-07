import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/people_sections.dart';

Person _p(String name, {String? team, String? chefe, String number = ''}) =>
    Person()
      ..fullName = name
      ..createdAt = DateTime(2026)
      ..team = team
      ..chefe = chefe
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
    test('follows the fixed team order, Sem equipa last, empty hidden', () {
      final sections = buildPeopleSections([
        _p('Rui', team: 'talho'),
        _p('João'),
        _p('Ana', team: 'livre_servico'),
        _p('Bia', team: 'gerencia'),
        _p('Velho', team: 'caixas'),
      ]);
      expect(_titles(sections), [
        'Livre Serviço',
        'Gerência',
        'Talho',
        'Sem equipa',
      ]);
      expect(_names(sections.last), ['João', 'Velho']);
    });

    test('chefes first in slot order, then members A–Z', () {
      final sections = buildPeopleSections([
        _p('Bruno', team: 'livre_servico'),
        _p('Noite', team: 'livre_servico', chefe: 'noite'),
        _p('álvaro', team: 'livre_servico'),
        _p('Dia', team: 'livre_servico', chefe: 'dia'),
      ]);
      expect(_names(sections.single), ['Dia', 'Noite', 'álvaro', 'Bruno']);
    });

    test('a slot that does not fit the team counts as a member', () {
      final sections = buildPeopleSections([
        _p('Zé', team: 'talho'),
        _p('Ana', team: 'talho', chefe: 'dia'),
        _p('Chefe', team: 'talho', chefe: 'chefe'),
      ]);
      expect(_names(sections.single), ['Chefe', 'Ana', 'Zé']);
    });
  });

  group('search', () {
    final people = [
      _p('João Pinto', team: 'talho', number: '3101'),
      _p('Ana Martins', team: 'gerencia', number: '1234'),
      _p('Rita Sousa', team: 'frente_de_loja'),
    ];

    List<String> found(String q) =>
        buildPeopleSections(people, query: q).expand(_names).toList();

    test('matches name ignoring case and accents', () {
      expect(found('joao'), ['João Pinto']);
    });

    test('matches team name ignoring accents', () {
      expect(found('gerencia'), ['Ana Martins']);
      expect(found('frente'), ['Rita Sousa']);
    });

    test('matches nº de colaborador', () {
      expect(found('310'), ['João Pinto']);
    });

    test('drops sections left empty', () {
      expect(_titles(buildPeopleSections(people, query: 'ana')), ['Gerência']);
    });

    test('blank query keeps everyone', () {
      expect(found('  '), ['Ana Martins', 'João Pinto', 'Rita Sousa']);
    });
  });
}
