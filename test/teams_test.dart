import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/teams.dart';

Person _p(
  String name, {
  String? team,
  String? role,
  String? chefe,
  String? turno,
  bool supervisor = false,
  bool segundaLinha = false,
  String uuid = '',
  bool deleted = false,
}) => Person()
  ..fullName = name
  ..createdAt = DateTime(2026)
  ..syncUuid = uuid
  ..team = team
  ..role = role
  ..chefe = chefe
  ..turno = turno
  ..supervisor = supervisor
  ..segundaLinha = segundaLinha
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

    test('Livre Serviço has day and night chefes', () {
      expect(teamById('livre_servico')!.chefeSlots, [
        ChefeSlot.dia,
        ChefeSlot.noite,
      ]);
    });

    test('Frente de Loja and Bem Estar have no chefe, others one', () {
      const none = {'frente_de_loja', 'bem_estar'};
      for (final t in teams.skip(1)) {
        expect(
          t.chefeSlots,
          none.contains(t.id) ? isEmpty : [ChefeSlot.chefe],
          reason: t.name,
        );
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

  group('roles', () {
    test('role by name, level from the role', () {
      expect(
        roleOf(_p('A', team: 'talho', role: 'chefeSeccao')),
        Role.chefeSeccao,
      );
      expect(levelOf(_p('B', team: 'gerencia', role: 'gerente')), 5);
      expect(Role.secretaria.label, 'Secretária de Loja');
      expect(Role.values.map((r) => r.level), [1, 2, 2, 3, 4, 4, 5]);
    });

    test('a role not allowed in the team reads as Operador', () {
      expect(roleOf(_p('A', team: 'talho', role: 'gestorArea')), Role.operador);
      expect(roleOf(_p('B', role: 'chefeSeccao')), Role.operador);
      expect(
        roleOf(_p('C', team: 'caixas', role: 'chefeSeccao')),
        Role.operador,
      );
      expect(roleOf(_p('D', team: 'talho', role: 'rei')), Role.operador);
    });

    test('old rows: the role comes from chefe, Gerência and tags', () {
      expect(roleOf(_p('A', team: 'gerencia', chefe: 'chefe')), Role.gerente);
      expect(roleOf(_p('B', team: 'gerencia')), Role.gestorArea);
      expect(
        roleOf(_p('C', team: 'livre_servico', chefe: 'noite')),
        Role.chefeSeccao,
      );
      expect(roleOf(_p('D', team: 'talho', chefe: 'chefe')), Role.chefeSeccao);
      expect(
        roleOf(_p('E', team: 'frente_de_loja', supervisor: true)),
        Role.supervisor,
      );
      expect(
        roleOf(_p('F', team: 'talho', segundaLinha: true)),
        Role.segundaLinha,
      );
      expect(
        roleOf(_p('G', team: 'frente_de_loja', chefe: 'chefe')),
        Role.operador,
      );
      expect(roleOf(_p('H', team: 'talho', supervisor: true)), Role.operador);
      expect(
        roleOf(_p('I', team: 'livre_servico', chefe: 'chefe')),
        Role.operador,
      );
      expect(roleOf(_p('J', chefe: 'chefe')), Role.operador);
    });

    test('a role set wins over the old fields', () {
      expect(
        roleOf(_p('A', team: 'talho', segundaLinha: true, role: 'operador')),
        Role.operador,
      );
      expect(
        roleOf(_p('B', team: 'gerencia', chefe: 'chefe', role: 'secretaria')),
        Role.secretaria,
      );
    });

    test('every team allows levels 1 to 3; only Gerência 4 and 5', () {
      const lower = [
        Role.operador,
        Role.segundaLinha,
        Role.supervisor,
        Role.chefeSeccao,
      ];
      for (final t in teams) {
        expect(
          rolesIn(t.id),
          t.id == gerenciaId ? Role.values : lower,
          reason: t.name,
        );
      }
      expect(rolesIn(null), [Role.operador]);
      expect(rolesIn('caixas'), [Role.operador]);
    });

    test('only Chefe de Secção and Gerente have a single holder', () {
      expect(Role.values.where(isSingleHolder), [
        Role.chefeSeccao,
        Role.gerente,
      ]);
    });
  });

  group('roleConflicts', () {
    test('one Chefe de Secção per team', () {
      final ana = _p('Ana', team: 'talho', role: 'chefeSeccao', uuid: 'a');
      final rui = _p('Rui', team: 'talho', role: 'chefeSeccao', uuid: 'r');
      final pei = _p('Pê', team: 'peixaria', role: 'chefeSeccao', uuid: 'p');
      expect(roleConflicts(rui, [ana, rui, pei]), [ana]);
      expect(roleHolder([ana, rui, pei], rui), same(ana));
    });

    test('one Chefe de Secção per turno in Livre Serviço', () {
      final day = _p(
        'Ana',
        team: 'livre_servico',
        role: 'chefeSeccao',
        turno: 'dia',
        uuid: 'a',
      );
      final night = _p(
        'Rui',
        team: 'livre_servico',
        role: 'chefeSeccao',
        turno: 'noite',
        uuid: 'r',
      );
      final day2 = _p(
        'Bia',
        team: 'livre_servico',
        role: 'chefeSeccao',
        turno: 'dia',
        uuid: 'b',
      );
      expect(roleConflicts(day2, [day, night]), [day]);
      expect(roleConflicts(night, [day]), isEmpty);
    });

    test('an old Livre Serviço chefe conflicts by their slot\'s turno', () {
      final old = _p('Ana', team: 'livre_servico', chefe: 'dia', uuid: 'a');
      final nova = _p(
        'Bia',
        team: 'livre_servico',
        role: 'chefeSeccao',
        turno: 'dia',
        uuid: 'b',
      );
      expect(roleConflicts(nova, [old]), [old]);
    });

    test('one Gerente de Loja', () {
      final g1 = _p('Ana', team: 'gerencia', role: 'gerente', uuid: 'a');
      final g2 = _p('Rui', team: 'gerencia', role: 'gerente', uuid: 'r');
      expect(roleConflicts(g2, [g1]), [g1]);
    });

    test('other roles have no limit', () {
      final a = _p('Ana', team: 'talho', role: 'supervisor', uuid: 'a');
      final b = _p('Rui', team: 'talho', role: 'supervisor', uuid: 'r');
      expect(roleConflicts(b, [a]), isEmpty);
      expect(roleHolder([a], b), isNull);
    });

    test('skips the person themself, by uuid, and deleted people', () {
      final ana = _p('Ana', team: 'talho', role: 'chefeSeccao', uuid: 'a');
      final anaFromDb = _p(
        'Ana',
        team: 'talho',
        role: 'chefeSeccao',
        uuid: 'a',
      );
      final gone = _p(
        'Zé',
        team: 'talho',
        role: 'chefeSeccao',
        uuid: 'z',
        deleted: true,
      );
      expect(roleConflicts(ana, [anaFromDb, gone]), isEmpty);
    });

    test('a new person (no uuid yet) is not mistaken for others', () {
      final newbie = _p('Novo', team: 'talho', role: 'chefeSeccao');
      final old = _p('Velho', team: 'talho', chefe: 'chefe');
      expect(roleConflicts(newbie, [old]), [old]);
    });
  });

  group('roleLineOf', () {
    test('role and team, with the turno in Livre Serviço', () {
      expect(
        roleLineOf(_p('A', team: 'talho', role: 'chefeSeccao')),
        'Chefe de Secção · Talho',
      );
      expect(
        roleLineOf(_p('B', team: 'livre_servico', turno: 'noite')),
        'Operador · Livre Serviço · Noite',
      );
      expect(roleLineOf(_p('C')), 'Operador · Sem equipa');
    });
  });

  group('roleTagsOf', () {
    test('the role from level 2, then Permanência', () {
      expect(roleTagsOf(_p('A', team: 'talho')), isEmpty);
      final p = _p('B', team: 'talho', role: 'chefeSeccao')..permanencia = true;
      expect(roleTagsOf(p), ['Chefe de Secção', 'Permanência']);
      expect(roleTagsOf(_p('C', team: 'frente_de_loja', supervisor: true)), [
        'Supervisor',
      ]);
      expect(roleTagsOf(_p('D', team: 'talho')..permanencia = true), [
        'Permanência',
      ]);
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

    test('an old Livre Serviço chefe is on their slot\'s turno', () {
      expect(turnoOf(_p('A', team: 'livre_servico', chefe: 'dia')), Turno.dia);
      expect(
        turnoOf(_p('B', team: 'livre_servico', chefe: 'noite', turno: 'dia')),
        Turno.noite,
      );
    });

    test('a Chefe de Secção of Livre Serviço has their own turno', () {
      expect(
        turnoOf(
          _p('A', team: 'livre_servico', role: 'chefeSeccao', turno: 'noite'),
        ),
        Turno.noite,
      );
      expect(
        turnoOf(
          _p(
            'B',
            team: 'livre_servico',
            role: 'chefeSeccao',
            chefe: 'dia',
            turno: 'noite',
          ),
        ),
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
