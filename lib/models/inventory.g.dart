// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInventoryCollection on Isar {
  IsarCollection<Inventory> get inventorys => this.collection();
}

const InventorySchema = CollectionSchema(
  name: r'Inventory',
  id: 9013770421438767579,
  properties: {
    r'accumulatedSeconds': PropertySchema(
      id: 0,
      name: r'accumulatedSeconds',
      type: IsarType.long,
    ),
    r'code': PropertySchema(id: 1, name: r'code', type: IsarType.string),
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
    r'finalValueCents': PropertySchema(
      id: 4,
      name: r'finalValueCents',
      type: IsarType.long,
    ),
    r'finishedAt': PropertySchema(
      id: 5,
      name: r'finishedAt',
      type: IsarType.dateTime,
    ),
    r'isFinalized': PropertySchema(
      id: 6,
      name: r'isFinalized',
      type: IsarType.bool,
    ),
    r'isLegacy': PropertySchema(id: 7, name: r'isLegacy', type: IsarType.bool),
    r'isPaused': PropertySchema(id: 8, name: r'isPaused', type: IsarType.bool),
    r'isRunning': PropertySchema(
      id: 9,
      name: r'isRunning',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(id: 10, name: r'name', type: IsarType.string),
    r'runningSince': PropertySchema(
      id: 11,
      name: r'runningSince',
      type: IsarType.dateTime,
    ),
    r'startedAt': PropertySchema(
      id: 12,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'syncDeletedAt': PropertySchema(
      id: 13,
      name: r'syncDeletedAt',
      type: IsarType.dateTime,
    ),
    r'syncUpdatedAt': PropertySchema(
      id: 14,
      name: r'syncUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'syncUuid': PropertySchema(
      id: 15,
      name: r'syncUuid',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 16, name: r'synced', type: IsarType.bool),
    r'valueCents': PropertySchema(
      id: 17,
      name: r'valueCents',
      type: IsarType.long,
    ),
  },

  estimateSize: _inventoryEstimateSize,
  serialize: _inventorySerialize,
  deserialize: _inventoryDeserialize,
  deserializeProp: _inventoryDeserializeProp,
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
  },
  links: {},
  embeddedSchemas: {},

  getId: _inventoryGetId,
  getLinks: _inventoryGetLinks,
  attach: _inventoryAttach,
  version: '3.3.2',
);

int _inventoryEstimateSize(
  Inventory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.code;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.createdByInitials;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.syncUuid.length * 3;
  return bytesCount;
}

void _inventorySerialize(
  Inventory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.accumulatedSeconds);
  writer.writeString(offsets[1], object.code);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.createdByInitials);
  writer.writeLong(offsets[4], object.finalValueCents);
  writer.writeDateTime(offsets[5], object.finishedAt);
  writer.writeBool(offsets[6], object.isFinalized);
  writer.writeBool(offsets[7], object.isLegacy);
  writer.writeBool(offsets[8], object.isPaused);
  writer.writeBool(offsets[9], object.isRunning);
  writer.writeString(offsets[10], object.name);
  writer.writeDateTime(offsets[11], object.runningSince);
  writer.writeDateTime(offsets[12], object.startedAt);
  writer.writeDateTime(offsets[13], object.syncDeletedAt);
  writer.writeDateTime(offsets[14], object.syncUpdatedAt);
  writer.writeString(offsets[15], object.syncUuid);
  writer.writeBool(offsets[16], object.synced);
  writer.writeLong(offsets[17], object.valueCents);
}

