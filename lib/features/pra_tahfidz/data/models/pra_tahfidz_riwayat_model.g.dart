// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pra_tahfidz_riwayat_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPraTahfidzRiwayatModelCollection on Isar {
  IsarCollection<PraTahfidzRiwayatModel> get praTahfidzRiwayatModels =>
      this.collection();
}

const PraTahfidzRiwayatModelSchema = CollectionSchema(
  name: r'PraTahfidzRiwayatModel',
  id: 3884397916872644136,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'halAkhir': PropertySchema(
      id: 1,
      name: r'halAkhir',
      type: IsarType.double,
    ),
    r'halAwal': PropertySchema(
      id: 2,
      name: r'halAwal',
      type: IsarType.double,
    ),
    r'idKelas': PropertySchema(
      id: 3,
      name: r'idKelas',
      type: IsarType.long,
    ),
    r'idKelompok': PropertySchema(
      id: 4,
      name: r'idKelompok',
      type: IsarType.long,
    ),
    r'namaGuru': PropertySchema(
      id: 5,
      name: r'namaGuru',
      type: IsarType.string,
    ),
    r'nis': PropertySchema(
      id: 6,
      name: r'nis',
      type: IsarType.string,
    ),
    r'sesi': PropertySchema(
      id: 7,
      name: r'sesi',
      type: IsarType.string,
    ),
    r'statusBacaan': PropertySchema(
      id: 8,
      name: r'statusBacaan',
      type: IsarType.string,
    ),
    r'sumberInput': PropertySchema(
      id: 9,
      name: r'sumberInput',
      type: IsarType.string,
    ),
    r'tanggal': PropertySchema(
      id: 10,
      name: r'tanggal',
      type: IsarType.string,
    ),
    r'totalHal': PropertySchema(
      id: 11,
      name: r'totalHal',
      type: IsarType.double,
    )
  },
  estimateSize: _praTahfidzRiwayatModelEstimateSize,
  serialize: _praTahfidzRiwayatModelSerialize,
  deserialize: _praTahfidzRiwayatModelDeserialize,
  deserializeProp: _praTahfidzRiwayatModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'nis': IndexSchema(
      id: -7696866782291048883,
      name: r'nis',
      unique: false,
      replace: false,
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
  getId: _praTahfidzRiwayatModelGetId,
  getLinks: _praTahfidzRiwayatModelGetLinks,
  attach: _praTahfidzRiwayatModelAttach,
  version: '3.1.0+1',
);

int _praTahfidzRiwayatModelEstimateSize(
  PraTahfidzRiwayatModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.namaGuru;
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
    final value = object.sesi;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.statusBacaan;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sumberInput;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tanggal;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _praTahfidzRiwayatModelSerialize(
  PraTahfidzRiwayatModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDouble(offsets[1], object.halAkhir);
  writer.writeDouble(offsets[2], object.halAwal);
  writer.writeLong(offsets[3], object.idKelas);
  writer.writeLong(offsets[4], object.idKelompok);
  writer.writeString(offsets[5], object.namaGuru);
  writer.writeString(offsets[6], object.nis);
  writer.writeString(offsets[7], object.sesi);
  writer.writeString(offsets[8], object.statusBacaan);
  writer.writeString(offsets[9], object.sumberInput);
  writer.writeString(offsets[10], object.tanggal);
  writer.writeDouble(offsets[11], object.totalHal);
}

PraTahfidzRiwayatModel _praTahfidzRiwayatModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PraTahfidzRiwayatModel();
  object.createdAt = reader.readDateTimeOrNull(offsets[0]);
  object.halAkhir = reader.readDoubleOrNull(offsets[1]);
  object.halAwal = reader.readDoubleOrNull(offsets[2]);
  object.id = id;
  object.idKelas = reader.readLongOrNull(offsets[3]);
  object.idKelompok = reader.readLongOrNull(offsets[4]);
  object.namaGuru = reader.readStringOrNull(offsets[5]);
  object.nis = reader.readStringOrNull(offsets[6]);
  object.sesi = reader.readStringOrNull(offsets[7]);
  object.statusBacaan = reader.readStringOrNull(offsets[8]);
  object.sumberInput = reader.readStringOrNull(offsets[9]);
  object.tanggal = reader.readStringOrNull(offsets[10]);
  object.totalHal = reader.readDoubleOrNull(offsets[11]);
  return object;
}

