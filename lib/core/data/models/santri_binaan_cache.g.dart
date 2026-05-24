// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'santri_binaan_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSantriBinaanCacheCollection on Isar {
  IsarCollection<SantriBinaanCache> get santriBinaanCaches => this.collection();
}

const SantriBinaanCacheSchema = CollectionSchema(
  name: r'SantriBinaanCache',
  id: -5229814279950968622,
  properties: {
    r'idKelas': PropertySchema(
      id: 0,
      name: r'idKelas',
      type: IsarType.long,
    ),
    r'kodeJalur': PropertySchema(
      id: 1,
      name: r'kodeJalur',
      type: IsarType.string,
    ),
    r'nama': PropertySchema(
      id: 2,
      name: r'nama',
      type: IsarType.string,
    ),
    r'nis': PropertySchema(
      id: 3,
      name: r'nis',
      type: IsarType.string,
    ),
    r'tingkatKelas': PropertySchema(
      id: 4,
      name: r'tingkatKelas',
      type: IsarType.string,
    )
  },
  estimateSize: _santriBinaanCacheEstimateSize,
  serialize: _santriBinaanCacheSerialize,
  deserialize: _santriBinaanCacheDeserialize,
  deserializeProp: _santriBinaanCacheDeserializeProp,
  idName: r'id',
  indexes: {
    r'nis': IndexSchema(
      id: -7696866782291048883,
      name: r'nis',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'nis',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _santriBinaanCacheGetId,
  getLinks: _santriBinaanCacheGetLinks,
  attach: _santriBinaanCacheAttach,
  version: '3.1.0+1',
);

int _santriBinaanCacheEstimateSize(
  SantriBinaanCache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.kodeJalur;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.nama.length * 3;
  bytesCount += 3 + object.nis.length * 3;
  {
    final value = object.tingkatKelas;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _santriBinaanCacheSerialize(
  SantriBinaanCache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.idKelas);
  writer.writeString(offsets[1], object.kodeJalur);
  writer.writeString(offsets[2], object.nama);
  writer.writeString(offsets[3], object.nis);
  writer.writeString(offsets[4], object.tingkatKelas);
}

SantriBinaanCache _santriBinaanCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SantriBinaanCache();
  object.id = id;
  object.idKelas = reader.readLong(offsets[0]);
  object.kodeJalur = reader.readStringOrNull(offsets[1]);
  object.nama = reader.readString(offsets[2]);
  object.nis = reader.readString(offsets[3]);
  object.tingkatKelas = reader.readStringOrNull(offsets[4]);
  return object;
}

P _santriBinaanCacheDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _santriBinaanCacheGetId(SantriBinaanCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _santriBinaanCacheGetLinks(
    SantriBinaanCache object) {
  return [];
}

void _santriBinaanCacheAttach(
    IsarCollection<dynamic> col, Id id, SantriBinaanCache object) {
  object.id = id;
}

extension SantriBinaanCacheByIndex on IsarCollection<SantriBinaanCache> {
  Future<SantriBinaanCache?> getByNis(String nis) {
    return getByIndex(r'nis', [nis]);
  }

  SantriBinaanCache? getByNisSync(String nis) {
    return getByIndexSync(r'nis', [nis]);
  }

  Future<bool> deleteByNis(String nis) {
    return deleteByIndex(r'nis', [nis]);
  }

  bool deleteByNisSync(String nis) {
    return deleteByIndexSync(r'nis', [nis]);
  }

  Future<List<SantriBinaanCache?>> getAllByNis(List<String> nisValues) {
    final values = nisValues.map((e) => [e]).toList();
    return getAllByIndex(r'nis', values);
  }

  List<SantriBinaanCache?> getAllByNisSync(List<String> nisValues) {
    final values = nisValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'nis', values);
  }

  Future<int> deleteAllByNis(List<String> nisValues) {
    final values = nisValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'nis', values);
  }

  int deleteAllByNisSync(List<String> nisValues) {
    final values = nisValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'nis', values);
  }

  Future<Id> putByNis(SantriBinaanCache object) {
    return putByIndex(r'nis', object);
  }

  Id putByNisSync(SantriBinaanCache object, {bool saveLinks = true}) {
    return putByIndexSync(r'nis', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNis(List<SantriBinaanCache> objects) {
    return putAllByIndex(r'nis', objects);
  }

  List<Id> putAllByNisSync(List<SantriBinaanCache> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'nis', objects, saveLinks: saveLinks);
  }
}

extension SantriBinaanCacheQueryWhereSort
    on QueryBuilder<SantriBinaanCache, SantriBinaanCache, QWhere> {
  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SantriBinaanCacheQueryWhere
    on QueryBuilder<SantriBinaanCache, SantriBinaanCache, QWhereClause> {
  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterWhereClause>
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

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterWhereClause>
      nisEqualTo(String nis) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis',
        value: [nis],
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterWhereClause>
      nisNotEqualTo(String nis) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nis',
              lower: [],
              upper: [nis],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nis',
              lower: [nis],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nis',
              lower: [nis],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nis',
              lower: [],
              upper: [nis],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SantriBinaanCacheQueryFilter
    on QueryBuilder<SantriBinaanCache, SantriBinaanCache, QFilterCondition> {
  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      idKelasEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelas',
        value: value,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      idKelasGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idKelas',
        value: value,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      idKelasLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idKelas',
        value: value,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      idKelasBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idKelas',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      kodeJalurIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'kodeJalur',
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      kodeJalurIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'kodeJalur',
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      kodeJalurEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kodeJalur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      kodeJalurGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kodeJalur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      kodeJalurLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kodeJalur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      kodeJalurBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kodeJalur',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      kodeJalurStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'kodeJalur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      kodeJalurEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'kodeJalur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      kodeJalurContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kodeJalur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      kodeJalurMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kodeJalur',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      kodeJalurIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kodeJalur',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      kodeJalurIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kodeJalur',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      namaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      namaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      namaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      namaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nama',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      namaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      namaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      namaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      namaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nama',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      namaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nama',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      namaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nama',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      nisEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      nisGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      nisLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      nisBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nis',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      nisStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      nisEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      nisContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      nisMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nis',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      nisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      nisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      tingkatKelasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tingkatKelas',
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      tingkatKelasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tingkatKelas',
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      tingkatKelasEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tingkatKelas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      tingkatKelasGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tingkatKelas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      tingkatKelasLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tingkatKelas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      tingkatKelasBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tingkatKelas',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      tingkatKelasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tingkatKelas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      tingkatKelasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tingkatKelas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      tingkatKelasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tingkatKelas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      tingkatKelasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tingkatKelas',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      tingkatKelasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tingkatKelas',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterFilterCondition>
      tingkatKelasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tingkatKelas',
        value: '',
      ));
    });
  }
}

