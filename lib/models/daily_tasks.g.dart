// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_tasks.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyTasksCollection on Isar {
  IsarCollection<DailyTasks> get dailyTasks => this.collection();
}

const DailyTasksSchema = CollectionSchema(
  name: r'DailyTasks',
  id: 471837438090756525,
  properties: {
    r'alteracoesPreco': PropertySchema(
      id: 0,
      name: r'alteracoesPreco',
      type: IsarType.bool,
    ),
    r'alteracoesPrecoBy': PropertySchema(
      id: 1,
      name: r'alteracoesPrecoBy',
      type: IsarType.string,
    ),
    r'alteracoesPrecoByNames': PropertySchema(
      id: 2,
      name: r'alteracoesPrecoByNames',
      type: IsarType.stringList,
    ),
    r'alteracoesPrecoCount': PropertySchema(
      id: 3,
      name: r'alteracoesPrecoCount',
      type: IsarType.long,
    ),
    r'backdatedTaskKeys': PropertySchema(
      id: 4,
      name: r'backdatedTaskKeys',
      type: IsarType.stringList,
    ),
    r'kiwiAbertura': PropertySchema(
      id: 5,
      name: r'kiwiAbertura',
      type: IsarType.bool,
    ),
    r'kiwiAberturaBy': PropertySchema(
      id: 6,
      name: r'kiwiAberturaBy',
      type: IsarType.string,
    ),
    r'kiwiAberturaByNames': PropertySchema(
      id: 7,
      name: r'kiwiAberturaByNames',
      type: IsarType.stringList,
    ),
    r'kiwiFecho': PropertySchema(
      id: 8,
      name: r'kiwiFecho',
      type: IsarType.bool,
    ),
    r'kiwiFechoBy': PropertySchema(
      id: 9,
      name: r'kiwiFechoBy',
      type: IsarType.string,
    ),
    r'kiwiFechoByNames': PropertySchema(
      id: 10,
      name: r'kiwiFechoByNames',
      type: IsarType.stringList,
    ),
    r'lastUpdatedAt': PropertySchema(
      id: 11,
      name: r'lastUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'preenchimentoQuadro': PropertySchema(
      id: 12,
      name: r'preenchimentoQuadro',
      type: IsarType.bool,
    ),
    r'preenchimentoQuadroBy': PropertySchema(
      id: 13,
      name: r'preenchimentoQuadroBy',
      type: IsarType.string,
    ),
    r'preenchimentoQuadroByNames': PropertySchema(
      id: 14,
      name: r'preenchimentoQuadroByNames',
      type: IsarType.stringList,
    ),
    r'serviceDay': PropertySchema(
      id: 15,
      name: r'serviceDay',
      type: IsarType.dateTime,
    ),
    r'syncDeletedAt': PropertySchema(
      id: 16,
      name: r'syncDeletedAt',
      type: IsarType.dateTime,
    ),
    r'syncUpdatedAt': PropertySchema(
      id: 17,
      name: r'syncUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'syncUuid': PropertySchema(
      id: 18,
      name: r'syncUuid',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 19, name: r'synced', type: IsarType.bool),
    r'validadesNoite': PropertySchema(
      id: 20,
      name: r'validadesNoite',
      type: IsarType.bool,
    ),
    r'validadesNoiteByNames': PropertySchema(
      id: 21,
      name: r'validadesNoiteByNames',
      type: IsarType.stringList,
    ),
    r'validadesNoiteCount': PropertySchema(
      id: 22,
      name: r'validadesNoiteCount',
      type: IsarType.long,
    ),
    r'verificacaoTemperaturas': PropertySchema(
      id: 23,
      name: r'verificacaoTemperaturas',
      type: IsarType.bool,
    ),
    r'verificacaoTemperaturasBy': PropertySchema(
      id: 24,
      name: r'verificacaoTemperaturasBy',
      type: IsarType.string,
    ),
    r'verificacaoTemperaturasByNames': PropertySchema(
      id: 25,
      name: r'verificacaoTemperaturasByNames',
      type: IsarType.stringList,
    ),
    r'verificacaoValidades': PropertySchema(
      id: 26,
      name: r'verificacaoValidades',
      type: IsarType.bool,
    ),
    r'verificacaoValidadesBy': PropertySchema(
      id: 27,
      name: r'verificacaoValidadesBy',
      type: IsarType.string,
    ),
    r'verificacaoValidadesByNames': PropertySchema(
      id: 28,
      name: r'verificacaoValidadesByNames',
      type: IsarType.stringList,
    ),
    r'verificacaoValidadesCount': PropertySchema(
      id: 29,
      name: r'verificacaoValidadesCount',
      type: IsarType.long,
    ),
  },

  estimateSize: _dailyTasksEstimateSize,
  serialize: _dailyTasksSerialize,
  deserialize: _dailyTasksDeserialize,
  deserializeProp: _dailyTasksDeserializeProp,
  idName: r'id',
  indexes: {
    r'syncUuid': IndexSchema(
      id: -4185038440025156770,
      name: r'syncUuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syncUuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'serviceDay': IndexSchema(
      id: -114834928129556000,
      name: r'serviceDay',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'serviceDay',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _dailyTasksGetId,
  getLinks: _dailyTasksGetLinks,
  attach: _dailyTasksAttach,
  version: '3.3.2',
);

int _dailyTasksEstimateSize(
  DailyTasks object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.alteracoesPrecoBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.alteracoesPrecoByNames.length * 3;
  {
    for (var i = 0; i < object.alteracoesPrecoByNames.length; i++) {
      final value = object.alteracoesPrecoByNames[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.backdatedTaskKeys.length * 3;
  {
    for (var i = 0; i < object.backdatedTaskKeys.length; i++) {
      final value = object.backdatedTaskKeys[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.kiwiAberturaBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.kiwiAberturaByNames.length * 3;
  {
    for (var i = 0; i < object.kiwiAberturaByNames.length; i++) {
      final value = object.kiwiAberturaByNames[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.kiwiFechoBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.kiwiFechoByNames.length * 3;
  {
    for (var i = 0; i < object.kiwiFechoByNames.length; i++) {
      final value = object.kiwiFechoByNames[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.preenchimentoQuadroBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.preenchimentoQuadroByNames.length * 3;
  {
    for (var i = 0; i < object.preenchimentoQuadroByNames.length; i++) {
      final value = object.preenchimentoQuadroByNames[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.syncUuid.length * 3;
  bytesCount += 3 + object.validadesNoiteByNames.length * 3;
  {
    for (var i = 0; i < object.validadesNoiteByNames.length; i++) {
      final value = object.validadesNoiteByNames[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.verificacaoTemperaturasBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.verificacaoTemperaturasByNames.length * 3;
  {
    for (var i = 0; i < object.verificacaoTemperaturasByNames.length; i++) {
      final value = object.verificacaoTemperaturasByNames[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.verificacaoValidadesBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.verificacaoValidadesByNames.length * 3;
  {
    for (var i = 0; i < object.verificacaoValidadesByNames.length; i++) {
      final value = object.verificacaoValidadesByNames[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _dailyTasksSerialize(
  DailyTasks object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.alteracoesPreco);
  writer.writeString(offsets[1], object.alteracoesPrecoBy);
  writer.writeStringList(offsets[2], object.alteracoesPrecoByNames);
  writer.writeLong(offsets[3], object.alteracoesPrecoCount);
  writer.writeStringList(offsets[4], object.backdatedTaskKeys);
  writer.writeBool(offsets[5], object.kiwiAbertura);
  writer.writeString(offsets[6], object.kiwiAberturaBy);
  writer.writeStringList(offsets[7], object.kiwiAberturaByNames);
  writer.writeBool(offsets[8], object.kiwiFecho);
  writer.writeString(offsets[9], object.kiwiFechoBy);
  writer.writeStringList(offsets[10], object.kiwiFechoByNames);
  writer.writeDateTime(offsets[11], object.lastUpdatedAt);
  writer.writeBool(offsets[12], object.preenchimentoQuadro);
  writer.writeString(offsets[13], object.preenchimentoQuadroBy);
  writer.writeStringList(offsets[14], object.preenchimentoQuadroByNames);
  writer.writeDateTime(offsets[15], object.serviceDay);
  writer.writeDateTime(offsets[16], object.syncDeletedAt);
  writer.writeDateTime(offsets[17], object.syncUpdatedAt);
  writer.writeString(offsets[18], object.syncUuid);
  writer.writeBool(offsets[19], object.synced);
  writer.writeBool(offsets[20], object.validadesNoite);
  writer.writeStringList(offsets[21], object.validadesNoiteByNames);
  writer.writeLong(offsets[22], object.validadesNoiteCount);
  writer.writeBool(offsets[23], object.verificacaoTemperaturas);
  writer.writeString(offsets[24], object.verificacaoTemperaturasBy);
  writer.writeStringList(offsets[25], object.verificacaoTemperaturasByNames);
  writer.writeBool(offsets[26], object.verificacaoValidades);
  writer.writeString(offsets[27], object.verificacaoValidadesBy);
  writer.writeStringList(offsets[28], object.verificacaoValidadesByNames);
  writer.writeLong(offsets[29], object.verificacaoValidadesCount);
}

DailyTasks _dailyTasksDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyTasks();
  object.alteracoesPreco = reader.readBool(offsets[0]);
  object.alteracoesPrecoBy = reader.readStringOrNull(offsets[1]);
  object.alteracoesPrecoByNames = reader.readStringList(offsets[2]) ?? [];
  object.alteracoesPrecoCount = reader.readLong(offsets[3]);
  object.backdatedTaskKeys = reader.readStringList(offsets[4]) ?? [];
  object.id = id;
  object.kiwiAbertura = reader.readBool(offsets[5]);
  object.kiwiAberturaBy = reader.readStringOrNull(offsets[6]);
  object.kiwiAberturaByNames = reader.readStringList(offsets[7]) ?? [];
  object.kiwiFecho = reader.readBool(offsets[8]);
  object.kiwiFechoBy = reader.readStringOrNull(offsets[9]);
  object.kiwiFechoByNames = reader.readStringList(offsets[10]) ?? [];
  object.lastUpdatedAt = reader.readDateTimeOrNull(offsets[11]);
  object.preenchimentoQuadro = reader.readBool(offsets[12]);
  object.preenchimentoQuadroBy = reader.readStringOrNull(offsets[13]);
  object.preenchimentoQuadroByNames = reader.readStringList(offsets[14]) ?? [];
  object.serviceDay = reader.readDateTime(offsets[15]);
  object.syncDeletedAt = reader.readDateTimeOrNull(offsets[16]);
  object.syncUpdatedAt = reader.readDateTime(offsets[17]);
  object.syncUuid = reader.readString(offsets[18]);
  object.synced = reader.readBool(offsets[19]);
  object.validadesNoite = reader.readBool(offsets[20]);
  object.validadesNoiteByNames = reader.readStringList(offsets[21]) ?? [];
  object.validadesNoiteCount = reader.readLong(offsets[22]);
  object.verificacaoTemperaturas = reader.readBool(offsets[23]);
  object.verificacaoTemperaturasBy = reader.readStringOrNull(offsets[24]);
  object.verificacaoTemperaturasByNames =
      reader.readStringList(offsets[25]) ?? [];
  object.verificacaoValidades = reader.readBool(offsets[26]);
  object.verificacaoValidadesBy = reader.readStringOrNull(offsets[27]);
  object.verificacaoValidadesByNames = reader.readStringList(offsets[28]) ?? [];
  object.verificacaoValidadesCount = reader.readLong(offsets[29]);
  return object;
}

P _dailyTasksDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringList(offset) ?? []) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 17:
      return (reader.readDateTime(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readStringList(offset) ?? []) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    case 23:
      return (reader.readBool(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringList(offset) ?? []) as P;
    case 26:
      return (reader.readBool(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readStringList(offset) ?? []) as P;
    case 29:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyTasksGetId(DailyTasks object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyTasksGetLinks(DailyTasks object) {
  return [];
}

void _dailyTasksAttach(IsarCollection<dynamic> col, Id id, DailyTasks object) {
  object.id = id;
}

extension DailyTasksByIndex on IsarCollection<DailyTasks> {
  Future<DailyTasks?> getByServiceDay(DateTime serviceDay) {
    return getByIndex(r'serviceDay', [serviceDay]);
  }

  DailyTasks? getByServiceDaySync(DateTime serviceDay) {
    return getByIndexSync(r'serviceDay', [serviceDay]);
  }

  Future<bool> deleteByServiceDay(DateTime serviceDay) {
    return deleteByIndex(r'serviceDay', [serviceDay]);
  }

  bool deleteByServiceDaySync(DateTime serviceDay) {
    return deleteByIndexSync(r'serviceDay', [serviceDay]);
  }

  Future<List<DailyTasks?>> getAllByServiceDay(
    List<DateTime> serviceDayValues,
  ) {
    final values = serviceDayValues.map((e) => [e]).toList();
    return getAllByIndex(r'serviceDay', values);
  }

  List<DailyTasks?> getAllByServiceDaySync(List<DateTime> serviceDayValues) {
    final values = serviceDayValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'serviceDay', values);
  }

  Future<int> deleteAllByServiceDay(List<DateTime> serviceDayValues) {
    final values = serviceDayValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'serviceDay', values);
  }

  int deleteAllByServiceDaySync(List<DateTime> serviceDayValues) {
    final values = serviceDayValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'serviceDay', values);
  }

  Future<Id> putByServiceDay(DailyTasks object) {
    return putByIndex(r'serviceDay', object);
  }

  Id putByServiceDaySync(DailyTasks object, {bool saveLinks = true}) {
    return putByIndexSync(r'serviceDay', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServiceDay(List<DailyTasks> objects) {
    return putAllByIndex(r'serviceDay', objects);
  }

  List<Id> putAllByServiceDaySync(
    List<DailyTasks> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'serviceDay', objects, saveLinks: saveLinks);
  }
}

extension DailyTasksQueryWhereSort
    on QueryBuilder<DailyTasks, DailyTasks, QWhere> {
  QueryBuilder<DailyTasks, DailyTasks, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterWhere> anyServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'serviceDay'),
      );
    });
  }
}

extension DailyTasksQueryWhere
    on QueryBuilder<DailyTasks, DailyTasks, QWhereClause> {
  QueryBuilder<DailyTasks, DailyTasks, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterWhereClause> syncUuidEqualTo(
    String syncUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncUuid', value: [syncUuid]),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterWhereClause> syncUuidNotEqualTo(
    String syncUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncUuid',
                lower: [],
                upper: [syncUuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncUuid',
                lower: [syncUuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncUuid',
                lower: [syncUuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'syncUuid',
                lower: [],
                upper: [syncUuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterWhereClause> serviceDayEqualTo(
    DateTime serviceDay,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'serviceDay', value: [serviceDay]),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterWhereClause> serviceDayNotEqualTo(
    DateTime serviceDay,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'serviceDay',
                lower: [],
                upper: [serviceDay],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'serviceDay',
                lower: [serviceDay],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'serviceDay',
                lower: [serviceDay],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'serviceDay',
                lower: [],
                upper: [serviceDay],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterWhereClause> serviceDayGreaterThan(
    DateTime serviceDay, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'serviceDay',
          lower: [serviceDay],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterWhereClause> serviceDayLessThan(
    DateTime serviceDay, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'serviceDay',
          lower: [],
          upper: [serviceDay],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterWhereClause> serviceDayBetween(
    DateTime lowerServiceDay,
    DateTime upperServiceDay, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'serviceDay',
          lower: [lowerServiceDay],
          includeLower: includeLower,
          upper: [upperServiceDay],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DailyTasksQueryFilter
    on QueryBuilder<DailyTasks, DailyTasks, QFilterCondition> {
  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'alteracoesPreco', value: value),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'alteracoesPrecoBy'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'alteracoesPrecoBy'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'alteracoesPrecoBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'alteracoesPrecoBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'alteracoesPrecoBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'alteracoesPrecoBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'alteracoesPrecoBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'alteracoesPrecoBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'alteracoesPrecoBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'alteracoesPrecoBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'alteracoesPrecoBy', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'alteracoesPrecoBy', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'alteracoesPrecoByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'alteracoesPrecoByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'alteracoesPrecoByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'alteracoesPrecoByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'alteracoesPrecoByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'alteracoesPrecoByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'alteracoesPrecoByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'alteracoesPrecoByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'alteracoesPrecoByNames', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'alteracoesPrecoByNames',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alteracoesPrecoByNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'alteracoesPrecoByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alteracoesPrecoByNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alteracoesPrecoByNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alteracoesPrecoByNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alteracoesPrecoByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'alteracoesPrecoCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'alteracoesPrecoCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'alteracoesPrecoCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  alteracoesPrecoCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'alteracoesPrecoCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'backdatedTaskKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'backdatedTaskKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'backdatedTaskKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'backdatedTaskKeys',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'backdatedTaskKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'backdatedTaskKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'backdatedTaskKeys',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'backdatedTaskKeys',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'backdatedTaskKeys', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'backdatedTaskKeys', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'backdatedTaskKeys', length, true, length, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'backdatedTaskKeys', 0, true, 0, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'backdatedTaskKeys', 0, false, 999999, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'backdatedTaskKeys', 0, true, length, include);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'backdatedTaskKeys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  backdatedTaskKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'backdatedTaskKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kiwiAbertura', value: value),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'kiwiAberturaBy'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'kiwiAberturaBy'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kiwiAberturaBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kiwiAberturaBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kiwiAberturaBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kiwiAberturaBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kiwiAberturaBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kiwiAberturaBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kiwiAberturaBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kiwiAberturaBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kiwiAberturaBy', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kiwiAberturaBy', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kiwiAberturaByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kiwiAberturaByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kiwiAberturaByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kiwiAberturaByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kiwiAberturaByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kiwiAberturaByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kiwiAberturaByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kiwiAberturaByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kiwiAberturaByNames', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'kiwiAberturaByNames',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'kiwiAberturaByNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kiwiAberturaByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kiwiAberturaByNames', 0, false, 999999, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kiwiAberturaByNames', 0, true, length, include);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'kiwiAberturaByNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiAberturaByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'kiwiAberturaByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> kiwiFechoEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kiwiFecho', value: value),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'kiwiFechoBy'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'kiwiFechoBy'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kiwiFechoBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kiwiFechoBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kiwiFechoBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kiwiFechoBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kiwiFechoBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kiwiFechoBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kiwiFechoBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kiwiFechoBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kiwiFechoBy', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kiwiFechoBy', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kiwiFechoByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kiwiFechoByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kiwiFechoByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kiwiFechoByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kiwiFechoByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kiwiFechoByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kiwiFechoByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kiwiFechoByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kiwiFechoByNames', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kiwiFechoByNames', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kiwiFechoByNames', length, true, length, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kiwiFechoByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kiwiFechoByNames', 0, false, 999999, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'kiwiFechoByNames', 0, true, length, include);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'kiwiFechoByNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  kiwiFechoByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'kiwiFechoByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  lastUpdatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastUpdatedAt'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  lastUpdatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastUpdatedAt'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  lastUpdatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  lastUpdatedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastUpdatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  lastUpdatedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastUpdatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  lastUpdatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastUpdatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'preenchimentoQuadro', value: value),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'preenchimentoQuadroBy'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'preenchimentoQuadroBy'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'preenchimentoQuadroBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'preenchimentoQuadroBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'preenchimentoQuadroBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'preenchimentoQuadroBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'preenchimentoQuadroBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'preenchimentoQuadroBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'preenchimentoQuadroBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'preenchimentoQuadroBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'preenchimentoQuadroBy', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'preenchimentoQuadroBy',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'preenchimentoQuadroByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'preenchimentoQuadroByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'preenchimentoQuadroByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'preenchimentoQuadroByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'preenchimentoQuadroByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'preenchimentoQuadroByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'preenchimentoQuadroByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'preenchimentoQuadroByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'preenchimentoQuadroByNames',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'preenchimentoQuadroByNames',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'preenchimentoQuadroByNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'preenchimentoQuadroByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'preenchimentoQuadroByNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'preenchimentoQuadroByNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'preenchimentoQuadroByNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  preenchimentoQuadroByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'preenchimentoQuadroByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> serviceDayEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serviceDay', value: value),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  serviceDayGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'serviceDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  serviceDayLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'serviceDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> serviceDayBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'serviceDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncDeletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncDeletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncDeletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncDeletedAt', value: value),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncDeletedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncDeletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncDeletedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncDeletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncDeletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncDeletedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncUpdatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncUpdatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncUpdatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncUpdatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncUpdatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncUpdatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> syncUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'syncUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> syncUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> syncUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncUuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'syncUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> syncUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'syncUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> syncUuidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'syncUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> syncUuidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'syncUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  syncUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'validadesNoite', value: value),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'validadesNoiteByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'validadesNoiteByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'validadesNoiteByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'validadesNoiteByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'validadesNoiteByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'validadesNoiteByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'validadesNoiteByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'validadesNoiteByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'validadesNoiteByNames', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'validadesNoiteByNames',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'validadesNoiteByNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validadesNoiteByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'validadesNoiteByNames', 0, false, 999999, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'validadesNoiteByNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'validadesNoiteByNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'validadesNoiteByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'validadesNoiteCount', value: value),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'validadesNoiteCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'validadesNoiteCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  validadesNoiteCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'validadesNoiteCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificacaoTemperaturas',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'verificacaoTemperaturasBy'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'verificacaoTemperaturasBy'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificacaoTemperaturasBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verificacaoTemperaturasBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verificacaoTemperaturasBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verificacaoTemperaturasBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'verificacaoTemperaturasBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'verificacaoTemperaturasBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'verificacaoTemperaturasBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'verificacaoTemperaturasBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificacaoTemperaturasBy',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'verificacaoTemperaturasBy',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificacaoTemperaturasByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verificacaoTemperaturasByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verificacaoTemperaturasByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verificacaoTemperaturasByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'verificacaoTemperaturasByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'verificacaoTemperaturasByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'verificacaoTemperaturasByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'verificacaoTemperaturasByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificacaoTemperaturasByNames',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'verificacaoTemperaturasByNames',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificacaoTemperaturasByNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificacaoTemperaturasByNames',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificacaoTemperaturasByNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificacaoTemperaturasByNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificacaoTemperaturasByNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoTemperaturasByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificacaoTemperaturasByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificacaoValidades',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'verificacaoValidadesBy'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'verificacaoValidadesBy'),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificacaoValidadesBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verificacaoValidadesBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verificacaoValidadesBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verificacaoValidadesBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'verificacaoValidadesBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'verificacaoValidadesBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'verificacaoValidadesBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'verificacaoValidadesBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verificacaoValidadesBy', value: ''),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'verificacaoValidadesBy',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificacaoValidadesByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verificacaoValidadesByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verificacaoValidadesByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verificacaoValidadesByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'verificacaoValidadesByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'verificacaoValidadesByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'verificacaoValidadesByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'verificacaoValidadesByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificacaoValidadesByNames',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'verificacaoValidadesByNames',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificacaoValidadesByNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'verificacaoValidadesByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificacaoValidadesByNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificacaoValidadesByNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificacaoValidadesByNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificacaoValidadesByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificacaoValidadesCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verificacaoValidadesCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verificacaoValidadesCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterFilterCondition>
  verificacaoValidadesCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verificacaoValidadesCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension DailyTasksQueryObject
    on QueryBuilder<DailyTasks, DailyTasks, QFilterCondition> {}

extension DailyTasksQueryLinks
    on QueryBuilder<DailyTasks, DailyTasks, QFilterCondition> {}

extension DailyTasksQuerySortBy
    on QueryBuilder<DailyTasks, DailyTasks, QSortBy> {
  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByAlteracoesPreco() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alteracoesPreco', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByAlteracoesPrecoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alteracoesPreco', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByAlteracoesPrecoBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alteracoesPrecoBy', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByAlteracoesPrecoByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alteracoesPrecoBy', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByAlteracoesPrecoCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alteracoesPrecoCount', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByAlteracoesPrecoCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alteracoesPrecoCount', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByKiwiAbertura() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiAbertura', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByKiwiAberturaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiAbertura', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByKiwiAberturaBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiAberturaBy', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByKiwiAberturaByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiAberturaBy', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByKiwiFecho() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiFecho', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByKiwiFechoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiFecho', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByKiwiFechoBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiFechoBy', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByKiwiFechoByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiFechoBy', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByLastUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByPreenchimentoQuadro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preenchimentoQuadro', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByPreenchimentoQuadroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preenchimentoQuadro', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByPreenchimentoQuadroBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preenchimentoQuadroBy', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByPreenchimentoQuadroByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preenchimentoQuadroBy', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByServiceDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> sortByValidadesNoite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validadesNoite', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByValidadesNoiteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validadesNoite', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByValidadesNoiteCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validadesNoiteCount', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByValidadesNoiteCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validadesNoiteCount', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByVerificacaoTemperaturas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoTemperaturas', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByVerificacaoTemperaturasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoTemperaturas', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByVerificacaoTemperaturasBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoTemperaturasBy', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByVerificacaoTemperaturasByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoTemperaturasBy', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByVerificacaoValidades() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoValidades', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByVerificacaoValidadesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoValidades', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByVerificacaoValidadesBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoValidadesBy', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByVerificacaoValidadesByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoValidadesBy', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByVerificacaoValidadesCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoValidadesCount', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByVerificacaoValidadesCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoValidadesCount', Sort.desc);
    });
  }
}

extension DailyTasksQuerySortThenBy
    on QueryBuilder<DailyTasks, DailyTasks, QSortThenBy> {
  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByAlteracoesPreco() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alteracoesPreco', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByAlteracoesPrecoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alteracoesPreco', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByAlteracoesPrecoBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alteracoesPrecoBy', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByAlteracoesPrecoByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alteracoesPrecoBy', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByAlteracoesPrecoCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alteracoesPrecoCount', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByAlteracoesPrecoCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alteracoesPrecoCount', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByKiwiAbertura() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiAbertura', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByKiwiAberturaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiAbertura', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByKiwiAberturaBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiAberturaBy', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByKiwiAberturaByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiAberturaBy', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByKiwiFecho() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiFecho', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByKiwiFechoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiFecho', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByKiwiFechoBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiFechoBy', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByKiwiFechoByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kiwiFechoBy', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByLastUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByPreenchimentoQuadro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preenchimentoQuadro', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByPreenchimentoQuadroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preenchimentoQuadro', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByPreenchimentoQuadroBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preenchimentoQuadroBy', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByPreenchimentoQuadroByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preenchimentoQuadroBy', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByServiceDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy> thenByValidadesNoite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validadesNoite', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByValidadesNoiteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validadesNoite', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByValidadesNoiteCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validadesNoiteCount', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByValidadesNoiteCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'validadesNoiteCount', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByVerificacaoTemperaturas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoTemperaturas', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByVerificacaoTemperaturasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoTemperaturas', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByVerificacaoTemperaturasBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoTemperaturasBy', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByVerificacaoTemperaturasByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoTemperaturasBy', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByVerificacaoValidades() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoValidades', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByVerificacaoValidadesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoValidades', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByVerificacaoValidadesBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoValidadesBy', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByVerificacaoValidadesByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoValidadesBy', Sort.desc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByVerificacaoValidadesCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoValidadesCount', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByVerificacaoValidadesCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificacaoValidadesCount', Sort.desc);
    });
  }
}

extension DailyTasksQueryWhereDistinct
    on QueryBuilder<DailyTasks, DailyTasks, QDistinct> {
  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByAlteracoesPreco() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alteracoesPreco');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByAlteracoesPrecoBy({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'alteracoesPrecoBy',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByAlteracoesPrecoByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alteracoesPrecoByNames');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByAlteracoesPrecoCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alteracoesPrecoCount');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByBackdatedTaskKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backdatedTaskKeys');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByKiwiAbertura() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kiwiAbertura');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByKiwiAberturaBy({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'kiwiAberturaBy',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByKiwiAberturaByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kiwiAberturaByNames');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByKiwiFecho() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kiwiFecho');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByKiwiFechoBy({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kiwiFechoBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByKiwiFechoByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kiwiFechoByNames');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdatedAt');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByPreenchimentoQuadro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preenchimentoQuadro');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByPreenchimentoQuadroBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'preenchimentoQuadroBy',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByPreenchimentoQuadroByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preenchimentoQuadroByNames');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceDay');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDeletedAt');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUpdatedAt');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctBySyncUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByValidadesNoite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'validadesNoite');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByValidadesNoiteByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'validadesNoiteByNames');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByValidadesNoiteCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'validadesNoiteCount');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByVerificacaoTemperaturas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificacaoTemperaturas');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByVerificacaoTemperaturasBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'verificacaoTemperaturasBy',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByVerificacaoTemperaturasByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificacaoTemperaturasByNames');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByVerificacaoValidades() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificacaoValidades');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByVerificacaoValidadesBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'verificacaoValidadesBy',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByVerificacaoValidadesByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificacaoValidadesByNames');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByVerificacaoValidadesCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificacaoValidadesCount');
    });
  }
}

extension DailyTasksQueryProperty
    on QueryBuilder<DailyTasks, DailyTasks, QQueryProperty> {
  QueryBuilder<DailyTasks, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations> alteracoesPrecoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alteracoesPreco');
    });
  }

  QueryBuilder<DailyTasks, String?, QQueryOperations>
  alteracoesPrecoByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alteracoesPrecoBy');
    });
  }

  QueryBuilder<DailyTasks, List<String>, QQueryOperations>
  alteracoesPrecoByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alteracoesPrecoByNames');
    });
  }

  QueryBuilder<DailyTasks, int, QQueryOperations>
  alteracoesPrecoCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alteracoesPrecoCount');
    });
  }

  QueryBuilder<DailyTasks, List<String>, QQueryOperations>
  backdatedTaskKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backdatedTaskKeys');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations> kiwiAberturaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kiwiAbertura');
    });
  }

  QueryBuilder<DailyTasks, String?, QQueryOperations> kiwiAberturaByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kiwiAberturaBy');
    });
  }

  QueryBuilder<DailyTasks, List<String>, QQueryOperations>
  kiwiAberturaByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kiwiAberturaByNames');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations> kiwiFechoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kiwiFecho');
    });
  }

  QueryBuilder<DailyTasks, String?, QQueryOperations> kiwiFechoByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kiwiFechoBy');
    });
  }

  QueryBuilder<DailyTasks, List<String>, QQueryOperations>
  kiwiFechoByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kiwiFechoByNames');
    });
  }

  QueryBuilder<DailyTasks, DateTime?, QQueryOperations>
  lastUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdatedAt');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations>
  preenchimentoQuadroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preenchimentoQuadro');
    });
  }

  QueryBuilder<DailyTasks, String?, QQueryOperations>
  preenchimentoQuadroByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preenchimentoQuadroBy');
    });
  }

  QueryBuilder<DailyTasks, List<String>, QQueryOperations>
  preenchimentoQuadroByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preenchimentoQuadroByNames');
    });
  }

  QueryBuilder<DailyTasks, DateTime, QQueryOperations> serviceDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceDay');
    });
  }

  QueryBuilder<DailyTasks, DateTime?, QQueryOperations>
  syncDeletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDeletedAt');
    });
  }

  QueryBuilder<DailyTasks, DateTime, QQueryOperations> syncUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUpdatedAt');
    });
  }

  QueryBuilder<DailyTasks, String, QQueryOperations> syncUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUuid');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations> validadesNoiteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'validadesNoite');
    });
  }

  QueryBuilder<DailyTasks, List<String>, QQueryOperations>
  validadesNoiteByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'validadesNoiteByNames');
    });
  }

  QueryBuilder<DailyTasks, int, QQueryOperations>
  validadesNoiteCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'validadesNoiteCount');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations>
  verificacaoTemperaturasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificacaoTemperaturas');
    });
  }

  QueryBuilder<DailyTasks, String?, QQueryOperations>
  verificacaoTemperaturasByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificacaoTemperaturasBy');
    });
  }

  QueryBuilder<DailyTasks, List<String>, QQueryOperations>
  verificacaoTemperaturasByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificacaoTemperaturasByNames');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations>
  verificacaoValidadesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificacaoValidades');
    });
  }

  QueryBuilder<DailyTasks, String?, QQueryOperations>
  verificacaoValidadesByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificacaoValidadesBy');
    });
  }

  QueryBuilder<DailyTasks, List<String>, QQueryOperations>
  verificacaoValidadesByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificacaoValidadesByNames');
    });
  }

  QueryBuilder<DailyTasks, int, QQueryOperations>
  verificacaoValidadesCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificacaoValidadesCount');
    });
  }
}
