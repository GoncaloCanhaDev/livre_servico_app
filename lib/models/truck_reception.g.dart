// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'truck_reception.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTruckReceptionCollection on Isar {
  IsarCollection<TruckReception> get truckReceptions => this.collection();
}

const TruckReceptionSchema = CollectionSchema(
  name: r'TruckReception',
  id: 7035015931963245718,
  properties: {
    r'arrivalTime': PropertySchema(
      id: 0,
      name: r'arrivalTime',
      type: IsarType.dateTime,
    ),
    r'licensePlate': PropertySchema(
      id: 1,
      name: r'licensePlate',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(id: 2, name: r'notes', type: IsarType.string),
    r'pallets': PropertySchema(
      id: 3,
      name: r'pallets',
      type: IsarType.objectList,

      target: r'PalletCount',
    ),
    r'sentVasilhame': PropertySchema(
      id: 4,
      name: r'sentVasilhame',
      type: IsarType.objectList,

      target: r'SentVasilhameItem',
    ),
    r'supplier': PropertySchema(
      id: 5,
      name: r'supplier',
      type: IsarType.string,
    ),
    r'totalMistas': PropertySchema(
      id: 6,
      name: r'totalMistas',
      type: IsarType.long,
    ),
    r'totalPallets': PropertySchema(
      id: 7,
      name: r'totalPallets',
      type: IsarType.long,
    ),
  },

  estimateSize: _truckReceptionEstimateSize,
  serialize: _truckReceptionSerialize,
  deserialize: _truckReceptionDeserialize,
  deserializeProp: _truckReceptionDeserializeProp,
  idName: r'id',
  indexes: {
    r'arrivalTime': IndexSchema(
      id: -1013225581166292242,
      name: r'arrivalTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'arrivalTime',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {
    r'PalletCount': PalletCountSchema,
    r'SentVasilhameItem': SentVasilhameItemSchema,
  },

  getId: _truckReceptionGetId,
  getLinks: _truckReceptionGetLinks,
  attach: _truckReceptionAttach,
  version: '3.3.2',
);

int _truckReceptionEstimateSize(
  TruckReception object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.licensePlate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.pallets.length * 3;
  {
    final offsets = allOffsets[PalletCount]!;
    for (var i = 0; i < object.pallets.length; i++) {
      final value = object.pallets[i];
      bytesCount += PalletCountSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.sentVasilhame.length * 3;
  {
    final offsets = allOffsets[SentVasilhameItem]!;
    for (var i = 0; i < object.sentVasilhame.length; i++) {
      final value = object.sentVasilhame[i];
      bytesCount += SentVasilhameItemSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  {
    final value = object.supplier;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _truckReceptionSerialize(
  TruckReception object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.arrivalTime);
  writer.writeString(offsets[1], object.licensePlate);
  writer.writeString(offsets[2], object.notes);
  writer.writeObjectList<PalletCount>(
    offsets[3],
    allOffsets,
    PalletCountSchema.serialize,
    object.pallets,
  );
  writer.writeObjectList<SentVasilhameItem>(
    offsets[4],
    allOffsets,
    SentVasilhameItemSchema.serialize,
    object.sentVasilhame,
  );
  writer.writeString(offsets[5], object.supplier);
  writer.writeLong(offsets[6], object.totalMistas);
  writer.writeLong(offsets[7], object.totalPallets);
}

TruckReception _truckReceptionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TruckReception();
  object.arrivalTime = reader.readDateTime(offsets[0]);
  object.id = id;
  object.licensePlate = reader.readStringOrNull(offsets[1]);
  object.notes = reader.readStringOrNull(offsets[2]);
  object.pallets =
      reader.readObjectList<PalletCount>(
        offsets[3],
        PalletCountSchema.deserialize,
        allOffsets,
        PalletCount(),
      ) ??
      [];
  object.sentVasilhame =
      reader.readObjectList<SentVasilhameItem>(
        offsets[4],
        SentVasilhameItemSchema.deserialize,
        allOffsets,
        SentVasilhameItem(),
      ) ??
      [];
  object.supplier = reader.readStringOrNull(offsets[5]);
  return object;
}

P _truckReceptionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readObjectList<PalletCount>(
                offset,
                PalletCountSchema.deserialize,
                allOffsets,
                PalletCount(),
              ) ??
              [])
          as P;
    case 4:
      return (reader.readObjectList<SentVasilhameItem>(
                offset,
                SentVasilhameItemSchema.deserialize,
                allOffsets,
                SentVasilhameItem(),
              ) ??
              [])
          as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _truckReceptionGetId(TruckReception object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _truckReceptionGetLinks(TruckReception object) {
  return [];
}

void _truckReceptionAttach(
  IsarCollection<dynamic> col,
  Id id,
  TruckReception object,
) {
  object.id = id;
}

extension TruckReceptionQueryWhereSort
    on QueryBuilder<TruckReception, TruckReception, QWhere> {
  QueryBuilder<TruckReception, TruckReception, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterWhere> anyArrivalTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'arrivalTime'),
      );
    });
  }
}

extension TruckReceptionQueryWhere
    on QueryBuilder<TruckReception, TruckReception, QWhereClause> {
  QueryBuilder<TruckReception, TruckReception, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<TruckReception, TruckReception, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterWhereClause> idBetween(
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

  QueryBuilder<TruckReception, TruckReception, QAfterWhereClause>
  arrivalTimeEqualTo(DateTime arrivalTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'arrivalTime',
          value: [arrivalTime],
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterWhereClause>
  arrivalTimeNotEqualTo(DateTime arrivalTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'arrivalTime',
                lower: [],
                upper: [arrivalTime],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'arrivalTime',
                lower: [arrivalTime],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'arrivalTime',
                lower: [arrivalTime],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'arrivalTime',
                lower: [],
                upper: [arrivalTime],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterWhereClause>
  arrivalTimeGreaterThan(DateTime arrivalTime, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'arrivalTime',
          lower: [arrivalTime],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterWhereClause>
  arrivalTimeLessThan(DateTime arrivalTime, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'arrivalTime',
          lower: [],
          upper: [arrivalTime],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterWhereClause>
  arrivalTimeBetween(
    DateTime lowerArrivalTime,
    DateTime upperArrivalTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'arrivalTime',
          lower: [lowerArrivalTime],
          includeLower: includeLower,
          upper: [upperArrivalTime],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TruckReceptionQueryFilter
    on QueryBuilder<TruckReception, TruckReception, QFilterCondition> {
  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  arrivalTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'arrivalTime', value: value),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  arrivalTimeGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'arrivalTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  arrivalTimeLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'arrivalTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  arrivalTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'arrivalTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
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

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
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

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  licensePlateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'licensePlate'),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  licensePlateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'licensePlate'),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  licensePlateEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'licensePlate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  licensePlateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'licensePlate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  licensePlateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'licensePlate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  licensePlateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'licensePlate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  licensePlateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'licensePlate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  licensePlateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'licensePlate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  licensePlateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'licensePlate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  licensePlateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'licensePlate',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  licensePlateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'licensePlate', value: ''),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  licensePlateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'licensePlate', value: ''),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  notesEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  notesGreaterThan(
    String? value, {
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

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  notesLessThan(
    String? value, {
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

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  notesBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  notesStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  notesEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  notesContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  notesMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  palletsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'pallets', length, true, length, true);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  palletsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'pallets', 0, true, 0, true);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  palletsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'pallets', 0, false, 999999, true);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  palletsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'pallets', 0, true, length, include);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  palletsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'pallets', length, include, 999999, true);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  palletsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pallets',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  sentVasilhameLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sentVasilhame', length, true, length, true);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  sentVasilhameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sentVasilhame', 0, true, 0, true);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  sentVasilhameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sentVasilhame', 0, false, 999999, true);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  sentVasilhameLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sentVasilhame', 0, true, length, include);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  sentVasilhameLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sentVasilhame', length, include, 999999, true);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  sentVasilhameLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sentVasilhame',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  supplierIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'supplier'),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  supplierIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'supplier'),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  supplierEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  supplierGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  supplierLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  supplierBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'supplier',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  supplierStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  supplierEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  supplierContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  supplierMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'supplier',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  supplierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'supplier', value: ''),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  supplierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'supplier', value: ''),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  totalMistasEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalMistas', value: value),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  totalMistasGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalMistas',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  totalMistasLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalMistas',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  totalMistasBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalMistas',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  totalPalletsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalPallets', value: value),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  totalPalletsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalPallets',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  totalPalletsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalPallets',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  totalPalletsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalPallets',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TruckReceptionQueryObject
    on QueryBuilder<TruckReception, TruckReception, QFilterCondition> {
  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  palletsElement(FilterQuery<PalletCount> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'pallets');
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterFilterCondition>
  sentVasilhameElement(FilterQuery<SentVasilhameItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'sentVasilhame');
    });
  }
}

