import '../models/aviso.dart';
import '../models/custom_task.dart';
import '../models/daily_tasks.dart';
import '../models/info_contacts.dart';
import '../models/info_entry.dart';
import '../models/inventory.dart';
import '../models/local_row.dart';
import '../models/opening_list.dart';
import '../models/pedido.dart';
import '../models/person.dart';
import '../models/store_access.dart';
import '../models/teams.dart';
import '../models/truck_reception.dart';
import '../models/weekly_tasks.dart';
import 'account_service.dart';
import 'local_db.dart';
import 'sync_meta.dart';

/// Writes the demo's example store (all invented) into `LocalDb.instance`,
/// with dates around [now]'s service day so it always looks like today,
/// and signs the demo in as its Livre Serviço Chefe de Secção (day), with
/// no online database. Returns that person's `syncUuid`.
Future<String> seedDemo({DateTime? now}) async {
  final n = now ?? DateTime.now();
  final today = currentServiceDay(n);
  final db = LocalDb.instance;
  DateTime day(int offset, [int hour = 5, int minute = 0]) =>
      DateTime(today.year, today.month, today.day + offset, hour, minute);
  T stamped<T extends SyncedRow>(T row) {
    SyncMeta.stamp(row);
    return row;
  }

  int minutes(int h, [int m = 0]) => h * 60 + m;

  Person person(
    String name,
    String? team,
    Role role, {
    Genero genero = Genero.masculino,
    String? turno,
    List<int> folgas = const [6, 7],
    int start = 6,
    int end = 14,
    int hours = 40,
    bool partTime = false,
    bool permanencia = false,
    DateTime? hired,
    (int, int)? birthday,
    Ausencia? away,
    String number = '',
  }) => stamped(
    Person()
      ..fullName = name
      ..collaboratorNumber = number
      ..createdAt = day(-200)
      ..team = team
      ..role = role.name
      ..turno = turno
      ..genero = genero
      ..folgas = [...folgas]
      ..shiftStart = minutes(start)
      ..shiftEnd = minutes(end)
      ..weeklyHours = hours
      ..partTime = partTime
      ..permanencia = permanencia
      ..hireDate = hired ?? day(-900)
      ..storeStartDate = hired ?? day(-700)
      ..birthDay = birthday?.$2
      ..birthMonth = birthday?.$1
      ..ausencias = [?away],
  );

  Ausencia ausencia(AusenciaTipo tipo, int from, int to) => Ausencia()
    ..tipo = tipo
    ..start = day(from, 0)
    ..end = day(to, 0);

  const f = Genero.feminino;
  final me = person(
    'Sofia Almeida',
    livreServicoId,
    Role.chefeSeccao,
    genero: f,
    turno: 'dia',
    number: '10234',
    permanencia: true,
    folgas: [7],
    hours: 40,
  );
  final people = [
    me,
    person(
      'Ricardo Matos',
      livreServicoId,
      Role.chefeSeccao,
      turno: 'noite',
      start: 22,
      end: 6,
      folgas: [1, 2],
    ),
    person(
      'Inês Rodrigues',
      livreServicoId,
      Role.segundaLinha,
      genero: f,
      turno: 'dia',
      birthday: (today.month, today.day),
      folgas: [3, 7],
    ),
    person('João Pereira', livreServicoId, Role.operador, turno: 'dia'),
    person(
      'Beatriz Costa',
      livreServicoId,
      Role.operador,
      genero: f,
      turno: 'dia',
      start: 7,
      end: 11,
      hours: 20,
      partTime: true,
      hired: day(-14),
    ),
    person(
      'Tiago Fernandes',
      livreServicoId,
      Role.operador,
      turno: 'dia',
      away: ausencia(AusenciaTipo.ferias, -2, 5),
    ),
    person(
      'Diogo Santos',
      livreServicoId,
      Role.operador,
      turno: 'noite',
      start: 22,
      end: 6,
      folgas: [4, 5],
    ),
    person(
      'Carla Mendes',
      livreServicoId,
      Role.operador,
      genero: f,
      turno: 'noite',
      start: 22,
      end: 6,
      hired: day(-90),
      folgas: [1, 7],
    ),
    person(
      'Helena Marques',
      gerenciaId,
      Role.gerente,
      genero: f,
      start: 9,
      end: 18,
      permanencia: true,
    ),
    person('Paulo Ribeiro', gerenciaId, Role.gestorArea, start: 8, end: 17),
    person(
      'Ana Lopes',
      gerenciaId,
      Role.secretaria,
      genero: f,
      start: 9,
      end: 17,
    ),
    person('Nuno Carvalho', 'talho', Role.chefeSeccao, start: 7, end: 16),
    person('Rui Gomes', 'talho', Role.operador, start: 7, end: 15),
    person(
      'Marta Pinto',
      'peixaria',
      Role.chefeSeccao,
      genero: f,
      start: 7,
      end: 16,
      away: ausencia(AusenciaTipo.baixa, -4, 10),
    ),
    person('Hugo Teixeira', 'peixaria', Role.segundaLinha, start: 8, end: 16),
    person('Luís Moreira', 'padaria', Role.chefeSeccao, start: 4, end: 12),
    person(
      'Patrícia Sousa',
      'frente_de_loja',
      Role.supervisor,
      genero: f,
      start: 8,
      end: 17,
    ),
    person(
      'Joana Silva',
      'frente_de_loja',
      Role.operador,
      genero: f,
      start: 14,
      end: 22,
      partTime: true,
      hours: 30,
    ),
  ];
  String uuid(String name) =>
      people.firstWhere((p) => p.fullName == name).syncUuid;
  List<String> team(String teamId, {String? turno}) => [
    for (final p in people)
      if (p.team == teamId &&
          (turno == null || p.turno == turno) &&
          p.syncUuid != me.syncUuid)
        p.syncUuid,
  ];

  final daily = stamped(
    DailyTasks()
      ..serviceDay = today
      ..kiwiAbertura = true
      ..kiwiAberturaByNames = ['Inês Rodrigues']
      ..verificacaoTemperaturas = true
      ..verificacaoTemperaturasByNames = ['João Pereira']
      ..alteracoesPreco = true
      ..alteracoesPrecoByNames = ['Sofia Almeida', 'Inês Rodrigues']
      ..alteracoesPrecoCount = 46
      ..verificacaoValidades = true
      ..verificacaoValidadesByNames = ['Beatriz Costa']
      ..verificacaoValidadesCount = 12
      ..lastUpdatedAt = day(0, 9, 40),
  );
  final yesterday = stamped(
    DailyTasks()
      ..serviceDay = day(-1)
      ..kiwiAbertura = true
      ..kiwiAberturaByNames = ['Sofia Almeida']
      ..verificacaoTemperaturas = true
      ..verificacaoTemperaturasByNames = ['João Pereira']
      ..preenchimentoQuadro = true
      ..preenchimentoQuadroByNames = ['Inês Rodrigues']
      ..verificacaoValidades = true
      ..verificacaoValidadesByNames = ['Inês Rodrigues']
      ..validadesNoite = true
      ..validadesNoiteByNames = ['Carla Mendes']
      ..kiwiFecho = true
      ..kiwiFechoByNames = ['Ricardo Matos'],
  );
  final weekly = stamped(
    WeeklyTasks()
      ..serviceWeek = currentServiceWeek(n)
      ..verificar1a = true
      ..verificar1aByNames = ['Inês Rodrigues']
      ..verificar1aCount = 18,
  );
  final opening = stamped(
    OpeningList()
      ..serviceDay = today
      ..createdByNames = ['Sofia Almeida']
      ..congelados = 6
      ..congeladosDoneAt = day(0, 7, 15)
      ..congeladosByNames = ['João Pereira']
      ..opls = 4
      ..naoPereciveis = 9,
  );
  final customTask = stamped(
    CustomTask()
      ..title = 'Repor sacos nas caixas'
      ..frequency = CustomTaskFrequency.daily
      ..createdAt = day(-30),
  );

  PalletCount pallets(String department, int total, [int mistas = 0]) =>
      PalletCount()
        ..department = department
        ..total = total
        ..mistas = mistas;
  final trucks = [
    stamped(
      TruckReception()
        ..arrivalTime = day(-1, 6, 20)
        ..type = TruckType.naoPereciveis
        ..createdByNames = ['Sofia Almeida']
        ..pallets = [
          pallets('mercearia', 8, 2),
          pallets('bebidas', 5),
          pallets('dph', 3, 1),
        ]
        ..expositores = [
          Expositor()
            ..amount = 2
            ..content = 'Azeite em promoção',
        ],
    ),
    stamped(
      TruckReception()
        ..arrivalTime = day(-1, 21, 40)
        ..type = TruckType.pereciveis
        ..createdByNames = ['Ricardo Matos']
        ..pallets = [
          pallets('iogurtes', 4),
          pallets('charcutaria', 2),
          pallets('fruta', 6, 1),
        ]
        ..issues = 'Uma palete de iogurtes com caixas amolgadas.',
    ),
    stamped(
      TruckReception()
        ..arrivalTime = day(-3, 6, 5)
        ..type = TruckType.naoPereciveis
        ..createdByNames = ['Inês Rodrigues']
        ..pallets = [pallets('mercearia', 10, 3), pallets('bazar', 2)],
    ),
  ];
  final inventories = [
    stamped(
      Inventory()
        ..name = 'Bebidas espirituosas'
        ..code = 'INV-0412'
        ..valueCents = 1834550
        ..createdAt = day(-6, 8)
        ..startedAt = day(-6, 8)
        ..finishedAt = day(-6, 11)
        ..finalValueCents = 1829120
        ..createdByNames = ['Sofia Almeida'],
    ),
    stamped(
      Inventory()
        ..name = 'Higiene oral'
        ..code = 'INV-0418'
        ..valueCents = 412300
        ..createdAt = day(0, 8)
        ..startedAt = day(0, 8, 30)
        ..createdByNames = ['Inês Rodrigues'],
    ),
  ];
  final pedidos = [
    stamped(
      Pedido()
        ..numero = '4500123987'
        ..supplier = 'Lactogal'
        ..createdAt = day(-6)
        ..expectedDate = day(-3, 0),
    ),
    stamped(
      Pedido()
        ..numero = '4500124410'
        ..supplier = 'Sumol+Compal'
        ..createdAt = day(-2)
        ..expectedDate = day(1, 0),
    ),
    stamped(
      Pedido()
        ..numero = '4500122001'
        ..supplier = 'Delta Cafés'
        ..createdAt = day(-10)
        ..expectedDate = day(-7, 0)
        ..finishedAt = day(-7, 10),
    ),
  ];
  InfoEntry info(
    String bucket,
    String title,
    String description, {
    String? group,
    String? phone,
  }) => stamped(
    InfoEntry()
      ..bucket = bucket
      ..title = title
      ..description = description
      ..group = group
      ..phone = phone
      ..createdAt = day(-60),
  );
  final infos = [
    info('loja_horario', 'Horário', 'Todos os dias, 8h00 às 21h00'),
    info('loja_morada', 'Morada', 'Rua das Flores, 120, Lisboa'),
    info(
      contactsBucket,
      'Manutenção (frio)',
      'Avarias de arcas e câmaras',
      group: 'Manutenção',
      phone: '210 000 000',
    ),
    info(
      contactsBucket,
      'Entreposto',
      'Dúvidas sobre entregas',
      group: 'Logística',
      phone: '210 000 001',
    ),
    info(
      'suporte_avarias',
      'Arca 3 dos congelados',
      'Não chega aos -18 ºC. Técnico pedido.',
    ),
  ];

  final received = stamped(
    Aviso()
      ..text =
          'Amanhã há visita da área: confirmem as validades e o quadro '
          'antes das 9h.'
      ..sentAt = day(0, 8, 10)
      ..fromPersonId = uuid('Paulo Ribeiro')
      ..fromName = 'Paulo Ribeiro'
      ..toPersonIds = [me.syncUuid, ...team(livreServicoId)],
  );
  final sent = stamped(
    Aviso()
      ..text = 'Atualizem as vossas folgas de novembro até sexta.'
      ..sentAt = day(-1, 15, 30)
      ..fromPersonId = me.syncUuid
      ..fromName = me.fullName
      ..toPersonIds = team(livreServicoId, turno: 'dia'),
  );
  final vistos = [
    for (final id in sent.toPersonIds.take(2))
      stamped(
        AvisoVisto()
          ..avisoId = sent.syncUuid
          ..personId = id
          ..seenAt = day(-1, 16),
      ),
  ];

  await db.transaction(() async {
    await db.persons.putAll(people);
    await db.dailyTasks.putAll([daily, yesterday]);
    await db.weeklyTasks.put(weekly);
    await db.openingLists.put(opening);
    await db.customTasks.put(customTask);
    await db.truckReceptions.putAll(trucks);
    await db.inventories.putAll(inventories);
    await db.pedidos.putAll(pedidos);
    await db.infoEntries.putAll(infos);
    await db.avisos.putAll([received, sent]);
    await db.avisoVistos.putAll(vistos);
  });

  AccountService.instance.store = (
    id: 'demo',
    name: 'Loja Demonstração',
    role: StoreRole.editor,
    personId: me.syncUuid,
    pending: false,
    access: StoreAccess(
      admin: false,
      level: 3,
      team: livreServicoId,
      personId: me.syncUuid,
    ),
  );
  return me.syncUuid;
}