P _praTahfidzRiwayatModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _praTahfidzRiwayatModelGetId(PraTahfidzRiwayatModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _praTahfidzRiwayatModelGetLinks(
    PraTahfidzRiwayatModel object) {
  return [];
}

void _praTahfidzRiwayatModelAttach(
    IsarCollection<dynamic> col, Id id, PraTahfidzRiwayatModel object) {
  object.id = id;
}

extension PraTahfidzRiwayatModelQueryWhereSort
    on QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QWhere> {
  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterWhere>
      anyIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKelas'),
      );
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterWhere>
      anyIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKelompok'),
      );
    });
  }
}

extension PraTahfidzRiwayatModelQueryWhere on QueryBuilder<
    PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QWhereClause> {
  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> nisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis',
        value: [null],
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> nisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nis',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> nisEqualTo(String? nis) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis',
        value: [nis],
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> nisNotEqualTo(String? nis) {
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelas',
        value: [null],
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKelas',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelasEqualTo(int? idKelas) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelas',
        value: [idKelas],
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelasNotEqualTo(int? idKelas) {
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelasGreaterThan(
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelasLessThan(
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelasBetween(
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [null],
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelompokIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKelompok',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelompokEqualTo(int? idKelompok) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [idKelompok],
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelompokNotEqualTo(int? idKelompok) {
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelompokGreaterThan(
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelompokLessThan(
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterWhereClause> idKelompokBetween(
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

extension PraTahfidzRiwayatModelQueryFilter on QueryBuilder<
    PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QFilterCondition> {
  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> halAkhirIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'halAkhir',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> halAkhirIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'halAkhir',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> halAkhirEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'halAkhir',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> halAkhirGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'halAkhir',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> halAkhirLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'halAkhir',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> halAkhirBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'halAkhir',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> halAwalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'halAwal',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> halAwalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'halAwal',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> halAwalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'halAwal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> halAwalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'halAwal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> halAwalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'halAwal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> halAwalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'halAwal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> idKelasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKelas',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> idKelasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKelas',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> idKelasEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelas',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> idKelompokIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> idKelompokEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelompok',
        value: value,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> namaGuruIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'namaGuru',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> namaGuruIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'namaGuru',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> namaGuruEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaGuru',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> namaGuruGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'namaGuru',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> namaGuruLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'namaGuru',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> namaGuruBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'namaGuru',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> namaGuruStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'namaGuru',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> namaGuruEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'namaGuru',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
          QAfterFilterCondition>
      namaGuruContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaGuru',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
          QAfterFilterCondition>
      namaGuruMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaGuru',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> namaGuruIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaGuru',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> namaGuruIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaGuru',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> nisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nis',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> nisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nis',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
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

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> nisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> nisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sesiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sesi',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sesiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sesi',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sesiEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sesi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sesiGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sesi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sesiLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sesi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sesiBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sesi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sesiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sesi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sesiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sesi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
          QAfterFilterCondition>
      sesiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sesi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
          QAfterFilterCondition>
      sesiMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sesi',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sesiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sesi',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sesiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sesi',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> statusBacaanIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'statusBacaan',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> statusBacaanIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'statusBacaan',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> statusBacaanEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusBacaan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> statusBacaanGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statusBacaan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> statusBacaanLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statusBacaan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> statusBacaanBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statusBacaan',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> statusBacaanStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'statusBacaan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> statusBacaanEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'statusBacaan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
          QAfterFilterCondition>
      statusBacaanContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'statusBacaan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
          QAfterFilterCondition>
      statusBacaanMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'statusBacaan',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> statusBacaanIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusBacaan',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> statusBacaanIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'statusBacaan',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sumberInputIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sumberInput',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sumberInputIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sumberInput',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sumberInputEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sumberInput',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sumberInputGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sumberInput',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sumberInputLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sumberInput',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sumberInputBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sumberInput',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sumberInputStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sumberInput',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sumberInputEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sumberInput',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
          QAfterFilterCondition>
      sumberInputContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sumberInput',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
          QAfterFilterCondition>
      sumberInputMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sumberInput',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sumberInputIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sumberInput',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> sumberInputIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sumberInput',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> tanggalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tanggal',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> tanggalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tanggal',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> tanggalEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> tanggalGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> tanggalLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> tanggalBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tanggal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> tanggalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> tanggalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
          QAfterFilterCondition>
      tanggalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
          QAfterFilterCondition>
      tanggalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tanggal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> tanggalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggal',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> tanggalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tanggal',
        value: '',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> totalHalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalHal',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> totalHalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalHal',
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> totalHalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalHal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> totalHalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalHal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> totalHalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalHal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel,
      QAfterFilterCondition> totalHalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalHal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension PraTahfidzRiwayatModelQueryObject on QueryBuilder<
    PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QFilterCondition> {}

extension PraTahfidzRiwayatModelQueryLinks on QueryBuilder<
    PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QFilterCondition> {}

extension PraTahfidzRiwayatModelQuerySortBy
    on QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QSortBy> {
  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByHalAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halAkhir', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByHalAkhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halAkhir', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByHalAwal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halAwal', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByHalAwalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halAwal', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByNamaGuru() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaGuru', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByNamaGuruDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaGuru', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortBySesi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sesi', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortBySesiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sesi', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByStatusBacaan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusBacaan', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByStatusBacaanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusBacaan', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortBySumberInput() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sumberInput', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortBySumberInputDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sumberInput', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByTanggal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggal', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByTanggalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggal', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByTotalHal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHal', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      sortByTotalHalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHal', Sort.desc);
    });
  }
}

extension PraTahfidzRiwayatModelQuerySortThenBy on QueryBuilder<
    PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QSortThenBy> {
  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByHalAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halAkhir', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByHalAkhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halAkhir', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByHalAwal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halAwal', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByHalAwalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halAwal', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByNamaGuru() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaGuru', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByNamaGuruDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaGuru', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenBySesi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sesi', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenBySesiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sesi', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByStatusBacaan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusBacaan', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByStatusBacaanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusBacaan', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenBySumberInput() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sumberInput', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenBySumberInputDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sumberInput', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByTanggal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggal', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByTanggalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggal', Sort.desc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByTotalHal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHal', Sort.asc);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QAfterSortBy>
      thenByTotalHalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalHal', Sort.desc);
    });
  }
}

extension PraTahfidzRiwayatModelQueryWhereDistinct
    on QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct> {
  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct>
      distinctByHalAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'halAkhir');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct>
      distinctByHalAwal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'halAwal');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct>
      distinctByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelas');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct>
      distinctByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelompok');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct>
      distinctByNamaGuru({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaGuru', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct>
      distinctByNis({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct>
      distinctBySesi({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sesi', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct>
      distinctByStatusBacaan({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statusBacaan', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct>
      distinctBySumberInput({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sumberInput', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct>
      distinctByTanggal({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tanggal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QDistinct>
      distinctByTotalHal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalHal');
    });
  }
}

extension PraTahfidzRiwayatModelQueryProperty on QueryBuilder<
    PraTahfidzRiwayatModel, PraTahfidzRiwayatModel, QQueryProperty> {
  QueryBuilder<PraTahfidzRiwayatModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, double?, QQueryOperations>
      halAkhirProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'halAkhir');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, double?, QQueryOperations>
      halAwalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'halAwal');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, int?, QQueryOperations>
      idKelasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelas');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, int?, QQueryOperations>
      idKelompokProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelompok');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, String?, QQueryOperations>
      namaGuruProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaGuru');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, String?, QQueryOperations>
      nisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nis');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, String?, QQueryOperations>
      sesiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sesi');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, String?, QQueryOperations>
      statusBacaanProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusBacaan');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, String?, QQueryOperations>
      sumberInputProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sumberInput');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, String?, QQueryOperations>
      tanggalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tanggal');
    });
  }

  QueryBuilder<PraTahfidzRiwayatModel, double?, QQueryOperations>
      totalHalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalHal');
    });
  }
}
