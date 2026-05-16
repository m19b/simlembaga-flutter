// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_santri_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProgressSantriModelCollection on Isar {
  IsarCollection<ProgressSantriModel> get progressSantriModels =>
      this.collection();
}

const ProgressSantriModelSchema = CollectionSchema(
  name: r'ProgressSantriModel',
  id: -5187968615443811271,
  properties: {
    r'halamanTerakhir': PropertySchema(
      id: 0,
      name: r'halamanTerakhir',
      type: IsarType.string,
    ),
    r'idKelas': PropertySchema(
      id: 1,
      name: r'idKelas',
      type: IsarType.long,
    ),
    r'idKelompok': PropertySchema(
      id: 2,
      name: r'idKelompok',
      type: IsarType.long,
    ),
    r'namaKelompok': PropertySchema(
      id: 3,
      name: r'namaKelompok',
      type: IsarType.string,
    ),
    r'namaSantri': PropertySchema(
      id: 4,
      name: r'namaSantri',
      type: IsarType.string,
    ),
    r'nis': PropertySchema(
      id: 5,
      name: r'nis',
      type: IsarType.string,
    ),
    r'rawJson': PropertySchema(
      id: 6,
      name: r'rawJson',
      type: IsarType.string,
    ),
    r'statusTerakhir': PropertySchema(
      id: 7,
      name: r'statusTerakhir',
      type: IsarType.string,
    ),
    r'tingkat': PropertySchema(
      id: 8,
      name: r'tingkat',
      type: IsarType.string,
    )
  },
  estimateSize: _progressSantriModelEstimateSize,
  serialize: _progressSantriModelSerialize,
  deserialize: _progressSantriModelDeserialize,
  deserializeProp: _progressSantriModelDeserializeProp,
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
    ),
    r'idKelas': IndexSchema(
      id: 902129728910038944,
      name: r'idKelas',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'idKelas',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'idKelompok': IndexSchema(
      id: 2014046695997885612,
      name: r'idKelompok',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'idKelompok',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _progressSantriModelGetId,
  getLinks: _progressSantriModelGetLinks,
  attach: _progressSantriModelAttach,
  version: '3.1.0+1',
);

int _progressSantriModelEstimateSize(
  ProgressSantriModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.halamanTerakhir;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.namaKelompok;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.namaSantri;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.nis;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rawJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.statusTerakhir;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tingkat;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _progressSantriModelSerialize(
  ProgressSantriModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.halamanTerakhir);
  writer.writeLong(offsets[1], object.idKelas);
  writer.writeLong(offsets[2], object.idKelompok);
  writer.writeString(offsets[3], object.namaKelompok);
  writer.writeString(offsets[4], object.namaSantri);
  writer.writeString(offsets[5], object.nis);
  writer.writeString(offsets[6], object.rawJson);
  writer.writeString(offsets[7], object.statusTerakhir);
  writer.writeString(offsets[8], object.tingkat);
}

ProgressSantriModel _progressSantriModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProgressSantriModel();
  object.halamanTerakhir = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.idKelas = reader.readLongOrNull(offsets[1]);
  object.idKelompok = reader.readLongOrNull(offsets[2]);
  object.namaKelompok = reader.readStringOrNull(offsets[3]);
  object.namaSantri = reader.readStringOrNull(offsets[4]);
  object.nis = reader.readStringOrNull(offsets[5]);
  object.rawJson = reader.readStringOrNull(offsets[6]);
  object.statusTerakhir = reader.readStringOrNull(offsets[7]);
  object.tingkat = reader.readStringOrNull(offsets[8]);
  return object;
}

P _progressSantriModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _progressSantriModelGetId(ProgressSantriModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _progressSantriModelGetLinks(
    ProgressSantriModel object) {
  return [];
}

void _progressSantriModelAttach(
    IsarCollection<dynamic> col, Id id, ProgressSantriModel object) {
  object.id = id;
}

extension ProgressSantriModelByIndex on IsarCollection<ProgressSantriModel> {
  Future<ProgressSantriModel?> getByNis(String? nis) {
    return getByIndex(r'nis', [nis]);
  }

  ProgressSantriModel? getByNisSync(String? nis) {
    return getByIndexSync(r'nis', [nis]);
  }

  Future<bool> deleteByNis(String? nis) {
    return deleteByIndex(r'nis', [nis]);
  }

  bool deleteByNisSync(String? nis) {
    return deleteByIndexSync(r'nis', [nis]);
  }

  Future<List<ProgressSantriModel?>> getAllByNis(List<String?> nisValues) {
    final values = nisValues.map((e) => [e]).toList();
    return getAllByIndex(r'nis', values);
  }

  List<ProgressSantriModel?> getAllByNisSync(List<String?> nisValues) {
    final values = nisValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'nis', values);
  }

  Future<int> deleteAllByNis(List<String?> nisValues) {
    final values = nisValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'nis', values);
  }

  int deleteAllByNisSync(List<String?> nisValues) {
    final values = nisValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'nis', values);
  }

  Future<Id> putByNis(ProgressSantriModel object) {
    return putByIndex(r'nis', object);
  }

  Id putByNisSync(ProgressSantriModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'nis', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNis(List<ProgressSantriModel> objects) {
    return putAllByIndex(r'nis', objects);
  }

  List<Id> putAllByNisSync(List<ProgressSantriModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'nis', objects, saveLinks: saveLinks);
  }
}

