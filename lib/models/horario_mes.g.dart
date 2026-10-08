// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horario_mes.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHorarioMesCollection on Isar {
  IsarCollection<HorarioMes> get horarioMes => this.collection();
}

const HorarioMesSchema = CollectionSchema(
  name: r'HorarioMes',
  id: -3274733685789584410,
  properties: {
    r'linhas': PropertySchema(
      id: 0,
      name: r'linhas',
      type: IsarType.objectList,

      target: r'HorarioLinha',
    ),
    r'mes': PropertySchema(id: 1, name: r'mes', type: IsarType.string),
  },

  estimateSize: _horarioMesEstimateSize,
  serialize: _horarioMesSerialize,
  deserialize: _horarioMesDeserialize,
  deserializeProp: _horarioMesDeserializeProp,
  idName: r'id',
  indexes: {
    r'mes': IndexSchema(
      id: 7434946374198654290,
      name: r'mes',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'mes',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'HorarioLinha': HorarioLinhaSchema},

  getId: _horarioMesGetId,
  getLinks: _horarioMesGetLinks,
  attach: _horarioMesAttach,
  version: '3.3.2',
);

int _horarioMesEstimateSize(
  HorarioMes object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.linhas.length * 3;
  {
    final offsets = allOffsets[HorarioLinha]!;
    for (var i = 0; i < object.linhas.length; i++) {
      final value = object.linhas[i];
      bytesCount += HorarioLinhaSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.mes.length * 3;
  return bytesCount;
}

void _horarioMesSerialize(
  HorarioMes object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<HorarioLinha>(
    offsets[0],
    allOffsets,
    HorarioLinhaSchema.serialize,
    object.linhas,
  );
  writer.writeString(offsets[1], object.mes);
}

HorarioMes _horarioMesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HorarioMes();
  object.id = id;
  object.linhas =
      reader.readObjectList<HorarioLinha>(
        offsets[0],
        HorarioLinhaSchema.deserialize,
        allOffsets,
        HorarioLinha(),
      ) ??
      [];
  object.mes = reader.readString(offsets[1]);
  return object;
}

P _horarioMesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<HorarioLinha>(
                offset,
                HorarioLinhaSchema.deserialize,
                allOffsets,
                HorarioLinha(),
              ) ??
              [])
          as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _horarioMesGetId(HorarioMes object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _horarioMesGetLinks(HorarioMes object) {
  return [];
}

void _horarioMesAttach(IsarCollection<dynamic> col, Id id, HorarioMes object) {
  object.id = id;
}

extension HorarioMesByIndex on IsarCollection<HorarioMes> {
  Future<HorarioMes?> getByMes(String mes) {
    return getByIndex(r'mes', [mes]);
  }

  HorarioMes? getByMesSync(String mes) {
    return getByIndexSync(r'mes', [mes]);
  }

  Future<bool> deleteByMes(String mes) {
    return deleteByIndex(r'mes', [mes]);
  }

  bool deleteByMesSync(String mes) {
    return deleteByIndexSync(r'mes', [mes]);
  }

  Future<List<HorarioMes?>> getAllByMes(List<String> mesValues) {
    final values = mesValues.map((e) => [e]).toList();
    return getAllByIndex(r'mes', values);
  }

  List<HorarioMes?> getAllByMesSync(List<String> mesValues) {
    final values = mesValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'mes', values);
  }

  Future<int> deleteAllByMes(List<String> mesValues) {
    final values = mesValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'mes', values);
  }

  int deleteAllByMesSync(List<String> mesValues) {
    final values = mesValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'mes', values);
  }

  Future<Id> putByMes(HorarioMes object) {
    return putByIndex(r'mes', object);
  }

  Id putByMesSync(HorarioMes object, {bool saveLinks = true}) {
    return putByIndexSync(r'mes', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMes(List<HorarioMes> objects) {
    return putAllByIndex(r'mes', objects);
  }

  List<Id> putAllByMesSync(List<HorarioMes> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'mes', objects, saveLinks: saveLinks);
  }
}

