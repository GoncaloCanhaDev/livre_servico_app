import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/teams.dart';

Person _p(
  String name, {
  String? team,
  String? chefe,
  String? turno,
  String uuid = '',
  bool deleted = false,
}) => Person()
  ..fullName = name
  ..createdAt = DateTime(2026)
  ..syncUuid = uuid
  ..team = team
  ..chefe = chefe
  ..turno = turno
  ..syncDeletedAt = deleted ? DateTime(2026) : null;

void main() {
  group('teams', () {
    test('are in the agreed order with Livre Serviço first', () {
      expect(teams.map((t) => t.name), [
        'Livre Serviço',
        'Gerência',
        'Charcutaria',
        'Meal Solutions',
        'Talho',
        'Peixaria',
        'Frente de Loja',
        'Bem Estar',
        'Padaria',
        'Fruta',
      ]);
    });

    test('Livre Serviço has day and night chefes, others one chefe', () {
      expect(teamById('livre_servico')!.chefeSlots, [
        ChefeSlot.dia,
        ChefeSlot.noite,
      ]);
      for (final t in teams.skip(1)) {
        expect(t.chefeSlots, [ChefeSlot.chefe], reason: t.name);
      }
    });

    test('teamById returns null for null or unknown ids', () {
      expect(teamById('talho')!.name, 'Talho');
      expect(teamById(null), isNull);
      expect(teamById('caixas'), isNull);
    });

    test('slot labels', () {
      expect(ChefeSlot.chefe.label, 'Chefe');
      expect(ChefeSlot.dia.label, 'Chefe de dia');
      expect(ChefeSlot.noite.label, 'Chefe de noite');
    });
  });

  group('chefeSlotOf', () {
    test('returns the slot when it belongs to the team', () {
      expect(
        chefeSlotOf(_p('A', team: 'talho', chefe: 'chefe')),
        ChefeSlot.chefe,
      );
      expect(
        chefeSlotOf(_p('B', team: 'livre_servico', chefe: 'noite')),
        ChefeSlot.noite,
      );
    });

    test('is null for members, wrong slots, unknown teams and no team', () {
      expect(chefeSlotOf(_p('A', team: 'talho')), isNull);
      expect(chefeSlotOf(_p('B', team: 'talho', chefe: 'dia')), isNull);
      expect(
        chefeSlotOf(_p('C', team: 'livre_servico', chefe: 'chefe')),
        isNull,
      );
      expect(chefeSlotOf(_p('D', team: 'caixas', chefe: 'chefe')), isNull);
      expect(chefeSlotOf(_p('E', chefe: 'chefe')), isNull);
    });
  });

  group('chefeHolder', () {
    final ana = _p('Ana', team: 'talho', chefe: 'chefe', uuid: 'a');
    final rui = _p('Rui', team: 'talho', uuid: 'r');

    test('finds the current holder', () {
      expect(
        chefeHolder([ana, rui], 'talho', ChefeSlot.chefe, except: rui),
        same(ana),
      );
    });

    test('ignores the person themself, by identity or by uuid', () {
      expect(chefeHolder([ana], 'talho', ChefeSlot.chefe, except: ana), isNull);
      final anaCopy = _p('Ana', team: 'talho', chefe: 'chefe', uuid: 'a');
      expect(
        chefeHolder([ana], 'talho', ChefeSlot.chefe, except: anaCopy),
        isNull,
      );
    });

    test('ignores deleted people and other slots/teams', () {
      final gone = _p('Zé', team: 'talho', chefe: 'chefe', deleted: true);
      final night = _p('Bia', team: 'livre_servico', chefe: 'noite');
      expect(
        chefeHolder([gone], 'talho', ChefeSlot.chefe, except: rui),
        isNull,
      );
      expect(
        chefeHolder([night], 'livre_servico', ChefeSlot.dia, except: rui),
        isNull,
      );
      expect(
        chefeHolder([ana], 'peixaria', ChefeSlot.chefe, except: rui),
        isNull,
      );
    });

    test('a new person (no uuid yet) is not mistaken for others', () {
      final newbie = _p('Novo', team: 'talho', chefe: 'chefe');
      final oldNoUuid = _p('Velho', team: 'talho', chefe: 'chefe');
      expect(
        chefeHolder([oldNoUuid], 'talho', ChefeSlot.chefe, except: newbie),
        same(oldNoUuid),
      );
    });
  });

  group('chefeConflicts', () {
    test('returns whoever else holds the same team and slot', () {
      final ana = _p('Ana', team: 'talho', chefe: 'chefe', uuid: 'a');
      final rui = _p('Rui', team: 'talho', chefe: 'chefe', uuid: 'r');
      expect(chefeConflicts(rui, [ana, rui]), [ana]);
    });

    test('is empty for members and for invalid slots', () {
      final ana = _p('Ana', team: 'talho', chefe: 'chefe', uuid: 'a');
      expect(chefeConflicts(_p('Rui', team: 'talho'), [ana]), isEmpty);
      expect(
        chefeConflicts(_p('Rui', team: 'talho', chefe: 'dia'), [ana]),
        isEmpty,
      );
    });

    test('day and night chefes of Livre Serviço do not conflict', () {
      final day = _p('Ana', team: 'livre_servico', chefe: 'dia', uuid: 'a');
      final night = _p('Rui', team: 'livre_servico', chefe: 'noite', uuid: 'r');
      expect(chefeConflicts(night, [day]), isEmpty);
    });

    test('skips the person themself and deleted people', () {
      final ana = _p('Ana', team: 'talho', chefe: 'chefe', uuid: 'a');
      final anaFromDb = _p('Ana', team: 'talho', chefe: 'chefe', uuid: 'a');
      final gone = _p(
        'Zé',
        team: 'talho',
        chefe: 'chefe',
        uuid: 'z',
        deleted: true,
      );
      expect(chefeConflicts(ana, [anaFromDb, gone]), isEmpty);
    });
  });

  group('turnos', () {
    test('only Livre Serviço is split by turno', () {
      expect(teamById('livre_servico')!.hasTurnos, isTrue);
      for (final t in teams.skip(1)) {
        expect(t.hasTurnos, isFalse, reason: t.name);
      }
    });

    test('turno labels and the chefe slot of each turno', () {
      expect(Turno.dia.label, 'Dia');
      expect(Turno.noite.label, 'Noite');
      expect(chefeSlotForTurno(Turno.dia), ChefeSlot.dia);
      expect(chefeSlotForTurno(Turno.noite), ChefeSlot.noite);
    });

    test('turnoOf reads a Livre Serviço member\'s turno', () {
      expect(
        turnoOf(_p('A', team: 'livre_servico', turno: 'noite')),
        Turno.noite,
      );
      expect(turnoOf(_p('B', team: 'livre_servico', turno: 'dia')), Turno.dia);
    });

    test('a Livre Serviço chefe is on their slot\'s turno', () {
      expect(turnoOf(_p('A', team: 'livre_servico', chefe: 'dia')), Turno.dia);
      expect(
        turnoOf(_p('B', team: 'livre_servico', chefe: 'noite', turno: 'dia')),
        Turno.noite,
      );
    });

    test('is null without a valid turno or outside Livre Serviço', () {
      expect(turnoOf(_p('A', team: 'livre_servico')), isNull);
      expect(turnoOf(_p('B', team: 'livre_servico', turno: 'tarde')), isNull);
      expect(turnoOf(_p('C', team: 'talho', turno: 'noite')), isNull);
      expect(turnoOf(_p('D', turno: 'dia')), isNull);
    });
  });
}
