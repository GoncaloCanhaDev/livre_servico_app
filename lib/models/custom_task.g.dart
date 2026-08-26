// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_task.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCustomTaskCollection on Isar {
  IsarCollection<CustomTask> get customTasks => this.collection();
}

const CustomTaskSchema = CollectionSchema(
  name: r'CustomTask',
  id: -8649036648097859085,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'frequency': PropertySchema(
      id: 1,
      name: r'frequency',
      type: IsarType.byte,
      enumMap: _CustomTaskfrequencyEnumValueMap,
    ),
    r'inputType': PropertySchema(
      id: 2,
      name: r'inputType',
      type: IsarType.byte,
      enumMap: _CustomTaskinputTypeEnumValueMap,
    ),
    r'syncDeletedAt': PropertySchema(
      id: 3,
      name: r'syncDeletedAt',
      type: IsarType.dateTime,
    ),
    r'syncUpdatedAt': PropertySchema(
      id: 4,
      name: r'syncUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'syncUuid': PropertySchema(
      id: 5,
      name: r'syncUuid',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 6, name: r'synced', type: IsarType.bool),
    r'title': PropertySchema(id: 7, name: r'title', type: IsarType.string),
  },

  estimateSize: _customTaskEstimateSize,
  serialize: _customTaskSerialize,
  deserialize: _customTaskDeserialize,
  deserializeProp: _customTaskDeserializeProp,
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

  getId: _customTaskGetId,
  getLinks: _customTaskGetLinks,
  attach: _customTaskAttach,
  version: '3.3.2',
);

int _customTaskEstimateSize(
  CustomTask object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.syncUuid.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _customTaskSerialize(
  CustomTask object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeByte(offsets[1], object.frequency.index);
  writer.writeByte(offsets[2], object.inputType.index);
  writer.writeDateTime(offsets[3], object.syncDeletedAt);
  writer.writeDateTime(offsets[4], object.syncUpdatedAt);
  writer.writeString(offsets[5], object.syncUuid);
  writer.writeBool(offsets[6], object.synced);
  writer.writeString(offsets[7], object.title);
}

CustomTask _customTaskDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CustomTask();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.frequency =
      _CustomTaskfrequencyValueEnumMap[reader.readByteOrNull(offsets[1])] ??
      CustomTaskFrequency.daily;
  object.id = id;
  object.inputType =
      _CustomTaskinputTypeValueEnumMap[reader.readByteOrNull(offsets[2])] ??
      CustomTaskInputType.simple;
  object.syncDeletedAt = reader.readDateTimeOrNull(offsets[3]);
  object.syncUpdatedAt = reader.readDateTime(offsets[4]);
  object.syncUuid = reader.readString(offsets[5]);
  object.synced = reader.readBool(offsets[6]);
  object.title = reader.readString(offsets[7]);
  return object;
}

P _customTaskDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (_CustomTaskfrequencyValueEnumMap[reader.readByteOrNull(offset)] ??
              CustomTaskFrequency.daily)
          as P;
    case 2:
      return (_CustomTaskinputTypeValueEnumMap[reader.readByteOrNull(offset)] ??
              CustomTaskInputType.simple)
          as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CustomTaskfrequencyEnumValueMap = {'daily': 0, 'weekly': 1, 'oneOff': 2};
const _CustomTaskfrequencyValueEnumMap = {
  0: CustomTaskFrequency.daily,
  1: CustomTaskFrequency.weekly,
  2: CustomTaskFrequency.oneOff,
};
const _CustomTaskinputTypeEnumValueMap = {'simple': 0, 'count': 1};
const _CustomTaskinputTypeValueEnumMap = {
  0: CustomTaskInputType.simple,
  1: CustomTaskInputType.count,
};

