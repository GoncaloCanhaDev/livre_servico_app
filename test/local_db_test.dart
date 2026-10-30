import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/custom_task.dart';
import 'package:livre_servico_app/models/daily_tasks.dart';
import 'package:livre_servico_app/models/horario_mes.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/models/truck_reception.dart';
import 'package:livre_servico_app/services/local_db.dart';
import 'package:livre_servico_app/services/sync_meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Microseconds since the epoch, the way Isar's exportJson wrote dates.
int micros(DateTime d) => d.toUtc().microsecondsSinceEpoch;

Person ana() => Person()
  ..fullName = 'Ana Silva'
  ..collaboratorNumber = '123'
  ..createdAt = DateTime(2026, 1, 1)
  ..folgas = [1, 3]
  ..ausencias = [
    Ausencia()
      ..tipo = AusenciaTipo.baixa
      ..start = DateTime(2026, 10, 1)
      ..end = DateTime(2026, 10, 14),
  ]
  ..genero = Genero.feminino;

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalDb.init(executor: NativeDatabase.memory());
  });
  tearDown(() => LocalDb.instance.close());

  group('JSON in the old Isar backup format', () {
    test('reads a person: dates in microseconds, enums by name, embedded', () {
      final p = Person.fromJson({
        'id': 7,
        'syncUuid': 'u-1',
        'syncUpdatedAt': micros(DateTime(2026, 9, 1, 10)),
        'syncDeletedAt': null,
        'synced': true,
        'fullName': 'Ana Silva',
        'collaboratorNumber': '123',
        'createdAt': micros(DateTime(2026, 1, 1)),
        'dateOfBirth': micros(DateTime(1990, 5, 20)),
        'hireDate': null,
        'team': 'livre_servico',
        'chefe': null,
        'permanencia': true,
        'folgas': [1, 3],
        'shiftStart': 420,
        'ausencias': [
          {
            'tipo': 'ferias',
            'start': micros(DateTime(2026, 8, 1)),
            'end': micros(DateTime(2026, 8, 15)),
          },
        ],
        'notes': ['Chaves'],
        'genero': 'feminino',
        // A field removed since: ignored.
        'role': 'x',
      });
      expect(p.id, 7);
      expect(p.syncUuid, 'u-1');
      expect(p.syncUpdatedAt, DateTime(2026, 9, 1, 10));
      expect(p.dateOfBirth, DateTime(1990, 5, 20));
      expect(p.hireDate, isNull);
      expect(p.permanencia, isTrue);
      expect(p.partTime, isFalse);
      expect(p.folgas, [1, 3]);
      expect(p.shiftStart, 420);
      expect(p.shiftEnd, isNull);
      expect(p.ausencias.single.tipo, AusenciaTipo.ferias);
      expect(p.ausencias.single.end, DateTime(2026, 8, 15));
      expect(p.notes, ['Chaves']);
      expect(p.genero, Genero.feminino);
    });

    test('reads enums stored by index and by name', () {
      final t = TruckReception.fromJson({
        'arrivalTime': micros(DateTime(2026, 10, 30, 7)),
        'type': 'naoPereciveis',
        'pallets': [
          {'category': 3, 'department': null, 'total': 4, 'mistas': 1},
          {'category': 0, 'department': 'talho', 'total': 2, 'mistas': 0},
        ],
        'sentVasilhame': [
          {'productName': 'Caixa verde', 'amount': 10},
        ],
        'expositores': null,
      });
      expect(t.type, TruckType.naoPereciveis);
      expect(t.pallets.first.label, 'Bebidas');
      expect(t.pallets.last.label, 'Talho');
      expect(t.totalPallets, 6);
      expect(t.sentVasilhame.single.amount, 10);
      expect(t.expositores, isEmpty);

      final task = CustomTask.fromJson({
        'title': 'Rever montra',
        'frequency': 1,
        'inputType': 1,
        'createdAt': micros(DateTime(2026, 2, 1)),
      });
      expect(task.frequency, CustomTaskFrequency.weekly);
      expect(task.inputType, CustomTaskInputType.count);
    });

    test('the one-off period key reads back as the same date', () {
      final e = CustomTaskEntry()
        ..taskUuid = 't'
        ..periodKey = oneOffPeriodKey;
      final back = CustomTaskEntry.fromJson(e.toJson());
      expect(back.periodKey, oneOffPeriodKey);
    });

    test('a written row reads back the same', () {
      final p = ana()..id = 3;
      SyncMeta.stamp(p);
      final json = jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>;
      expect(Person.fromJson(json).toJson(), p.toJson());
    });
  });

  group('LocalDb', () {
    test('put gives ids and reads return copies', () async {
      final db = LocalDb.instance;
      final first = ana();
      final id = await db.persons.put(first);
      expect(id, 1);
      expect(first.id, 1);
      expect(await db.persons.put(ana()), 2);

      final read = (await db.persons.get(1))!;
      read.fullName = 'Changed';
      read.folgas.add(5);
      final again = (await db.persons.get(1))!;
      expect(again.fullName, 'Ana Silva');
      expect(again.folgas, [1, 3]);
      // Nor does changing the saved object afterwards.
      first.folgas.add(6);
      expect((await db.persons.get(1))!.folgas, [1, 3]);
    });

    test('soft-deleted rows only show with includeDeleted', () async {
      final db = LocalDb.instance;
      await db.persons.put(ana());
      final id = await db.persons.put(ana());
      expect(await db.persons.softDelete(id), isTrue);
      expect(await db.persons.softDelete(id), isFalse);
      expect(await db.persons.all(), hasLength(1));
      expect(await db.persons.all(includeDeleted: true), hasLength(2));
      expect((await db.persons.get(id))!.syncDeletedAt, isNotNull);
    });

    test('firstWhere returns the oldest match', () async {
      final db = LocalDb.instance;
      final day = DateTime(2026, 10, 30, 5);
      await db.dailyTasks.put(DailyTasks()..serviceDay = day);
      await db.dailyTasks.put(DailyTasks()..serviceDay = day);
      final found = await db.dailyTasks.firstWhere(
        (t) => t.serviceDay.isAtSameMomentAs(day.toUtc()),
      );
      expect(found!.id, 1);
    });

    test('a failed transaction leaves nothing behind', () async {
      final db = LocalDb.instance;
      await expectLater(
        db.transaction(() async {
          await db.persons.put(ana());
          throw StateError('boom');
        }),
        throwsStateError,
      );
      expect(await db.persons.all(includeDeleted: true), isEmpty);
      expect(await db.persons.put(ana()), 1);
    });

    test('deleteWhere and clear remove rows for good', () async {
      final db = LocalDb.instance;
      await db.horarioMeses.put(HorarioMes()..mes = '2026-10');
      await db.horarioMeses.put(HorarioMes()..mes = '2026-11');
      await db.horarioMeses.deleteWhere((m) => m.mes == '2026-10');
      expect(
        (await db.horarioMeses.all(includeDeleted: true)).map((m) => m.mes),
        ['2026-11'],
      );
      await db.horarioMeses.clear();
      expect(await db.horarioMeses.all(includeDeleted: true), isEmpty);
    });

    test('importJson replaces the rows and keeps their ids', () async {
      final db = LocalDb.instance;
      await db.persons.put(ana());
      final row = (ana()..id = 42).toJson();
      await db.persons.importJson([row]);
      final all = await db.persons.all();
      expect(all.single.id, 42);
      expect(db.persons.exportJson().single['id'], 42);
      expect(await db.persons.put(ana()), 43);
    });

    test('rows survive closing and opening the database', () async {
      final dir = await Directory.systemTemp.createTemp('local_db_test');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/db.sqlite');

      await LocalDb.instance.close();
      await LocalDb.init(executor: NativeDatabase(file));
      await LocalDb.instance.persons.put(ana());
      await LocalDb.instance.close();

      await LocalDb.init(executor: NativeDatabase(file));
      final p = (await LocalDb.instance.persons.all()).single;
      expect(p.fullName, 'Ana Silva');
      expect(p.ausencias.single.tipo, AusenciaTipo.baixa);
      expect(await LocalDb.instance.persons.put(ana()), 2);
    });

    test('startup gives older rows a uuid', () async {
      final db = LocalDb.instance;
      await db.persons.put(ana());
      await db.backfillSync();
      expect((await db.persons.get(1))!.syncUuid, isNotEmpty);
    });
  });
}