extension TruckReceptionQueryLinks
    on QueryBuilder<TruckReception, TruckReception, QFilterCondition> {}

extension TruckReceptionQuerySortBy
    on QueryBuilder<TruckReception, TruckReception, QSortBy> {
  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  sortByArrivalTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arrivalTime', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  sortByArrivalTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arrivalTime', Sort.desc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  sortByLicensePlate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licensePlate', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  sortByLicensePlateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licensePlate', Sort.desc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy> sortBySupplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  sortBySupplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.desc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  sortByTotalMistas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMistas', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  sortByTotalMistasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMistas', Sort.desc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  sortByTotalPallets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPallets', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  sortByTotalPalletsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPallets', Sort.desc);
    });
  }
}

extension TruckReceptionQuerySortThenBy
    on QueryBuilder<TruckReception, TruckReception, QSortThenBy> {
  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  thenByArrivalTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arrivalTime', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  thenByArrivalTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arrivalTime', Sort.desc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  thenByLicensePlate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licensePlate', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  thenByLicensePlateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'licensePlate', Sort.desc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy> thenBySupplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  thenBySupplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.desc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  thenByTotalMistas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMistas', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  thenByTotalMistasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalMistas', Sort.desc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  thenByTotalPallets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPallets', Sort.asc);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QAfterSortBy>
  thenByTotalPalletsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPallets', Sort.desc);
    });
  }
}