extension HorarioMesQueryWhereSort
    on QueryBuilder<HorarioMes, HorarioMes, QWhere> {
  QueryBuilder<HorarioMes, HorarioMes, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HorarioMesQueryWhere
    on QueryBuilder<HorarioMes, HorarioMes, QWhereClause> {
  QueryBuilder<HorarioMes, HorarioMes, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<HorarioMes, HorarioMes, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterWhereClause> idBetween(
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

  QueryBuilder<HorarioMes, HorarioMes, QAfterWhereClause> mesEqualTo(
    String mes,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'mes', value: [mes]),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterWhereClause> mesNotEqualTo(
    String mes,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mes',
                lower: [],
                upper: [mes],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mes',
                lower: [mes],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mes',
                lower: [mes],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mes',
                lower: [],
                upper: [mes],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension HorarioMesQueryFilter
    on QueryBuilder<HorarioMes, HorarioMes, QFilterCondition> {
  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> idBetween(
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

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition>
  linhasLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'linhas', length, true, length, true);
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> linhasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'linhas', 0, true, 0, true);
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition>
  linhasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'linhas', 0, false, 999999, true);
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition>
  linhasLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'linhas', 0, true, length, include);
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition>
  linhasLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'linhas', length, include, 999999, true);
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition>
  linhasLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linhas',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> mesEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> mesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> mesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> mesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> mesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> mesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> mesContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> mesMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> mesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mes', value: ''),
      );
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> mesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'mes', value: ''),
      );
    });
  }
}

extension HorarioMesQueryObject
    on QueryBuilder<HorarioMes, HorarioMes, QFilterCondition> {
  QueryBuilder<HorarioMes, HorarioMes, QAfterFilterCondition> linhasElement(
    FilterQuery<HorarioLinha> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'linhas');
    });
  }
}

extension HorarioMesQueryLinks
    on QueryBuilder<HorarioMes, HorarioMes, QFilterCondition> {}

extension HorarioMesQuerySortBy
    on QueryBuilder<HorarioMes, HorarioMes, QSortBy> {
  QueryBuilder<HorarioMes, HorarioMes, QAfterSortBy> sortByMes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mes', Sort.asc);
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterSortBy> sortByMesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mes', Sort.desc);
    });
  }
}

extension HorarioMesQuerySortThenBy
    on QueryBuilder<HorarioMes, HorarioMes, QSortThenBy> {
  QueryBuilder<HorarioMes, HorarioMes, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterSortBy> thenByMes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mes', Sort.asc);
    });
  }

  QueryBuilder<HorarioMes, HorarioMes, QAfterSortBy> thenByMesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mes', Sort.desc);
    });
  }
}

extension HorarioMesQueryWhereDistinct
    on QueryBuilder<HorarioMes, HorarioMes, QDistinct> {
  QueryBuilder<HorarioMes, HorarioMes, QDistinct> distinctByMes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mes', caseSensitive: caseSensitive);
    });
  }
}

extension HorarioMesQueryProperty
    on QueryBuilder<HorarioMes, HorarioMes, QQueryProperty> {
  QueryBuilder<HorarioMes, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HorarioMes, List<HorarioLinha>, QQueryOperations>
  linhasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linhas');
    });
  }

  QueryBuilder<HorarioMes, String, QQueryOperations> mesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mes');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const HorarioLinhaSchema = Schema(
  name: r'HorarioLinha',
  id: -3639484374080530844,
  properties: {
    r'codigos': PropertySchema(
      id: 0,
      name: r'codigos',
      type: IsarType.stringList,
    ),
    r'nome': PropertySchema(id: 1, name: r'nome', type: IsarType.string),
  },

  estimateSize: _horarioLinhaEstimateSize,
  serialize: _horarioLinhaSerialize,
  deserialize: _horarioLinhaDeserialize,
  deserializeProp: _horarioLinhaDeserializeProp,
);

int _horarioLinhaEstimateSize(
  HorarioLinha object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.codigos.length * 3;
  {
    for (var i = 0; i < object.codigos.length; i++) {
      final value = object.codigos[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.nome.length * 3;
  return bytesCount;
}

void _horarioLinhaSerialize(
  HorarioLinha object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.codigos);
  writer.writeString(offsets[1], object.nome);
}

HorarioLinha _horarioLinhaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HorarioLinha();
  object.codigos = reader.readStringList(offsets[0]) ?? [];
  object.nome = reader.readString(offsets[1]);
  return object;
}

P _horarioLinhaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension HorarioLinhaQueryFilter
    on QueryBuilder<HorarioLinha, HorarioLinha, QFilterCondition> {
  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'codigos',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'codigos',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'codigos',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'codigos',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'codigos',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'codigos',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'codigos',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'codigos',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'codigos', value: ''),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'codigos', value: ''),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'codigos', length, true, length, true);
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'codigos', 0, true, 0, true);
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'codigos', 0, false, 999999, true);
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'codigos', 0, true, length, include);
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'codigos', length, include, 999999, true);
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  codigosLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'codigos',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition> nomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  nomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition> nomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition> nomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nome',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  nomeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition> nomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition> nomeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition> nomeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nome',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  nomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nome', value: ''),
      );
    });
  }

  QueryBuilder<HorarioLinha, HorarioLinha, QAfterFilterCondition>
  nomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nome', value: ''),
      );
    });
  }
}

extension HorarioLinhaQueryObject
    on QueryBuilder<HorarioLinha, HorarioLinha, QFilterCondition> {}
