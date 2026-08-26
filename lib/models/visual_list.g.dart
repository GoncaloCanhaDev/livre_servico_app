// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_list.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVisualListCollection on Isar {
  IsarCollection<VisualList> get visualLists => this.collection();
}

const VisualListSchema = CollectionSchema(
  name: r'VisualList',
  id: 5448947017900679418,
  properties: {
    r'backdated': PropertySchema(
      id: 0,
      name: r'backdated',
      type: IsarType.bool,
    ),
    r'beneficioCents': PropertySchema(
      id: 1,
      name: r'beneficioCents',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdByInitials': PropertySchema(
      id: 3,
      name: r'createdByInitials',
      type: IsarType.string,
    ),
    r'createdByNames': PropertySchema(
      id: 4,
      name: r'createdByNames',
      type: IsarType.stringList,
    ),
    r'itensPicados': PropertySchema(
      id: 5,
      name: r'itensPicados',
      type: IsarType.long,
    ),
    r'quebraCents': PropertySchema(
      id: 6,
      name: r'quebraCents',
      type: IsarType.long,
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
  },

  estimateSize: _visualListEstimateSize,
  serialize: _visualListSerialize,
  deserialize: _visualListDeserialize,
  deserializeProp: _visualListDeserializeProp,
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
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'serviceDay': IndexSchema(
      id: -114834928129556000,
      name: r'serviceDay',
      unique: false,
      replace: false,
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

  getId: _visualListGetId,
  getLinks: _visualListGetLinks,
  attach: _visualListAttach,
  version: '3.3.2',
);

int _visualListEstimateSize(
  VisualList object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
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
  bytesCount += 3 + object.syncUuid.length * 3;
  return bytesCount;
}

void _visualListSerialize(
  VisualList object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.backdated);
  writer.writeLong(offsets[1], object.beneficioCents);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.createdByInitials);
  writer.writeStringList(offsets[4], object.createdByNames);
  writer.writeLong(offsets[5], object.itensPicados);
  writer.writeLong(offsets[6], object.quebraCents);
  writer.writeDateTime(offsets[7], object.serviceDay);
  writer.writeDateTime(offsets[8], object.syncDeletedAt);
  writer.writeDateTime(offsets[9], object.syncUpdatedAt);
  writer.writeString(offsets[10], object.syncUuid);
  writer.writeBool(offsets[11], object.synced);
}

VisualList _visualListDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VisualList();
  object.backdated = reader.readBool(offsets[0]);
  object.beneficioCents = reader.readLong(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.createdByInitials = reader.readStringOrNull(offsets[3]);
  object.createdByNames = reader.readStringList(offsets[4]) ?? [];
  object.id = id;
  object.itensPicados = reader.readLong(offsets[5]);
  object.quebraCents = reader.readLong(offsets[6]);
  object.serviceDay = reader.readDateTime(offsets[7]);
  object.syncDeletedAt = reader.readDateTimeOrNull(offsets[8]);
  object.syncUpdatedAt = reader.readDateTime(offsets[9]);
  object.syncUuid = reader.readString(offsets[10]);
  object.synced = reader.readBool(offsets[11]);
  return object;
}

P _visualListDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _visualListGetId(VisualList object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _visualListGetLinks(VisualList object) {
  return [];
}

void _visualListAttach(IsarCollection<dynamic> col, Id id, VisualList object) {
  object.id = id;
}

extension VisualListQueryWhereSort
    on QueryBuilder<VisualList, VisualList, QWhere> {
  QueryBuilder<VisualList, VisualList, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterWhere> anyServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'serviceDay'),
      );
    });
  }
}

