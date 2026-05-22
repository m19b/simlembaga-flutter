// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riwayat_tahsin_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRiwayatTahsinModelCollection on Isar {
  IsarCollection<RiwayatTahsinModel> get riwayatTahsinModels =>
      this.collection();
}

const RiwayatTahsinModelSchema = CollectionSchema(
  name: r'RiwayatTahsinModel',
  id: 1473427823827887902,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'jilidId': PropertySchema(
      id: 1,
      name: r'jilidId',
      type: IsarType.long,
    ),
    r'modeBelajar': PropertySchema(
      id: 2,
      name: r'modeBelajar',
      type: IsarType.string,
    ),
    r'namaGuru': PropertySchema(
      id: 3,
      name: r'namaGuru',
      type: IsarType.string,
    ),
    r'namaKelompok': PropertySchema(
      id: 4,
      name: r'namaKelompok',
      type: IsarType.string,
    ),
    r'namaSantri': PropertySchema(
      id: 5,
      name: r'namaSantri',
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
      type: IsarType.long,
    ),
    r'statusHalaman': PropertySchema(
      id: 8,
      name: r'statusHalaman',
      type: IsarType.string,
    ),
    r'tanggal': PropertySchema(
      id: 9,
      name: r'tanggal',
      type: IsarType.string,
    ),
    r'tingkat': PropertySchema(
      id: 10,
      name: r'tingkat',
      type: IsarType.string,
    )
  },
  estimateSize: _riwayatTahsinModelEstimateSize,
  serialize: _riwayatTahsinModelSerialize,
  deserialize: _riwayatTahsinModelDeserialize,
  deserializeProp: _riwayatTahsinModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'nis_jilidId': IndexSchema(
      id: 843629475183208014,
      name: r'nis_jilidId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nis',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'jilidId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'jilidId': IndexSchema(
      id: 3426480177685990416,
      name: r'jilidId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'jilidId',
          type: IndexType.value,
          caseSensitive: false,
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
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'sesi': IndexSchema(
      id: 239240615698560900,
      name: r'sesi',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sesi',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _riwayatTahsinModelGetId,
  getLinks: _riwayatTahsinModelGetLinks,
  attach: _riwayatTahsinModelAttach,
  version: '3.1.0+1',
);

int _riwayatTahsinModelEstimateSize(
  RiwayatTahsinModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.modeBelajar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.namaGuru;
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
    final value = object.statusHalaman;
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
  {
    final value = object.tingkat;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _riwayatTahsinModelSerialize(
  RiwayatTahsinModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeLong(offsets[1], object.jilidId);
  writer.writeString(offsets[2], object.modeBelajar);
  writer.writeString(offsets[3], object.namaGuru);
  writer.writeString(offsets[4], object.namaKelompok);
  writer.writeString(offsets[5], object.namaSantri);
  writer.writeString(offsets[6], object.nis);
  writer.writeLong(offsets[7], object.sesi);
  writer.writeString(offsets[8], object.statusHalaman);
  writer.writeString(offsets[9], object.tanggal);
  writer.writeString(offsets[10], object.tingkat);
}

RiwayatTahsinModel _riwayatTahsinModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RiwayatTahsinModel();
  object.createdAt = reader.readDateTimeOrNull(offsets[0]);
  object.id = id;
  object.jilidId = reader.readLongOrNull(offsets[1]);
  object.modeBelajar = reader.readStringOrNull(offsets[2]);
  object.namaGuru = reader.readStringOrNull(offsets[3]);
  object.namaKelompok = reader.readStringOrNull(offsets[4]);
  object.namaSantri = reader.readStringOrNull(offsets[5]);
  object.nis = reader.readStringOrNull(offsets[6]);
  object.sesi = reader.readLongOrNull(offsets[7]);
  object.statusHalaman = reader.readStringOrNull(offsets[8]);
  object.tanggal = reader.readStringOrNull(offsets[9]);
  object.tingkat = reader.readStringOrNull(offsets[10]);
  return object;
}

P _riwayatTahsinModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _riwayatTahsinModelGetId(RiwayatTahsinModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _riwayatTahsinModelGetLinks(
    RiwayatTahsinModel object) {
  return [];
}

void _riwayatTahsinModelAttach(
    IsarCollection<dynamic> col, Id id, RiwayatTahsinModel object) {
  object.id = id;
}

extension RiwayatTahsinModelQueryWhereSort
    on QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QWhere> {
  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhere>
      anyJilidId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'jilidId'),
      );
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhere> anySesi() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sesi'),
      );
    });
  }
}

