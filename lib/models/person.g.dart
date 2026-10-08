// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPersonCollection on Isar {
  IsarCollection<Person> get persons => this.collection();
}

const PersonSchema = CollectionSchema(
  name: r'Person',
  id: 7854610480646705599,
  properties: {
    r'ausencias': PropertySchema(
      id: 0,
      name: r'ausencias',
      type: IsarType.objectList,

      target: r'Ausencia',
    ),
    r'chefe': PropertySchema(id: 1, name: r'chefe', type: IsarType.string),
    r'collaboratorNumber': PropertySchema(
      id: 2,
      name: r'collaboratorNumber',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dateOfBirth': PropertySchema(
      id: 4,
      name: r'dateOfBirth',
      type: IsarType.dateTime,
    ),
    r'folgas': PropertySchema(id: 5, name: r'folgas', type: IsarType.longList),
    r'fullName': PropertySchema(
      id: 6,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'genero': PropertySchema(
      id: 7,
      name: r'genero',
      type: IsarType.string,
      enumMap: _PersongeneroEnumValueMap,
    ),
    r'hireDate': PropertySchema(
      id: 8,
      name: r'hireDate',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(id: 9, name: r'notes', type: IsarType.stringList),
    r'partTime': PropertySchema(id: 10, name: r'partTime', type: IsarType.bool),
    r'permanencia': PropertySchema(
      id: 11,
      name: r'permanencia',
      type: IsarType.bool,
    ),
    r'phoneNumber': PropertySchema(
      id: 12,
      name: r'phoneNumber',
      type: IsarType.string,
    ),
    r'photoPath': PropertySchema(
      id: 13,
      name: r'photoPath',
      type: IsarType.string,
    ),
    r'segundaLinha': PropertySchema(
      id: 14,
      name: r'segundaLinha',
      type: IsarType.bool,
    ),
    r'shiftEnd': PropertySchema(id: 15, name: r'shiftEnd', type: IsarType.long),
    r'shiftStart': PropertySchema(
      id: 16,
      name: r'shiftStart',
      type: IsarType.long,
    ),
    r'storeStartDate': PropertySchema(
      id: 17,
      name: r'storeStartDate',
      type: IsarType.dateTime,
    ),
    r'supervisor': PropertySchema(
      id: 18,
      name: r'supervisor',
      type: IsarType.bool,
    ),
    r'syncDeletedAt': PropertySchema(
      id: 19,
      name: r'syncDeletedAt',
      type: IsarType.dateTime,
    ),
    r'syncUpdatedAt': PropertySchema(
      id: 20,
      name: r'syncUpdatedAt',
      type: IsarType.dateTime,
    ),
    r'syncUuid': PropertySchema(
      id: 21,
      name: r'syncUuid',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 22, name: r'synced', type: IsarType.bool),
    r'team': PropertySchema(id: 23, name: r'team', type: IsarType.string),
    r'turno': PropertySchema(id: 24, name: r'turno', type: IsarType.string),
    r'weeklyHours': PropertySchema(
      id: 25,
      name: r'weeklyHours',
      type: IsarType.long,
    ),
  },

  estimateSize: _personEstimateSize,
  serialize: _personSerialize,
  deserialize: _personDeserialize,
  deserializeProp: _personDeserializeProp,
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
  embeddedSchemas: {r'Ausencia': AusenciaSchema},

  getId: _personGetId,
  getLinks: _personGetLinks,
  attach: _personAttach,
  version: '3.3.2',
);

int _personEstimateSize(
  Person object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.ausencias.length * 3;
  {
    final offsets = allOffsets[Ausencia]!;
    for (var i = 0; i < object.ausencias.length; i++) {
      final value = object.ausencias[i];
      bytesCount += AusenciaSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.chefe;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.collaboratorNumber.length * 3;
  bytesCount += 3 + object.folgas.length * 8;
  bytesCount += 3 + object.fullName.length * 3;
  {
    final value = object.genero;
    if (value != null) {
      bytesCount += 3 + value.name.length * 3;
    }
  }
  bytesCount += 3 + object.notes.length * 3;
  {
    for (var i = 0; i < object.notes.length; i++) {
      final value = object.notes[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.phoneNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.photoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.syncUuid.length * 3;
  {
    final value = object.team;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.turno;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _personSerialize(
  Person object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<Ausencia>(
    offsets[0],
    allOffsets,
    AusenciaSchema.serialize,
    object.ausencias,
  );
  writer.writeString(offsets[1], object.chefe);
  writer.writeString(offsets[2], object.collaboratorNumber);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDateTime(offsets[4], object.dateOfBirth);
  writer.writeLongList(offsets[5], object.folgas);
  writer.writeString(offsets[6], object.fullName);
  writer.writeString(offsets[7], object.genero?.name);
  writer.writeDateTime(offsets[8], object.hireDate);
  writer.writeStringList(offsets[9], object.notes);
  writer.writeBool(offsets[10], object.partTime);
  writer.writeBool(offsets[11], object.permanencia);
  writer.writeString(offsets[12], object.phoneNumber);
  writer.writeString(offsets[13], object.photoPath);
  writer.writeBool(offsets[14], object.segundaLinha);
  writer.writeLong(offsets[15], object.shiftEnd);
  writer.writeLong(offsets[16], object.shiftStart);
  writer.writeDateTime(offsets[17], object.storeStartDate);
  writer.writeBool(offsets[18], object.supervisor);
  writer.writeDateTime(offsets[19], object.syncDeletedAt);
  writer.writeDateTime(offsets[20], object.syncUpdatedAt);
  writer.writeString(offsets[21], object.syncUuid);
  writer.writeBool(offsets[22], object.synced);
  writer.writeString(offsets[23], object.team);
  writer.writeString(offsets[24], object.turno);
  writer.writeLong(offsets[25], object.weeklyHours);
}

Person _personDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Person();
  object.ausencias =
      reader.readObjectList<Ausencia>(
        offsets[0],
        AusenciaSchema.deserialize,
        allOffsets,
        Ausencia(),
      ) ??
      [];
  object.chefe = reader.readStringOrNull(offsets[1]);
  object.collaboratorNumber = reader.readString(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.dateOfBirth = reader.readDateTimeOrNull(offsets[4]);
  object.folgas = reader.readLongList(offsets[5]) ?? [];
  object.fullName = reader.readString(offsets[6]);
  object.genero =
      _PersongeneroValueEnumMap[reader.readStringOrNull(offsets[7])];
  object.hireDate = reader.readDateTimeOrNull(offsets[8]);
  object.id = id;
  object.notes = reader.readStringList(offsets[9]) ?? [];
  object.partTime = reader.readBool(offsets[10]);
  object.permanencia = reader.readBool(offsets[11]);
  object.phoneNumber = reader.readStringOrNull(offsets[12]);
  object.photoPath = reader.readStringOrNull(offsets[13]);
  object.segundaLinha = reader.readBool(offsets[14]);
  object.shiftEnd = reader.readLongOrNull(offsets[15]);
  object.shiftStart = reader.readLongOrNull(offsets[16]);
  object.storeStartDate = reader.readDateTimeOrNull(offsets[17]);
  object.supervisor = reader.readBool(offsets[18]);
  object.syncDeletedAt = reader.readDateTimeOrNull(offsets[19]);
  object.syncUpdatedAt = reader.readDateTime(offsets[20]);
  object.syncUuid = reader.readString(offsets[21]);
  object.synced = reader.readBool(offsets[22]);
  object.team = reader.readStringOrNull(offsets[23]);
  object.turno = reader.readStringOrNull(offsets[24]);
  object.weeklyHours = reader.readLongOrNull(offsets[25]);
  return object;
}

P _personDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<Ausencia>(
                offset,
                AusenciaSchema.deserialize,
                allOffsets,
                Ausencia(),
              ) ??
              [])
          as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readLongList(offset) ?? []) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (_PersongeneroValueEnumMap[reader.readStringOrNull(offset)]) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 20:
      return (reader.readDateTime(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readBool(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PersongeneroEnumValueMap = {
  r'masculino': r'masculino',
  r'feminino': r'feminino',
};
const _PersongeneroValueEnumMap = {
  r'masculino': Genero.masculino,
  r'feminino': Genero.feminino,
};

Id _personGetId(Person object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _personGetLinks(Person object) {
  return [];
}

void _personAttach(IsarCollection<dynamic> col, Id id, Person object) {
  object.id = id;
}

extension PersonQueryWhereSort on QueryBuilder<Person, Person, QWhere> {
  QueryBuilder<Person, Person, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PersonQueryWhere on QueryBuilder<Person, Person, QWhereClause> {
  QueryBuilder<Person, Person, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Person, Person, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Person, Person, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterWhereClause> idBetween(
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

  QueryBuilder<Person, Person, QAfterWhereClause> syncUuidEqualTo(
    String syncUuid,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'syncUuid', value: [syncUuid]),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterWhereClause> syncUuidNotEqualTo(
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

extension PersonQueryFilter on QueryBuilder<Person, Person, QFilterCondition> {
  QueryBuilder<Person, Person, QAfterFilterCondition> ausenciasLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ausencias', length, true, length, true);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> ausenciasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ausencias', 0, true, 0, true);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> ausenciasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ausencias', 0, false, 999999, true);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> ausenciasLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ausencias', 0, true, length, include);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition>
  ausenciasLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ausencias', length, include, 999999, true);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> ausenciasLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ausencias',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> chefeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'chefe'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> chefeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'chefe'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> chefeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'chefe',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> chefeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'chefe',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> chefeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'chefe',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> chefeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'chefe',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> chefeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'chefe',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> chefeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'chefe',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> chefeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'chefe',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> chefeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'chefe',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> chefeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'chefe', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> chefeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'chefe', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> collaboratorNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'collaboratorNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition>
  collaboratorNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'collaboratorNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition>
  collaboratorNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'collaboratorNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> collaboratorNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'collaboratorNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition>
  collaboratorNumberStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'collaboratorNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition>
  collaboratorNumberEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'collaboratorNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition>
  collaboratorNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'collaboratorNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> collaboratorNumberMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'collaboratorNumber',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition>
  collaboratorNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'collaboratorNumber', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition>
  collaboratorNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'collaboratorNumber', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<Person, Person, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> dateOfBirthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'dateOfBirth'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> dateOfBirthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'dateOfBirth'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> dateOfBirthEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dateOfBirth', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> dateOfBirthGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dateOfBirth',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> dateOfBirthLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dateOfBirth',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> dateOfBirthBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dateOfBirth',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> folgasElementEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'folgas', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> folgasElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'folgas',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> folgasElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'folgas',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> folgasElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'folgas',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> folgasLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'folgas', length, true, length, true);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> folgasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'folgas', 0, true, 0, true);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> folgasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'folgas', 0, false, 999999, true);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> folgasLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'folgas', 0, true, length, include);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> folgasLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'folgas', length, include, 999999, true);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> folgasLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'folgas',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> fullNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> fullNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> fullNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> fullNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fullName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> fullNameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fullName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> fullNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fullName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fullName', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fullName', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> generoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'genero'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> generoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'genero'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> generoEqualTo(
    Genero? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'genero',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> generoGreaterThan(
    Genero? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'genero',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> generoLessThan(
    Genero? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'genero',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> generoBetween(
    Genero? lower,
    Genero? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'genero',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> generoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'genero',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> generoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'genero',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> generoContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'genero',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> generoMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'genero',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> generoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'genero', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> generoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'genero', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> hireDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'hireDate'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> hireDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'hireDate'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> hireDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hireDate', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> hireDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hireDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> hireDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hireDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> hireDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hireDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> notesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesLengthEqualTo(
    int length,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'notes', length, true, length, true);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'notes', 0, true, 0, true);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'notes', 0, false, 999999, true);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'notes', 0, true, length, include);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'notes', length, include, 999999, true);
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> notesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'notes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> partTimeEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'partTime', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> permanenciaEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'permanencia', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> phoneNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'phoneNumber'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> phoneNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'phoneNumber'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> phoneNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'phoneNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> phoneNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'phoneNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> phoneNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'phoneNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> phoneNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'phoneNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> phoneNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'phoneNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> phoneNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'phoneNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> phoneNumberContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'phoneNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> phoneNumberMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'phoneNumber',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> phoneNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'phoneNumber', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> phoneNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'phoneNumber', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> photoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'photoPath'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> photoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'photoPath'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> photoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'photoPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> photoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'photoPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> photoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'photoPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> photoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'photoPath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> photoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'photoPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> photoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'photoPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> photoPathContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'photoPath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> photoPathMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'photoPath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> photoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'photoPath', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> photoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'photoPath', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> segundaLinhaEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'segundaLinha', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> shiftEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'shiftEnd'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> shiftEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'shiftEnd'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> shiftEndEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'shiftEnd', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> shiftEndGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'shiftEnd',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> shiftEndLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'shiftEnd',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> shiftEndBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'shiftEnd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> shiftStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'shiftStart'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> shiftStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'shiftStart'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> shiftStartEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'shiftStart', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> shiftStartGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'shiftStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> shiftStartLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'shiftStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> shiftStartBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'shiftStart',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> storeStartDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'storeStartDate'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition>
  storeStartDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'storeStartDate'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> storeStartDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'storeStartDate', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> storeStartDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'storeStartDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> storeStartDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'storeStartDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> storeStartDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'storeStartDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> supervisorEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'supervisor', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> syncDeletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> syncDeletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncDeletedAt'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> syncDeletedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncDeletedAt', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> syncDeletedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncDeletedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncDeletedAtBetween(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUpdatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUpdatedAt', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUpdatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUpdatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUpdatedAtBetween(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUuidEqualTo(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUuidGreaterThan(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUuidLessThan(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUuidBetween(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUuidStartsWith(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUuidEndsWith(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUuidContains(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUuidMatches(
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

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> syncUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'syncUuid', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> teamIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'team'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> teamIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'team'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> teamEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'team',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> teamGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'team',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> teamLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'team',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> teamBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'team',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> teamStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'team',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> teamEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'team',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> teamContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'team',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> teamMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'team',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> teamIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'team', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> teamIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'team', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> turnoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'turno'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> turnoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'turno'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> turnoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'turno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> turnoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'turno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> turnoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'turno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> turnoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'turno',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> turnoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'turno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> turnoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'turno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> turnoContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'turno',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> turnoMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'turno',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> turnoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'turno', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> turnoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'turno', value: ''),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> weeklyHoursIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'weeklyHours'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> weeklyHoursIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'weeklyHours'),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> weeklyHoursEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'weeklyHours', value: value),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> weeklyHoursGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weeklyHours',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> weeklyHoursLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weeklyHours',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Person, Person, QAfterFilterCondition> weeklyHoursBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weeklyHours',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PersonQueryObject on QueryBuilder<Person, Person, QFilterCondition> {
  QueryBuilder<Person, Person, QAfterFilterCondition> ausenciasElement(
    FilterQuery<Ausencia> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'ausencias');
    });
  }
}

extension PersonQueryLinks on QueryBuilder<Person, Person, QFilterCondition> {}

extension PersonQuerySortBy on QueryBuilder<Person, Person, QSortBy> {
  QueryBuilder<Person, Person, QAfterSortBy> sortByChefe() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chefe', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByChefeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chefe', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByCollaboratorNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaboratorNumber', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByCollaboratorNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaboratorNumber', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByGenero() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genero', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByGeneroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genero', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByHireDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hireDate', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByHireDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hireDate', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByPartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partTime', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByPartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partTime', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByPermanencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permanencia', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByPermanenciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permanencia', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByPhoneNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByPhoneNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortBySegundaLinha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'segundaLinha', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortBySegundaLinhaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'segundaLinha', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByShiftEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftEnd', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByShiftEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftEnd', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByShiftStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftStart', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByShiftStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftStart', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByStoreStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeStartDate', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByStoreStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeStartDate', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortBySupervisor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisor', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortBySupervisorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisor', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByTeam() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'team', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByTeamDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'team', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByTurno() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turno', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByTurnoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turno', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByWeeklyHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyHours', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> sortByWeeklyHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyHours', Sort.desc);
    });
  }
}

extension PersonQuerySortThenBy on QueryBuilder<Person, Person, QSortThenBy> {
  QueryBuilder<Person, Person, QAfterSortBy> thenByChefe() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chefe', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByChefeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chefe', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByCollaboratorNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaboratorNumber', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByCollaboratorNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collaboratorNumber', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByGenero() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genero', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByGeneroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genero', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByHireDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hireDate', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByHireDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hireDate', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByPartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partTime', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByPartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partTime', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByPermanencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permanencia', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByPermanenciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permanencia', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByPhoneNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByPhoneNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phoneNumber', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenBySegundaLinha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'segundaLinha', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenBySegundaLinhaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'segundaLinha', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByShiftEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftEnd', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByShiftEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftEnd', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByShiftStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftStart', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByShiftStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shiftStart', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByStoreStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeStartDate', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByStoreStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeStartDate', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenBySupervisor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisor', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenBySupervisorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supervisor', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenBySyncDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncDeletedAt', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenBySyncUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdatedAt', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenBySyncUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenBySyncUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUuid', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByTeam() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'team', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByTeamDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'team', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByTurno() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turno', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByTurnoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turno', Sort.desc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByWeeklyHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyHours', Sort.asc);
    });
  }

  QueryBuilder<Person, Person, QAfterSortBy> thenByWeeklyHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyHours', Sort.desc);
    });
  }
}

extension PersonQueryWhereDistinct on QueryBuilder<Person, Person, QDistinct> {
  QueryBuilder<Person, Person, QDistinct> distinctByChefe({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chefe', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByCollaboratorNumber({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'collaboratorNumber',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateOfBirth');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByFolgas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'folgas');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByFullName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByGenero({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genero', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByHireDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hireDate');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByPartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partTime');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByPermanencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permanencia');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByPhoneNumber({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phoneNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByPhotoPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctBySegundaLinha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'segundaLinha');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByShiftEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shiftEnd');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByShiftStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shiftStart');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByStoreStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storeStartDate');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctBySupervisor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supervisor');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctBySyncDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncDeletedAt');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctBySyncUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUpdatedAt');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctBySyncUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByTeam({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'team', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByTurno({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'turno', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Person, Person, QDistinct> distinctByWeeklyHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyHours');
    });
  }
}

extension PersonQueryProperty on QueryBuilder<Person, Person, QQueryProperty> {
  QueryBuilder<Person, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Person, List<Ausencia>, QQueryOperations> ausenciasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ausencias');
    });
  }

  QueryBuilder<Person, String?, QQueryOperations> chefeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chefe');
    });
  }

  QueryBuilder<Person, String, QQueryOperations> collaboratorNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collaboratorNumber');
    });
  }

  QueryBuilder<Person, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Person, DateTime?, QQueryOperations> dateOfBirthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateOfBirth');
    });
  }

  QueryBuilder<Person, List<int>, QQueryOperations> folgasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'folgas');
    });
  }

  QueryBuilder<Person, String, QQueryOperations> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<Person, Genero?, QQueryOperations> generoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genero');
    });
  }

  QueryBuilder<Person, DateTime?, QQueryOperations> hireDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hireDate');
    });
  }

  QueryBuilder<Person, List<String>, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<Person, bool, QQueryOperations> partTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partTime');
    });
  }

  QueryBuilder<Person, bool, QQueryOperations> permanenciaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permanencia');
    });
  }

  QueryBuilder<Person, String?, QQueryOperations> phoneNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phoneNumber');
    });
  }

  QueryBuilder<Person, String?, QQueryOperations> photoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoPath');
    });
  }

  QueryBuilder<Person, bool, QQueryOperations> segundaLinhaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'segundaLinha');
    });
  }

  QueryBuilder<Person, int?, QQueryOperations> shiftEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shiftEnd');
    });
  }

  QueryBuilder<Person, int?, QQueryOperations> shiftStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shiftStart');
    });
  }

  QueryBuilder<Person, DateTime?, QQueryOperations> storeStartDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storeStartDate');
    });
  }

  QueryBuilder<Person, bool, QQueryOperations> supervisorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supervisor');
    });
  }

  QueryBuilder<Person, DateTime?, QQueryOperations> syncDeletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncDeletedAt');
    });
  }

  QueryBuilder<Person, DateTime, QQueryOperations> syncUpdatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUpdatedAt');
    });
  }

  QueryBuilder<Person, String, QQueryOperations> syncUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUuid');
    });
  }

  QueryBuilder<Person, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<Person, String?, QQueryOperations> teamProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'team');
    });
  }

  QueryBuilder<Person, String?, QQueryOperations> turnoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'turno');
    });
  }

  QueryBuilder<Person, int?, QQueryOperations> weeklyHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyHours');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const AusenciaSchema = Schema(
  name: r'Ausencia',
  id: 4547368435530688916,
  properties: {
    r'end': PropertySchema(id: 0, name: r'end', type: IsarType.dateTime),
    r'start': PropertySchema(id: 1, name: r'start', type: IsarType.dateTime),
    r'tipo': PropertySchema(
      id: 2,
      name: r'tipo',
      type: IsarType.string,
      enumMap: _AusenciatipoEnumValueMap,
    ),
  },

  estimateSize: _ausenciaEstimateSize,
  serialize: _ausenciaSerialize,
  deserialize: _ausenciaDeserialize,
  deserializeProp: _ausenciaDeserializeProp,
);

