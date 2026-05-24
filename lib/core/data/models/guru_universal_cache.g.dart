// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guru_universal_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGuruUniversalCacheCollection on Isar {
  IsarCollection<GuruUniversalCache> get guruUniversalCaches =>
      this.collection();
}

const GuruUniversalCacheSchema = CollectionSchema(
  name: r'GuruUniversalCache',
  id: -6764036278945770215,
  properties: {
    r'nama': PropertySchema(
      id: 0,
      name: r'nama',
      type: IsarType.string,
    ),
    r'nig': PropertySchema(
      id: 1,
      name: r'nig',
      type: IsarType.string,
    )
  },
  estimateSize: _guruUniversalCacheEstimateSize,
  serialize: _guruUniversalCacheSerialize,
  deserialize: _guruUniversalCacheDeserialize,
  deserializeProp: _guruUniversalCacheDeserializeProp,
  idName: r'id',
  indexes: {
    r'nig': IndexSchema(
      id: 2537609945333237678,
      name: r'nig',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'nig',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _guruUniversalCacheGetId,
  getLinks: _guruUniversalCacheGetLinks,
  attach: _guruUniversalCacheAttach,
  version: '3.1.0+1',
);

int _guruUniversalCacheEstimateSize(
  GuruUniversalCache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.nama.length * 3;
  bytesCount += 3 + object.nig.length * 3;
  return bytesCount;
}

void _guruUniversalCacheSerialize(
  GuruUniversalCache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.nama);
  writer.writeString(offsets[1], object.nig);
}

GuruUniversalCache _guruUniversalCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GuruUniversalCache();
  object.id = id;
  object.nama = reader.readString(offsets[0]);
  object.nig = reader.readString(offsets[1]);
  return object;
}

P _guruUniversalCacheDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _guruUniversalCacheGetId(GuruUniversalCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _guruUniversalCacheGetLinks(
    GuruUniversalCache object) {
  return [];
}

void _guruUniversalCacheAttach(
    IsarCollection<dynamic> col, Id id, GuruUniversalCache object) {
  object.id = id;
}

extension GuruUniversalCacheByIndex on IsarCollection<GuruUniversalCache> {
  Future<GuruUniversalCache?> getByNig(String nig) {
    return getByIndex(r'nig', [nig]);
  }

  GuruUniversalCache? getByNigSync(String nig) {
    return getByIndexSync(r'nig', [nig]);
  }

  Future<bool> deleteByNig(String nig) {
    return deleteByIndex(r'nig', [nig]);
  }

  bool deleteByNigSync(String nig) {
    return deleteByIndexSync(r'nig', [nig]);
  }

  Future<List<GuruUniversalCache?>> getAllByNig(List<String> nigValues) {
    final values = nigValues.map((e) => [e]).toList();
    return getAllByIndex(r'nig', values);
  }

  List<GuruUniversalCache?> getAllByNigSync(List<String> nigValues) {
    final values = nigValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'nig', values);
  }

  Future<int> deleteAllByNig(List<String> nigValues) {
    final values = nigValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'nig', values);
  }

  int deleteAllByNigSync(List<String> nigValues) {
    final values = nigValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'nig', values);
  }

  Future<Id> putByNig(GuruUniversalCache object) {
    return putByIndex(r'nig', object);
  }

  Id putByNigSync(GuruUniversalCache object, {bool saveLinks = true}) {
    return putByIndexSync(r'nig', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNig(List<GuruUniversalCache> objects) {
    return putAllByIndex(r'nig', objects);
  }

  List<Id> putAllByNigSync(List<GuruUniversalCache> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'nig', objects, saveLinks: saveLinks);
  }
}

extension GuruUniversalCacheQueryWhereSort
    on QueryBuilder<GuruUniversalCache, GuruUniversalCache, QWhere> {
  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GuruUniversalCacheQueryWhere
    on QueryBuilder<GuruUniversalCache, GuruUniversalCache, QWhereClause> {
  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterWhereClause>
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

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterWhereClause>
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

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterWhereClause>
      nigEqualTo(String nig) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nig',
        value: [nig],
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterWhereClause>
      nigNotEqualTo(String nig) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nig',
              lower: [],
              upper: [nig],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nig',
              lower: [nig],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nig',
              lower: [nig],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nig',
              lower: [],
              upper: [nig],
              includeUpper: false,
            ));
      }
    });
  }
}

extension GuruUniversalCacheQueryFilter
    on QueryBuilder<GuruUniversalCache, GuruUniversalCache, QFilterCondition> {
  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
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

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
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

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
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

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
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

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
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

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
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

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
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

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
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

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
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

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      namaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      namaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nama',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      namaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nama',
        value: '',
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      namaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nama',
        value: '',
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      nigEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nig',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      nigGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nig',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      nigLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nig',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      nigBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nig',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      nigStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nig',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      nigEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nig',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      nigContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nig',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      nigMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nig',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      nigIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nig',
        value: '',
      ));
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterFilterCondition>
      nigIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nig',
        value: '',
      ));
    });
  }
}

extension GuruUniversalCacheQueryObject
    on QueryBuilder<GuruUniversalCache, GuruUniversalCache, QFilterCondition> {}

extension GuruUniversalCacheQueryLinks
    on QueryBuilder<GuruUniversalCache, GuruUniversalCache, QFilterCondition> {}

extension GuruUniversalCacheQuerySortBy
    on QueryBuilder<GuruUniversalCache, GuruUniversalCache, QSortBy> {
  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterSortBy>
      sortByNama() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.asc);
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterSortBy>
      sortByNamaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.desc);
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterSortBy>
      sortByNig() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nig', Sort.asc);
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterSortBy>
      sortByNigDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nig', Sort.desc);
    });
  }
}

extension GuruUniversalCacheQuerySortThenBy
    on QueryBuilder<GuruUniversalCache, GuruUniversalCache, QSortThenBy> {
  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterSortBy>
      thenByNama() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.asc);
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterSortBy>
      thenByNamaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.desc);
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterSortBy>
      thenByNig() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nig', Sort.asc);
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QAfterSortBy>
      thenByNigDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nig', Sort.desc);
    });
  }
}

extension GuruUniversalCacheQueryWhereDistinct
    on QueryBuilder<GuruUniversalCache, GuruUniversalCache, QDistinct> {
  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QDistinct>
      distinctByNama({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nama', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GuruUniversalCache, GuruUniversalCache, QDistinct> distinctByNig(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nig', caseSensitive: caseSensitive);
    });
  }
}

extension GuruUniversalCacheQueryProperty
    on QueryBuilder<GuruUniversalCache, GuruUniversalCache, QQueryProperty> {
  QueryBuilder<GuruUniversalCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GuruUniversalCache, String, QQueryOperations> namaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nama');
    });
  }

  QueryBuilder<GuruUniversalCache, String, QQueryOperations> nigProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nig');
    });
  }
}
