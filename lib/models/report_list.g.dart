// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_list.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReportListCollection on Isar {
  IsarCollection<ReportList> get reportLists => this.collection();
}

const ReportListSchema = CollectionSchema(
  name: r'ReportList',
  id: 282802983348313683,
  properties: {
    r'diasSemVendas': PropertySchema(
      id: 0,
      name: r'diasSemVendas',
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
    r'massiva': PropertySchema(id: 3, name: r'massiva', type: IsarType.long),
    r'regularizacoes': PropertySchema(
      id: 4,
      name: r'regularizacoes',
      type: IsarType.long,
    ),
    r'repetidos': PropertySchema(
      id: 5,
      name: r'repetidos',
      type: IsarType.long,
    ),
    r'serviceDay': PropertySchema(
      id: 6,
      name: r'serviceDay',
      type: IsarType.dateTime,
    ),
    r'total': PropertySchema(id: 7, name: r'total', type: IsarType.long),
  },

  estimateSize: _reportListEstimateSize,
  serialize: _reportListSerialize,
  deserialize: _reportListDeserialize,
  deserializeProp: _reportListDeserializeProp,
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

  getId: _reportListGetId,
  getLinks: _reportListGetLinks,
  attach: _reportListAttach,
  version: '3.3.2',
);

int _reportListEstimateSize(
  ReportList object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _reportListSerialize(
  ReportList object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.diasSemVendas);
  writer.writeDateTime(offsets[1], object.finalizedAt);
  writer.writeBool(offsets[2], object.isFinalized);
  writer.writeLong(offsets[3], object.massiva);
  writer.writeLong(offsets[4], object.regularizacoes);
  writer.writeLong(offsets[5], object.repetidos);
  writer.writeDateTime(offsets[6], object.serviceDay);
  writer.writeLong(offsets[7], object.total);
}

ReportList _reportListDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReportList();
  object.diasSemVendas = reader.readLong(offsets[0]);
  object.finalizedAt = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.massiva = reader.readLong(offsets[3]);
  object.regularizacoes = reader.readLong(offsets[4]);
  object.repetidos = reader.readLong(offsets[5]);
  object.serviceDay = reader.readDateTime(offsets[6]);
  return object;
}

P _reportListDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _reportListGetId(ReportList object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _reportListGetLinks(ReportList object) {
  return [];
}

void _reportListAttach(IsarCollection<dynamic> col, Id id, ReportList object) {
  object.id = id;
}

extension ReportListByIndex on IsarCollection<ReportList> {
  Future<ReportList?> getByServiceDay(DateTime serviceDay) {
    return getByIndex(r'serviceDay', [serviceDay]);
  }

  ReportList? getByServiceDaySync(DateTime serviceDay) {
    return getByIndexSync(r'serviceDay', [serviceDay]);
  }

  Future<bool> deleteByServiceDay(DateTime serviceDay) {
    return deleteByIndex(r'serviceDay', [serviceDay]);
  }

  bool deleteByServiceDaySync(DateTime serviceDay) {
    return deleteByIndexSync(r'serviceDay', [serviceDay]);
  }

  Future<List<ReportList?>> getAllByServiceDay(
    List<DateTime> serviceDayValues,
  ) {
    final values = serviceDayValues.map((e) => [e]).toList();
    return getAllByIndex(r'serviceDay', values);
  }

  List<ReportList?> getAllByServiceDaySync(List<DateTime> serviceDayValues) {
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

  Future<Id> putByServiceDay(ReportList object) {
    return putByIndex(r'serviceDay', object);
  }

  Id putByServiceDaySync(ReportList object, {bool saveLinks = true}) {
    return putByIndexSync(r'serviceDay', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByServiceDay(List<ReportList> objects) {
    return putAllByIndex(r'serviceDay', objects);
  }

  List<Id> putAllByServiceDaySync(
    List<ReportList> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'serviceDay', objects, saveLinks: saveLinks);
  }
}

extension ReportListQueryWhereSort
    on QueryBuilder<ReportList, ReportList, QWhere> {
  QueryBuilder<ReportList, ReportList, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterWhere> anyServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'serviceDay'),
      );
    });
  }
}

