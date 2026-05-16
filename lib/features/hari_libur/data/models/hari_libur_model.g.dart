// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hari_libur_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHariLiburModelCollection on Isar {
  IsarCollection<HariLiburModel> get hariLiburModels => this.collection();
}

const HariLiburModelSchema = CollectionSchema(
  name: r'HariLiburModel',
  id: 547177600138297525,
  properties: {
    r'idKelompok': PropertySchema(
      id: 0,
      name: r'idKelompok',
      type: IsarType.long,
    ),
    r'idLibur': PropertySchema(
      id: 1,
      name: r'idLibur',
      type: IsarType.long,
    ),
    r'kategori': PropertySchema(
      id: 2,
      name: r'kategori',
      type: IsarType.string,
    ),
    r'keterangan': PropertySchema(
      id: 3,
      name: r'keterangan',
      type: IsarType.string,
    ),
    r'namaLibur': PropertySchema(
      id: 4,
      name: r'namaLibur',
      type: IsarType.string,
    ),
    r'tahun': PropertySchema(
      id: 5,
      name: r'tahun',
      type: IsarType.long,
    ),
    r'tanggalAkhir': PropertySchema(
      id: 6,
      name: r'tanggalAkhir',
      type: IsarType.string,
    ),
    r'tanggalAkhirDt': PropertySchema(
      id: 7,
      name: r'tanggalAkhirDt',
      type: IsarType.dateTime,
    ),
    r'tanggalDt': PropertySchema(
      id: 8,
      name: r'tanggalDt',
      type: IsarType.dateTime,
    ),
    r'tanggalMulai': PropertySchema(
      id: 9,
      name: r'tanggalMulai',
      type: IsarType.string,
    ),
    r'tanggalMulaiDt': PropertySchema(
      id: 10,
      name: r'tanggalMulaiDt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _hariLiburModelEstimateSize,
  serialize: _hariLiburModelSerialize,
  deserialize: _hariLiburModelDeserialize,
  deserializeProp: _hariLiburModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'tahun': IndexSchema(
      id: 8026603012877518747,
      name: r'tahun',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tahun',
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
  getId: _hariLiburModelGetId,
  getLinks: _hariLiburModelGetLinks,
  attach: _hariLiburModelAttach,
  version: '3.1.0+1',
);

int _hariLiburModelEstimateSize(
  HariLiburModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.kategori;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.keterangan.length * 3;
  bytesCount += 3 + object.namaLibur.length * 3;
  bytesCount += 3 + object.tanggalAkhir.length * 3;
  bytesCount += 3 + object.tanggalMulai.length * 3;
  return bytesCount;
}

void _hariLiburModelSerialize(
  HariLiburModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.idKelompok);
  writer.writeLong(offsets[1], object.idLibur);
  writer.writeString(offsets[2], object.kategori);
  writer.writeString(offsets[3], object.keterangan);
  writer.writeString(offsets[4], object.namaLibur);
  writer.writeLong(offsets[5], object.tahun);
  writer.writeString(offsets[6], object.tanggalAkhir);
  writer.writeDateTime(offsets[7], object.tanggalAkhirDt);
  writer.writeDateTime(offsets[8], object.tanggalDt);
  writer.writeString(offsets[9], object.tanggalMulai);
  writer.writeDateTime(offsets[10], object.tanggalMulaiDt);
}

HariLiburModel _hariLiburModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HariLiburModel();
  object.id = id;
  object.idKelompok = reader.readLongOrNull(offsets[0]);
  object.idLibur = reader.readLongOrNull(offsets[1]);
  object.kategori = reader.readStringOrNull(offsets[2]);
  object.keterangan = reader.readString(offsets[3]);
  object.tahun = reader.readLongOrNull(offsets[5]);
  object.tanggalAkhir = reader.readString(offsets[6]);
  object.tanggalMulai = reader.readString(offsets[9]);
  return object;
}

P _hariLiburModelDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _hariLiburModelGetId(HariLiburModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _hariLiburModelGetLinks(HariLiburModel object) {
  return [];
}

void _hariLiburModelAttach(
    IsarCollection<dynamic> col, Id id, HariLiburModel object) {
  object.id = id;
}

extension HariLiburModelQueryWhereSort
    on QueryBuilder<HariLiburModel, HariLiburModel, QWhere> {
  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhere> anyTahun() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'tahun'),
      );
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhere> anyIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKelompok'),
      );
    });
  }
}

