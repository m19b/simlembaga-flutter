// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tahfidz_santri_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTahfidzSantriModelCollection on Isar {
  IsarCollection<TahfidzSantriModel> get tahfidzSantriModels =>
      this.collection();
}

const TahfidzSantriModelSchema = CollectionSchema(
  name: r'TahfidzSantriModel',
  id: -5700120774973498079,
  properties: {
    r'foto': PropertySchema(
      id: 0,
      name: r'foto',
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
    r'mutqinRate': PropertySchema(
      id: 3,
      name: r'mutqinRate',
      type: IsarType.double,
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
    r'sudahSetor': PropertySchema(
      id: 7,
      name: r'sudahSetor',
      type: IsarType.bool,
    ),
    r'tingkat': PropertySchema(
      id: 8,
      name: r'tingkat',
      type: IsarType.string,
    ),
    r'totalManzilHal': PropertySchema(
      id: 9,
      name: r'totalManzilHal',
      type: IsarType.double,
    ),
    r'totalSabaqHal': PropertySchema(
      id: 10,
      name: r'totalSabaqHal',
      type: IsarType.double,
    ),
    r'totalZiyadahHal': PropertySchema(
      id: 11,
      name: r'totalZiyadahHal',
      type: IsarType.double,
    )
  },
  estimateSize: _tahfidzSantriModelEstimateSize,
  serialize: _tahfidzSantriModelSerialize,
  deserialize: _tahfidzSantriModelDeserialize,
  deserializeProp: _tahfidzSantriModelDeserializeProp,
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
  getId: _tahfidzSantriModelGetId,
  getLinks: _tahfidzSantriModelGetLinks,
  attach: _tahfidzSantriModelAttach,
  version: '3.1.0+1',
);

int _tahfidzSantriModelEstimateSize(
  TahfidzSantriModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.foto;
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
    final value = object.tingkat;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _tahfidzSantriModelSerialize(
  TahfidzSantriModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.foto);
  writer.writeLong(offsets[1], object.idKelas);
  writer.writeLong(offsets[2], object.idKelompok);
  writer.writeDouble(offsets[3], object.mutqinRate);
  writer.writeString(offsets[4], object.namaSantri);
  writer.writeString(offsets[5], object.nis);
  writer.writeString(offsets[6], object.rawJson);
  writer.writeBool(offsets[7], object.sudahSetor);
  writer.writeString(offsets[8], object.tingkat);
  writer.writeDouble(offsets[9], object.totalManzilHal);
  writer.writeDouble(offsets[10], object.totalSabaqHal);
  writer.writeDouble(offsets[11], object.totalZiyadahHal);
}

TahfidzSantriModel _tahfidzSantriModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TahfidzSantriModel();
  object.foto = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.idKelas = reader.readLongOrNull(offsets[1]);
  object.idKelompok = reader.readLongOrNull(offsets[2]);
  object.mutqinRate = reader.readDoubleOrNull(offsets[3]);
  object.namaSantri = reader.readStringOrNull(offsets[4]);
  object.nis = reader.readStringOrNull(offsets[5]);
  object.rawJson = reader.readStringOrNull(offsets[6]);
  object.sudahSetor = reader.readBoolOrNull(offsets[7]);
  object.tingkat = reader.readStringOrNull(offsets[8]);
  object.totalManzilHal = reader.readDoubleOrNull(offsets[9]);
  object.totalSabaqHal = reader.readDoubleOrNull(offsets[10]);
  object.totalZiyadahHal = reader.readDoubleOrNull(offsets[11]);
  return object;
}

P _tahfidzSantriModelDeserializeProp<P>(
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
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readBoolOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tahfidzSantriModelGetId(TahfidzSantriModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tahfidzSantriModelGetLinks(
    TahfidzSantriModel object) {
  return [];
}

void _tahfidzSantriModelAttach(
    IsarCollection<dynamic> col, Id id, TahfidzSantriModel object) {
  object.id = id;
}

extension TahfidzSantriModelByIndex on IsarCollection<TahfidzSantriModel> {
  Future<TahfidzSantriModel?> getByNis(String? nis) {
    return getByIndex(r'nis', [nis]);
  }

  TahfidzSantriModel? getByNisSync(String? nis) {
    return getByIndexSync(r'nis', [nis]);
  }

  Future<bool> deleteByNis(String? nis) {
    return deleteByIndex(r'nis', [nis]);
  }

  bool deleteByNisSync(String? nis) {
    return deleteByIndexSync(r'nis', [nis]);
  }

  Future<List<TahfidzSantriModel?>> getAllByNis(List<String?> nisValues) {
    final values = nisValues.map((e) => [e]).toList();
    return getAllByIndex(r'nis', values);
  }

  List<TahfidzSantriModel?> getAllByNisSync(List<String?> nisValues) {
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

  Future<Id> putByNis(TahfidzSantriModel object) {
    return putByIndex(r'nis', object);
  }

  Id putByNisSync(TahfidzSantriModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'nis', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNis(List<TahfidzSantriModel> objects) {
    return putAllByIndex(r'nis', objects);
  }

  List<Id> putAllByNisSync(List<TahfidzSantriModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'nis', objects, saveLinks: saveLinks);
  }
}

extension TahfidzSantriModelQueryWhereSort
    on QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QWhere> {
  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhere>
      anyIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKelas'),
      );
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhere>
      anyIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKelompok'),
      );
    });
  }
}