Id _customTaskGetId(CustomTask object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _customTaskGetLinks(CustomTask object) {
  return [];
}

void _customTaskAttach(IsarCollection<dynamic> col, Id id, CustomTask object) {
  object.id = id;
}

extension CustomTaskQueryWhereSort
    on QueryBuilder<CustomTask, CustomTask, QWhere> {
  QueryBuilder<CustomTask, CustomTask, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CustomTaskQueryWhere
    on QueryBuilder<CustomTask, CustomTask, QWhereClause> {
  QueryBuilder<CustomTask, CustomTask, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<CustomTask, CustomTask, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterWhereClause> idBetween(
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

  QueryBuilder<CustomTask, CustomTask, QAfterWhereClause> syncUuidEqualTo(
    String syncUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncUuid', value: [syncUuid]),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterWhereClause> syncUuidNotEqualTo(
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

extension CustomTaskQueryFilter
    on QueryBuilder<CustomTask, CustomTask, QFilterCondition> {
  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> frequencyEqualTo(
    CustomTaskFrequency value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'frequency', value: value),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
  frequencyGreaterThan(CustomTaskFrequency value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'frequency',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> frequencyLessThan(
    CustomTaskFrequency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'frequency',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> frequencyBetween(
    CustomTaskFrequency lower,
    CustomTaskFrequency upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'frequency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> inputTypeEqualTo(
    CustomTaskInputType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'inputType', value: value),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
  inputTypeGreaterThan(CustomTaskInputType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'inputType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> inputTypeLessThan(
    CustomTaskInputType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'inputType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> inputTypeBetween(
    CustomTaskInputType lower,
    CustomTaskInputType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'inputType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
  syncDeletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
  syncDeletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
  syncDeletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncDeletedAt', value: value),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
  syncUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> syncUuidEqualTo(
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> syncUuidLessThan(
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> syncUuidBetween(
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> syncUuidEndsWith(
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> syncUuidContains(
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> syncUuidMatches(
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

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
  syncUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
  syncUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }
}

extension CustomTaskQueryObject
    on QueryBuilder<CustomTask, CustomTask, QFilterCondition> {}

extension CustomTaskQueryLinks
    on QueryBuilder<CustomTask, CustomTask, QFilterCondition> {}

extension CustomTaskQuerySortBy
    on QueryBuilder<CustomTask, CustomTask, QSortBy> {
  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortByInputType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputType', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortByInputTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputType', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension CustomTaskQuerySortThenBy
    on QueryBuilder<CustomTask, CustomTask, QSortThenBy> {
  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenByInputType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputType', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenByInputTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inputType', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension CustomTaskQueryWhereDistinct
    on QueryBuilder<CustomTask, CustomTask, QDistinct> {
  QueryBuilder<CustomTask, CustomTask, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CustomTask, CustomTask, QDistinct> distinctByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequency');
    });
  }

  QueryBuilder<CustomTask, CustomTask, QDistinct> distinctByInputType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inputType');
    });
  }

  QueryBuilder<CustomTask, CustomTask, QDistinct> distinctBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDeletedAt');
    });
  }

  QueryBuilder<CustomTask, CustomTask, QDistinct> distinctBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUpdatedAt');
    });
  }

  QueryBuilder<CustomTask, CustomTask, QDistinct> distinctBySyncUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CustomTask, CustomTask, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<CustomTask, CustomTask, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension CustomTaskQueryProperty
    on QueryBuilder<CustomTask, CustomTask, QQueryProperty> {
  QueryBuilder<CustomTask, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CustomTask, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CustomTask, CustomTaskFrequency, QQueryOperations>
  frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequency');
    });
  }

  QueryBuilder<CustomTask, CustomTaskInputType, QQueryOperations>
  inputTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inputType');
    });
  }

  QueryBuilder<CustomTask, DateTime?, QQueryOperations>
  syncDeletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDeletedAt');
    });
  }

  QueryBuilder<CustomTask, DateTime, QQueryOperations> syncUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUpdatedAt');
    });
  }

  QueryBuilder<CustomTask, String, QQueryOperations> syncUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUuid');
    });
  }

  QueryBuilder<CustomTask, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<CustomTask, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCustomTaskEntryCollection on Isar {
  IsarCollection<CustomTaskEntry> get customTaskEntrys => this.collection();
}