extension HariLiburModelQueryWhere
    on QueryBuilder<HariLiburModel, HariLiburModel, QWhereClause> {
  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause>
      tahunIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tahun',
        value: [null],
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause>
      tahunIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tahun',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause> tahunEqualTo(
      int? tahun) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tahun',
        value: [tahun],
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause>
      tahunNotEqualTo(int? tahun) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tahun',
              lower: [],
              upper: [tahun],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tahun',
              lower: [tahun],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tahun',
              lower: [tahun],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tahun',
              lower: [],
              upper: [tahun],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause>
      tahunGreaterThan(
    int? tahun, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tahun',
        lower: [tahun],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause> tahunLessThan(
    int? tahun, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tahun',
        lower: [],
        upper: [tahun],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause> tahunBetween(
    int? lowerTahun,
    int? upperTahun, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tahun',
        lower: [lowerTahun],
        includeLower: includeLower,
        upper: [upperTahun],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause>
      idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [null],
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause>
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

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause>
      idKelompokEqualTo(int? idKelompok) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [idKelompok],
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause>
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

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause>
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

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause>
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

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterWhereClause>
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

extension HariLiburModelQueryFilter
    on QueryBuilder<HariLiburModel, HariLiburModel, QFilterCondition> {
  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
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

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
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

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      idKelompokIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      idKelompokEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelompok',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
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

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
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

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
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

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      idLiburIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idLibur',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      idLiburIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idLibur',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      idLiburEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idLibur',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      idLiburGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idLibur',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      idLiburLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idLibur',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      idLiburBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idLibur',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      kategoriIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'kategori',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      kategoriIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'kategori',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      kategoriEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kategori',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      kategoriGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kategori',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      kategoriLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kategori',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      kategoriBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kategori',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      kategoriStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'kategori',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      kategoriEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'kategori',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      kategoriContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kategori',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      kategoriMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kategori',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      kategoriIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kategori',
        value: '',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      kategoriIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kategori',
        value: '',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      keteranganEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      keteranganGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      keteranganLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      keteranganBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'keterangan',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      keteranganStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      keteranganEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      keteranganContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      keteranganMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'keterangan',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      keteranganIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keterangan',
        value: '',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      keteranganIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'keterangan',
        value: '',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      namaLiburEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaLibur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      namaLiburGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'namaLibur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      namaLiburLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'namaLibur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      namaLiburBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'namaLibur',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      namaLiburStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'namaLibur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      namaLiburEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'namaLibur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      namaLiburContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaLibur',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      namaLiburMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaLibur',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      namaLiburIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaLibur',
        value: '',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      namaLiburIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaLibur',
        value: '',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tahunIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tahun',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tahunIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tahun',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tahunEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tahun',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tahunGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tahun',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tahunLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tahun',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tahunBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tahun',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalAkhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tanggalAkhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tanggalAkhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tanggalAkhir',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tanggalAkhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tanggalAkhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tanggalAkhir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tanggalAkhir',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalAkhir',
        value: '',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tanggalAkhir',
        value: '',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirDtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tanggalAkhirDt',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirDtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tanggalAkhirDt',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirDtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalAkhirDt',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirDtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tanggalAkhirDt',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirDtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tanggalAkhirDt',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalAkhirDtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tanggalAkhirDt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalDtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tanggalDt',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalDtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tanggalDt',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalDtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalDt',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalDtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tanggalDt',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalDtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tanggalDt',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalDtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tanggalDt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalMulai',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tanggalMulai',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tanggalMulai',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tanggalMulai',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tanggalMulai',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tanggalMulai',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tanggalMulai',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tanggalMulai',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalMulai',
        value: '',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tanggalMulai',
        value: '',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiDtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tanggalMulaiDt',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiDtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tanggalMulaiDt',
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiDtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalMulaiDt',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiDtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tanggalMulaiDt',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiDtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tanggalMulaiDt',
        value: value,
      ));
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterFilterCondition>
      tanggalMulaiDtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tanggalMulaiDt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension HariLiburModelQueryObject
    on QueryBuilder<HariLiburModel, HariLiburModel, QFilterCondition> {}

extension HariLiburModelQueryLinks
    on QueryBuilder<HariLiburModel, HariLiburModel, QFilterCondition> {}

extension HariLiburModelQuerySortBy
    on QueryBuilder<HariLiburModel, HariLiburModel, QSortBy> {
  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> sortByIdLibur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idLibur', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByIdLiburDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idLibur', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> sortByKategori() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kategori', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByKategoriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kategori', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByKeterangan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keterangan', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByKeteranganDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keterangan', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> sortByNamaLibur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaLibur', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByNamaLiburDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaLibur', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> sortByTahun() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tahun', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> sortByTahunDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tahun', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByTanggalAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalAkhir', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByTanggalAkhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalAkhir', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByTanggalAkhirDt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalAkhirDt', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByTanggalAkhirDtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalAkhirDt', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> sortByTanggalDt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalDt', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByTanggalDtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalDt', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByTanggalMulai() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalMulai', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByTanggalMulaiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalMulai', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByTanggalMulaiDt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalMulaiDt', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      sortByTanggalMulaiDtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalMulaiDt', Sort.desc);
    });
  }
}