extension TruckReceptionQueryWhereDistinct
    on QueryBuilder<TruckReception, TruckReception, QDistinct> {
  QueryBuilder<TruckReception, TruckReception, QDistinct>
  distinctByArrivalTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'arrivalTime');
    });
  }

  QueryBuilder<TruckReception, TruckReception, QDistinct>
  distinctByLicensePlate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'licensePlate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QDistinct> distinctBySupplier({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supplier', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TruckReception, TruckReception, QDistinct>
  distinctByTotalMistas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalMistas');
    });
  }

  QueryBuilder<TruckReception, TruckReception, QDistinct>
  distinctByTotalPallets() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPallets');
    });
  }
}

extension TruckReceptionQueryProperty
    on QueryBuilder<TruckReception, TruckReception, QQueryProperty> {
  QueryBuilder<TruckReception, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TruckReception, DateTime, QQueryOperations>
  arrivalTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'arrivalTime');
    });
  }

  QueryBuilder<TruckReception, String?, QQueryOperations>
  licensePlateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'licensePlate');
    });
  }

  QueryBuilder<TruckReception, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<TruckReception, List<PalletCount>, QQueryOperations>
  palletsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pallets');
    });
  }

  QueryBuilder<TruckReception, List<SentVasilhameItem>, QQueryOperations>
  sentVasilhameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sentVasilhame');
    });
  }

  QueryBuilder<TruckReception, String?, QQueryOperations> supplierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supplier');
    });
  }

  QueryBuilder<TruckReception, int, QQueryOperations> totalMistasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalMistas');
    });
  }

  QueryBuilder<TruckReception, int, QQueryOperations> totalPalletsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPallets');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PalletCountSchema = Schema(
  name: r'PalletCount',
  id: 4770566104238187884,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.byte,
      enumMap: _PalletCountcategoryEnumValueMap,
    ),
    r'mistas': PropertySchema(id: 1, name: r'mistas', type: IsarType.long),
    r'total': PropertySchema(id: 2, name: r'total', type: IsarType.long),
  },

  estimateSize: _palletCountEstimateSize,
  serialize: _palletCountSerialize,
  deserialize: _palletCountDeserialize,
  deserializeProp: _palletCountDeserializeProp,
);

int _palletCountEstimateSize(
  PalletCount object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _palletCountSerialize(
  PalletCount object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.category.index);
  writer.writeLong(offsets[1], object.mistas);
  writer.writeLong(offsets[2], object.total);
}

PalletCount _palletCountDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PalletCount();
  object.category =
      _PalletCountcategoryValueEnumMap[reader.readByteOrNull(offsets[0])] ??
      PalletCategory.frescosCharcutaria;
  object.mistas = reader.readLong(offsets[1]);
  object.total = reader.readLong(offsets[2]);
  return object;
}

