// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_line.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInventoryLineCollection on Isar {
  IsarCollection<InventoryLine> get inventoryLines => this.collection();
}

const InventoryLineSchema = CollectionSchema(
  name: r'InventoryLine',
  id: 6190652310993660851,
  properties: {
    r'count': PropertySchema(id: 0, name: r'count', type: IsarType.long),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdByInitials': PropertySchema(
      id: 2,
      name: r'createdByInitials',
      type: IsarType.string,
    ),
    r'ean': PropertySchema(id: 3, name: r'ean', type: IsarType.string),
    r'parentUuid': PropertySchema(
      id: 4,
      name: r'parentUuid',
      type: IsarType.string,
    ),
    r'productName': PropertySchema(
      id: 5,
      name: r'productName',
      type: IsarType.string,
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
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _inventoryLineEstimateSize,
  serialize: _inventoryLineSerialize,
  deserialize: _inventoryLineDeserialize,
  deserializeProp: _inventoryLineDeserializeProp,
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
    r'parentUuid': IndexSchema(
      id: -1046607046339657543,
      name: r'parentUuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'parentUuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'ean': IndexSchema(
      id: 470098543478402927,
      name: r'ean',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ean',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _inventoryLineGetId,
  getLinks: _inventoryLineGetLinks,
  attach: _inventoryLineAttach,
  version: '3.3.2',
);

int _inventoryLineEstimateSize(
  InventoryLine object,
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
  bytesCount += 3 + object.ean.length * 3;
  bytesCount += 3 + object.parentUuid.length * 3;
  {
    final value = object.productName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncUuid.length * 3;
  return bytesCount;
}

void _inventoryLineSerialize(
  InventoryLine object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.count);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.createdByInitials);
  writer.writeString(offsets[3], object.ean);
  writer.writeString(offsets[4], object.parentUuid);
  writer.writeString(offsets[5], object.productName);
  writer.writeDateTime(offsets[6], object.syncDeletedAt);
  writer.writeDateTime(offsets[7], object.syncUpdatedAt);
  writer.writeString(offsets[8], object.syncUuid);
  writer.writeBool(offsets[9], object.synced);
  writer.writeDateTime(offsets[10], object.updatedAt);
}

InventoryLine _inventoryLineDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventoryLine();
  object.count = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.createdByInitials = reader.readStringOrNull(offsets[2]);
  object.ean = reader.readString(offsets[3]);
  object.id = id;
  object.parentUuid = reader.readString(offsets[4]);
  object.productName = reader.readStringOrNull(offsets[5]);
  object.syncDeletedAt = reader.readDateTimeOrNull(offsets[6]);
  object.syncUpdatedAt = reader.readDateTime(offsets[7]);
  object.syncUuid = reader.readString(offsets[8]);
  object.synced = reader.readBool(offsets[9]);
  object.updatedAt = reader.readDateTime(offsets[10]);
  return object;
}

P _inventoryLineDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inventoryLineGetId(InventoryLine object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inventoryLineGetLinks(InventoryLine object) {
  return [];
}

void _inventoryLineAttach(
  IsarCollection<dynamic> col,
  Id id,
  InventoryLine object,
) {
  object.id = id;
}

extension InventoryLineQueryWhereSort
    on QueryBuilder<InventoryLine, InventoryLine, QWhere> {
  QueryBuilder<InventoryLine, InventoryLine, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InventoryLineQueryWhere
    on QueryBuilder<InventoryLine, InventoryLine, QWhereClause> {
  QueryBuilder<InventoryLine, InventoryLine, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterWhereClause> idBetween(
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterWhereClause> syncUuidEqualTo(
    String syncUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncUuid', value: [syncUuid]),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterWhereClause>
  syncUuidNotEqualTo(String syncUuid) {
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterWhereClause>
  parentUuidEqualTo(String parentUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'parentUuid', value: [parentUuid]),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterWhereClause>
  parentUuidNotEqualTo(String parentUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentUuid',
                lower: [],
                upper: [parentUuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentUuid',
                lower: [parentUuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentUuid',
                lower: [parentUuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentUuid',
                lower: [],
                upper: [parentUuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterWhereClause> eanEqualTo(
    String ean,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ean', value: [ean]),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterWhereClause> eanNotEqualTo(
    String ean,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ean',
                lower: [],
                upper: [ean],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ean',
                lower: [ean],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ean',
                lower: [ean],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ean',
                lower: [],
                upper: [ean],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension InventoryLineQueryFilter
    on QueryBuilder<InventoryLine, InventoryLine, QFilterCondition> {
  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  countEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'count', value: value),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  countGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'count',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  countLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'count',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  countBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'count',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  createdAtBetween(
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  createdByInitialsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdByInitials'),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  createdByInitialsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdByInitials'),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  createdByInitialsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdByInitials', value: ''),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  createdByInitialsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'createdByInitials', value: ''),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition> eanEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ean',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  eanGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ean',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition> eanLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ean',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition> eanBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ean',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  eanStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ean',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition> eanEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ean',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition> eanContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ean',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition> eanMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ean',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  eanIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ean', value: ''),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  eanIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ean', value: ''),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition> idBetween(
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  parentUuidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'parentUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  parentUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parentUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  parentUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parentUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  parentUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parentUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  parentUuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'parentUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  parentUuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'parentUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  parentUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'parentUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  parentUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'parentUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  parentUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parentUuid', value: ''),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  parentUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'parentUuid', value: ''),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  productNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'productName'),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  productNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'productName'),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  productNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'productName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  productNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'productName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  productNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'productName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  productNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'productName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  productNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'productName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  productNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'productName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  productNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'productName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  productNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'productName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  productNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'productName', value: ''),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  productNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'productName', value: ''),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  syncDeletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  syncDeletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  syncDeletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncDeletedAt', value: value),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  syncUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  syncUuidEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  syncUuidBetween(
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  syncUuidMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  syncUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  syncUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension InventoryLineQueryObject
    on QueryBuilder<InventoryLine, InventoryLine, QFilterCondition> {}

extension InventoryLineQueryLinks
    on QueryBuilder<InventoryLine, InventoryLine, QFilterCondition> {}

extension InventoryLineQuerySortBy
    on QueryBuilder<InventoryLine, InventoryLine, QSortBy> {
  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> sortByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> sortByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  sortByCreatedByInitials() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  sortByCreatedByInitialsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> sortByEan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ean', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> sortByEanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ean', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> sortByParentUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentUuid', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  sortByParentUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentUuid', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> sortByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  sortByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  sortBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  sortBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  sortBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  sortBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> sortBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  sortBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension InventoryLineQuerySortThenBy
    on QueryBuilder<InventoryLine, InventoryLine, QSortThenBy> {
  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  thenByCreatedByInitials() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  thenByCreatedByInitialsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenByEan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ean', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenByEanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ean', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenByParentUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentUuid', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  thenByParentUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentUuid', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  thenByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  thenBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  thenBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  thenBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  thenBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  thenBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension InventoryLineQueryWhereDistinct
    on QueryBuilder<InventoryLine, InventoryLine, QDistinct> {
  QueryBuilder<InventoryLine, InventoryLine, QDistinct> distinctByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'count');
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QDistinct>
  distinctByCreatedByInitials({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'createdByInitials',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QDistinct> distinctByEan({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ean', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QDistinct> distinctByParentUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QDistinct> distinctByProductName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QDistinct>
  distinctBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDeletedAt');
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QDistinct>
  distinctBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUpdatedAt');
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QDistinct> distinctBySyncUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<InventoryLine, InventoryLine, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension InventoryLineQueryProperty
    on QueryBuilder<InventoryLine, InventoryLine, QQueryProperty> {
  QueryBuilder<InventoryLine, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InventoryLine, int, QQueryOperations> countProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'count');
    });
  }

  QueryBuilder<InventoryLine, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InventoryLine, String?, QQueryOperations>
  createdByInitialsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByInitials');
    });
  }

  QueryBuilder<InventoryLine, String, QQueryOperations> eanProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ean');
    });
  }

  QueryBuilder<InventoryLine, String, QQueryOperations> parentUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentUuid');
    });
  }

  QueryBuilder<InventoryLine, String?, QQueryOperations> productNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productName');
    });
  }

  QueryBuilder<InventoryLine, DateTime?, QQueryOperations>
  syncDeletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDeletedAt');
    });
  }

  QueryBuilder<InventoryLine, DateTime, QQueryOperations>
  syncUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUpdatedAt');
    });
  }

  QueryBuilder<InventoryLine, String, QQueryOperations> syncUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUuid');
    });
  }

  QueryBuilder<InventoryLine, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<InventoryLine, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