extension ReportListQueryWhere
    on QueryBuilder<ReportList, ReportList, QWhereClause> {
  QueryBuilder<ReportList, ReportList, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ReportList, ReportList, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterWhereClause> idBetween(
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

  QueryBuilder<ReportList, ReportList, QAfterWhereClause> serviceDayEqualTo(
    DateTime serviceDay,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'serviceDay', value: [serviceDay]),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterWhereClause> serviceDayNotEqualTo(
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

  QueryBuilder<ReportList, ReportList, QAfterWhereClause> serviceDayGreaterThan(
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

  QueryBuilder<ReportList, ReportList, QAfterWhereClause> serviceDayLessThan(
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

  QueryBuilder<ReportList, ReportList, QAfterWhereClause> serviceDayBetween(
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

extension ReportListQueryFilter
    on QueryBuilder<ReportList, ReportList, QFilterCondition> {
  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  diasSemVendasEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'diasSemVendas', value: value),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  diasSemVendasGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'diasSemVendas',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  diasSemVendasLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'diasSemVendas',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  diasSemVendasBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'diasSemVendas',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  finalizedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'finalizedAt'),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  finalizedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'finalizedAt'),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  finalizedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'finalizedAt', value: value),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
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

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
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

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
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

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  isFinalizedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isFinalized', value: value),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> massivaEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'massiva', value: value),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  massivaGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'massiva',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> massivaLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'massiva',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> massivaBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'massiva',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  regularizacoesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'regularizacoes', value: value),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  regularizacoesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'regularizacoes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  regularizacoesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'regularizacoes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  regularizacoesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'regularizacoes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> repetidosEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'repetidos', value: value),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
  repetidosGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'repetidos',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> repetidosLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'repetidos',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> repetidosBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'repetidos',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> serviceDayEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serviceDay', value: value),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
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

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition>
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

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> serviceDayBetween(
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

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> totalEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'total', value: value),
      );
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> totalGreaterThan(
    int value, {
    bool include = false,
  }) {
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

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> totalLessThan(
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

  QueryBuilder<ReportList, ReportList, QAfterFilterCondition> totalBetween(
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

extension ReportListQueryObject
    on QueryBuilder<ReportList, ReportList, QFilterCondition> {}

extension ReportListQueryLinks
    on QueryBuilder<ReportList, ReportList, QFilterCondition> {}

extension ReportListQuerySortBy
    on QueryBuilder<ReportList, ReportList, QSortBy> {
  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByDiasSemVendas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diasSemVendas', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByDiasSemVendasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diasSemVendas', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByFinalizedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalizedAt', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByFinalizedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalizedAt', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByIsFinalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinalized', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByIsFinalizedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinalized', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByMassiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'massiva', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByMassivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'massiva', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByRegularizacoes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regularizacoes', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy>
  sortByRegularizacoesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regularizacoes', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByRepetidos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetidos', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByRepetidosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetidos', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByServiceDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension ReportListQuerySortThenBy
    on QueryBuilder<ReportList, ReportList, QSortThenBy> {
  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByDiasSemVendas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diasSemVendas', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByDiasSemVendasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diasSemVendas', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByFinalizedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalizedAt', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByFinalizedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finalizedAt', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByIsFinalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinalized', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByIsFinalizedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFinalized', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByMassiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'massiva', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByMassivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'massiva', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByRegularizacoes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regularizacoes', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy>
  thenByRegularizacoesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'regularizacoes', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByRepetidos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetidos', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByRepetidosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetidos', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByServiceDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serviceDay', Sort.desc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<ReportList, ReportList, QAfterSortBy> thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }
}

extension ReportListQueryWhereDistinct
    on QueryBuilder<ReportList, ReportList, QDistinct> {
  QueryBuilder<ReportList, ReportList, QDistinct> distinctByDiasSemVendas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diasSemVendas');
    });
  }

  QueryBuilder<ReportList, ReportList, QDistinct> distinctByFinalizedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finalizedAt');
    });
  }

  QueryBuilder<ReportList, ReportList, QDistinct> distinctByIsFinalized() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFinalized');
    });
  }

  QueryBuilder<ReportList, ReportList, QDistinct> distinctByMassiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'massiva');
    });
  }

  QueryBuilder<ReportList, ReportList, QDistinct> distinctByRegularizacoes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'regularizacoes');
    });
  }

  QueryBuilder<ReportList, ReportList, QDistinct> distinctByRepetidos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repetidos');
    });
  }

  QueryBuilder<ReportList, ReportList, QDistinct> distinctByServiceDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serviceDay');
    });
  }

  QueryBuilder<ReportList, ReportList, QDistinct> distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }
}

extension ReportListQueryProperty
    on QueryBuilder<ReportList, ReportList, QQueryProperty> {
  QueryBuilder<ReportList, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReportList, int, QQueryOperations> diasSemVendasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diasSemVendas');
    });
  }

  QueryBuilder<ReportList, DateTime?, QQueryOperations> finalizedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finalizedAt');
    });
  }

  QueryBuilder<ReportList, bool, QQueryOperations> isFinalizedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFinalized');
    });
  }

  QueryBuilder<ReportList, int, QQueryOperations> massivaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'massiva');
    });
  }

  QueryBuilder<ReportList, int, QQueryOperations> regularizacoesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'regularizacoes');
    });
  }

  QueryBuilder<ReportList, int, QQueryOperations> repetidosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repetidos');
    });
  }

  QueryBuilder<ReportList, DateTime, QQueryOperations> serviceDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serviceDay');
    });
  }

  QueryBuilder<ReportList, int, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }
}
