// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tahfidz_riwayat_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTahfidzRiwayatModelCollection on Isar {
  IsarCollection<TahfidzRiwayatModel> get tahfidzRiwayatModels =>
      this.collection();
}

const TahfidzRiwayatModelSchema = CollectionSchema(
  name: r'TahfidzRiwayatModel',
  id: 8550349204041614962,
  properties: {
    r'idKelas': PropertySchema(
      id: 0,
      name: r'idKelas',
      type: IsarType.long,
    ),
    r'idKelompok': PropertySchema(
      id: 1,
      name: r'idKelompok',
      type: IsarType.long,
    ),
    r'manzilAkhir': PropertySchema(
      id: 2,
      name: r'manzilAkhir',
      type: IsarType.double,
    ),
    r'manzilAwal': PropertySchema(
      id: 3,
      name: r'manzilAwal',
      type: IsarType.double,
    ),
    r'manzilTotal': PropertySchema(
      id: 4,
      name: r'manzilTotal',
      type: IsarType.double,
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
    r'sabaqAkhir': PropertySchema(
      id: 7,
      name: r'sabaqAkhir',
      type: IsarType.double,
    ),
    r'sabaqAwal': PropertySchema(
      id: 8,
      name: r'sabaqAwal',
      type: IsarType.double,
    ),
    r'sabaqTotal': PropertySchema(
      id: 9,
      name: r'sabaqTotal',
      type: IsarType.double,
    ),
    r'statusLulus': PropertySchema(
      id: 10,
      name: r'statusLulus',
      type: IsarType.string,
    ),
    r'tanggal': PropertySchema(
      id: 11,
      name: r'tanggal',
      type: IsarType.dateTime,
    ),
    r'ziyadahAkhir': PropertySchema(
      id: 12,
      name: r'ziyadahAkhir',
      type: IsarType.double,
    ),
    r'ziyadahAwal': PropertySchema(
      id: 13,
      name: r'ziyadahAwal',
      type: IsarType.double,
    ),
    r'ziyadahTotal': PropertySchema(
      id: 14,
      name: r'ziyadahTotal',
      type: IsarType.double,
    )
  },
  estimateSize: _tahfidzRiwayatModelEstimateSize,
  serialize: _tahfidzRiwayatModelSerialize,
  deserialize: _tahfidzRiwayatModelDeserialize,
  deserializeProp: _tahfidzRiwayatModelDeserializeProp,
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
    r'tanggal': IndexSchema(
      id: 5193070597002198496,
      name: r'tanggal',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tanggal',
          type: IndexType.value,
          caseSensitive: false,
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
  getId: _tahfidzRiwayatModelGetId,
  getLinks: _tahfidzRiwayatModelGetLinks,
  attach: _tahfidzRiwayatModelAttach,
  version: '3.1.0+1',
);

int _tahfidzRiwayatModelEstimateSize(
  TahfidzRiwayatModel object,
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
    final value = object.statusLulus;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _tahfidzRiwayatModelSerialize(
  TahfidzRiwayatModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.idKelas);
  writer.writeLong(offsets[1], object.idKelompok);
  writer.writeDouble(offsets[2], object.manzilAkhir);
  writer.writeDouble(offsets[3], object.manzilAwal);
  writer.writeDouble(offsets[4], object.manzilTotal);
  writer.writeString(offsets[5], object.namaGuru);
  writer.writeString(offsets[6], object.nis);
  writer.writeDouble(offsets[7], object.sabaqAkhir);
  writer.writeDouble(offsets[8], object.sabaqAwal);
  writer.writeDouble(offsets[9], object.sabaqTotal);
  writer.writeString(offsets[10], object.statusLulus);
  writer.writeDateTime(offsets[11], object.tanggal);
  writer.writeDouble(offsets[12], object.ziyadahAkhir);
  writer.writeDouble(offsets[13], object.ziyadahAwal);
  writer.writeDouble(offsets[14], object.ziyadahTotal);
}

TahfidzRiwayatModel _tahfidzRiwayatModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TahfidzRiwayatModel();
  object.id = id;
  object.idKelas = reader.readLongOrNull(offsets[0]);
  object.idKelompok = reader.readLongOrNull(offsets[1]);
  object.manzilAkhir = reader.readDoubleOrNull(offsets[2]);
  object.manzilAwal = reader.readDoubleOrNull(offsets[3]);
  object.manzilTotal = reader.readDoubleOrNull(offsets[4]);
  object.namaGuru = reader.readStringOrNull(offsets[5]);
  object.nis = reader.readStringOrNull(offsets[6]);
  object.sabaqAkhir = reader.readDoubleOrNull(offsets[7]);
  object.sabaqAwal = reader.readDoubleOrNull(offsets[8]);
  object.sabaqTotal = reader.readDoubleOrNull(offsets[9]);
  object.statusLulus = reader.readStringOrNull(offsets[10]);
  object.tanggal = reader.readDateTimeOrNull(offsets[11]);
  object.ziyadahAkhir = reader.readDoubleOrNull(offsets[12]);
  object.ziyadahAwal = reader.readDoubleOrNull(offsets[13]);
  object.ziyadahTotal = reader.readDoubleOrNull(offsets[14]);
  return object;
}

P _tahfidzRiwayatModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readDoubleOrNull(offset)) as P;
    case 14:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tahfidzRiwayatModelGetId(TahfidzRiwayatModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tahfidzRiwayatModelGetLinks(
    TahfidzRiwayatModel object) {
  return [];
}

void _tahfidzRiwayatModelAttach(
    IsarCollection<dynamic> col, Id id, TahfidzRiwayatModel object) {
  object.id = id;
}

extension TahfidzRiwayatModelQueryWhereSort
    on QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QWhere> {
  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhere>
      anyTanggal() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'tanggal'),
      );
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhere>
      anyIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKelas'),
      );
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhere>
      anyIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKelompok'),
      );
    });
  }
}

