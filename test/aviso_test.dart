import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/aviso.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/store_access.dart';
import 'package:livre_servico_app/models/teams.dart';

final _now = DateTime(2026, 10, 31, 12);

Aviso _aviso(
  String uuid,
  List<String> to, {
  int daysAgo = 0,
  String from = 'chefe',
  bool deleted = false,
}) => Aviso()
  ..syncUuid = uuid
  ..text = 'Aviso $uuid'
  ..sentAt = _now.subtract(Duration(days: daysAgo, minutes: 1))
  ..fromPersonId = from
  ..fromName = 'Rui'
  ..toPersonIds = to
  ..syncDeletedAt = deleted ? _now : null;

AvisoVisto _visto(String aviso, String person) => AvisoVisto()
  ..avisoId = aviso
  ..personId = person
  ..seenAt = _now;

Person _p(String uuid, String? team, {bool deleted = false}) => Person()
  ..fullName = uuid
  ..createdAt = DateTime(2026)
  ..syncUuid = uuid
  ..team = team
  ..syncDeletedAt = deleted ? _now : null;

List<String> _ids(List<Aviso> a) => a.map((x) => x.syncUuid).toList();

void main() {
  test('Home shows unseen avisos for me, under 7 days, newest first', () {
    final avisos = [
      _aviso('old', ['ana'], daysAgo: 7),
      _aviso('a', ['ana'], daysAgo: 2),
      _aviso('b', ['ana', 'rui'], daysAgo: 1),
      _aviso('other', ['rui']),
    ];
    expect(_ids(avisosOnHome(avisos, const [], 'ana', _now)), ['b', 'a']);
  });

  test('a Visto hides it from Home only for that person', () {
    final avisos = [
      _aviso('a', ['ana', 'rui']),
    ];
    final vistos = [_visto('a', 'ana')];
    expect(avisosOnHome(avisos, vistos, 'ana', _now), isEmpty);
    expect(_ids(avisosOnHome(avisos, vistos, 'rui', _now)), ['a']);
  });

  test('deleted avisos show nowhere', () {
    final avisos = [
      _aviso('a', ['ana'], deleted: true),
    ];
    expect(avisosOnHome(avisos, const [], 'ana', _now), isEmpty);
    expect(avisosReceived(avisos, 'ana', _now), isEmpty);
    expect(avisosSent(avisos, 'chefe', _now), isEmpty);
  });

  test('the screen keeps 30 days', () {
    final avisos = [
      _aviso('a', ['ana'], daysAgo: 29),
      _aviso('b', ['ana'], daysAgo: 30),
      _aviso('c', ['ana'], daysAgo: 3),
    ];
    expect(_ids(avisosReceived(avisos, 'ana', _now)), ['c', 'a']);
    expect(_ids(avisosSent(avisos, 'chefe', _now)), ['c', 'a']);
    expect(avisosSent(avisos, 'ana', _now), isEmpty);
  });

  test('recipients: a team resolved to people the sender reaches, '
      'never the sender', () {
    const chefe = StoreAccess(
      admin: false,
      level: 3,
      team: 'talho',
      personId: 'me',
    );
    final people = [
      _p('me', 'talho'),
      _p('t1', 'talho'),
      _p('t2', 'talho'),
      _p('gone', 'talho', deleted: true),
      _p('px', 'peixaria'),
      _p('', 'talho'),
    ];
    expect(recipientsFor(chefe, people, teamIds: {'talho'}), ['t1', 't2']);
    expect(
      recipientsFor(chefe, people, teamIds: {'talho'}, personIds: {'px', 't1'}),
      ['t1', 't2'],
    );
    expect(recipientsFor(chefe, people, personIds: {'t2', 'me'}), ['t2']);
  });

  test('seenBy lists only recipients', () {
    final a = _aviso('a', ['ana', 'rui']);
    final seen = seenBy(a, [
      _visto('a', 'ana'),
      _visto('a', 'zé'),
      _visto('b', 'rui'),
    ]);
    expect(seen.keys, ['ana']);
  });

  test('when: today, yesterday, or the date', () {
    expect(avisoWhen(DateTime(2026, 10, 31, 9, 5), _now), 'hoje 09:05');
    expect(avisoWhen(DateTime(2026, 10, 30, 18, 30), _now), 'ontem 18:30');
    expect(avisoWhen(DateTime(2026, 10, 2, 7, 0), _now), '2/10 07:00');
  });

  test('JSON round trip', () {
    final a = Aviso.fromJson(_aviso('a', ['ana', 'rui']).toJson());
    expect(
      (a.syncUuid, a.text, a.fromPersonId, a.fromName),
      ('a', 'Aviso a', 'chefe', 'Rui'),
    );
    expect(a.toPersonIds, ['ana', 'rui']);
    expect(a.sentAt, _now.subtract(const Duration(minutes: 1)));
    final v = AvisoVisto.fromJson(_visto('a', 'ana').toJson());
    expect((v.avisoId, v.personId, v.seenAt), ('a', 'ana', _now));
  });

  test('limits', () {
    expect((avisoHomeDays, avisoKeepDays, avisoMaxLength), (7, 30, 500));
    expect(Role.segundaLinha.level, 2);
  });
}
