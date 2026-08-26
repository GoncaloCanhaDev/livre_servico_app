// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_tasks.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWeeklyTasksCollection on Isar {
  IsarCollection<WeeklyTasks> get weeklyTasks => this.collection();
}

const WeeklyTasksSchema = CollectionSchema(
  name: r'WeeklyTasks',
  id: 1111169730684679589,
  properties: {
    r'backdatedTaskKeys': PropertySchema(
      id: 0,
      name: r'backdatedTaskKeys',
      type: IsarType.stringList,
    ),
    r'lastUpdatedAt': PropertySchema(
      id: 1,
      name: r'lastUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'limpezaMaquinaVoltas': PropertySchema(
      id: 2,
      name: r'limpezaMaquinaVoltas',
      type: IsarType.bool,
    ),
    r'limpezaMaquinaVoltasBy': PropertySchema(
      id: 3,
      name: r'limpezaMaquinaVoltasBy',
      type: IsarType.string,
    ),
    r'limpezaMaquinaVoltasByNames': PropertySchema(
      id: 4,
      name: r'limpezaMaquinaVoltasByNames',
      type: IsarType.stringList,
    ),
    r'serviceWeek': PropertySchema(
      id: 5,
      name: r'serviceWeek',
      type: IsarType.dateTime,
    ),
    r'syncDeletedAt': PropertySchema(
      id: 6,
      name: r'syncDeletedAt',
      type: IsarType.dateTime,
    ),
    r'syncUpdatedAt': PropertySchema(
      id: 7,
      name: r'syncUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'syncUuid': PropertySchema(
      id: 8,
      name: r'syncUuid',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 9, name: r'synced', type: IsarType.bool),
    r'verificar1a': PropertySchema(
      id: 10,
      name: r'verificar1a',
      type: IsarType.bool,
    ),
    r'verificar1aBy': PropertySchema(
      id: 11,
      name: r'verificar1aBy',
      type: IsarType.string,
    ),
    r'verificar1aByNames': PropertySchema(
      id: 12,
      name: r'verificar1aByNames',
      type: IsarType.stringList,
    ),
    r'verificar1aCount': PropertySchema(
      id: 13,
      name: r'verificar1aCount',
      type: IsarType.long,
    ),
    r'verificar4a': PropertySchema(
      id: 14,
      name: r'verificar4a',
      type: IsarType.bool,
    ),
    r'verificar4aBy': PropertySchema(
      id: 15,
      name: r'verificar4aBy',
      type: IsarType.string,
    ),
    r'verificar4aByNames': PropertySchema(
      id: 16,
      name: r'verificar4aByNames',
      type: IsarType.stringList,
    ),
    r'verificar4aCount': PropertySchema(
      id: 17,
      name: r'verificar4aCount',
      type: IsarType.long,
    ),
  },

  estimateSize: _weeklyTasksEstimateSize,
  serialize: _weeklyTasksSerialize,
  deserialize: _weeklyTasksDeserialize,
  deserializeProp: _weeklyTasksDeserializeProp,
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
    r'serviceWeek': IndexSchema(
      id: -2819572863641919731,
      name: r'serviceWeek',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'serviceWeek',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _weeklyTasksGetId,
  getLinks: _weeklyTasksGetLinks,
  attach: _weeklyTasksAttach,
  version: '3.3.2',
);

int _weeklyTasksEstimateSize(
  WeeklyTasks object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.backdatedTaskKeys.length * 3;
  {
    for (var i = 0; i < object.backdatedTaskKeys.length; i++) {
      final value = object.backdatedTaskKeys[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.limpezaMaquinaVoltasBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.limpezaMaquinaVoltasByNames.length * 3;
  {
    for (var i = 0; i < object.limpezaMaquinaVoltasByNames.length; i++) {
      final value = object.limpezaMaquinaVoltasByNames[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.syncUuid.length * 3;
  {
    final value = object.verificar1aBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.verificar1aByNames.length * 3;
  {
    for (var i = 0; i < object.verificar1aByNames.length; i++) {
      final value = object.verificar1aByNames[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.verificar4aBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.verificar4aByNames.length * 3;
  {
    for (var i = 0; i < object.verificar4aByNames.length; i++) {
      final value = object.verificar4aByNames[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _weeklyTasksSerialize(
  WeeklyTasks object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.backdatedTaskKeys);
  writer.writeDateTime(offsets[1], object.lastUpdatedAt);
  writer.writeBool(offsets[2], object.limpezaMaquinaVoltas);
  writer.writeString(offsets[3], object.limpezaMaquinaVoltasBy);
  writer.writeStringList(offsets[4], object.limpezaMaquinaVoltasByNames);
  writer.writeDateTime(offsets[5], object.serviceWeek);
  writer.writeDateTime(offsets[6], object.syncDeletedAt);
  writer.writeDateTime(offsets[7], object.syncUpdatedAt);
  writer.writeString(offsets[8], object.syncUuid);
  writer.writeBool(offsets[9], object.synced);
  writer.writeBool(offsets[10], object.verificar1a);
  writer.writeString(offsets[11], object.verificar1aBy);
  writer.writeStringList(offsets[12], object.verificar1aByNames);
  writer.writeLong(offsets[13], object.verificar1aCount);
  writer.writeBool(offsets[14], object.verificar4a);
  writer.writeString(offsets[15], object.verificar4aBy);
  writer.writeStringList(offsets[16], object.verificar4aByNames);
  writer.writeLong(offsets[17], object.verificar4aCount);
}

WeeklyTasks _weeklyTasksDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WeeklyTasks();
  object.backdatedTaskKeys = reader.readStringList(offsets[0]) ?? [];
  object.id = id;
  object.lastUpdatedAt = reader.readDateTimeOrNull(offsets[1]);
  object.limpezaMaquinaVoltas = reader.readBool(offsets[2]);
  object.limpezaMaquinaVoltasBy = reader.readStringOrNull(offsets[3]);
  object.limpezaMaquinaVoltasByNames = reader.readStringList(offsets[4]) ?? [];
  object.serviceWeek = reader.readDateTime(offsets[5]);
  object.syncDeletedAt = reader.readDateTimeOrNull(offsets[6]);
  object.syncUpdatedAt = reader.readDateTime(offsets[7]);
  object.syncUuid = reader.readString(offsets[8]);
  object.synced = reader.readBool(offsets[9]);
  object.verificar1a = reader.readBool(offsets[10]);
  object.verificar1aBy = reader.readStringOrNull(offsets[11]);
  object.verificar1aByNames = reader.readStringList(offsets[12]) ?? [];
  object.verificar1aCount = reader.readLong(offsets[13]);
  object.verificar4a = reader.readBool(offsets[14]);
  object.verificar4aBy = reader.readStringOrNull(offsets[15]);
  object.verificar4aByNames = reader.readStringList(offsets[16]) ?? [];
  object.verificar4aCount = reader.readLong(offsets[17]);
  return object;
}

P _weeklyTasksDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringList(offset) ?? []) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _weeklyTasksGetId(WeeklyTasks object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _weeklyTasksGetLinks(WeeklyTasks object) {
  return [];
}

void _weeklyTasksAttach(
  IsarCollection<dynamic> col,
  Id id,
  WeeklyTasks object,
) {
  object.id = id;
}

extension WeeklyTasksByIndex on IsarCollection<WeeklyTasks> {
  Future<WeeklyTasks?> getByServiceWeek(DateTime serviceWeek) {
    return getByIndex(r'serviceWeek', [serviceWeek]);
  }

  WeeklyTasks? getByServiceWeekSync(DateTime serviceWeek) {
    return getByIndexSync(r'serviceWeek', [serviceWeek]);
  }

  Future<bool> deleteByServiceWeek(DateTime serviceWeek) {
    return deleteByIndex(r'serviceWeek', [serviceWeek]);
  }

  bool deleteByServiceWeekSync(DateTime serviceWeek) {
    return deleteByIndexSync(r'serviceWeek', [serviceWeek]);
  }

  Future<List<WeeklyTasks?>> getAllByServiceWeek(
    List<DateTime> serviceWeekValues,
  ) {
    final values = serviceWeekValues.map((e) => [e]).toList();
    return getAllByIndex(r'serviceWeek', values);
  }

  List<WeeklyTasks?> getAllByServiceWeekSync(List<DateTime> serviceWeekValues) {
    final values = serviceWeekValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'serviceWeek', values);
  }

  Future<int> deleteAllByServiceWeek(List<DateTime> serviceWeekValues) {
    final values = serviceWeekValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'serviceWeek', values);
  }

  int deleteAllByServiceWeekSync(List<DateTime> serviceWeekValues) {
    final values = serviceWeekValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'serviceWeek', values);
  }

  Future<Id> putByServiceWeek(WeeklyTasks object) {
    return putByIndex(r'serviceWeek', object);
  }

  Id putByServiceWeekSync(WeeklyTasks object, {bool saveLinks = true}) {
    return putByIndexSync(r'serviceWeek', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServiceWeek(List<WeeklyTasks> objects) {
    return putAllByIndex(r'serviceWeek', objects);
  }

  List<Id> putAllByServiceWeekSync(
    List<WeeklyTasks> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'serviceWeek', objects, saveLinks: saveLinks);
  }
}

extension WeeklyTasksQueryWhereSort
    on QueryBuilder<WeeklyTasks, WeeklyTasks, QWhere> {
  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhere> anyServiceWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'serviceWeek'),
      );
    });
  }
}

extension WeeklyTasksQueryWhere
    on QueryBuilder<WeeklyTasks, WeeklyTasks, QWhereClause> {
  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhereClause> idBetween(
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhereClause> syncUuidEqualTo(
    String syncUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncUuid', value: [syncUuid]),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhereClause> syncUuidNotEqualTo(
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhereClause> serviceWeekEqualTo(
    DateTime serviceWeek,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'serviceWeek',
          value: [serviceWeek],
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhereClause>
  serviceWeekNotEqualTo(DateTime serviceWeek) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'serviceWeek',
                lower: [],
                upper: [serviceWeek],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'serviceWeek',
                lower: [serviceWeek],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'serviceWeek',
                lower: [serviceWeek],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'serviceWeek',
                lower: [],
                upper: [serviceWeek],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhereClause>
  serviceWeekGreaterThan(DateTime serviceWeek, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'serviceWeek',
          lower: [serviceWeek],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhereClause> serviceWeekLessThan(
    DateTime serviceWeek, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'serviceWeek',
          lower: [],
          upper: [serviceWeek],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterWhereClause> serviceWeekBetween(
    DateTime lowerServiceWeek,
    DateTime upperServiceWeek, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'serviceWeek',
          lower: [lowerServiceWeek],
          includeLower: includeLower,
          upper: [upperServiceWeek],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WeeklyTasksQueryFilter
    on QueryBuilder<WeeklyTasks, WeeklyTasks, QFilterCondition> {
  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  backdatedTaskKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'backdatedTaskKeys', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  backdatedTaskKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'backdatedTaskKeys', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  backdatedTaskKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'backdatedTaskKeys', length, true, length, true);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  backdatedTaskKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'backdatedTaskKeys', 0, true, 0, true);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  backdatedTaskKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'backdatedTaskKeys', 0, false, 999999, true);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  backdatedTaskKeysLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'backdatedTaskKeys', 0, true, length, include);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  lastUpdatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastUpdatedAt'),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  lastUpdatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastUpdatedAt'),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  lastUpdatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'limpezaMaquinaVoltasBy'),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'limpezaMaquinaVoltasBy'),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'limpezaMaquinaVoltasBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'limpezaMaquinaVoltasBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'limpezaMaquinaVoltasBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'limpezaMaquinaVoltasBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'limpezaMaquinaVoltasBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'limpezaMaquinaVoltasBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'limpezaMaquinaVoltasBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'limpezaMaquinaVoltasBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'limpezaMaquinaVoltasBy', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'limpezaMaquinaVoltasBy',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'limpezaMaquinaVoltasByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'limpezaMaquinaVoltasByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'limpezaMaquinaVoltasByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'limpezaMaquinaVoltasByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'limpezaMaquinaVoltasByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'limpezaMaquinaVoltasByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'limpezaMaquinaVoltasByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'limpezaMaquinaVoltasByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'limpezaMaquinaVoltasByNames',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'limpezaMaquinaVoltasByNames',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'limpezaMaquinaVoltasByNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'limpezaMaquinaVoltasByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'limpezaMaquinaVoltasByNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'limpezaMaquinaVoltasByNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'limpezaMaquinaVoltasByNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  limpezaMaquinaVoltasByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'limpezaMaquinaVoltasByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  serviceWeekEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serviceWeek', value: value),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  serviceWeekGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'serviceWeek',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  serviceWeekLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'serviceWeek',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  serviceWeekBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'serviceWeek',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  syncDeletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  syncDeletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  syncDeletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncDeletedAt', value: value),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  syncUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition> syncUuidEqualTo(
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  syncUuidLessThan(
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition> syncUuidBetween(
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  syncUuidEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  syncUuidContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition> syncUuidMatches(
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

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  syncUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  syncUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verificar1a', value: value),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'verificar1aBy'),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'verificar1aBy'),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificar1aBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verificar1aBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verificar1aBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verificar1aBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'verificar1aBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'verificar1aBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'verificar1aBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'verificar1aBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verificar1aBy', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'verificar1aBy', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificar1aByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verificar1aByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verificar1aByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verificar1aByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'verificar1aByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'verificar1aByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'verificar1aByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'verificar1aByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verificar1aByNames', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'verificar1aByNames', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificar1aByNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'verificar1aByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'verificar1aByNames', 0, false, 999999, true);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'verificar1aByNames', 0, true, length, include);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificar1aByNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificar1aByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verificar1aCount', value: value),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verificar1aCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verificar1aCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar1aCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verificar1aCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verificar4a', value: value),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'verificar4aBy'),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'verificar4aBy'),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificar4aBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verificar4aBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verificar4aBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verificar4aBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'verificar4aBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'verificar4aBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'verificar4aBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'verificar4aBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verificar4aBy', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'verificar4aBy', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'verificar4aByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verificar4aByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verificar4aByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verificar4aByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'verificar4aByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'verificar4aByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'verificar4aByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'verificar4aByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verificar4aByNames', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'verificar4aByNames', value: ''),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificar4aByNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'verificar4aByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'verificar4aByNames', 0, false, 999999, true);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'verificar4aByNames', 0, true, length, include);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificar4aByNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'verificar4aByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'verificar4aCount', value: value),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'verificar4aCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'verificar4aCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterFilterCondition>
  verificar4aCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'verificar4aCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension WeeklyTasksQueryObject
    on QueryBuilder<WeeklyTasks, WeeklyTasks, QFilterCondition> {}

extension WeeklyTasksQueryLinks
    on QueryBuilder<WeeklyTasks, WeeklyTasks, QFilterCondition> {}

extension WeeklyTasksQuerySortBy
    on QueryBuilder<WeeklyTasks, WeeklyTasks, QSortBy> {
  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortByLastUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortByLimpezaMaquinaVoltas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limpezaMaquinaVoltas', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortByLimpezaMaquinaVoltasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limpezaMaquinaVoltas', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortByLimpezaMaquinaVoltasBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limpezaMaquinaVoltasBy', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortByLimpezaMaquinaVoltasByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limpezaMaquinaVoltasBy', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortByServiceWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceWeek', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortByServiceWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceWeek', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortByVerificar1a() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar1a', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortByVerificar1aDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar1a', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortByVerificar1aBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar1aBy', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortByVerificar1aByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar1aBy', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortByVerificar1aCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar1aCount', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortByVerificar1aCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar1aCount', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortByVerificar4a() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar4a', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortByVerificar4aDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar4a', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> sortByVerificar4aBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar4aBy', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortByVerificar4aByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar4aBy', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortByVerificar4aCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar4aCount', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  sortByVerificar4aCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar4aCount', Sort.desc);
    });
  }
}