int _ausenciaEstimateSize(
  Ausencia object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.tipo.name.length * 3;
  return bytesCount;
}

void _ausenciaSerialize(
  Ausencia object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.end);
  writer.writeDateTime(offsets[1], object.start);
  writer.writeString(offsets[2], object.tipo.name);
}

Ausencia _ausenciaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Ausencia();
  object.end = reader.readDateTime(offsets[0]);
  object.start = reader.readDateTime(offsets[1]);
  object.tipo =
      _AusenciatipoValueEnumMap[reader.readStringOrNull(offsets[2])] ??
      AusenciaTipo.ferias;
  return object;
}

P _ausenciaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (_AusenciatipoValueEnumMap[reader.readStringOrNull(offset)] ??
              AusenciaTipo.ferias)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AusenciatipoEnumValueMap = {
  r'ferias': r'ferias',
  r'baixa': r'baixa',
  r'formacao': r'formacao',
  r'outra': r'outra',
};
const _AusenciatipoValueEnumMap = {
  r'ferias': AusenciaTipo.ferias,
  r'baixa': AusenciaTipo.baixa,
  r'formacao': AusenciaTipo.formacao,
  r'outra': AusenciaTipo.outra,
};

extension AusenciaQueryFilter
    on QueryBuilder<Ausencia, Ausencia, QFilterCondition> {
  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> endEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'end', value: value),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> endGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'end',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> endLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'end',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> endBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'end',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> startEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'start', value: value),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> startGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'start',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> startLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'start',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> startBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'start',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> tipoEqualTo(
    AusenciaTipo value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tipo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> tipoGreaterThan(
    AusenciaTipo value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tipo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> tipoLessThan(
    AusenciaTipo value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tipo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> tipoBetween(
    AusenciaTipo lower,
    AusenciaTipo upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tipo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> tipoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tipo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> tipoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tipo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> tipoContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tipo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> tipoMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tipo',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> tipoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tipo', value: ''),
      );
    });
  }

  QueryBuilder<Ausencia, Ausencia, QAfterFilterCondition> tipoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tipo', value: ''),
      );
    });
  }
}

extension AusenciaQueryObject
    on QueryBuilder<Ausencia, Ausencia, QFilterCondition> {}
