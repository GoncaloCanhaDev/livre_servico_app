// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opening_list.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOpeningListCollection on Isar {
  IsarCollection<OpeningList> get openingLists => this.collection();
}

const OpeningListSchema = CollectionSchema(
  name: r'OpeningList',
  id: -1264859112631077036,
  properties: {
    r'backdated': PropertySchema(
      id: 0,
      name: r'backdated',
      type: IsarType.bool,
    ),
    r'congelados': PropertySchema(
      id: 1,
      name: r'congelados',
      type: IsarType.long,
    ),
    r'congeladosByNames': PropertySchema(
      id: 2,
      name: r'congeladosByNames',
      type: IsarType.stringList,
    ),
    r'congeladosDoneAt': PropertySchema(
      id: 3,
      name: r'congeladosDoneAt',
      type: IsarType.dateTime,
    ),
    r'createdByInitials': PropertySchema(
      id: 4,
      name: r'createdByInitials',
      type: IsarType.string,
    ),
    r'createdByNames': PropertySchema(
      id: 5,
      name: r'createdByNames',
      type: IsarType.stringList,
    ),
    r'finalizedAt': PropertySchema(
      id: 6,
      name: r'finalizedAt',
      type: IsarType.dateTime,
    ),
    r'isFinalized': PropertySchema(
      id: 7,
      name: r'isFinalized',
      type: IsarType.bool,
    ),
    r'naoPereciveis': PropertySchema(
      id: 8,
      name: r'naoPereciveis',
      type: IsarType.long,
    ),
    r'naoPereciveisByNames': PropertySchema(
      id: 9,
      name: r'naoPereciveisByNames',
      type: IsarType.stringList,
    ),
    r'naoPereciveisDoneAt': PropertySchema(
      id: 10,
      name: r'naoPereciveisDoneAt',
      type: IsarType.dateTime,
    ),
    r'opls': PropertySchema(id: 11, name: r'opls', type: IsarType.long),
    r'oplsByNames': PropertySchema(
      id: 12,
      name: r'oplsByNames',
      type: IsarType.stringList,
    ),
    r'oplsDoneAt': PropertySchema(
      id: 13,
      name: r'oplsDoneAt',
      type: IsarType.dateTime,
    ),
    r'serviceDay': PropertySchema(
      id: 14,
      name: r'serviceDay',
      type: IsarType.dateTime,
    ),
    r'syncDeletedAt': PropertySchema(
      id: 15,
      name: r'syncDeletedAt',
      type: IsarType.dateTime,
    ),
    r'syncUpdatedAt': PropertySchema(
      id: 16,
      name: r'syncUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'syncUuid': PropertySchema(
      id: 17,
      name: r'syncUuid',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 18, name: r'synced', type: IsarType.bool),
    r'total': PropertySchema(id: 19, name: r'total', type: IsarType.long),
  },

  estimateSize: _openingListEstimateSize,
  serialize: _openingListSerialize,
  deserialize: _openingListDeserialize,
  deserializeProp: _openingListDeserializeProp,
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

  getId: _openingListGetId,
  getLinks: _openingListGetLinks,
  attach: _openingListAttach,
  version: '3.3.2',
);