extension SantriBinaanCacheQueryObject
    on QueryBuilder<SantriBinaanCache, SantriBinaanCache, QFilterCondition> {}

extension SantriBinaanCacheQueryLinks
    on QueryBuilder<SantriBinaanCache, SantriBinaanCache, QFilterCondition> {}

extension SantriBinaanCacheQuerySortBy
    on QueryBuilder<SantriBinaanCache, SantriBinaanCache, QSortBy> {
  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      sortByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      sortByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      sortByKodeJalur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kodeJalur', Sort.asc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      sortByKodeJalurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kodeJalur', Sort.desc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      sortByNama() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.asc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      sortByNamaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.desc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy> sortByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      sortByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      sortByTingkatKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkatKelas', Sort.asc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      sortByTingkatKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkatKelas', Sort.desc);
    });
  }
}

extension SantriBinaanCacheQuerySortThenBy
    on QueryBuilder<SantriBinaanCache, SantriBinaanCache, QSortThenBy> {
  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      thenByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      thenByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      thenByKodeJalur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kodeJalur', Sort.asc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      thenByKodeJalurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kodeJalur', Sort.desc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      thenByNama() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.asc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      thenByNamaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.desc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy> thenByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      thenByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      thenByTingkatKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkatKelas', Sort.asc);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QAfterSortBy>
      thenByTingkatKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkatKelas', Sort.desc);
    });
  }
}

extension SantriBinaanCacheQueryWhereDistinct
    on QueryBuilder<SantriBinaanCache, SantriBinaanCache, QDistinct> {
  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QDistinct>
      distinctByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelas');
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QDistinct>
      distinctByKodeJalur({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kodeJalur', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QDistinct> distinctByNama(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nama', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QDistinct> distinctByNis(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SantriBinaanCache, SantriBinaanCache, QDistinct>
      distinctByTingkatKelas({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tingkatKelas', caseSensitive: caseSensitive);
    });
  }
}

extension SantriBinaanCacheQueryProperty
    on QueryBuilder<SantriBinaanCache, SantriBinaanCache, QQueryProperty> {
  QueryBuilder<SantriBinaanCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SantriBinaanCache, int, QQueryOperations> idKelasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelas');
    });
  }

  QueryBuilder<SantriBinaanCache, String?, QQueryOperations>
      kodeJalurProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kodeJalur');
    });
  }

  QueryBuilder<SantriBinaanCache, String, QQueryOperations> namaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nama');
    });
  }

  QueryBuilder<SantriBinaanCache, String, QQueryOperations> nisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nis');
    });
  }

  QueryBuilder<SantriBinaanCache, String?, QQueryOperations>
      tingkatKelasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tingkatKelas');
    });
  }
}
