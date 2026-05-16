// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pra_tahfidz_santri_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPraTahfidzSantriModelCollection on Isar {
  IsarCollection<PraTahfidzSantriModel> get praTahfidzSantriModels =>
      this.collection();
}

const PraTahfidzSantriModelSchema = CollectionSchema(
  name: r'PraTahfidzSantriModel',
  id: -4241259615207915459,
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
    r'kumulatifHalaman': PropertySchema(
      id: 3,
      name: r'kumulatifHalaman',
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
    r'pointerHalaman': PropertySchema(
      id: 6,
      name: r'pointerHalaman',
      type: IsarType.double,
    ),
    r'rawJson': PropertySchema(
      id: 7,
      name: r'rawJson',
      type: IsarType.string,
    ),
    r'sudahSetor': PropertySchema(
      id: 8,
      name: r'sudahSetor',
      type: IsarType.bool,
    ),
    r'tingkat': PropertySchema(
      id: 9,
      name: r'tingkat',
      type: IsarType.string,
    ),
    r'totalSetoran': PropertySchema(
      id: 10,
      name: r'totalSetoran',
      type: IsarType.long,
    )
  },
  estimateSize: _praTahfidzSantriModelEstimateSize,
  serialize: _praTahfidzSantriModelSerialize,
  deserialize: _praTahfidzSantriModelDeserialize,
  deserializeProp: _praTahfidzSantriModelDeserializeProp,
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
  getId: _praTahfidzSantriModelGetId,
  getLinks: _praTahfidzSantriModelGetLinks,
  attach: _praTahfidzSantriModelAttach,
  version: '3.1.0+1',
);

int _praTahfidzSantriModelEstimateSize(
  PraTahfidzSantriModel object,
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

void _praTahfidzSantriModelSerialize(
  PraTahfidzSantriModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.foto);
  writer.writeLong(offsets[1], object.idKelas);
  writer.writeLong(offsets[2], object.idKelompok);
  writer.writeDouble(offsets[3], object.kumulatifHalaman);
  writer.writeString(offsets[4], object.namaSantri);
  writer.writeString(offsets[5], object.nis);
  writer.writeDouble(offsets[6], object.pointerHalaman);
  writer.writeString(offsets[7], object.rawJson);
  writer.writeBool(offsets[8], object.sudahSetor);
  writer.writeString(offsets[9], object.tingkat);
  writer.writeLong(offsets[10], object.totalSetoran);
}

PraTahfidzSantriModel _praTahfidzSantriModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PraTahfidzSantriModel();
  object.foto = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.idKelas = reader.readLongOrNull(offsets[1]);
  object.idKelompok = reader.readLongOrNull(offsets[2]);
  object.kumulatifHalaman = reader.readDoubleOrNull(offsets[3]);
  object.namaSantri = reader.readStringOrNull(offsets[4]);
  object.nis = reader.readStringOrNull(offsets[5]);
  object.pointerHalaman = reader.readDoubleOrNull(offsets[6]);
  object.rawJson = reader.readStringOrNull(offsets[7]);
  object.sudahSetor = reader.readBoolOrNull(offsets[8]);
  object.tingkat = reader.readStringOrNull(offsets[9]);
  object.totalSetoran = reader.readLongOrNull(offsets[10]);
  return object;
}

