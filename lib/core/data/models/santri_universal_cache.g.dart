// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'santri_universal_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSantriUniversalCacheCollection on Isar {
  IsarCollection<SantriUniversalCache> get santriUniversalCaches =>
      this.collection();
}

const SantriUniversalCacheSchema = CollectionSchema(
  name: r'SantriUniversalCache',
  id: -5326148758359252350,
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
  estimateSize: _santriUniversalCacheEstimateSize,
  serialize: _santriUniversalCacheSerialize,
  deserialize: _santriUniversalCacheDeserialize,
  deserializeProp: _santriUniversalCacheDeserializeProp,
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
  getId: _santriUniversalCacheGetId,
  getLinks: _santriUniversalCacheGetLinks,
  attach: _santriUniversalCacheAttach,
  version: '3.1.0+1',
);

int _santriUniversalCacheEstimateSize(
  SantriUniversalCache object,
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

void _santriUniversalCacheSerialize(
  SantriUniversalCache object,
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

SantriUniversalCache _santriUniversalCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SantriUniversalCache();
  object.id = id;
  object.idKelas = reader.readLong(offsets[0]);
  object.kodeJalur = reader.readStringOrNull(offsets[1]);
  object.nama = reader.readString(offsets[2]);
  object.nis = reader.readString(offsets[3]);
  object.tingkatKelas = reader.readStringOrNull(offsets[4]);
  return object;
}

P _santriUniversalCacheDeserializeProp<P>(
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

Id _santriUniversalCacheGetId(SantriUniversalCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _santriUniversalCacheGetLinks(
    SantriUniversalCache object) {
  return [];
}

void _santriUniversalCacheAttach(
    IsarCollection<dynamic> col, Id id, SantriUniversalCache object) {
  object.id = id;
}

extension SantriUniversalCacheByIndex on IsarCollection<SantriUniversalCache> {
  Future<SantriUniversalCache?> getByNis(String nis) {
    return getByIndex(r'nis', [nis]);
  }

  SantriUniversalCache? getByNisSync(String nis) {
    return getByIndexSync(r'nis', [nis]);
  }

  Future<bool> deleteByNis(String nis) {
    return deleteByIndex(r'nis', [nis]);
  }

  bool deleteByNisSync(String nis) {
    return deleteByIndexSync(r'nis', [nis]);
  }

  Future<List<SantriUniversalCache?>> getAllByNis(List<String> nisValues) {
    final values = nisValues.map((e) => [e]).toList();
    return getAllByIndex(r'nis', values);
  }

  List<SantriUniversalCache?> getAllByNisSync(List<String> nisValues) {
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

  Future<Id> putByNis(SantriUniversalCache object) {
    return putByIndex(r'nis', object);
  }

  Id putByNisSync(SantriUniversalCache object, {bool saveLinks = true}) {
    return putByIndexSync(r'nis', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNis(List<SantriUniversalCache> objects) {
    return putAllByIndex(r'nis', objects);
  }

  List<Id> putAllByNisSync(List<SantriUniversalCache> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'nis', objects, saveLinks: saveLinks);
  }
}

extension SantriUniversalCacheQueryWhereSort
    on QueryBuilder<SantriUniversalCache, SantriUniversalCache, QWhere> {
  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SantriUniversalCacheQueryWhere
    on QueryBuilder<SantriUniversalCache, SantriUniversalCache, QWhereClause> {
  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterWhereClause>
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterWhereClause>
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterWhereClause>
      nisEqualTo(String nis) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis',
        value: [nis],
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterWhereClause>
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

extension SantriUniversalCacheQueryFilter on QueryBuilder<SantriUniversalCache,
    SantriUniversalCache, QFilterCondition> {
  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> idKelasEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelas',
        value: value,
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> idKelasGreaterThan(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> idKelasLessThan(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> idKelasBetween(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> kodeJalurIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'kodeJalur',
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> kodeJalurIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'kodeJalur',
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> kodeJalurEqualTo(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> kodeJalurGreaterThan(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> kodeJalurLessThan(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> kodeJalurBetween(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> kodeJalurStartsWith(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> kodeJalurEndsWith(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
          QAfterFilterCondition>
      kodeJalurContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kodeJalur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
          QAfterFilterCondition>
      kodeJalurMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kodeJalur',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> kodeJalurIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kodeJalur',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> kodeJalurIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kodeJalur',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> namaEqualTo(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> namaGreaterThan(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> namaLessThan(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> namaBetween(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> namaStartsWith(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> namaEndsWith(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
          QAfterFilterCondition>
      namaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
          QAfterFilterCondition>
      namaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nama',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> namaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nama',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> namaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nama',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> nisEqualTo(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> nisGreaterThan(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> nisLessThan(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> nisBetween(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> nisStartsWith(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> nisEndsWith(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
          QAfterFilterCondition>
      nisContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
          QAfterFilterCondition>
      nisMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nis',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> nisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> nisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> tingkatKelasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tingkatKelas',
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> tingkatKelasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tingkatKelas',
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> tingkatKelasEqualTo(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> tingkatKelasGreaterThan(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> tingkatKelasLessThan(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> tingkatKelasBetween(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> tingkatKelasStartsWith(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> tingkatKelasEndsWith(
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

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
          QAfterFilterCondition>
      tingkatKelasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tingkatKelas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
          QAfterFilterCondition>
      tingkatKelasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tingkatKelas',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> tingkatKelasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tingkatKelas',
        value: '',
      ));
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache,
      QAfterFilterCondition> tingkatKelasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tingkatKelas',
        value: '',
      ));
    });
  }
}

extension SantriUniversalCacheQueryObject on QueryBuilder<SantriUniversalCache,
    SantriUniversalCache, QFilterCondition> {}

extension SantriUniversalCacheQueryLinks on QueryBuilder<SantriUniversalCache,
    SantriUniversalCache, QFilterCondition> {}

extension SantriUniversalCacheQuerySortBy
    on QueryBuilder<SantriUniversalCache, SantriUniversalCache, QSortBy> {
  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      sortByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      sortByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      sortByKodeJalur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kodeJalur', Sort.asc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      sortByKodeJalurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kodeJalur', Sort.desc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      sortByNama() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.asc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      sortByNamaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.desc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      sortByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      sortByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      sortByTingkatKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkatKelas', Sort.asc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      sortByTingkatKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkatKelas', Sort.desc);
    });
  }
}

extension SantriUniversalCacheQuerySortThenBy
    on QueryBuilder<SantriUniversalCache, SantriUniversalCache, QSortThenBy> {
  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      thenByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      thenByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      thenByKodeJalur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kodeJalur', Sort.asc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      thenByKodeJalurDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kodeJalur', Sort.desc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      thenByNama() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.asc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      thenByNamaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.desc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      thenByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      thenByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      thenByTingkatKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkatKelas', Sort.asc);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QAfterSortBy>
      thenByTingkatKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkatKelas', Sort.desc);
    });
  }
}

extension SantriUniversalCacheQueryWhereDistinct
    on QueryBuilder<SantriUniversalCache, SantriUniversalCache, QDistinct> {
  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QDistinct>
      distinctByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelas');
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QDistinct>
      distinctByKodeJalur({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kodeJalur', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QDistinct>
      distinctByNama({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nama', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QDistinct>
      distinctByNis({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SantriUniversalCache, SantriUniversalCache, QDistinct>
      distinctByTingkatKelas({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tingkatKelas', caseSensitive: caseSensitive);
    });
  }
}

extension SantriUniversalCacheQueryProperty on QueryBuilder<
    SantriUniversalCache, SantriUniversalCache, QQueryProperty> {
  QueryBuilder<SantriUniversalCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SantriUniversalCache, int, QQueryOperations> idKelasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelas');
    });
  }

  QueryBuilder<SantriUniversalCache, String?, QQueryOperations>
      kodeJalurProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kodeJalur');
    });
  }

  QueryBuilder<SantriUniversalCache, String, QQueryOperations> namaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nama');
    });
  }

  QueryBuilder<SantriUniversalCache, String, QQueryOperations> nisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nis');
    });
  }

  QueryBuilder<SantriUniversalCache, String?, QQueryOperations>
      tingkatKelasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tingkatKelas');
    });
  }
}
