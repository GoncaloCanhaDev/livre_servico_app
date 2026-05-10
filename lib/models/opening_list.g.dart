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
    r'congelados': PropertySchema(
      id: 0,
      name: r'congelados',
      type: IsarType.long,
    ),
    r'finalizedAt': PropertySchema(
      id: 1,
      name: r'finalizedAt',
      type: IsarType.dateTime,
    ),
    r'isFinalized': PropertySchema(
      id: 2,
      name: r'isFinalized',
      type: IsarType.bool,
    ),
    r'naoPereciveis': PropertySchema(
      id: 3,
      name: r'naoPereciveis',
      type: IsarType.long,
    ),
    r'opls': PropertySchema(id: 4, name: r'opls', type: IsarType.long),
    r'serviceDay': PropertySchema(
      id: 5,
      name: r'serviceDay',
      type: IsarType.dateTime,
    ),
    r'total': PropertySchema(id: 6, name: r'total', type: IsarType.long),
  },

  estimateSize: _openingListEstimateSize,
  serialize: _openingListSerialize,
  deserialize: _openingListDeserialize,
  deserializeProp: _openingListDeserializeProp,
  idName: r'id',
  indexes: {
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
  return bytesCount;
}

void _openingListSerialize(
  OpeningList object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.congelados);
  writer.writeDateTime(offsets[1], object.finalizedAt);
  writer.writeBool(offsets[2], object.isFinalized);
  writer.writeLong(offsets[3], object.naoPereciveis);
  writer.writeLong(offsets[4], object.opls);
  writer.writeDateTime(offsets[5], object.serviceDay);
  writer.writeLong(offsets[6], object.total);
}

OpeningList _openingListDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OpeningList();
  object.congelados = reader.readLong(offsets[0]);
  object.finalizedAt = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.naoPereciveis = reader.readLong(offsets[3]);
  object.opls = reader.readLong(offsets[4]);
  object.serviceDay = reader.readDateTime(offsets[5]);
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
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
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
  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByCongelados() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'congelados');
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

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByOpls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'opls');
    });
  }

  QueryBuilder<OpeningList, OpeningList, QDistinct> distinctByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceDay');
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

  QueryBuilder<OpeningList, int, QQueryOperations> congeladosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'congelados');
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

  QueryBuilder<OpeningList, int, QQueryOperations> oplsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'opls');
    });
  }

  QueryBuilder<OpeningList, DateTime, QQueryOperations> serviceDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceDay');
    });
  }

  QueryBuilder<OpeningList, int, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }
}