extension VisualListQueryWhere
    on QueryBuilder<VisualList, VisualList, QWhereClause> {
  QueryBuilder<VisualList, VisualList, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> idBetween(
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

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> syncUuidEqualTo(
    String syncUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncUuid', value: [syncUuid]),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> syncUuidNotEqualTo(
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

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> createdAtEqualTo(
    DateTime createdAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'createdAt', value: [createdAt]),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> createdAtNotEqualTo(
    DateTime createdAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [createdAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'createdAt',
                lower: [],
                upper: [createdAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [createdAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [],
          upper: [createdAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'createdAt',
          lower: [lowerCreatedAt],
          includeLower: includeLower,
          upper: [upperCreatedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> serviceDayEqualTo(
    DateTime serviceDay,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'serviceDay', value: [serviceDay]),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> serviceDayNotEqualTo(
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

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> serviceDayGreaterThan(
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

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> serviceDayLessThan(
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

  QueryBuilder<VisualList, VisualList, QAfterWhereClause> serviceDayBetween(
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

extension VisualListQueryFilter
    on QueryBuilder<VisualList, VisualList, QFilterCondition> {
  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> backdatedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'backdated', value: value),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  beneficioCentsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'beneficioCents', value: value),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  beneficioCentsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'beneficioCents',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  beneficioCentsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'beneficioCents',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  beneficioCentsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'beneficioCents',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  createdByInitialsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdByInitials'),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  createdByInitialsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdByInitials'),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  createdByInitialsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdByInitials', value: ''),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  createdByInitialsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'createdByInitials', value: ''),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  createdByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdByNames', value: ''),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  createdByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'createdByNames', value: ''),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  createdByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'createdByNames', length, true, length, true);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  createdByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'createdByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  createdByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'createdByNames', 0, false, 999999, true);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  createdByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'createdByNames', 0, true, length, include);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  createdByNamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'createdByNames', length, include, 999999, true);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  itensPicadosEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itensPicados', value: value),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  itensPicadosGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itensPicados',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  itensPicadosLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itensPicados',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  itensPicadosBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itensPicados',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  quebraCentsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quebraCents', value: value),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  quebraCentsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quebraCents',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  quebraCentsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quebraCents',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  quebraCentsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quebraCents',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> serviceDayEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serviceDay', value: value),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> serviceDayBetween(
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  syncDeletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  syncDeletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  syncDeletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncDeletedAt', value: value),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  syncUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> syncUuidEqualTo(
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> syncUuidLessThan(
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> syncUuidBetween(
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> syncUuidEndsWith(
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> syncUuidContains(
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> syncUuidMatches(
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

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  syncUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition>
  syncUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }
}

extension VisualListQueryObject
    on QueryBuilder<VisualList, VisualList, QFilterCondition> {}

extension VisualListQueryLinks
    on QueryBuilder<VisualList, VisualList, QFilterCondition> {}

extension VisualListQuerySortBy
    on QueryBuilder<VisualList, VisualList, QSortBy> {
  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortByBackdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdated', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortByBackdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdated', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortByBeneficioCents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beneficioCents', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy>
  sortByBeneficioCentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beneficioCents', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortByCreatedByInitials() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy>
  sortByCreatedByInitialsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortByItensPicados() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPicados', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortByItensPicadosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPicados', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortByQuebraCents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quebraCents', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortByQuebraCentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quebraCents', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortByServiceDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }
}

extension VisualListQuerySortThenBy
    on QueryBuilder<VisualList, VisualList, QSortThenBy> {
  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByBackdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdated', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByBackdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdated', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByBeneficioCents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beneficioCents', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy>
  thenByBeneficioCentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beneficioCents', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByCreatedByInitials() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy>
  thenByCreatedByInitialsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByItensPicados() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPicados', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByItensPicadosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPicados', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByQuebraCents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quebraCents', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByQuebraCentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quebraCents', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenByServiceDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<VisualList, VisualList, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }
}

extension VisualListQueryWhereDistinct
    on QueryBuilder<VisualList, VisualList, QDistinct> {
  QueryBuilder<VisualList, VisualList, QDistinct> distinctByBackdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backdated');
    });
  }

  QueryBuilder<VisualList, VisualList, QDistinct> distinctByBeneficioCents() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'beneficioCents');
    });
  }

  QueryBuilder<VisualList, VisualList, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<VisualList, VisualList, QDistinct> distinctByCreatedByInitials({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'createdByInitials',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<VisualList, VisualList, QDistinct> distinctByCreatedByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdByNames');
    });
  }

  QueryBuilder<VisualList, VisualList, QDistinct> distinctByItensPicados() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itensPicados');
    });
  }

  QueryBuilder<VisualList, VisualList, QDistinct> distinctByQuebraCents() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quebraCents');
    });
  }

  QueryBuilder<VisualList, VisualList, QDistinct> distinctByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceDay');
    });
  }

  QueryBuilder<VisualList, VisualList, QDistinct> distinctBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDeletedAt');
    });
  }

  QueryBuilder<VisualList, VisualList, QDistinct> distinctBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUpdatedAt');
    });
  }

  QueryBuilder<VisualList, VisualList, QDistinct> distinctBySyncUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisualList, VisualList, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }
}

extension VisualListQueryProperty
    on QueryBuilder<VisualList, VisualList, QQueryProperty> {
  QueryBuilder<VisualList, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VisualList, bool, QQueryOperations> backdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backdated');
    });
  }

  QueryBuilder<VisualList, int, QQueryOperations> beneficioCentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'beneficioCents');
    });
  }

  QueryBuilder<VisualList, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<VisualList, String?, QQueryOperations>
  createdByInitialsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByInitials');
    });
  }

  QueryBuilder<VisualList, List<String>, QQueryOperations>
  createdByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByNames');
    });
  }

  QueryBuilder<VisualList, int, QQueryOperations> itensPicadosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itensPicados');
    });
  }

  QueryBuilder<VisualList, int, QQueryOperations> quebraCentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quebraCents');
    });
  }

  QueryBuilder<VisualList, DateTime, QQueryOperations> serviceDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceDay');
    });
  }

  QueryBuilder<VisualList, DateTime?, QQueryOperations>
  syncDeletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDeletedAt');
    });
  }

  QueryBuilder<VisualList, DateTime, QQueryOperations> syncUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUpdatedAt');
    });
  }

  QueryBuilder<VisualList, String, QQueryOperations> syncUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUuid');
    });
  }

  QueryBuilder<VisualList, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }
}