extension ProgressSantriModelQueryWhereSort
    on QueryBuilder<ProgressSantriModel, ProgressSantriModel, QWhere> {
  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhere>
      anyIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKelas'),
      );
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhere>
      anyIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKelompok'),
      );
    });
  }
}

extension ProgressSantriModelQueryWhere
    on QueryBuilder<ProgressSantriModel, ProgressSantriModel, QWhereClause> {
  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      nisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis',
        value: [null],
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      nisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nis',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      nisEqualTo(String? nis) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis',
        value: [nis],
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      nisNotEqualTo(String? nis) {
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelas',
        value: [null],
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKelas',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelasEqualTo(int? idKelas) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelas',
        value: [idKelas],
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelasNotEqualTo(int? idKelas) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idKelas',
              lower: [],
              upper: [idKelas],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idKelas',
              lower: [idKelas],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idKelas',
              lower: [idKelas],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idKelas',
              lower: [],
              upper: [idKelas],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelasGreaterThan(
    int? idKelas, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKelas',
        lower: [idKelas],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelasLessThan(
    int? idKelas, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKelas',
        lower: [],
        upper: [idKelas],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelasBetween(
    int? lowerIdKelas,
    int? upperIdKelas, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKelas',
        lower: [lowerIdKelas],
        includeLower: includeLower,
        upper: [upperIdKelas],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [null],
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelompokIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKelompok',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelompokEqualTo(int? idKelompok) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [idKelompok],
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelompokNotEqualTo(int? idKelompok) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idKelompok',
              lower: [],
              upper: [idKelompok],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idKelompok',
              lower: [idKelompok],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idKelompok',
              lower: [idKelompok],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idKelompok',
              lower: [],
              upper: [idKelompok],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelompokGreaterThan(
    int? idKelompok, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKelompok',
        lower: [idKelompok],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelompokLessThan(
    int? idKelompok, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKelompok',
        lower: [],
        upper: [idKelompok],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterWhereClause>
      idKelompokBetween(
    int? lowerIdKelompok,
    int? upperIdKelompok, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKelompok',
        lower: [lowerIdKelompok],
        includeLower: includeLower,
        upper: [upperIdKelompok],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProgressSantriModelQueryFilter on QueryBuilder<ProgressSantriModel,
    ProgressSantriModel, QFilterCondition> {
  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      halamanTerakhirIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'halamanTerakhir',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      halamanTerakhirIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'halamanTerakhir',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      halamanTerakhirEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'halamanTerakhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      halamanTerakhirGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'halamanTerakhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      halamanTerakhirLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'halamanTerakhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      halamanTerakhirBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'halamanTerakhir',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      halamanTerakhirStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'halamanTerakhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      halamanTerakhirEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'halamanTerakhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      halamanTerakhirContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'halamanTerakhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      halamanTerakhirMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'halamanTerakhir',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      halamanTerakhirIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'halamanTerakhir',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      halamanTerakhirIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'halamanTerakhir',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idKelasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKelas',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idKelasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKelas',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idKelasEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelas',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idKelasGreaterThan(
    int? value, {
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idKelasLessThan(
    int? value, {
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idKelasBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idKelompokIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idKelompokEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelompok',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idKelompokGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idKelompok',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idKelompokLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idKelompok',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      idKelompokBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idKelompok',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'namaKelompok',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaKelompokIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'namaKelompok',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaKelompokEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaKelompok',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaKelompokGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'namaKelompok',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaKelompokLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'namaKelompok',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaKelompokBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'namaKelompok',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaKelompokStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'namaKelompok',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaKelompokEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'namaKelompok',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaKelompokContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaKelompok',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaKelompokMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaKelompok',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaKelompokIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaKelompok',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaKelompokIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaKelompok',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaSantriIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'namaSantri',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaSantriIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'namaSantri',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaSantriEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaSantri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaSantriGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'namaSantri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaSantriLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'namaSantri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaSantriBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'namaSantri',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaSantriStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'namaSantri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaSantriEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'namaSantri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaSantriContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaSantri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaSantriMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaSantri',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaSantriIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaSantri',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      namaSantriIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaSantri',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      nisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nis',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      nisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nis',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      nisEqualTo(
    String? value, {
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      nisGreaterThan(
    String? value, {
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      nisLessThan(
    String? value, {
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      nisBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
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

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      nisContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      nisMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nis',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      nisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      nisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      rawJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rawJson',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      rawJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rawJson',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      rawJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      rawJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      rawJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      rawJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      rawJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      rawJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      rawJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      rawJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      rawJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      rawJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      statusTerakhirIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'statusTerakhir',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      statusTerakhirIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'statusTerakhir',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      statusTerakhirEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusTerakhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      statusTerakhirGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statusTerakhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      statusTerakhirLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statusTerakhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      statusTerakhirBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statusTerakhir',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      statusTerakhirStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'statusTerakhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      statusTerakhirEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'statusTerakhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      statusTerakhirContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'statusTerakhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      statusTerakhirMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'statusTerakhir',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      statusTerakhirIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusTerakhir',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      statusTerakhirIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'statusTerakhir',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      tingkatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tingkat',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      tingkatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tingkat',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      tingkatEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tingkat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      tingkatGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tingkat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      tingkatLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tingkat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      tingkatBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tingkat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      tingkatStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tingkat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      tingkatEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tingkat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      tingkatContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tingkat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      tingkatMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tingkat',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      tingkatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tingkat',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterFilterCondition>
      tingkatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tingkat',
        value: '',
      ));
    });
  }
}

extension ProgressSantriModelQueryObject on QueryBuilder<ProgressSantriModel,
    ProgressSantriModel, QFilterCondition> {}

extension ProgressSantriModelQueryLinks on QueryBuilder<ProgressSantriModel,
    ProgressSantriModel, QFilterCondition> {}

extension ProgressSantriModelQuerySortBy
    on QueryBuilder<ProgressSantriModel, ProgressSantriModel, QSortBy> {
  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByHalamanTerakhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halamanTerakhir', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByHalamanTerakhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halamanTerakhir', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByNamaKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaKelompok', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByNamaKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaKelompok', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByNamaSantri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByNamaSantriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByRawJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJson', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByRawJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJson', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByStatusTerakhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusTerakhir', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByStatusTerakhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusTerakhir', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByTingkat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      sortByTingkatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.desc);
    });
  }
}

extension ProgressSantriModelQuerySortThenBy
    on QueryBuilder<ProgressSantriModel, ProgressSantriModel, QSortThenBy> {
  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByHalamanTerakhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halamanTerakhir', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByHalamanTerakhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halamanTerakhir', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByNamaKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaKelompok', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByNamaKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaKelompok', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByNamaSantri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByNamaSantriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByRawJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJson', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByRawJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJson', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByStatusTerakhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusTerakhir', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByStatusTerakhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusTerakhir', Sort.desc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByTingkat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.asc);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QAfterSortBy>
      thenByTingkatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.desc);
    });
  }
}

extension ProgressSantriModelQueryWhereDistinct
    on QueryBuilder<ProgressSantriModel, ProgressSantriModel, QDistinct> {
  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QDistinct>
      distinctByHalamanTerakhir({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'halamanTerakhir',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QDistinct>
      distinctByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelas');
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QDistinct>
      distinctByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelompok');
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QDistinct>
      distinctByNamaKelompok({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaKelompok', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QDistinct>
      distinctByNamaSantri({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaSantri', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QDistinct>
      distinctByNis({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QDistinct>
      distinctByRawJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QDistinct>
      distinctByStatusTerakhir({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statusTerakhir',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProgressSantriModel, ProgressSantriModel, QDistinct>
      distinctByTingkat({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tingkat', caseSensitive: caseSensitive);
    });
  }
}

extension ProgressSantriModelQueryProperty
    on QueryBuilder<ProgressSantriModel, ProgressSantriModel, QQueryProperty> {
  QueryBuilder<ProgressSantriModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProgressSantriModel, String?, QQueryOperations>
      halamanTerakhirProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'halamanTerakhir');
    });
  }

  QueryBuilder<ProgressSantriModel, int?, QQueryOperations> idKelasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelas');
    });
  }

  QueryBuilder<ProgressSantriModel, int?, QQueryOperations>
      idKelompokProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelompok');
    });
  }

  QueryBuilder<ProgressSantriModel, String?, QQueryOperations>
      namaKelompokProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaKelompok');
    });
  }

  QueryBuilder<ProgressSantriModel, String?, QQueryOperations>
      namaSantriProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaSantri');
    });
  }

  QueryBuilder<ProgressSantriModel, String?, QQueryOperations> nisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nis');
    });
  }

  QueryBuilder<ProgressSantriModel, String?, QQueryOperations>
      rawJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawJson');
    });
  }

  QueryBuilder<ProgressSantriModel, String?, QQueryOperations>
      statusTerakhirProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusTerakhir');
    });
  }

  QueryBuilder<ProgressSantriModel, String?, QQueryOperations>
      tingkatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tingkat');
    });
  }
}