extension TahfidzSantriModelQueryWhere
    on QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QWhereClause> {
  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
      nisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis',
        value: [null],
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
      nisEqualTo(String? nis) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis',
        value: [nis],
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
      idKelasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelas',
        value: [null],
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
      idKelasEqualTo(int? idKelas) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelas',
        value: [idKelas],
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
      idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [null],
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
      idKelompokEqualTo(int? idKelompok) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [idKelompok],
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterWhereClause>
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

extension TahfidzSantriModelQueryFilter
    on QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QFilterCondition> {
  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      fotoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'foto',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      fotoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'foto',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      fotoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      fotoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'foto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      fotoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'foto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      fotoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'foto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      fotoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'foto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      fotoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'foto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      fotoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'foto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      fotoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'foto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      fotoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foto',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      fotoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'foto',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      idKelasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKelas',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      idKelasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKelas',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      idKelasEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelas',
        value: value,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      idKelompokIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      idKelompokEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelompok',
        value: value,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      mutqinRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mutqinRate',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      mutqinRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mutqinRate',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      mutqinRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mutqinRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      mutqinRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mutqinRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      mutqinRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mutqinRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      mutqinRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mutqinRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      namaSantriIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'namaSantri',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      namaSantriIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'namaSantri',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      namaSantriContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaSantri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      namaSantriMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaSantri',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      namaSantriIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaSantri',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      namaSantriIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaSantri',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      nisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nis',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      nisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nis',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      nisContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      nisMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nis',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      nisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      nisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      rawJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rawJson',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      rawJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rawJson',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      rawJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      rawJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      rawJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      rawJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      sudahSetorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sudahSetor',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      sudahSetorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sudahSetor',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      sudahSetorEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sudahSetor',
        value: value,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      tingkatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tingkat',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      tingkatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tingkat',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      tingkatContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tingkat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      tingkatMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tingkat',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      tingkatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tingkat',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      tingkatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tingkat',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalManzilHalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalManzilHal',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalManzilHalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalManzilHal',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalManzilHalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalManzilHal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalManzilHalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalManzilHal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalManzilHalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalManzilHal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalManzilHalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalManzilHal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalSabaqHalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalSabaqHal',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalSabaqHalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalSabaqHal',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalSabaqHalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSabaqHal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalSabaqHalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSabaqHal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalSabaqHalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSabaqHal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalSabaqHalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSabaqHal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalZiyadahHalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalZiyadahHal',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalZiyadahHalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalZiyadahHal',
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalZiyadahHalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalZiyadahHal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalZiyadahHalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalZiyadahHal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalZiyadahHalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalZiyadahHal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterFilterCondition>
      totalZiyadahHalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalZiyadahHal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension TahfidzSantriModelQueryObject
    on QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QFilterCondition> {}

extension TahfidzSantriModelQueryLinks
    on QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QFilterCondition> {}

extension TahfidzSantriModelQuerySortBy
    on QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QSortBy> {
  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByFoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foto', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByFotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foto', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByMutqinRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mutqinRate', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByMutqinRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mutqinRate', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByNamaSantri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByNamaSantriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByRawJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJson', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByRawJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJson', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortBySudahSetor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sudahSetor', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortBySudahSetorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sudahSetor', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByTingkat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByTingkatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByTotalManzilHal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalManzilHal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByTotalManzilHalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalManzilHal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByTotalSabaqHal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSabaqHal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByTotalSabaqHalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSabaqHal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByTotalZiyadahHal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalZiyadahHal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      sortByTotalZiyadahHalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalZiyadahHal', Sort.desc);
    });
  }
}

