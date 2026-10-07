import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/people_sections.dart';

Person _p(
  String name, {
  String? team,
  String? chefe,
  String? turno,
  String number = '',
  bool permanencia = false,
  bool partTime = false,
  bool supervisor = false,
  bool segundaLinha = false,
}) => Person()
  ..fullName = name
  ..createdAt = DateTime(2026)
  ..team = team
  ..chefe = chefe
  ..turno = turno
  ..collaboratorNumber = number
  ..permanencia = permanencia
  ..partTime = partTime
  ..supervisor = supervisor
  ..segundaLinha = segundaLinha;

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
        _p('Ana', team: 'livre_servico', turno: 'dia'),
        _p('Bia', team: 'gerencia'),
        _p('Velho', team: 'caixas'),
      ]);
      expect(_titles(sections), [
        'Livre Serviço · Dia',
        'Gerência',
        'Talho',
        'Sem equipa',
      ]);
      expect(_names(sections.last), ['João', 'Velho']);
    });

    test('chefe first, then members A–Z ignoring case and accents', () {
      final sections = buildPeopleSections([
        _p('Bruno', team: 'padaria'),
        _p('Chefe', team: 'padaria', chefe: 'chefe'),
        _p('álvaro', team: 'padaria'),
      ]);
      expect(_names(sections.single), ['Chefe', 'álvaro', 'Bruno']);
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

  group('Frente de Loja supervisors', () {
    final people = [
      _p('Zé', team: 'frente_de_loja'),
      _p('Rita', team: 'frente_de_loja', supervisor: true),
      _p('Chefe', team: 'frente_de_loja', chefe: 'chefe'),
      _p('Ana', team: 'frente_de_loja'),
      _p('Bruno', team: 'frente_de_loja', supervisor: true),
    ];

    test('supervisors A–Z, then members A–Z (no chefe here)', () {
      expect(_names(buildPeopleSections(people).single), [
        'Bruno',
        'Rita',
        'Ana',
        'Chefe',
        'Zé',
      ]);
    });

    test('search matches supervisor', () {
      expect(
        buildPeopleSections(
          people,
          query: 'supervisor',
        ).expand(_names).toList(),
        ['Bruno', 'Rita'],
      );
    });
  });

  group('Segunda Linha', () {
    final people = [
      _p('Zé', team: 'talho'),
      _p('Rui', team: 'talho', segundaLinha: true),
      _p('Chefe', team: 'talho', chefe: 'chefe'),
      _p('Ana', team: 'talho'),
      _p('Bia', team: 'talho', segundaLinha: true),
    ];

    test('chefe, then Segunda Linha A–Z, then members A–Z', () {
      expect(_names(buildPeopleSections(people).single), [
        'Chefe',
        'Bia',
        'Rui',
        'Ana',
        'Zé',
      ]);
    });

    test('search matches segunda linha', () {
      expect(
        buildPeopleSections(
          people,
          query: 'segunda linha',
        ).expand(_names).toList(),
        ['Bia', 'Rui'],
      );
    });
  });

  group('count line', () {
    final people = [
      _p('Ana', team: 'talho'),
      _p('Rui', team: 'talho', partTime: true),
      _p('Bia', team: 'gerencia'),
    ];

    test('totals everyone with the horário split', () {
      expect(
        peopleCountText(people),
        '3 pessoas · 2 tempo inteiro · 1 tempo parcial',
      );
    });

    test('while searching shows matches out of the total', () {
      expect(peopleCountText(people, query: 'talho'), '2 de 3 pessoas');
      expect(peopleCountText(people, query: 'bia'), '1 de 3 pessoas');
    });

    test('uses the singular for one person', () {
      expect(
        peopleCountText([_p('Ana')]),
        '1 pessoa · 1 tempo inteiro · 0 tempo parcial',
      );
    });
  });

  group('Livre Serviço turnos', () {
    final people = [
      _p('Rui', team: 'livre_servico', turno: 'noite'),
      _p('Zé', team: 'talho'),
      _p('Sem', team: 'livre_servico'),
      _p('Bia', team: 'livre_servico', turno: 'dia'),
      _p('Chefe N', team: 'livre_servico', chefe: 'noite'),
      _p('Ana', team: 'livre_servico', turno: 'noite'),
      _p('Chefe D', team: 'livre_servico', chefe: 'dia', turno: 'noite'),
    ];

    test('only the Livre Serviço sections start open', () {
      final sections = buildPeopleSections([...people, _p('Nobody')]);
      expect(
        {for (final s in sections) s.title: s.openByDefault},
        {
          'Livre Serviço · Dia': true,
          'Livre Serviço · Noite': true,
          'Livre Serviço · Sem turno': true,
          'Talho': false,
          'Sem equipa': false,
        },
      );
    });

    test('split into Dia, Noite and Sem turno before the next team', () {
      final sections = buildPeopleSections(people);
      expect(_titles(sections), [
        'Livre Serviço · Dia',
        'Livre Serviço · Noite',
        'Livre Serviço · Sem turno',
        'Talho',
      ]);
    });

    test('each turno lists its chefe first, then members A–Z', () {
      final sections = buildPeopleSections(people);
      expect(_names(sections[0]), ['Chefe D', 'Bia']);
      expect(_names(sections[1]), ['Chefe N', 'Ana', 'Rui']);
      expect(_names(sections[2]), ['Sem']);
    });

    test('search matches the turno', () {
      expect(
        buildPeopleSections(people, query: 'noite').expand(_names).toList(),
        ['Chefe N', 'Ana', 'Rui'],
      );
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

    test('matches the Permanência tag, with or without the accent', () {
      final tagged = [
        ...people,
        _p('Paula Reis', team: 'talho', permanencia: true),
      ];
      List<String> find(String q) =>
          buildPeopleSections(tagged, query: q).expand(_names).toList();
      expect(find('permanencia'), ['Paula Reis']);
      expect(find('Permanência'), ['Paula Reis']);
    });

    test('a new person is full time', () {
      expect(Person().partTime, isFalse);
    });

    test('"parcial" finds part-time people', () {
      final mixed = [
        ...people,
        _p('Paulo Dias', team: 'talho', partTime: true),
      ];
      expect(
        buildPeopleSections(mixed, query: 'parcial').expand(_names).toList(),
        ['Paulo Dias'],
      );
    });

    test('blank query keeps everyone', () {
      expect(found('  '), ['Ana Martins', 'João Pinto', 'Rita Sousa']);
    });
  });
}