int _openingListEstimateSize(
  OpeningList object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.congeladosByNames.length * 3;
  {
    for (var i = 0; i < object.congeladosByNames.length; i++) {
      final value = object.congeladosByNames[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.createdByInitials;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.createdByNames.length * 3;
  {
    for (var i = 0; i < object.createdByNames.length; i++) {
      final value = object.createdByNames[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.naoPereciveisByNames.length * 3;
  {
    for (var i = 0; i < object.naoPereciveisByNames.length; i++) {
      final value = object.naoPereciveisByNames[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.oplsByNames.length * 3;
  {
    for (var i = 0; i < object.oplsByNames.length; i++) {
      final value = object.oplsByNames[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.syncUuid.length * 3;
  return bytesCount;
}

void _openingListSerialize(
  OpeningList object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.backdated);
  writer.writeLong(offsets[1], object.congelados);
  writer.writeStringList(offsets[2], object.congeladosByNames);
  writer.writeDateTime(offsets[3], object.congeladosDoneAt);
  writer.writeString(offsets[4], object.createdByInitials);
  writer.writeStringList(offsets[5], object.createdByNames);
  writer.writeDateTime(offsets[6], object.finalizedAt);
  writer.writeBool(offsets[7], object.isFinalized);
  writer.writeLong(offsets[8], object.naoPereciveis);
  writer.writeStringList(offsets[9], object.naoPereciveisByNames);
  writer.writeDateTime(offsets[10], object.naoPereciveisDoneAt);
  writer.writeLong(offsets[11], object.opls);
  writer.writeStringList(offsets[12], object.oplsByNames);
  writer.writeDateTime(offsets[13], object.oplsDoneAt);
  writer.writeDateTime(offsets[14], object.serviceDay);
  writer.writeDateTime(offsets[15], object.syncDeletedAt);
  writer.writeDateTime(offsets[16], object.syncUpdatedAt);
  writer.writeString(offsets[17], object.syncUuid);
  writer.writeBool(offsets[18], object.synced);
  writer.writeLong(offsets[19], object.total);
}

OpeningList _openingListDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OpeningList();
  object.backdated = reader.readBool(offsets[0]);
  object.congelados = reader.readLong(offsets[1]);
  object.congeladosByNames = reader.readStringList(offsets[2]) ?? [];
  object.congeladosDoneAt = reader.readDateTimeOrNull(offsets[3]);
  object.createdByInitials = reader.readStringOrNull(offsets[4]);
  object.createdByNames = reader.readStringList(offsets[5]) ?? [];
  object.finalizedAt = reader.readDateTimeOrNull(offsets[6]);
  object.id = id;
  object.naoPereciveis = reader.readLong(offsets[8]);
  object.naoPereciveisByNames = reader.readStringList(offsets[9]) ?? [];
  object.naoPereciveisDoneAt = reader.readDateTimeOrNull(offsets[10]);
  object.opls = reader.readLong(offsets[11]);
  object.oplsByNames = reader.readStringList(offsets[12]) ?? [];
  object.oplsDoneAt = reader.readDateTimeOrNull(offsets[13]);
  object.serviceDay = reader.readDateTime(offsets[14]);
  object.syncDeletedAt = reader.readDateTimeOrNull(offsets[15]);
  object.syncUpdatedAt = reader.readDateTime(offsets[16]);
  object.syncUuid = reader.readString(offsets[17]);
  object.synced = reader.readBool(offsets[18]);
  return object;
}

P _openingListDeserializeProp<P>(
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
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readDateTime(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _openingListGetId(OpeningList object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _openingListGetLinks(OpeningList object) {
  return [];
}

void _openingListAttach(
  IsarCollection<dynamic> col,
  Id id,
  OpeningList object,
) {
  object.id = id;
}

extension OpeningListByIndex on IsarCollection<OpeningList> {
  Future<OpeningList?> getByServiceDay(DateTime serviceDay) {
    return getByIndex(r'serviceDay', [serviceDay]);
  }

  OpeningList? getByServiceDaySync(DateTime serviceDay) {
    return getByIndexSync(r'serviceDay', [serviceDay]);
  }

  Future<bool> deleteByServiceDay(DateTime serviceDay) {
    return deleteByIndex(r'serviceDay', [serviceDay]);
  }

  bool deleteByServiceDaySync(DateTime serviceDay) {
    return deleteByIndexSync(r'serviceDay', [serviceDay]);
  }

  Future<List<OpeningList?>> getAllByServiceDay(
    List<DateTime> serviceDayValues,
  ) {
    final values = serviceDayValues.map((e) => [e]).toList();
    return getAllByIndex(r'serviceDay', values);
  }

  List<OpeningList?> getAllByServiceDaySync(List<DateTime> serviceDayValues) {
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

  Future<Id> putByServiceDay(OpeningList object) {
    return putByIndex(r'serviceDay', object);
  }

  Id putByServiceDaySync(OpeningList object, {bool saveLinks = true}) {
    return putByIndexSync(r'serviceDay', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServiceDay(List<OpeningList> objects) {
    return putAllByIndex(r'serviceDay', objects);
  }

  List<Id> putAllByServiceDaySync(
    List<OpeningList> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'serviceDay', objects, saveLinks: saveLinks);
  }
}

extension OpeningListQueryWhereSort
    on QueryBuilder<OpeningList, OpeningList, QWhere> {
  QueryBuilder<OpeningList, OpeningList, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterWhere> anyServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'serviceDay'),
      );
    });
  }
}

extension OpeningListQueryWhere
    on QueryBuilder<OpeningList, OpeningList, QWhereClause> {
  QueryBuilder<OpeningList, OpeningList, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<OpeningList, OpeningList, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterWhereClause> idBetween(
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

  QueryBuilder<OpeningList, OpeningList, QAfterWhereClause> syncUuidEqualTo(
    String syncUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncUuid', value: [syncUuid]),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterWhereClause> syncUuidNotEqualTo(
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

  QueryBuilder<OpeningList, OpeningList, QAfterWhereClause> serviceDayEqualTo(
    DateTime serviceDay,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'serviceDay', value: [serviceDay]),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterWhereClause>
  serviceDayNotEqualTo(DateTime serviceDay) {
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

  QueryBuilder<OpeningList, OpeningList, QAfterWhereClause>
  serviceDayGreaterThan(DateTime serviceDay, {bool include = false}) {
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

  QueryBuilder<OpeningList, OpeningList, QAfterWhereClause> serviceDayLessThan(
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

  QueryBuilder<OpeningList, OpeningList, QAfterWhereClause> serviceDayBetween(
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

extension OpeningListQueryFilter
    on QueryBuilder<OpeningList, OpeningList, QFilterCondition> {
  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  backdatedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'backdated', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'congelados', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'congelados',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'congelados',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'congelados',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'congeladosByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'congeladosByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'congeladosByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'congeladosByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'congeladosByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'congeladosByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'congeladosByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'congeladosByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'congeladosByNames', value: ''),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'congeladosByNames', value: ''),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'congeladosByNames', length, true, length, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'congeladosByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'congeladosByNames', 0, false, 999999, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'congeladosByNames', 0, true, length, include);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'congeladosByNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'congeladosByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosDoneAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'congeladosDoneAt'),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosDoneAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'congeladosDoneAt'),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosDoneAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'congeladosDoneAt', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosDoneAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'congeladosDoneAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosDoneAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'congeladosDoneAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  congeladosDoneAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'congeladosDoneAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByInitialsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdByInitials'),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByInitialsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdByInitials'),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByInitialsEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'createdByInitials',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByInitialsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdByInitials',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByInitialsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdByInitials',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByInitialsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdByInitials',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByInitialsStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'createdByInitials',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByInitialsEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'createdByInitials',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByInitialsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'createdByInitials',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByInitialsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'createdByInitials',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByInitialsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdByInitials', value: ''),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByInitialsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'createdByInitials', value: ''),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'createdByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'createdByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'createdByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'createdByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'createdByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdByNames', value: ''),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'createdByNames', value: ''),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'createdByNames', length, true, length, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'createdByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'createdByNames', 0, false, 999999, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'createdByNames', 0, true, length, include);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'createdByNames', length, include, 999999, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  createdByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'createdByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  finalizedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'finalizedAt'),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  finalizedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'finalizedAt'),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  finalizedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'finalizedAt', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  finalizedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'finalizedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  finalizedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'finalizedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  finalizedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'finalizedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> idBetween(
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  isFinalizedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isFinalized', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'naoPereciveis', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'naoPereciveis',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'naoPereciveis',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'naoPereciveis',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'naoPereciveisByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'naoPereciveisByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'naoPereciveisByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'naoPereciveisByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'naoPereciveisByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'naoPereciveisByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'naoPereciveisByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'naoPereciveisByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'naoPereciveisByNames', value: ''),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'naoPereciveisByNames',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'naoPereciveisByNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'naoPereciveisByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'naoPereciveisByNames', 0, false, 999999, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'naoPereciveisByNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'naoPereciveisByNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'naoPereciveisByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisDoneAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'naoPereciveisDoneAt'),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisDoneAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'naoPereciveisDoneAt'),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisDoneAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'naoPereciveisDoneAt', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisDoneAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'naoPereciveisDoneAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisDoneAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'naoPereciveisDoneAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  naoPereciveisDoneAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'naoPereciveisDoneAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> oplsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'opls', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> oplsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'opls',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> oplsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'opls',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> oplsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'opls',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'oplsByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'oplsByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'oplsByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'oplsByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'oplsByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'oplsByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'oplsByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'oplsByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'oplsByNames', value: ''),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'oplsByNames', value: ''),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'oplsByNames', length, true, length, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'oplsByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'oplsByNames', 0, false, 999999, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'oplsByNames', 0, true, length, include);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'oplsByNames', length, include, 999999, true);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'oplsByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsDoneAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'oplsDoneAt'),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsDoneAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'oplsDoneAt'),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsDoneAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'oplsDoneAt', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsDoneAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'oplsDoneAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsDoneAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'oplsDoneAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  oplsDoneAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'oplsDoneAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  serviceDayEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serviceDay', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  serviceDayBetween(
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  syncDeletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  syncDeletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  syncDeletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncDeletedAt', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  syncUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> syncUuidEqualTo(
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> syncUuidBetween(
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> syncUuidMatches(
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

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  syncUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  syncUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> totalEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'total', value: value),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition>
  totalGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'total',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> totalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'total',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterFilterCondition> totalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'total',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension OpeningListQueryObject
    on QueryBuilder<OpeningList, OpeningList, QFilterCondition> {}

extension OpeningListQueryLinks
    on QueryBuilder<OpeningList, OpeningList, QFilterCondition> {}

extension OpeningListQuerySortBy
    on QueryBuilder<OpeningList, OpeningList, QSortBy> {
  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByBackdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdated', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByBackdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdated', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByCongelados() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'congelados', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByCongeladosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'congelados', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  sortByCongeladosDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'congeladosDoneAt', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  sortByCongeladosDoneAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'congeladosDoneAt', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  sortByCreatedByInitials() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  sortByCreatedByInitialsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByFinalizedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalizedAt', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByFinalizedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalizedAt', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByIsFinalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinalized', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByIsFinalizedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinalized', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByNaoPereciveis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'naoPereciveis', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  sortByNaoPereciveisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'naoPereciveis', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  sortByNaoPereciveisDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'naoPereciveisDoneAt', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  sortByNaoPereciveisDoneAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'naoPereciveisDoneAt', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByOpls() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opls', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByOplsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opls', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByOplsDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oplsDoneAt', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByOplsDoneAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oplsDoneAt', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByServiceDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  sortBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  sortBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension OpeningListQuerySortThenBy
    on QueryBuilder<OpeningList, OpeningList, QSortThenBy> {
  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByBackdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdated', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByBackdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdated', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByCongelados() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'congelados', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByCongeladosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'congelados', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  thenByCongeladosDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'congeladosDoneAt', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  thenByCongeladosDoneAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'congeladosDoneAt', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  thenByCreatedByInitials() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  thenByCreatedByInitialsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByFinalizedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalizedAt', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByFinalizedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalizedAt', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByIsFinalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinalized', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByIsFinalizedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinalized', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByNaoPereciveis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'naoPereciveis', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  thenByNaoPereciveisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'naoPereciveis', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  thenByNaoPereciveisDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'naoPereciveisDoneAt', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  thenByNaoPereciveisDoneAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'naoPereciveisDoneAt', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByOpls() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opls', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByOplsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'opls', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByOplsDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oplsDoneAt', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByOplsDoneAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oplsDoneAt', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByServiceDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  thenBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy>
  thenBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QAfterSortBy> thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension OpeningListQueryWhereDistinct
    on QueryBuilder<OpeningList, OpeningList, QDistinct> {
  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByBackdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backdated');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByCongelados() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'congelados');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct>
  distinctByCongeladosByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'congeladosByNames');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct>
  distinctByCongeladosDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'congeladosDoneAt');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct>
  distinctByCreatedByInitials({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'createdByInitials',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByCreatedByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdByNames');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByFinalizedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finalizedAt');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByIsFinalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFinalized');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByNaoPereciveis() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'naoPereciveis');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct>
  distinctByNaoPereciveisByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'naoPereciveisByNames');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct>
  distinctByNaoPereciveisDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'naoPereciveisDoneAt');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByOpls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'opls');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByOplsByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'oplsByNames');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByOplsDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'oplsDoneAt');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceDay');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDeletedAt');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUpdatedAt');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctBySyncUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }
}

extension OpeningListQueryProperty
    on QueryBuilder<OpeningList, OpeningList, QQueryProperty> {
  QueryBuilder<OpeningList, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OpeningList, bool, QQueryOperations> backdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backdated');
    });
  }

  QueryBuilder<OpeningList, int, QQueryOperations> congeladosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'congelados');
    });
  }

  QueryBuilder<OpeningList, List<String>, QQueryOperations>
  congeladosByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'congeladosByNames');
    });
  }

  QueryBuilder<OpeningList, DateTime?, QQueryOperations>
  congeladosDoneAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'congeladosDoneAt');
    });
  }

  QueryBuilder<OpeningList, String?, QQueryOperations>
  createdByInitialsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByInitials');
    });
  }

  QueryBuilder<OpeningList, List<String>, QQueryOperations>
  createdByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByNames');
    });
  }

  QueryBuilder<OpeningList, DateTime?, QQueryOperations> finalizedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finalizedAt');
    });
  }

  QueryBuilder<OpeningList, bool, QQueryOperations> isFinalizedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFinalized');
    });
  }

  QueryBuilder<OpeningList, int, QQueryOperations> naoPereciveisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'naoPereciveis');
    });
  }

  QueryBuilder<OpeningList, List<String>, QQueryOperations>
  naoPereciveisByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'naoPereciveisByNames');
    });
  }

  QueryBuilder<OpeningList, DateTime?, QQueryOperations>
  naoPereciveisDoneAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'naoPereciveisDoneAt');
    });
  }

  QueryBuilder<OpeningList, int, QQueryOperations> oplsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'opls');
    });
  }

  QueryBuilder<OpeningList, List<String>, QQueryOperations>
  oplsByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'oplsByNames');
    });
  }

  QueryBuilder<OpeningList, DateTime?, QQueryOperations> oplsDoneAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'oplsDoneAt');
    });
  }

  QueryBuilder<OpeningList, DateTime, QQueryOperations> serviceDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceDay');
    });
  }

  QueryBuilder<OpeningList, DateTime?, QQueryOperations>
  syncDeletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDeletedAt');
    });
  }

  QueryBuilder<OpeningList, DateTime, QQueryOperations>
  syncUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUpdatedAt');
    });
  }

  QueryBuilder<OpeningList, String, QQueryOperations> syncUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUuid');
    });
  }

  QueryBuilder<OpeningList, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<OpeningList, int, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }
}