const CustomTaskEntrySchema = CollectionSchema(
  name: r'CustomTaskEntry',
  id: 3034950442465323444,
  properties: {
    r'backdated': PropertySchema(
      id: 0,
      name: r'backdated',
      type: IsarType.bool,
    ),
    r'count': PropertySchema(id: 1, name: r'count', type: IsarType.long),
    r'done': PropertySchema(id: 2, name: r'done', type: IsarType.bool),
    r'doneAt': PropertySchema(id: 3, name: r'doneAt', type: IsarType.dateTime),
    r'doneBy': PropertySchema(id: 4, name: r'doneBy', type: IsarType.string),
    r'doneByNames': PropertySchema(
      id: 5,
      name: r'doneByNames',
      type: IsarType.stringList,
    ),
    r'periodKey': PropertySchema(
      id: 6,
      name: r'periodKey',
      type: IsarType.dateTime,
    ),
    r'syncDeletedAt': PropertySchema(
      id: 7,
      name: r'syncDeletedAt',
      type: IsarType.dateTime,
    ),
    r'syncUpdatedAt': PropertySchema(
      id: 8,
      name: r'syncUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'syncUuid': PropertySchema(
      id: 9,
      name: r'syncUuid',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 10, name: r'synced', type: IsarType.bool),
    r'taskUuid': PropertySchema(
      id: 11,
      name: r'taskUuid',
      type: IsarType.string,
    ),
  },

  estimateSize: _customTaskEntryEstimateSize,
  serialize: _customTaskEntrySerialize,
  deserialize: _customTaskEntryDeserialize,
  deserializeProp: _customTaskEntryDeserializeProp,
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
    r'taskUuid': IndexSchema(
      id: -2843492851132056829,
      name: r'taskUuid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'taskUuid',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'periodKey': IndexSchema(
      id: 1168583613613626778,
      name: r'periodKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'periodKey',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _customTaskEntryGetId,
  getLinks: _customTaskEntryGetLinks,
  attach: _customTaskEntryAttach,
  version: '3.3.2',
);

int _customTaskEntryEstimateSize(
  CustomTaskEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.doneBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.doneByNames.length * 3;
  {
    for (var i = 0; i < object.doneByNames.length; i++) {
      final value = object.doneByNames[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.syncUuid.length * 3;
  bytesCount += 3 + object.taskUuid.length * 3;
  return bytesCount;
}

void _customTaskEntrySerialize(
  CustomTaskEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.backdated);
  writer.writeLong(offsets[1], object.count);
  writer.writeBool(offsets[2], object.done);
  writer.writeDateTime(offsets[3], object.doneAt);
  writer.writeString(offsets[4], object.doneBy);
  writer.writeStringList(offsets[5], object.doneByNames);
  writer.writeDateTime(offsets[6], object.periodKey);
  writer.writeDateTime(offsets[7], object.syncDeletedAt);
  writer.writeDateTime(offsets[8], object.syncUpdatedAt);
  writer.writeString(offsets[9], object.syncUuid);
  writer.writeBool(offsets[10], object.synced);
  writer.writeString(offsets[11], object.taskUuid);
}

CustomTaskEntry _customTaskEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CustomTaskEntry();
  object.backdated = reader.readBool(offsets[0]);
  object.count = reader.readLongOrNull(offsets[1]);
  object.done = reader.readBool(offsets[2]);
  object.doneAt = reader.readDateTimeOrNull(offsets[3]);
  object.doneBy = reader.readStringOrNull(offsets[4]);
  object.doneByNames = reader.readStringList(offsets[5]) ?? [];
  object.id = id;
  object.periodKey = reader.readDateTime(offsets[6]);
  object.syncDeletedAt = reader.readDateTimeOrNull(offsets[7]);
  object.syncUpdatedAt = reader.readDateTime(offsets[8]);
  object.syncUuid = reader.readString(offsets[9]);
  object.synced = reader.readBool(offsets[10]);
  object.taskUuid = reader.readString(offsets[11]);
  return object;
}

P _customTaskEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _customTaskEntryGetId(CustomTaskEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _customTaskEntryGetLinks(CustomTaskEntry object) {
  return [];
}

void _customTaskEntryAttach(
  IsarCollection<dynamic> col,
  Id id,
  CustomTaskEntry object,
) {
  object.id = id;
}

extension CustomTaskEntryQueryWhereSort
    on QueryBuilder<CustomTaskEntry, CustomTaskEntry, QWhere> {
  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhere> anyPeriodKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'periodKey'),
      );
    });
  }
}