Inventory _inventoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Inventory();
  object.accumulatedSeconds = reader.readLong(offsets[0]);
  object.code = reader.readStringOrNull(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.createdByInitials = reader.readStringOrNull(offsets[3]);
  object.finalValueCents = reader.readLongOrNull(offsets[4]);
  object.finishedAt = reader.readDateTimeOrNull(offsets[5]);
  object.id = id;
  object.name = reader.readString(offsets[10]);
  object.runningSince = reader.readDateTimeOrNull(offsets[11]);
  object.startedAt = reader.readDateTimeOrNull(offsets[12]);
  object.syncDeletedAt = reader.readDateTimeOrNull(offsets[13]);
  object.syncUpdatedAt = reader.readDateTime(offsets[14]);
  object.syncUuid = reader.readString(offsets[15]);
  object.synced = reader.readBool(offsets[16]);
  object.valueCents = reader.readLong(offsets[17]);
  return object;
}

P _inventoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inventoryGetId(Inventory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inventoryGetLinks(Inventory object) {
  return [];
}

void _inventoryAttach(IsarCollection<dynamic> col, Id id, Inventory object) {
  object.id = id;
}

extension InventoryQueryWhereSort
    on QueryBuilder<Inventory, Inventory, QWhere> {
  QueryBuilder<Inventory, Inventory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InventoryQueryWhere
    on QueryBuilder<Inventory, Inventory, QWhereClause> {
  QueryBuilder<Inventory, Inventory, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Inventory, Inventory, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterWhereClause> idBetween(
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

  QueryBuilder<Inventory, Inventory, QAfterWhereClause> syncUuidEqualTo(
    String syncUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncUuid', value: [syncUuid]),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterWhereClause> syncUuidNotEqualTo(
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
}

extension InventoryQueryFilter
    on QueryBuilder<Inventory, Inventory, QFilterCondition> {
  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  accumulatedSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accumulatedSeconds', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  accumulatedSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'accumulatedSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  accumulatedSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'accumulatedSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  accumulatedSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'accumulatedSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> codeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'code'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> codeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'code'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> codeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'code',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> codeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'code',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> codeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'code',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> codeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'code',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> codeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'code',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> codeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'code',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> codeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'code',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> codeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'code',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> codeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'code', value: ''),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> codeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'code', value: ''),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  createdByInitialsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdByInitials'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  createdByInitialsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdByInitials'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  createdByInitialsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdByInitials', value: ''),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  createdByInitialsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'createdByInitials', value: ''),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  finalValueCentsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'finalValueCents'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  finalValueCentsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'finalValueCents'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  finalValueCentsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'finalValueCents', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  finalValueCentsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'finalValueCents',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  finalValueCentsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'finalValueCents',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  finalValueCentsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'finalValueCents',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> finishedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'finishedAt'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  finishedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'finishedAt'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> finishedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'finishedAt', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  finishedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'finishedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> finishedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'finishedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> finishedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'finishedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> isFinalizedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isFinalized', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> isLegacyEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isLegacy', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> isPausedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isPaused', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> isRunningEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isRunning', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  runningSinceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'runningSince'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  runningSinceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'runningSince'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> runningSinceEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'runningSince', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  runningSinceGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'runningSince',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  runningSinceLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'runningSince',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> runningSinceBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'runningSince',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> startedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'startedAt'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  startedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'startedAt'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> startedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  startedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> startedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> startedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  syncDeletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  syncDeletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  syncDeletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncDeletedAt', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  syncUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> syncUuidEqualTo(
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> syncUuidGreaterThan(
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> syncUuidLessThan(
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> syncUuidBetween(
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> syncUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> syncUuidEndsWith(
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> syncUuidContains(
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> syncUuidMatches(
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

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> syncUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  syncUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> valueCentsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'valueCents', value: value),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition>
  valueCentsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'valueCents',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> valueCentsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'valueCents',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterFilterCondition> valueCentsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'valueCents',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension InventoryQueryObject
    on QueryBuilder<Inventory, Inventory, QFilterCondition> {}

extension InventoryQueryLinks
    on QueryBuilder<Inventory, Inventory, QFilterCondition> {}

extension InventoryQuerySortBy on QueryBuilder<Inventory, Inventory, QSortBy> {
  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByAccumulatedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accumulatedSeconds', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy>
  sortByAccumulatedSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accumulatedSeconds', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByCreatedByInitials() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy>
  sortByCreatedByInitialsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByFinalValueCents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalValueCents', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByFinalValueCentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalValueCents', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByFinishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByIsFinalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinalized', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByIsFinalizedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinalized', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByIsLegacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLegacy', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByIsLegacyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLegacy', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByIsPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByIsRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRunning', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByIsRunningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRunning', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByRunningSince() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runningSince', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByRunningSinceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runningSince', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByValueCents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valueCents', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> sortByValueCentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valueCents', Sort.desc);
    });
  }
}

extension InventoryQuerySortThenBy
    on QueryBuilder<Inventory, Inventory, QSortThenBy> {
  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByAccumulatedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accumulatedSeconds', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy>
  thenByAccumulatedSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accumulatedSeconds', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByCreatedByInitials() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy>
  thenByCreatedByInitialsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByFinalValueCents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalValueCents', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByFinalValueCentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalValueCents', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByFinishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedAt', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByIsFinalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinalized', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByIsFinalizedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinalized', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByIsLegacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLegacy', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByIsLegacyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLegacy', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByIsPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByIsRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRunning', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByIsRunningDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRunning', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByRunningSince() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runningSince', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByRunningSinceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runningSince', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByValueCents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valueCents', Sort.asc);
    });
  }

  QueryBuilder<Inventory, Inventory, QAfterSortBy> thenByValueCentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valueCents', Sort.desc);
    });
  }
}