P _praTahfidzSantriModelDeserializeProp<P>(
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
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readBoolOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _praTahfidzSantriModelGetId(PraTahfidzSantriModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _praTahfidzSantriModelGetLinks(
    PraTahfidzSantriModel object) {
  return [];
}

void _praTahfidzSantriModelAttach(
    IsarCollection<dynamic> col, Id id, PraTahfidzSantriModel object) {
  object.id = id;
}

extension PraTahfidzSantriModelByIndex
    on IsarCollection<PraTahfidzSantriModel> {
  Future<PraTahfidzSantriModel?> getByNis(String? nis) {
    return getByIndex(r'nis', [nis]);
  }

  PraTahfidzSantriModel? getByNisSync(String? nis) {
    return getByIndexSync(r'nis', [nis]);
  }

  Future<bool> deleteByNis(String? nis) {
    return deleteByIndex(r'nis', [nis]);
  }

  bool deleteByNisSync(String? nis) {
    return deleteByIndexSync(r'nis', [nis]);
  }

  Future<List<PraTahfidzSantriModel?>> getAllByNis(List<String?> nisValues) {
    final values = nisValues.map((e) => [e]).toList();
    return getAllByIndex(r'nis', values);
  }

  List<PraTahfidzSantriModel?> getAllByNisSync(List<String?> nisValues) {
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

  Future<Id> putByNis(PraTahfidzSantriModel object) {
    return putByIndex(r'nis', object);
  }

  Id putByNisSync(PraTahfidzSantriModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'nis', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNis(List<PraTahfidzSantriModel> objects) {
    return putAllByIndex(r'nis', objects);
  }

  List<Id> putAllByNisSync(List<PraTahfidzSantriModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'nis', objects, saveLinks: saveLinks);
  }
}

extension PraTahfidzSantriModelQueryWhereSort
    on QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QWhere> {
  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhere>
      anyIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKelas'),
      );
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhere>
      anyIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKelompok'),
      );
    });
  }
}