extension CustomTaskEntryQueryWhere
    on QueryBuilder<CustomTaskEntry, CustomTaskEntry, QWhereClause> {
  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause> idBetween(
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause>
  syncUuidEqualTo(String syncUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncUuid', value: [syncUuid]),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause>
  taskUuidEqualTo(String taskUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'taskUuid', value: [taskUuid]),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause>
  taskUuidNotEqualTo(String taskUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'taskUuid',
                lower: [],
                upper: [taskUuid],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'taskUuid',
                lower: [taskUuid],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'taskUuid',
                lower: [taskUuid],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'taskUuid',
                lower: [],
                upper: [taskUuid],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause>
  periodKeyEqualTo(DateTime periodKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'periodKey', value: [periodKey]),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause>
  periodKeyNotEqualTo(DateTime periodKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'periodKey',
                lower: [],
                upper: [periodKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'periodKey',
                lower: [periodKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'periodKey',
                lower: [periodKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'periodKey',
                lower: [],
                upper: [periodKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause>
  periodKeyGreaterThan(DateTime periodKey, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'periodKey',
          lower: [periodKey],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause>
  periodKeyLessThan(DateTime periodKey, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'periodKey',
          lower: [],
          upper: [periodKey],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterWhereClause>
  periodKeyBetween(
    DateTime lowerPeriodKey,
    DateTime upperPeriodKey, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'periodKey',
          lower: [lowerPeriodKey],
          includeLower: includeLower,
          upper: [upperPeriodKey],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CustomTaskEntryQueryFilter
    on QueryBuilder<CustomTaskEntry, CustomTaskEntry, QFilterCondition> {
  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  backdatedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'backdated', value: value),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  countIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'count'),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  countIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'count'),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  countEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'count', value: value),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  countGreaterThan(int? value, {bool include = false}) {
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  countLessThan(int? value, {bool include = false}) {
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  countBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'done', value: value),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'doneAt'),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'doneAt'),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'doneAt', value: value),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'doneAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'doneAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'doneAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'doneBy'),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'doneBy'),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'doneBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'doneBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'doneBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'doneBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'doneBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'doneBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'doneBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'doneBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'doneBy', value: ''),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'doneBy', value: ''),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'doneByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'doneByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'doneByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'doneByNames',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'doneByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'doneByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'doneByNames',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'doneByNames',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'doneByNames', value: ''),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'doneByNames', value: ''),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'doneByNames', length, true, length, true);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'doneByNames', 0, true, 0, true);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'doneByNames', 0, false, 999999, true);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'doneByNames', 0, true, length, include);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'doneByNames', length, include, 999999, true);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  doneByNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'doneByNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  periodKeyEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'periodKey', value: value),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  periodKeyGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'periodKey',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  periodKeyLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'periodKey',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  periodKeyBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'periodKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  syncDeletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  syncDeletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  syncDeletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncDeletedAt', value: value),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  syncUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
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

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  syncUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  syncUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  taskUuidEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'taskUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  taskUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'taskUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  taskUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'taskUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  taskUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'taskUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  taskUuidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'taskUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  taskUuidEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'taskUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  taskUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'taskUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  taskUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'taskUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  taskUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'taskUuid', value: ''),
      );
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterFilterCondition>
  taskUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'taskUuid', value: ''),
      );
    });
  }
}