extension HariLiburModelQuerySortThenBy
    on QueryBuilder<HariLiburModel, HariLiburModel, QSortThenBy> {
  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> thenByIdLibur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idLibur', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByIdLiburDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idLibur', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> thenByKategori() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kategori', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByKategoriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kategori', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByKeterangan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keterangan', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByKeteranganDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keterangan', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> thenByNamaLibur() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaLibur', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByNamaLiburDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaLibur', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> thenByTahun() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tahun', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> thenByTahunDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tahun', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByTanggalAkhir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalAkhir', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByTanggalAkhirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalAkhir', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByTanggalAkhirDt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalAkhirDt', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByTanggalAkhirDtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalAkhirDt', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy> thenByTanggalDt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalDt', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByTanggalDtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalDt', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByTanggalMulai() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalMulai', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByTanggalMulaiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalMulai', Sort.desc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByTanggalMulaiDt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalMulaiDt', Sort.asc);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QAfterSortBy>
      thenByTanggalMulaiDtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalMulaiDt', Sort.desc);
    });
  }
}

extension HariLiburModelQueryWhereDistinct
    on QueryBuilder<HariLiburModel, HariLiburModel, QDistinct> {
  QueryBuilder<HariLiburModel, HariLiburModel, QDistinct>
      distinctByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelompok');
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QDistinct> distinctByIdLibur() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idLibur');
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QDistinct> distinctByKategori(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kategori', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QDistinct> distinctByKeterangan(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keterangan', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QDistinct> distinctByNamaLibur(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaLibur', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QDistinct> distinctByTahun() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tahun');
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QDistinct>
      distinctByTanggalAkhir({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tanggalAkhir', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QDistinct>
      distinctByTanggalAkhirDt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tanggalAkhirDt');
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QDistinct>
      distinctByTanggalDt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tanggalDt');
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QDistinct>
      distinctByTanggalMulai({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tanggalMulai', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HariLiburModel, HariLiburModel, QDistinct>
      distinctByTanggalMulaiDt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tanggalMulaiDt');
    });
  }
}

extension HariLiburModelQueryProperty
    on QueryBuilder<HariLiburModel, HariLiburModel, QQueryProperty> {
  QueryBuilder<HariLiburModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HariLiburModel, int?, QQueryOperations> idKelompokProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelompok');
    });
  }

  QueryBuilder<HariLiburModel, int?, QQueryOperations> idLiburProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idLibur');
    });
  }

  QueryBuilder<HariLiburModel, String?, QQueryOperations> kategoriProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kategori');
    });
  }

  QueryBuilder<HariLiburModel, String, QQueryOperations> keteranganProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keterangan');
    });
  }

  QueryBuilder<HariLiburModel, String, QQueryOperations> namaLiburProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaLibur');
    });
  }

  QueryBuilder<HariLiburModel, int?, QQueryOperations> tahunProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tahun');
    });
  }

  QueryBuilder<HariLiburModel, String, QQueryOperations>
      tanggalAkhirProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tanggalAkhir');
    });
  }

  QueryBuilder<HariLiburModel, DateTime?, QQueryOperations>
      tanggalAkhirDtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tanggalAkhirDt');
    });
  }

  QueryBuilder<HariLiburModel, DateTime?, QQueryOperations>
      tanggalDtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tanggalDt');
    });
  }

  QueryBuilder<HariLiburModel, String, QQueryOperations>
      tanggalMulaiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tanggalMulai');
    });
  }

  QueryBuilder<HariLiburModel, DateTime?, QQueryOperations>
      tanggalMulaiDtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tanggalMulaiDt');
    });
  }
}