extension PraTahfidzSantriModelQueryWhere on QueryBuilder<PraTahfidzSantriModel,
    PraTahfidzSantriModel, QWhereClause> {
  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
      nisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis',
        value: [null],
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
      nisEqualTo(String? nis) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis',
        value: [nis],
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
      idKelasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelas',
        value: [null],
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
      idKelasEqualTo(int? idKelas) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelas',
        value: [idKelas],
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
      idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [null],
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
      idKelompokEqualTo(int? idKelompok) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [idKelompok],
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterWhereClause>
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

extension PraTahfidzSantriModelQueryFilter on QueryBuilder<
    PraTahfidzSantriModel, PraTahfidzSantriModel, QFilterCondition> {
  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> fotoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'foto',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> fotoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'foto',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> fotoEqualTo(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> fotoGreaterThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> fotoLessThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> fotoBetween(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> fotoStartsWith(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> fotoEndsWith(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
          QAfterFilterCondition>
      fotoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'foto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
          QAfterFilterCondition>
      fotoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'foto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> fotoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foto',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> fotoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'foto',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idKelasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKelas',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idKelasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKelas',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idKelasEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelas',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idKelasGreaterThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idKelasLessThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idKelasBetween(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idKelompokIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idKelompokEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelompok',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idKelompokGreaterThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idKelompokLessThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> idKelompokBetween(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> kumulatifHalamanIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'kumulatifHalaman',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> kumulatifHalamanIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'kumulatifHalaman',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> kumulatifHalamanEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kumulatifHalaman',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> kumulatifHalamanGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kumulatifHalaman',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> kumulatifHalamanLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kumulatifHalaman',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> kumulatifHalamanBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kumulatifHalaman',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> namaSantriIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'namaSantri',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> namaSantriIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'namaSantri',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> namaSantriEqualTo(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> namaSantriGreaterThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> namaSantriLessThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> namaSantriBetween(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> namaSantriStartsWith(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> namaSantriEndsWith(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
          QAfterFilterCondition>
      namaSantriContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaSantri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
          QAfterFilterCondition>
      namaSantriMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaSantri',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> namaSantriIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaSantri',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> namaSantriIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaSantri',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> nisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nis',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> nisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nis',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> nisEqualTo(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> nisGreaterThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> nisLessThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> nisBetween(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> nisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> nisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> pointerHalamanIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pointerHalaman',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> pointerHalamanIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pointerHalaman',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> pointerHalamanEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pointerHalaman',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> pointerHalamanGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pointerHalaman',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> pointerHalamanLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pointerHalaman',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> pointerHalamanBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pointerHalaman',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> rawJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rawJson',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> rawJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rawJson',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> rawJsonEqualTo(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> rawJsonGreaterThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> rawJsonLessThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> rawJsonBetween(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> rawJsonStartsWith(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> rawJsonEndsWith(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
          QAfterFilterCondition>
      rawJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
          QAfterFilterCondition>
      rawJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> rawJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawJson',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> rawJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawJson',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> sudahSetorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sudahSetor',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> sudahSetorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sudahSetor',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> sudahSetorEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sudahSetor',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> tingkatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tingkat',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> tingkatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tingkat',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> tingkatEqualTo(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> tingkatGreaterThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> tingkatLessThan(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> tingkatBetween(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> tingkatStartsWith(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> tingkatEndsWith(
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

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
          QAfterFilterCondition>
      tingkatContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tingkat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
          QAfterFilterCondition>
      tingkatMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tingkat',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> tingkatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tingkat',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> tingkatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tingkat',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> totalSetoranIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalSetoran',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> totalSetoranIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalSetoran',
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> totalSetoranEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSetoran',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> totalSetoranGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSetoran',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> totalSetoranLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSetoran',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel,
      QAfterFilterCondition> totalSetoranBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSetoran',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PraTahfidzSantriModelQueryObject on QueryBuilder<
    PraTahfidzSantriModel, PraTahfidzSantriModel, QFilterCondition> {}

extension PraTahfidzSantriModelQueryLinks on QueryBuilder<PraTahfidzSantriModel,
    PraTahfidzSantriModel, QFilterCondition> {}

extension PraTahfidzSantriModelQuerySortBy
    on QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QSortBy> {
  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByFoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foto', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByFotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foto', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByKumulatifHalaman() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kumulatifHalaman', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByKumulatifHalamanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kumulatifHalaman', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByNamaSantri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByNamaSantriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByPointerHalaman() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pointerHalaman', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByPointerHalamanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pointerHalaman', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByRawJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJson', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByRawJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJson', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortBySudahSetor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sudahSetor', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortBySudahSetorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sudahSetor', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByTingkat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByTingkatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByTotalSetoran() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSetoran', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      sortByTotalSetoranDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSetoran', Sort.desc);
    });
  }
}

extension PraTahfidzSantriModelQuerySortThenBy
    on QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QSortThenBy> {
  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByFoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foto', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByFotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'foto', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByKumulatifHalaman() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kumulatifHalaman', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByKumulatifHalamanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kumulatifHalaman', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByNamaSantri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByNamaSantriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByPointerHalaman() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pointerHalaman', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByPointerHalamanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pointerHalaman', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByRawJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJson', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByRawJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawJson', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenBySudahSetor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sudahSetor', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenBySudahSetorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sudahSetor', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByTingkat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByTingkatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByTotalSetoran() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSetoran', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QAfterSortBy>
      thenByTotalSetoranDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSetoran', Sort.desc);
    });
  }
}

extension PraTahfidzSantriModelQueryWhereDistinct
    on QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QDistinct> {
  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QDistinct>
      distinctByFoto({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foto', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QDistinct>
      distinctByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelas');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QDistinct>
      distinctByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelompok');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QDistinct>
      distinctByKumulatifHalaman() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kumulatifHalaman');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QDistinct>
      distinctByNamaSantri({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaSantri', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QDistinct>
      distinctByNis({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QDistinct>
      distinctByPointerHalaman() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pointerHalaman');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QDistinct>
      distinctByRawJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QDistinct>
      distinctBySudahSetor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sudahSetor');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QDistinct>
      distinctByTingkat({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tingkat', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PraTahfidzSantriModel, PraTahfidzSantriModel, QDistinct>
      distinctByTotalSetoran() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSetoran');
    });
  }
}

extension PraTahfidzSantriModelQueryProperty on QueryBuilder<
    PraTahfidzSantriModel, PraTahfidzSantriModel, QQueryProperty> {
  QueryBuilder<PraTahfidzSantriModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, String?, QQueryOperations>
      fotoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foto');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, int?, QQueryOperations>
      idKelasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelas');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, int?, QQueryOperations>
      idKelompokProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelompok');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, double?, QQueryOperations>
      kumulatifHalamanProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kumulatifHalaman');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, String?, QQueryOperations>
      namaSantriProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaSantri');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, String?, QQueryOperations> nisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nis');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, double?, QQueryOperations>
      pointerHalamanProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pointerHalaman');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, String?, QQueryOperations>
      rawJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawJson');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, bool?, QQueryOperations>
      sudahSetorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sudahSetor');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, String?, QQueryOperations>
      tingkatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tingkat');
    });
  }

  QueryBuilder<PraTahfidzSantriModel, int?, QQueryOperations>
      totalSetoranProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSetoran');
    });
  }
}