extension WeeklyTasksQuerySortThenBy
    on QueryBuilder<WeeklyTasks, WeeklyTasks, QSortThenBy> {
  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenByLastUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenByLimpezaMaquinaVoltas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limpezaMaquinaVoltas', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenByLimpezaMaquinaVoltasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limpezaMaquinaVoltas', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenByLimpezaMaquinaVoltasBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limpezaMaquinaVoltasBy', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenByLimpezaMaquinaVoltasByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limpezaMaquinaVoltasBy', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenByServiceWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceWeek', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenByServiceWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceWeek', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenByVerificar1a() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar1a', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenByVerificar1aDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar1a', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenByVerificar1aBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar1aBy', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenByVerificar1aByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar1aBy', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenByVerificar1aCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar1aCount', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenByVerificar1aCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar1aCount', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenByVerificar4a() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar4a', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenByVerificar4aDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar4a', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy> thenByVerificar4aBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar4aBy', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenByVerificar4aByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar4aBy', Sort.desc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenByVerificar4aCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar4aCount', Sort.asc);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QAfterSortBy>
  thenByVerificar4aCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificar4aCount', Sort.desc);
    });
  }
}

extension WeeklyTasksQueryWhereDistinct
    on QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct> {
  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct>
  distinctByBackdatedTaskKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backdatedTaskKeys');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct> distinctByLastUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdatedAt');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct>
  distinctByLimpezaMaquinaVoltas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'limpezaMaquinaVoltas');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct>
  distinctByLimpezaMaquinaVoltasBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'limpezaMaquinaVoltasBy',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct>
  distinctByLimpezaMaquinaVoltasByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'limpezaMaquinaVoltasByNames');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct> distinctByServiceWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceWeek');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct> distinctBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDeletedAt');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct> distinctBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUpdatedAt');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct> distinctBySyncUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct> distinctByVerificar1a() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificar1a');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct> distinctByVerificar1aBy({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'verificar1aBy',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct>
  distinctByVerificar1aByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificar1aByNames');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct>
  distinctByVerificar1aCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificar1aCount');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct> distinctByVerificar4a() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificar4a');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct> distinctByVerificar4aBy({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'verificar4aBy',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct>
  distinctByVerificar4aByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificar4aByNames');
    });
  }

  QueryBuilder<WeeklyTasks, WeeklyTasks, QDistinct>
  distinctByVerificar4aCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificar4aCount');
    });
  }
}