extension RiwayatTahsinModelQueryWhere
    on QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QWhereClause> {
  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      nisIsNullAnyJilidId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis_jilidId',
        value: [null],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      nisIsNotNullAnyJilidId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nis_jilidId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      nisEqualToAnyJilidId(String? nis) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis_jilidId',
        value: [nis],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      nisNotEqualToAnyJilidId(String? nis) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nis_jilidId',
              lower: [],
              upper: [nis],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nis_jilidId',
              lower: [nis],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nis_jilidId',
              lower: [nis],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nis_jilidId',
              lower: [],
              upper: [nis],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      nisEqualToJilidIdIsNull(String? nis) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis_jilidId',
        value: [nis, null],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      nisEqualToJilidIdIsNotNull(String? nis) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nis_jilidId',
        lower: [nis, null],
        includeLower: false,
        upper: [
          nis,
        ],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      nisJilidIdEqualTo(String? nis, int? jilidId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nis_jilidId',
        value: [nis, jilidId],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      nisEqualToJilidIdNotEqualTo(String? nis, int? jilidId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nis_jilidId',
              lower: [nis],
              upper: [nis, jilidId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nis_jilidId',
              lower: [nis, jilidId],
              includeLower: false,
              upper: [nis],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nis_jilidId',
              lower: [nis, jilidId],
              includeLower: false,
              upper: [nis],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nis_jilidId',
              lower: [nis],
              upper: [nis, jilidId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      nisEqualToJilidIdGreaterThan(
    String? nis,
    int? jilidId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nis_jilidId',
        lower: [nis, jilidId],
        includeLower: include,
        upper: [nis],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      nisEqualToJilidIdLessThan(
    String? nis,
    int? jilidId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nis_jilidId',
        lower: [nis],
        upper: [nis, jilidId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      nisEqualToJilidIdBetween(
    String? nis,
    int? lowerJilidId,
    int? upperJilidId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'nis_jilidId',
        lower: [nis, lowerJilidId],
        includeLower: includeLower,
        upper: [nis, upperJilidId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      jilidIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'jilidId',
        value: [null],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      jilidIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'jilidId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      jilidIdEqualTo(int? jilidId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'jilidId',
        value: [jilidId],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      jilidIdNotEqualTo(int? jilidId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'jilidId',
              lower: [],
              upper: [jilidId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'jilidId',
              lower: [jilidId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'jilidId',
              lower: [jilidId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'jilidId',
              lower: [],
              upper: [jilidId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      jilidIdGreaterThan(
    int? jilidId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'jilidId',
        lower: [jilidId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      jilidIdLessThan(
    int? jilidId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'jilidId',
        lower: [],
        upper: [jilidId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      jilidIdBetween(
    int? lowerJilidId,
    int? upperJilidId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'jilidId',
        lower: [lowerJilidId],
        includeLower: includeLower,
        upper: [upperJilidId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      tanggalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tanggal',
        value: [null],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      tanggalEqualTo(String? tanggal) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tanggal',
        value: [tanggal],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      tanggalNotEqualTo(String? tanggal) {
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      sesiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sesi',
        value: [null],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      sesiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sesi',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      sesiEqualTo(int? sesi) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sesi',
        value: [sesi],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      sesiNotEqualTo(int? sesi) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sesi',
              lower: [],
              upper: [sesi],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sesi',
              lower: [sesi],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sesi',
              lower: [sesi],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sesi',
              lower: [],
              upper: [sesi],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      sesiGreaterThan(
    int? sesi, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sesi',
        lower: [sesi],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      sesiLessThan(
    int? sesi, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sesi',
        lower: [],
        upper: [sesi],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterWhereClause>
      sesiBetween(
    int? lowerSesi,
    int? upperSesi, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sesi',
        lower: [lowerSesi],
        includeLower: includeLower,
        upper: [upperSesi],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RiwayatTahsinModelQueryFilter
    on QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QFilterCondition> {
  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      createdAtGreaterThan(
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      jilidIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'jilidId',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      jilidIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'jilidId',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      jilidIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jilidId',
        value: value,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      jilidIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jilidId',
        value: value,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      jilidIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jilidId',
        value: value,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      jilidIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jilidId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      modeBelajarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'modeBelajar',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      modeBelajarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'modeBelajar',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      modeBelajarEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modeBelajar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      modeBelajarGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'modeBelajar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      modeBelajarLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'modeBelajar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      modeBelajarBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'modeBelajar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      modeBelajarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'modeBelajar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      modeBelajarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'modeBelajar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      modeBelajarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'modeBelajar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      modeBelajarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'modeBelajar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      modeBelajarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modeBelajar',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      modeBelajarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'modeBelajar',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaGuruIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'namaGuru',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaGuruIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'namaGuru',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaGuruContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaGuru',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaGuruMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaGuru',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaGuruIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaGuru',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaGuruIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaGuru',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'namaKelompok',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaKelompokIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'namaKelompok',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaKelompokContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaKelompok',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaKelompokMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaKelompok',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaKelompokIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaKelompok',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaKelompokIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaKelompok',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaSantriIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'namaSantri',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaSantriIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'namaSantri',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaSantriContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaSantri',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaSantriMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaSantri',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaSantriIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaSantri',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      namaSantriIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaSantri',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      nisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nis',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      nisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nis',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      nisContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      nisMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nis',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      nisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      nisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nis',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      sesiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sesi',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      sesiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sesi',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      sesiEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sesi',
        value: value,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      sesiGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sesi',
        value: value,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      sesiLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sesi',
        value: value,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      sesiBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sesi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      statusHalamanIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'statusHalaman',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      statusHalamanIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'statusHalaman',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      statusHalamanEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusHalaman',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      statusHalamanGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statusHalaman',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      statusHalamanLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statusHalaman',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      statusHalamanBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statusHalaman',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      statusHalamanStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'statusHalaman',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      statusHalamanEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'statusHalaman',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      statusHalamanContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'statusHalaman',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      statusHalamanMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'statusHalaman',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      statusHalamanIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusHalaman',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      statusHalamanIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'statusHalaman',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tanggalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tanggal',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tanggalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tanggal',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tanggalEqualTo(
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tanggalGreaterThan(
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tanggalLessThan(
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tanggalBetween(
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tanggalStartsWith(
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tanggalEndsWith(
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tanggalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tanggalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tanggal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tanggalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggal',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tanggalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tanggal',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tingkatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tingkat',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tingkatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tingkat',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
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

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tingkatContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tingkat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tingkatMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tingkat',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tingkatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tingkat',
        value: '',
      ));
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterFilterCondition>
      tingkatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tingkat',
        value: '',
      ));
    });
  }
}

extension RiwayatTahsinModelQueryObject
    on QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QFilterCondition> {}

extension RiwayatTahsinModelQueryLinks
    on QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QFilterCondition> {}

extension RiwayatTahsinModelQuerySortBy
    on QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QSortBy> {
  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByJilidId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jilidId', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByJilidIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jilidId', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByModeBelajar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modeBelajar', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByModeBelajarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modeBelajar', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByNamaGuru() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaGuru', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByNamaGuruDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaGuru', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByNamaKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaKelompok', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByNamaKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaKelompok', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByNamaSantri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByNamaSantriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortBySesi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sesi', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortBySesiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sesi', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByStatusHalaman() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusHalaman', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByStatusHalamanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusHalaman', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByTanggal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggal', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByTanggalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggal', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByTingkat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      sortByTingkatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.desc);
    });
  }
}

extension RiwayatTahsinModelQuerySortThenBy
    on QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QSortThenBy> {
  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByJilidId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jilidId', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByJilidIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jilidId', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByModeBelajar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modeBelajar', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByModeBelajarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modeBelajar', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByNamaGuru() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaGuru', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByNamaGuruDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaGuru', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByNamaKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaKelompok', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByNamaKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaKelompok', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByNamaSantri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByNamaSantriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaSantri', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByNis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByNisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nis', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenBySesi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sesi', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenBySesiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sesi', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByStatusHalaman() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusHalaman', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByStatusHalamanDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusHalaman', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByTanggal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggal', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByTanggalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggal', Sort.desc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByTingkat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.asc);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QAfterSortBy>
      thenByTingkatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.desc);
    });
  }
}

extension RiwayatTahsinModelQueryWhereDistinct
    on QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QDistinct> {
  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QDistinct>
      distinctByJilidId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jilidId');
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QDistinct>
      distinctByModeBelajar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modeBelajar', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QDistinct>
      distinctByNamaGuru({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaGuru', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QDistinct>
      distinctByNamaKelompok({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaKelompok', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QDistinct>
      distinctByNamaSantri({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaSantri', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QDistinct> distinctByNis(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QDistinct>
      distinctBySesi() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sesi');
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QDistinct>
      distinctByStatusHalaman({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statusHalaman',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QDistinct>
      distinctByTanggal({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tanggal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QDistinct>
      distinctByTingkat({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tingkat', caseSensitive: caseSensitive);
    });
  }
}

extension RiwayatTahsinModelQueryProperty
    on QueryBuilder<RiwayatTahsinModel, RiwayatTahsinModel, QQueryProperty> {
  QueryBuilder<RiwayatTahsinModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RiwayatTahsinModel, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<RiwayatTahsinModel, int?, QQueryOperations> jilidIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jilidId');
    });
  }

  QueryBuilder<RiwayatTahsinModel, String?, QQueryOperations>
      modeBelajarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modeBelajar');
    });
  }

  QueryBuilder<RiwayatTahsinModel, String?, QQueryOperations>
      namaGuruProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaGuru');
    });
  }

  QueryBuilder<RiwayatTahsinModel, String?, QQueryOperations>
      namaKelompokProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaKelompok');
    });
  }

  QueryBuilder<RiwayatTahsinModel, String?, QQueryOperations>
      namaSantriProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaSantri');
    });
  }

  QueryBuilder<RiwayatTahsinModel, String?, QQueryOperations> nisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nis');
    });
  }

  QueryBuilder<RiwayatTahsinModel, int?, QQueryOperations> sesiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sesi');
    });
  }

  QueryBuilder<RiwayatTahsinModel, String?, QQueryOperations>
      statusHalamanProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusHalaman');
    });
  }

  QueryBuilder<RiwayatTahsinModel, String?, QQueryOperations>
      tanggalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tanggal');
    });
  }

  QueryBuilder<RiwayatTahsinModel, String?, QQueryOperations>
      tingkatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tingkat');
    });
  }
}