extension TahfidzRiwayatModelQueryWhere
    on QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QWhereClause> {
  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      nisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis',
        value: [null],
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      nisEqualTo(String? nis) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis',
        value: [nis],
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      tanggalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tanggal',
        value: [null],
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      tanggalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tanggal',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      tanggalEqualTo(DateTime? tanggal) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tanggal',
        value: [tanggal],
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      tanggalNotEqualTo(DateTime? tanggal) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tanggal',
              lower: [],
              upper: [tanggal],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tanggal',
              lower: [tanggal],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tanggal',
              lower: [tanggal],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tanggal',
              lower: [],
              upper: [tanggal],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      tanggalGreaterThan(
    DateTime? tanggal, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tanggal',
        lower: [tanggal],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      tanggalLessThan(
    DateTime? tanggal, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tanggal',
        lower: [],
        upper: [tanggal],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      tanggalBetween(
    DateTime? lowerTanggal,
    DateTime? upperTanggal, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tanggal',
        lower: [lowerTanggal],
        includeLower: includeLower,
        upper: [upperTanggal],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      idKelasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelas',
        value: [null],
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      idKelasEqualTo(int? idKelas) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelas',
        value: [idKelas],
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [null],
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
      idKelompokEqualTo(int? idKelompok) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [idKelompok],
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterWhereClause>
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

extension TahfidzRiwayatModelQueryFilter on QueryBuilder<TahfidzRiwayatModel,
    TahfidzRiwayatModel, QFilterCondition> {
  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      idKelasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKelas',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      idKelasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKelas',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      idKelasEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelas',
        value: value,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      idKelompokIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      idKelompokEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelompok',
        value: value,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilAkhirIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'manzilAkhir',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilAkhirIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'manzilAkhir',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilAkhirEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'manzilAkhir',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilAkhirGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'manzilAkhir',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilAkhirLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'manzilAkhir',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilAkhirBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'manzilAkhir',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilAwalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'manzilAwal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilAwalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'manzilAwal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilAwalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'manzilAwal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilAwalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'manzilAwal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilAwalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'manzilAwal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilAwalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'manzilAwal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilTotalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'manzilTotal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilTotalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'manzilTotal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilTotalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'manzilTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilTotalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'manzilTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilTotalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'manzilTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      manzilTotalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'manzilTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      namaGuruIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'namaGuru',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      namaGuruIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'namaGuru',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      namaGuruEqualTo(
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      namaGuruGreaterThan(
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      namaGuruLessThan(
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      namaGuruBetween(
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      namaGuruStartsWith(
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      namaGuruEndsWith(
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      namaGuruContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaGuru',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      namaGuruMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaGuru',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      namaGuruIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaGuru',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      namaGuruIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaGuru',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      nisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nis',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      nisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nis',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
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

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      nisContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      nisMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nis',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      nisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      nisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqAkhirIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sabaqAkhir',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqAkhirIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sabaqAkhir',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqAkhirEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sabaqAkhir',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqAkhirGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sabaqAkhir',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqAkhirLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sabaqAkhir',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqAkhirBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sabaqAkhir',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqAwalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sabaqAwal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqAwalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sabaqAwal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqAwalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sabaqAwal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqAwalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sabaqAwal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqAwalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sabaqAwal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqAwalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sabaqAwal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqTotalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sabaqTotal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqTotalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sabaqTotal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqTotalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sabaqTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqTotalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sabaqTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqTotalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sabaqTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      sabaqTotalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sabaqTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      statusLulusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'statusLulus',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      statusLulusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'statusLulus',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      statusLulusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusLulus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      statusLulusGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statusLulus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      statusLulusLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statusLulus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      statusLulusBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statusLulus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      statusLulusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'statusLulus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      statusLulusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'statusLulus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      statusLulusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'statusLulus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      statusLulusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'statusLulus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      statusLulusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusLulus',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      statusLulusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'statusLulus',
        value: '',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      tanggalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tanggal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      tanggalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tanggal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      tanggalEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggal',
        value: value,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      tanggalGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tanggal',
        value: value,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      tanggalLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tanggal',
        value: value,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      tanggalBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tanggal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahAkhirIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ziyadahAkhir',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahAkhirIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ziyadahAkhir',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahAkhirEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ziyadahAkhir',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahAkhirGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ziyadahAkhir',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahAkhirLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ziyadahAkhir',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahAkhirBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ziyadahAkhir',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahAwalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ziyadahAwal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahAwalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ziyadahAwal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahAwalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ziyadahAwal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahAwalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ziyadahAwal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahAwalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ziyadahAwal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahAwalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ziyadahAwal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahTotalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ziyadahTotal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahTotalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ziyadahTotal',
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahTotalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ziyadahTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahTotalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ziyadahTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahTotalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ziyadahTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterFilterCondition>
      ziyadahTotalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ziyadahTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension TahfidzRiwayatModelQueryObject on QueryBuilder<TahfidzRiwayatModel,
    TahfidzRiwayatModel, QFilterCondition> {}

extension TahfidzRiwayatModelQueryLinks on QueryBuilder<TahfidzRiwayatModel,
    TahfidzRiwayatModel, QFilterCondition> {}

extension TahfidzRiwayatModelQuerySortBy
    on QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QSortBy> {
  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByManzilAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manzilAkhir', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByManzilAkhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manzilAkhir', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByManzilAwal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manzilAwal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByManzilAwalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manzilAwal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByManzilTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manzilTotal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByManzilTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manzilTotal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByNamaGuru() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaGuru', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByNamaGuruDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaGuru', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortBySabaqAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sabaqAkhir', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortBySabaqAkhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sabaqAkhir', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortBySabaqAwal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sabaqAwal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortBySabaqAwalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sabaqAwal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortBySabaqTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sabaqTotal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortBySabaqTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sabaqTotal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByStatusLulus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusLulus', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByStatusLulusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusLulus', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByTanggal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByTanggalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByZiyadahAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ziyadahAkhir', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByZiyadahAkhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ziyadahAkhir', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByZiyadahAwal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ziyadahAwal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByZiyadahAwalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ziyadahAwal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByZiyadahTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ziyadahTotal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      sortByZiyadahTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ziyadahTotal', Sort.desc);
    });
  }
}

extension TahfidzRiwayatModelQuerySortThenBy
    on QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QSortThenBy> {
  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByManzilAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manzilAkhir', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByManzilAkhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manzilAkhir', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByManzilAwal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manzilAwal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByManzilAwalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manzilAwal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByManzilTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manzilTotal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByManzilTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manzilTotal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByNamaGuru() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaGuru', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByNamaGuruDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaGuru', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenBySabaqAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sabaqAkhir', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenBySabaqAkhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sabaqAkhir', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenBySabaqAwal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sabaqAwal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenBySabaqAwalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sabaqAwal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenBySabaqTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sabaqTotal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenBySabaqTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sabaqTotal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByStatusLulus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusLulus', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByStatusLulusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusLulus', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByTanggal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByTanggalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByZiyadahAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ziyadahAkhir', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByZiyadahAkhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ziyadahAkhir', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByZiyadahAwal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ziyadahAwal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByZiyadahAwalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ziyadahAwal', Sort.desc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByZiyadahTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ziyadahTotal', Sort.asc);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QAfterSortBy>
      thenByZiyadahTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ziyadahTotal', Sort.desc);
    });
  }
}

extension TahfidzRiwayatModelQueryWhereDistinct
    on QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct> {
  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelas');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelompok');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctByManzilAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'manzilAkhir');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctByManzilAwal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'manzilAwal');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctByManzilTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'manzilTotal');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctByNamaGuru({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaGuru', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctByNis({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctBySabaqAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sabaqAkhir');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctBySabaqAwal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sabaqAwal');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctBySabaqTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sabaqTotal');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctByStatusLulus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statusLulus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctByTanggal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tanggal');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctByZiyadahAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ziyadahAkhir');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctByZiyadahAwal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ziyadahAwal');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QDistinct>
      distinctByZiyadahTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ziyadahTotal');
    });
  }
}