extension InventoryQueryWhereDistinct
    on QueryBuilder<Inventory, Inventory, QDistinct> {
  QueryBuilder<Inventory, Inventory, QDistinct> distinctByAccumulatedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accumulatedSeconds');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByCode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'code', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByCreatedByInitials({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'createdByInitials',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByFinalValueCents() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finalValueCents');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByFinishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finishedAt');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByIsFinalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFinalized');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByIsLegacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLegacy');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPaused');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByIsRunning() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRunning');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByRunningSince() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'runningSince');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDeletedAt');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUpdatedAt');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctBySyncUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<Inventory, Inventory, QDistinct> distinctByValueCents() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'valueCents');
    });
  }
}

extension InventoryQueryProperty
    on QueryBuilder<Inventory, Inventory, QQueryProperty> {
  QueryBuilder<Inventory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Inventory, int, QQueryOperations> accumulatedSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accumulatedSeconds');
    });
  }

  QueryBuilder<Inventory, String?, QQueryOperations> codeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'code');
    });
  }

  QueryBuilder<Inventory, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Inventory, String?, QQueryOperations>
  createdByInitialsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByInitials');
    });
  }

  QueryBuilder<Inventory, int?, QQueryOperations> finalValueCentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finalValueCents');
    });
  }

  QueryBuilder<Inventory, DateTime?, QQueryOperations> finishedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finishedAt');
    });
  }

  QueryBuilder<Inventory, bool, QQueryOperations> isFinalizedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFinalized');
    });
  }

  QueryBuilder<Inventory, bool, QQueryOperations> isLegacyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLegacy');
    });
  }

  QueryBuilder<Inventory, bool, QQueryOperations> isPausedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPaused');
    });
  }

  QueryBuilder<Inventory, bool, QQueryOperations> isRunningProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRunning');
    });
  }

  QueryBuilder<Inventory, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Inventory, DateTime?, QQueryOperations> runningSinceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'runningSince');
    });
  }

  QueryBuilder<Inventory, DateTime?, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<Inventory, DateTime?, QQueryOperations> syncDeletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDeletedAt');
    });
  }

  QueryBuilder<Inventory, DateTime, QQueryOperations> syncUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUpdatedAt');
    });
  }

  QueryBuilder<Inventory, String, QQueryOperations> syncUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUuid');
    });
  }

  QueryBuilder<Inventory, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<Inventory, int, QQueryOperations> valueCentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'valueCents');
    });
  }
}