P _palletCountDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_PalletCountcategoryValueEnumMap[reader.readByteOrNull(offset)] ??
              PalletCategory.frescosCharcutaria)
          as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PalletCountcategoryEnumValueMap = {
  'frescosCharcutaria': 0,
  'frescosIogurtes': 1,
  'dph': 2,
  'bebidas': 3,
  'mercearia': 4,
  'bazar': 5,
  'leite': 6,
  'animal': 7,
  'vasilhame': 8,
  'congelados': 9,
};
const _PalletCountcategoryValueEnumMap = {
  0: PalletCategory.frescosCharcutaria,
  1: PalletCategory.frescosIogurtes,
  2: PalletCategory.dph,
  3: PalletCategory.bebidas,
  4: PalletCategory.mercearia,
  5: PalletCategory.bazar,
  6: PalletCategory.leite,
  7: PalletCategory.animal,
  8: PalletCategory.vasilhame,
  9: PalletCategory.congelados,
};

extension PalletCountQueryFilter
    on QueryBuilder<PalletCount, PalletCount, QFilterCondition> {
  QueryBuilder<PalletCount, PalletCount, QAfterFilterCondition> categoryEqualTo(
    PalletCategory value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: value),
      );
    });
  }

  QueryBuilder<PalletCount, PalletCount, QAfterFilterCondition>
  categoryGreaterThan(PalletCategory value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'category',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PalletCount, PalletCount, QAfterFilterCondition>
  categoryLessThan(PalletCategory value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'category',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PalletCount, PalletCount, QAfterFilterCondition> categoryBetween(
    PalletCategory lower,
    PalletCategory upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'category',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PalletCount, PalletCount, QAfterFilterCondition> mistasEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mistas', value: value),
      );
    });
  }

  QueryBuilder<PalletCount, PalletCount, QAfterFilterCondition>
  mistasGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mistas',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PalletCount, PalletCount, QAfterFilterCondition> mistasLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mistas',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PalletCount, PalletCount, QAfterFilterCondition> mistasBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mistas',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PalletCount, PalletCount, QAfterFilterCondition> totalEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'total', value: value),
      );
    });
  }

  QueryBuilder<PalletCount, PalletCount, QAfterFilterCondition>
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

  QueryBuilder<PalletCount, PalletCount, QAfterFilterCondition> totalLessThan(
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

  QueryBuilder<PalletCount, PalletCount, QAfterFilterCondition> totalBetween(
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

extension PalletCountQueryObject
    on QueryBuilder<PalletCount, PalletCount, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const SentVasilhameItemSchema = Schema(
  name: r'SentVasilhameItem',
  id: -8432056822164070440,
  properties: {
    r'amount': PropertySchema(id: 0, name: r'amount', type: IsarType.long),
    r'productName': PropertySchema(
      id: 1,
      name: r'productName',
      type: IsarType.string,
    ),
  },

  estimateSize: _sentVasilhameItemEstimateSize,
  serialize: _sentVasilhameItemSerialize,
  deserialize: _sentVasilhameItemDeserialize,
  deserializeProp: _sentVasilhameItemDeserializeProp,
);

int _sentVasilhameItemEstimateSize(
  SentVasilhameItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.productName.length * 3;
  return bytesCount;
}

void _sentVasilhameItemSerialize(
  SentVasilhameItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.amount);
  writer.writeString(offsets[1], object.productName);
}

SentVasilhameItem _sentVasilhameItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SentVasilhameItem();
  object.amount = reader.readLong(offsets[0]);
  object.productName = reader.readString(offsets[1]);
  return object;
}

P _sentVasilhameItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension SentVasilhameItemQueryFilter
    on QueryBuilder<SentVasilhameItem, SentVasilhameItem, QFilterCondition> {
  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
  amountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'amount', value: value),
      );
    });
  }

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
  amountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
  amountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
  amountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
  productNameEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
  productNameGreaterThan(
    String value, {
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

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
  productNameLessThan(
    String value, {
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

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
  productNameBetween(
    String lower,
    String upper, {
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

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
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

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
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

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
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

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
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

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
  productNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'productName', value: ''),
      );
    });
  }

  QueryBuilder<SentVasilhameItem, SentVasilhameItem, QAfterFilterCondition>
  productNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'productName', value: ''),
      );
    });
  }
}

extension SentVasilhameItemQueryObject
    on QueryBuilder<SentVasilhameItem, SentVasilhameItem, QFilterCondition> {}