extension CustomTaskEntryQueryObject
    on QueryBuilder<CustomTaskEntry, CustomTaskEntry, QFilterCondition> {}

extension CustomTaskEntryQueryLinks
    on QueryBuilder<CustomTaskEntry, CustomTaskEntry, QFilterCondition> {}

extension CustomTaskEntryQuerySortBy
    on QueryBuilder<CustomTaskEntry, CustomTaskEntry, QSortBy> {
  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortByBackdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdated', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortByBackdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdated', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy> sortByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy> sortByDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'done', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortByDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'done', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy> sortByDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneAt', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortByDoneAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneAt', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy> sortByDoneBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneBy', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortByDoneByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneBy', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortByPeriodKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodKey', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortByPeriodKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodKey', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortByTaskUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskUuid', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  sortByTaskUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskUuid', Sort.desc);
    });
  }
}

extension CustomTaskEntryQuerySortThenBy
    on QueryBuilder<CustomTaskEntry, CustomTaskEntry, QSortThenBy> {
  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenByBackdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdated', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenByBackdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'backdated', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy> thenByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy> thenByDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'done', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenByDoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'done', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy> thenByDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneAt', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenByDoneAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneAt', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy> thenByDoneBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneBy', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenByDoneByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doneBy', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenByPeriodKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodKey', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenByPeriodKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodKey', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenByTaskUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskUuid', Sort.asc);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QAfterSortBy>
  thenByTaskUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskUuid', Sort.desc);
    });
  }
}

extension CustomTaskEntryQueryWhereDistinct
    on QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct> {
  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct>
  distinctByBackdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'backdated');
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct> distinctByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'count');
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct> distinctByDone() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'done');
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct> distinctByDoneAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'doneAt');
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct> distinctByDoneBy({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'doneBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct>
  distinctByDoneByNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'doneByNames');
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct>
  distinctByPeriodKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodKey');
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct>
  distinctBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDeletedAt');
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct>
  distinctBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUpdatedAt');
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct> distinctBySyncUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<CustomTaskEntry, CustomTaskEntry, QDistinct> distinctByTaskUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskUuid', caseSensitive: caseSensitive);
    });
  }
}

extension CustomTaskEntryQueryProperty
    on QueryBuilder<CustomTaskEntry, CustomTaskEntry, QQueryProperty> {
  QueryBuilder<CustomTaskEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CustomTaskEntry, bool, QQueryOperations> backdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'backdated');
    });
  }

  QueryBuilder<CustomTaskEntry, int?, QQueryOperations> countProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'count');
    });
  }

  QueryBuilder<CustomTaskEntry, bool, QQueryOperations> doneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'done');
    });
  }

  QueryBuilder<CustomTaskEntry, DateTime?, QQueryOperations> doneAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'doneAt');
    });
  }

  QueryBuilder<CustomTaskEntry, String?, QQueryOperations> doneByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'doneBy');
    });
  }

  QueryBuilder<CustomTaskEntry, List<String>, QQueryOperations>
  doneByNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'doneByNames');
    });
  }

  QueryBuilder<CustomTaskEntry, DateTime, QQueryOperations>
  periodKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodKey');
    });
  }

  QueryBuilder<CustomTaskEntry, DateTime?, QQueryOperations>
  syncDeletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDeletedAt');
    });
  }

  QueryBuilder<CustomTaskEntry, DateTime, QQueryOperations>
  syncUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUpdatedAt');
    });
  }

  QueryBuilder<CustomTaskEntry, String, QQueryOperations> syncUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUuid');
    });
  }

  QueryBuilder<CustomTaskEntry, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<CustomTaskEntry, String, QQueryOperations> taskUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskUuid');
    });
  }
}
