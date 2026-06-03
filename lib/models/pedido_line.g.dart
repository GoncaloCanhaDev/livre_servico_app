// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido_line.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPedidoLineCollection on Isar {
  IsarCollection<PedidoLine> get pedidoLines => this.collection();
}

const PedidoLineSchema = CollectionSchema(
  name: r'PedidoLine',
  id: -2489104862575969980,
  properties: {
    r'caixas': PropertySchema(id: 0, name: r'caixas', type: IsarType.long),
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

  estimateSize: _pedidoLineEstimateSize,
  serialize: _pedidoLineSerialize,
  deserialize: _pedidoLineDeserialize,
  deserializeProp: _pedidoLineDeserializeProp,
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

  getId: _pedidoLineGetId,
  getLinks: _pedidoLineGetLinks,
  attach: _pedidoLineAttach,
  version: '3.3.2',
);

int _pedidoLineEstimateSize(
  PedidoLine object,
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

void _pedidoLineSerialize(
  PedidoLine object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.caixas);
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

PedidoLine _pedidoLineDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PedidoLine();
  object.caixas = reader.readLong(offsets[0]);
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

P _pedidoLineDeserializeProp<P>(
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

Id _pedidoLineGetId(PedidoLine object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pedidoLineGetLinks(PedidoLine object) {
  return [];
}

void _pedidoLineAttach(IsarCollection<dynamic> col, Id id, PedidoLine object) {
  object.id = id;
}

extension PedidoLineQueryWhereSort
    on QueryBuilder<PedidoLine, PedidoLine, QWhere> {
  QueryBuilder<PedidoLine, PedidoLine, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PedidoLineQueryWhere
    on QueryBuilder<PedidoLine, PedidoLine, QWhereClause> {
  QueryBuilder<PedidoLine, PedidoLine, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterWhereClause> idBetween(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterWhereClause> syncUuidEqualTo(
    String syncUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncUuid', value: [syncUuid]),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterWhereClause> syncUuidNotEqualTo(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterWhereClause> parentUuidEqualTo(
    String parentUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'parentUuid', value: [parentUuid]),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterWhereClause> parentUuidNotEqualTo(
    String parentUuid,
  ) {
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterWhereClause> eanEqualTo(
    String ean,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ean', value: [ean]),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterWhereClause> eanNotEqualTo(
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

extension PedidoLineQueryFilter
    on QueryBuilder<PedidoLine, PedidoLine, QFilterCondition> {
  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> caixasEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'caixas', value: value),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> caixasGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'caixas',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> caixasLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'caixas',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> caixasBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'caixas',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  createdByInitialsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'createdByInitials'),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  createdByInitialsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'createdByInitials'),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  createdByInitialsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdByInitials', value: ''),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  createdByInitialsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'createdByInitials', value: ''),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> eanEqualTo(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> eanGreaterThan(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> eanLessThan(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> eanBetween(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> eanStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> eanEndsWith(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> eanContains(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> eanMatches(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> eanIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ean', value: ''),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> eanIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ean', value: ''),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> parentUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> parentUuidBetween(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> parentUuidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  parentUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parentUuid', value: ''),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  parentUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'parentUuid', value: ''),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  productNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'productName'),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  productNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'productName'),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  productNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'productName', value: ''),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  productNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'productName', value: ''),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  syncDeletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  syncDeletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  syncDeletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncDeletedAt', value: value),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  syncUpdatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> syncUuidEqualTo(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> syncUuidLessThan(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> syncUuidBetween(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> syncUuidEndsWith(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> syncUuidContains(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> syncUuidMatches(
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  syncUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
  syncUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition>
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<PedidoLine, PedidoLine, QAfterFilterCondition> updatedAtBetween(
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

extension PedidoLineQueryObject
    on QueryBuilder<PedidoLine, PedidoLine, QFilterCondition> {}

extension PedidoLineQueryLinks
    on QueryBuilder<PedidoLine, PedidoLine, QFilterCondition> {}

extension PedidoLineQuerySortBy
    on QueryBuilder<PedidoLine, PedidoLine, QSortBy> {
  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByCaixas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caixas', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByCaixasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caixas', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByCreatedByInitials() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy>
  sortByCreatedByInitialsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByEan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ean', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByEanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ean', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByParentUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentUuid', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByParentUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentUuid', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PedidoLineQuerySortThenBy
    on QueryBuilder<PedidoLine, PedidoLine, QSortThenBy> {
  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByCaixas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caixas', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByCaixasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caixas', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByCreatedByInitials() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy>
  thenByCreatedByInitialsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByInitials', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByEan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ean', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByEanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ean', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByParentUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentUuid', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByParentUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentUuid', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByProductName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByProductNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productName', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PedidoLineQueryWhereDistinct
    on QueryBuilder<PedidoLine, PedidoLine, QDistinct> {
  QueryBuilder<PedidoLine, PedidoLine, QDistinct> distinctByCaixas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caixas');
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QDistinct> distinctByCreatedByInitials({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'createdByInitials',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QDistinct> distinctByEan({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ean', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QDistinct> distinctByParentUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QDistinct> distinctByProductName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QDistinct> distinctBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDeletedAt');
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QDistinct> distinctBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUpdatedAt');
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QDistinct> distinctBySyncUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<PedidoLine, PedidoLine, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PedidoLineQueryProperty
    on QueryBuilder<PedidoLine, PedidoLine, QQueryProperty> {
  QueryBuilder<PedidoLine, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PedidoLine, int, QQueryOperations> caixasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caixas');
    });
  }

  QueryBuilder<PedidoLine, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PedidoLine, String?, QQueryOperations>
  createdByInitialsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByInitials');
    });
  }

  QueryBuilder<PedidoLine, String, QQueryOperations> eanProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ean');
    });
  }

  QueryBuilder<PedidoLine, String, QQueryOperations> parentUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentUuid');
    });
  }

  QueryBuilder<PedidoLine, String?, QQueryOperations> productNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productName');
    });
  }

  QueryBuilder<PedidoLine, DateTime?, QQueryOperations>
  syncDeletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDeletedAt');
    });
  }

  QueryBuilder<PedidoLine, DateTime, QQueryOperations> syncUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUpdatedAt');
    });
  }

  QueryBuilder<PedidoLine, String, QQueryOperations> syncUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUuid');
    });
  }

  QueryBuilder<PedidoLine, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<PedidoLine, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
