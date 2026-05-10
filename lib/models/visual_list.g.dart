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
    r'beneficioCents': PropertySchema(
      id: 0,
      name: r'beneficioCents',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'itensPicados': PropertySchema(
      id: 2,
      name: r'itensPicados',
      type: IsarType.long,
    ),
    r'quebraCents': PropertySchema(
      id: 3,
      name: r'quebraCents',
      type: IsarType.long,
    ),
    r'serviceDay': PropertySchema(
      id: 4,
      name: r'serviceDay',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _visualListEstimateSize,
  serialize: _visualListSerialize,
  deserialize: _visualListDeserialize,
  deserializeProp: _visualListDeserializeProp,
  idName: r'id',
  indexes: {
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
  return bytesCount;
}

void _visualListSerialize(
  VisualList object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.beneficioCents);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.itensPicados);
  writer.writeLong(offsets[3], object.quebraCents);
  writer.writeDateTime(offsets[4], object.serviceDay);
}

VisualList _visualListDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VisualList();
  object.beneficioCents = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.itensPicados = reader.readLong(offsets[2]);
  object.quebraCents = reader.readLong(offsets[3]);
  object.serviceDay = reader.readDateTime(offsets[4]);
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
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
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
}

extension VisualListQueryObject
    on QueryBuilder<VisualList, VisualList, QFilterCondition> {}

extension VisualListQueryLinks
    on QueryBuilder<VisualList, VisualList, QFilterCondition> {}

extension VisualListQuerySortBy
    on QueryBuilder<VisualList, VisualList, QSortBy> {
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
}

extension VisualListQuerySortThenBy
    on QueryBuilder<VisualList, VisualList, QSortThenBy> {
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
}

extension VisualListQueryWhereDistinct
    on QueryBuilder<VisualList, VisualList, QDistinct> {
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
}

extension VisualListQueryProperty
    on QueryBuilder<VisualList, VisualList, QQueryProperty> {
  QueryBuilder<VisualList, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
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
}
