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
    r'alteracoesPrecoCount': PropertySchema(
      id: 1,
      name: r'alteracoesPrecoCount',
      type: IsarType.long,
    ),
    r'kiwiAbertura': PropertySchema(
      id: 2,
      name: r'kiwiAbertura',
      type: IsarType.bool,
    ),
    r'kiwiFecho': PropertySchema(
      id: 3,
      name: r'kiwiFecho',
      type: IsarType.bool,
    ),
    r'lastUpdatedAt': PropertySchema(
      id: 4,
      name: r'lastUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'limpezaMaquinaVoltas': PropertySchema(
      id: 5,
      name: r'limpezaMaquinaVoltas',
      type: IsarType.bool,
    ),
    r'preenchimentoQuadro': PropertySchema(
      id: 6,
      name: r'preenchimentoQuadro',
      type: IsarType.bool,
    ),
    r'serviceDay': PropertySchema(
      id: 7,
      name: r'serviceDay',
      type: IsarType.dateTime,
    ),
    r'syncDeletedAt': PropertySchema(
      id: 8,
      name: r'syncDeletedAt',
      type: IsarType.dateTime,
    ),
    r'syncUpdatedAt': PropertySchema(
      id: 9,
      name: r'syncUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'syncUuid': PropertySchema(
      id: 10,
      name: r'syncUuid',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 11, name: r'synced', type: IsarType.bool),
    r'verificacaoTemperaturas': PropertySchema(
      id: 12,
      name: r'verificacaoTemperaturas',
      type: IsarType.bool,
    ),
    r'verificacaoValidades': PropertySchema(
      id: 13,
      name: r'verificacaoValidades',
      type: IsarType.bool,
    ),
    r'verificacaoValidadesCount': PropertySchema(
      id: 14,
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
  bytesCount += 3 + object.syncUuid.length * 3;
  return bytesCount;
}

void _dailyTasksSerialize(
  DailyTasks object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.alteracoesPreco);
  writer.writeLong(offsets[1], object.alteracoesPrecoCount);
  writer.writeBool(offsets[2], object.kiwiAbertura);
  writer.writeBool(offsets[3], object.kiwiFecho);
  writer.writeDateTime(offsets[4], object.lastUpdatedAt);
  writer.writeBool(offsets[5], object.limpezaMaquinaVoltas);
  writer.writeBool(offsets[6], object.preenchimentoQuadro);
  writer.writeDateTime(offsets[7], object.serviceDay);
  writer.writeDateTime(offsets[8], object.syncDeletedAt);
  writer.writeDateTime(offsets[9], object.syncUpdatedAt);
  writer.writeString(offsets[10], object.syncUuid);
  writer.writeBool(offsets[11], object.synced);
  writer.writeBool(offsets[12], object.verificacaoTemperaturas);
  writer.writeBool(offsets[13], object.verificacaoValidades);
  writer.writeLong(offsets[14], object.verificacaoValidadesCount);
}

DailyTasks _dailyTasksDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyTasks();
  object.alteracoesPreco = reader.readBool(offsets[0]);
  object.alteracoesPrecoCount = reader.readLong(offsets[1]);
  object.id = id;
  object.kiwiAbertura = reader.readBool(offsets[2]);
  object.kiwiFecho = reader.readBool(offsets[3]);
  object.lastUpdatedAt = reader.readDateTimeOrNull(offsets[4]);
  object.limpezaMaquinaVoltas = reader.readBool(offsets[5]);
  object.preenchimentoQuadro = reader.readBool(offsets[6]);
  object.serviceDay = reader.readDateTime(offsets[7]);
  object.syncDeletedAt = reader.readDateTimeOrNull(offsets[8]);
  object.syncUpdatedAt = reader.readDateTime(offsets[9]);
  object.syncUuid = reader.readString(offsets[10]);
  object.synced = reader.readBool(offsets[11]);
  object.verificacaoTemperaturas = reader.readBool(offsets[12]);
  object.verificacaoValidades = reader.readBool(offsets[13]);
  object.verificacaoValidadesCount = reader.readLong(offsets[14]);
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
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
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
  limpezaMaquinaVoltasEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'limpezaMaquinaVoltas',
          value: value,
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
  sortByLimpezaMaquinaVoltas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limpezaMaquinaVoltas', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  sortByLimpezaMaquinaVoltasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limpezaMaquinaVoltas', Sort.desc);
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
  thenByLimpezaMaquinaVoltas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limpezaMaquinaVoltas', Sort.asc);
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QAfterSortBy>
  thenByLimpezaMaquinaVoltasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limpezaMaquinaVoltas', Sort.desc);
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

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByAlteracoesPrecoCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alteracoesPrecoCount');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByKiwiAbertura() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kiwiAbertura');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByKiwiFecho() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kiwiFecho');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct> distinctByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdatedAt');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByLimpezaMaquinaVoltas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'limpezaMaquinaVoltas');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByPreenchimentoQuadro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preenchimentoQuadro');
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

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByVerificacaoTemperaturas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificacaoTemperaturas');
    });
  }

  QueryBuilder<DailyTasks, DailyTasks, QDistinct>
  distinctByVerificacaoValidades() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificacaoValidades');
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

  QueryBuilder<DailyTasks, int, QQueryOperations>
  alteracoesPrecoCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alteracoesPrecoCount');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations> kiwiAberturaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kiwiAbertura');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations> kiwiFechoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kiwiFecho');
    });
  }

  QueryBuilder<DailyTasks, DateTime?, QQueryOperations>
  lastUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdatedAt');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations>
  limpezaMaquinaVoltasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'limpezaMaquinaVoltas');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations>
  preenchimentoQuadroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preenchimentoQuadro');
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

  QueryBuilder<DailyTasks, bool, QQueryOperations>
  verificacaoTemperaturasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificacaoTemperaturas');
    });
  }

  QueryBuilder<DailyTasks, bool, QQueryOperations>
  verificacaoValidadesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificacaoValidades');
    });
  }

  QueryBuilder<DailyTasks, int, QQueryOperations>
  verificacaoValidadesCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificacaoValidadesCount');
    });
  }
}