extension WeeklyTasksQueryProperty
    on QueryBuilder<WeeklyTasks, WeeklyTasks, QQueryProperty> {
  QueryBuilder<WeeklyTasks, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WeeklyTasks, List<String>, QQueryOperations>
  backdatedTaskKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backdatedTaskKeys');
    });
  }

  QueryBuilder<WeeklyTasks, DateTime?, QQueryOperations>
  lastUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdatedAt');
    });
  }

  QueryBuilder<WeeklyTasks, bool, QQueryOperations>
  limpezaMaquinaVoltasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'limpezaMaquinaVoltas');
    });
  }

  QueryBuilder<WeeklyTasks, String?, QQueryOperations>
  limpezaMaquinaVoltasByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'limpezaMaquinaVoltasBy');
    });
  }

  QueryBuilder<WeeklyTasks, List<String>, QQueryOperations>
  limpezaMaquinaVoltasByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'limpezaMaquinaVoltasByNames');
    });
  }

  QueryBuilder<WeeklyTasks, DateTime, QQueryOperations> serviceWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceWeek');
    });
  }

  QueryBuilder<WeeklyTasks, DateTime?, QQueryOperations>
  syncDeletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDeletedAt');
    });
  }

  QueryBuilder<WeeklyTasks, DateTime, QQueryOperations>
  syncUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUpdatedAt');
    });
  }

  QueryBuilder<WeeklyTasks, String, QQueryOperations> syncUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUuid');
    });
  }

  QueryBuilder<WeeklyTasks, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<WeeklyTasks, bool, QQueryOperations> verificar1aProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificar1a');
    });
  }

  QueryBuilder<WeeklyTasks, String?, QQueryOperations> verificar1aByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificar1aBy');
    });
  }

  QueryBuilder<WeeklyTasks, List<String>, QQueryOperations>
  verificar1aByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificar1aByNames');
    });
  }

  QueryBuilder<WeeklyTasks, int, QQueryOperations> verificar1aCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificar1aCount');
    });
  }

  QueryBuilder<WeeklyTasks, bool, QQueryOperations> verificar4aProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificar4a');
    });
  }

  QueryBuilder<WeeklyTasks, String?, QQueryOperations> verificar4aByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificar4aBy');
    });
  }

  QueryBuilder<WeeklyTasks, List<String>, QQueryOperations>
  verificar4aByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificar4aByNames');
    });
  }

  QueryBuilder<WeeklyTasks, int, QQueryOperations> verificar4aCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificar4aCount');
    });
  }
}