extension TahfidzRiwayatModelQueryProperty
    on QueryBuilder<TahfidzRiwayatModel, TahfidzRiwayatModel, QQueryProperty> {
  QueryBuilder<TahfidzRiwayatModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, int?, QQueryOperations> idKelasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelas');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, int?, QQueryOperations>
      idKelompokProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelompok');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, double?, QQueryOperations>
      manzilAkhirProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'manzilAkhir');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, double?, QQueryOperations>
      manzilAwalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'manzilAwal');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, double?, QQueryOperations>
      manzilTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'manzilTotal');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, String?, QQueryOperations>
      namaGuruProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaGuru');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, String?, QQueryOperations> nisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nis');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, double?, QQueryOperations>
      sabaqAkhirProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sabaqAkhir');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, double?, QQueryOperations>
      sabaqAwalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sabaqAwal');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, double?, QQueryOperations>
      sabaqTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sabaqTotal');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, String?, QQueryOperations>
      statusLulusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusLulus');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, DateTime?, QQueryOperations>
      tanggalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tanggal');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, double?, QQueryOperations>
      ziyadahAkhirProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ziyadahAkhir');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, double?, QQueryOperations>
      ziyadahAwalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ziyadahAwal');
    });
  }

  QueryBuilder<TahfidzRiwayatModel, double?, QQueryOperations>
      ziyadahTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ziyadahTotal');
    });
  }
}