extension TahfidzSantriModelQuerySortThenBy
    on QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QSortThenBy> {
  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByFoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foto', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByFotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foto', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByMutqinRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mutqinRate', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByMutqinRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mutqinRate', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByNamaSantri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByNamaSantriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByRawJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJson', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByRawJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJson', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenBySudahSetor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sudahSetor', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenBySudahSetorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sudahSetor', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByTingkat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByTingkatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByTotalManzilHal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalManzilHal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByTotalManzilHalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalManzilHal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByTotalSabaqHal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSabaqHal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByTotalSabaqHalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSabaqHal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByTotalZiyadahHal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalZiyadahHal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QAfterSortBy>
      thenByTotalZiyadahHalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalZiyadahHal', Sort.desc);
    });
  }
}

extension TahfidzSantriModelQueryWhereDistinct
    on QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct> {
  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct>
      distinctByFoto({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foto', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct>
      distinctByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelas');
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct>
      distinctByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelompok');
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct>
      distinctByMutqinRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mutqinRate');
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct>
      distinctByNamaSantri({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaSantri', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct> distinctByNis(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct>
      distinctByRawJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct>
      distinctBySudahSetor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sudahSetor');
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct>
      distinctByTingkat({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tingkat', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct>
      distinctByTotalManzilHal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalManzilHal');
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct>
      distinctByTotalSabaqHal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSabaqHal');
    });
  }

  QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QDistinct>
      distinctByTotalZiyadahHal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalZiyadahHal');
    });
  }
}

extension TahfidzSantriModelQueryProperty
    on QueryBuilder<TahfidzSantriModel, TahfidzSantriModel, QQueryProperty> {
  QueryBuilder<TahfidzSantriModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TahfidzSantriModel, String?, QQueryOperations> fotoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foto');
    });
  }

  QueryBuilder<TahfidzSantriModel, int?, QQueryOperations> idKelasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelas');
    });
  }

  QueryBuilder<TahfidzSantriModel, int?, QQueryOperations>
      idKelompokProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelompok');
    });
  }

  QueryBuilder<TahfidzSantriModel, double?, QQueryOperations>
      mutqinRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mutqinRate');
    });
  }

  QueryBuilder<TahfidzSantriModel, String?, QQueryOperations>
      namaSantriProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaSantri');
    });
  }

  QueryBuilder<TahfidzSantriModel, String?, QQueryOperations> nisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nis');
    });
  }

  QueryBuilder<TahfidzSantriModel, String?, QQueryOperations>
      rawJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawJson');
    });
  }

  QueryBuilder<TahfidzSantriModel, bool?, QQueryOperations>
      sudahSetorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sudahSetor');
    });
  }

  QueryBuilder<TahfidzSantriModel, String?, QQueryOperations>
      tingkatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tingkat');
    });
  }

  QueryBuilder<TahfidzSantriModel, double?, QQueryOperations>
      totalManzilHalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalManzilHal');
    });
  }

  QueryBuilder<TahfidzSantriModel, double?, QQueryOperations>
      totalSabaqHalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSabaqHal');
    });
  }

  QueryBuilder<TahfidzSantriModel, double?, QQueryOperations>
      totalZiyadahHalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalZiyadahHal');
    });
  }
}
