// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kelas_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetKelasModelCollection on Isar {
  IsarCollection<KelasModel> get kelasModels => this.collection();
}

const KelasModelSchema = CollectionSchema(
  name: r'KelasModel',
  id: -7703803508872374520,
  properties: {
    r'checkpoints': PropertySchema(
      id: 0,
      name: r'checkpoints',
      type: IsarType.objectList,
      target: r'CheckpointLokal',
    ),
    r'idKategori': PropertySchema(
      id: 1,
      name: r'idKategori',
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
    r'tingkat': PropertySchema(
      id: 4,
      name: r'tingkat',
      type: IsarType.string,
    )
  },
  estimateSize: _kelasModelEstimateSize,
  serialize: _kelasModelSerialize,
  deserialize: _kelasModelDeserialize,
  deserializeProp: _kelasModelDeserializeProp,
  idName: r'idKelas',
  indexes: {
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
    ),
    r'idKategori': IndexSchema(
      id: 4999808549075746472,
      name: r'idKategori',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'idKategori',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'CheckpointLokal': CheckpointLokalSchema},
  getId: _kelasModelGetId,
  getLinks: _kelasModelGetLinks,
  attach: _kelasModelAttach,
  version: '3.1.0+1',
);

int _kelasModelEstimateSize(
  KelasModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.checkpoints;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[CheckpointLokal]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              CheckpointLokalSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final value = object.namaKelompok;
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

void _kelasModelSerialize(
  KelasModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<CheckpointLokal>(
    offsets[0],
    allOffsets,
    CheckpointLokalSchema.serialize,
    object.checkpoints,
  );
  writer.writeLong(offsets[1], object.idKategori);
  writer.writeLong(offsets[2], object.idKelompok);
  writer.writeString(offsets[3], object.namaKelompok);
  writer.writeString(offsets[4], object.tingkat);
}

KelasModel _kelasModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = KelasModel();
  object.checkpoints = reader.readObjectList<CheckpointLokal>(
    offsets[0],
    CheckpointLokalSchema.deserialize,
    allOffsets,
    CheckpointLokal(),
  );
  object.idKategori = reader.readLongOrNull(offsets[1]);
  object.idKelas = id;
  object.idKelompok = reader.readLongOrNull(offsets[2]);
  object.namaKelompok = reader.readStringOrNull(offsets[3]);
  object.tingkat = reader.readStringOrNull(offsets[4]);
  return object;
}

P _kelasModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<CheckpointLokal>(
        offset,
        CheckpointLokalSchema.deserialize,
        allOffsets,
        CheckpointLokal(),
      )) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _kelasModelGetId(KelasModel object) {
  return object.idKelas;
}

List<IsarLinkBase<dynamic>> _kelasModelGetLinks(KelasModel object) {
  return [];
}

void _kelasModelAttach(IsarCollection<dynamic> col, Id id, KelasModel object) {
  object.idKelas = id;
}

extension KelasModelQueryWhereSort
    on QueryBuilder<KelasModel, KelasModel, QWhere> {
  QueryBuilder<KelasModel, KelasModel, QAfterWhere> anyIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhere> anyIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKelompok'),
      );
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhere> anyIdKategori() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'idKategori'),
      );
    });
  }
}

extension KelasModelQueryWhere
    on QueryBuilder<KelasModel, KelasModel, QWhereClause> {
  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKelasEqualTo(
      Id idKelas) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: idKelas,
        upper: idKelas,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKelasNotEqualTo(
      Id idKelas) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: idKelas, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: idKelas, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: idKelas, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: idKelas, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKelasGreaterThan(
      Id idKelas,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: idKelas, includeLower: include),
      );
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKelasLessThan(
      Id idKelas,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: idKelas, includeUpper: include),
      );
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKelasBetween(
    Id lowerIdKelas,
    Id upperIdKelas, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIdKelas,
        includeLower: includeLower,
        upper: upperIdKelas,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [null],
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause>
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

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKelompokEqualTo(
      int? idKelompok) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKelompok',
        value: [idKelompok],
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKelompokNotEqualTo(
      int? idKelompok) {
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

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKelompokGreaterThan(
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

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKelompokLessThan(
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

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKelompokBetween(
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

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKategoriIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKategori',
        value: [null],
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause>
      idKategoriIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKategori',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKategoriEqualTo(
      int? idKategori) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idKategori',
        value: [idKategori],
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKategoriNotEqualTo(
      int? idKategori) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idKategori',
              lower: [],
              upper: [idKategori],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idKategori',
              lower: [idKategori],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idKategori',
              lower: [idKategori],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idKategori',
              lower: [],
              upper: [idKategori],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKategoriGreaterThan(
    int? idKategori, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKategori',
        lower: [idKategori],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKategoriLessThan(
    int? idKategori, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKategori',
        lower: [],
        upper: [idKategori],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterWhereClause> idKategoriBetween(
    int? lowerIdKategori,
    int? upperIdKategori, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idKategori',
        lower: [lowerIdKategori],
        includeLower: includeLower,
        upper: [upperIdKategori],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension KelasModelQueryFilter
    on QueryBuilder<KelasModel, KelasModel, QFilterCondition> {
  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      checkpointsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'checkpoints',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      checkpointsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'checkpoints',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      checkpointsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'checkpoints',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      checkpointsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'checkpoints',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      checkpointsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'checkpoints',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      checkpointsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'checkpoints',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      checkpointsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'checkpoints',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      checkpointsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'checkpoints',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      idKategoriIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKategori',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      idKategoriIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKategori',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> idKategoriEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKategori',
        value: value,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      idKategoriGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idKategori',
        value: value,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      idKategoriLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idKategori',
        value: value,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> idKategoriBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idKategori',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> idKelasEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelas',
        value: value,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      idKelasGreaterThan(
    Id value, {
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> idKelasLessThan(
    Id value, {
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> idKelasBetween(
    Id lower,
    Id upper, {
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      idKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      idKelompokIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idKelompok',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> idKelompokEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idKelompok',
        value: value,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> idKelompokBetween(
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      namaKelompokIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'namaKelompok',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      namaKelompokIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'namaKelompok',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      namaKelompokContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaKelompok',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      namaKelompokMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaKelompok',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      namaKelompokIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaKelompok',
        value: '',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      namaKelompokIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaKelompok',
        value: '',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> tingkatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tingkat',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      tingkatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tingkat',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> tingkatEqualTo(
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> tingkatLessThan(
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> tingkatBetween(
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> tingkatStartsWith(
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> tingkatEndsWith(
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

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> tingkatContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tingkat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> tingkatMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tingkat',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition> tingkatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tingkat',
        value: '',
      ));
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      tingkatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tingkat',
        value: '',
      ));
    });
  }
}

extension KelasModelQueryObject
    on QueryBuilder<KelasModel, KelasModel, QFilterCondition> {
  QueryBuilder<KelasModel, KelasModel, QAfterFilterCondition>
      checkpointsElement(FilterQuery<CheckpointLokal> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'checkpoints');
    });
  }
}

extension KelasModelQueryLinks
    on QueryBuilder<KelasModel, KelasModel, QFilterCondition> {}

extension KelasModelQuerySortBy
    on QueryBuilder<KelasModel, KelasModel, QSortBy> {
  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> sortByIdKategori() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKategori', Sort.asc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> sortByIdKategoriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKategori', Sort.desc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> sortByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> sortByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> sortByNamaKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaKelompok', Sort.asc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> sortByNamaKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaKelompok', Sort.desc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> sortByTingkat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.asc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> sortByTingkatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.desc);
    });
  }
}

extension KelasModelQuerySortThenBy
    on QueryBuilder<KelasModel, KelasModel, QSortThenBy> {
  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> thenByIdKategori() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKategori', Sort.asc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> thenByIdKategoriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKategori', Sort.desc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> thenByIdKelas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.asc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> thenByIdKelasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelas', Sort.desc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> thenByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.asc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> thenByIdKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idKelompok', Sort.desc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> thenByNamaKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaKelompok', Sort.asc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> thenByNamaKelompokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaKelompok', Sort.desc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> thenByTingkat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.asc);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QAfterSortBy> thenByTingkatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tingkat', Sort.desc);
    });
  }
}

extension KelasModelQueryWhereDistinct
    on QueryBuilder<KelasModel, KelasModel, QDistinct> {
  QueryBuilder<KelasModel, KelasModel, QDistinct> distinctByIdKategori() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKategori');
    });
  }

  QueryBuilder<KelasModel, KelasModel, QDistinct> distinctByIdKelompok() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idKelompok');
    });
  }

  QueryBuilder<KelasModel, KelasModel, QDistinct> distinctByNamaKelompok(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaKelompok', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<KelasModel, KelasModel, QDistinct> distinctByTingkat(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tingkat', caseSensitive: caseSensitive);
    });
  }
}

extension KelasModelQueryProperty
    on QueryBuilder<KelasModel, KelasModel, QQueryProperty> {
  QueryBuilder<KelasModel, int, QQueryOperations> idKelasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelas');
    });
  }

  QueryBuilder<KelasModel, List<CheckpointLokal>?, QQueryOperations>
      checkpointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkpoints');
    });
  }

  QueryBuilder<KelasModel, int?, QQueryOperations> idKategoriProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKategori');
    });
  }

  QueryBuilder<KelasModel, int?, QQueryOperations> idKelompokProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idKelompok');
    });
  }

  QueryBuilder<KelasModel, String?, QQueryOperations> namaKelompokProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaKelompok');
    });
  }

  QueryBuilder<KelasModel, String?, QQueryOperations> tingkatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tingkat');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const CheckpointLokalSchema = Schema(
  name: r'CheckpointLokal',
  id: 2069937980356377376,
  properties: {
    r'halamanTarget': PropertySchema(
      id: 0,
      name: r'halamanTarget',
      type: IsarType.double,
    ),
    r'harusTes': PropertySchema(
      id: 1,
      name: r'harusTes',
      type: IsarType.long,
    ),
    r'keterangan': PropertySchema(
      id: 2,
      name: r'keterangan',
      type: IsarType.string,
    )
  },
  estimateSize: _checkpointLokalEstimateSize,
  serialize: _checkpointLokalSerialize,
  deserialize: _checkpointLokalDeserialize,
  deserializeProp: _checkpointLokalDeserializeProp,
);

int _checkpointLokalEstimateSize(
  CheckpointLokal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.keterangan;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _checkpointLokalSerialize(
  CheckpointLokal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.halamanTarget);
  writer.writeLong(offsets[1], object.harusTes);
  writer.writeString(offsets[2], object.keterangan);
}

CheckpointLokal _checkpointLokalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CheckpointLokal();
  object.halamanTarget = reader.readDoubleOrNull(offsets[0]);
  object.harusTes = reader.readLongOrNull(offsets[1]);
  object.keterangan = reader.readStringOrNull(offsets[2]);
  return object;
}

P _checkpointLokalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension CheckpointLokalQueryFilter
    on QueryBuilder<CheckpointLokal, CheckpointLokal, QFilterCondition> {
  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      halamanTargetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'halamanTarget',
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      halamanTargetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'halamanTarget',
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      halamanTargetEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'halamanTarget',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      halamanTargetGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'halamanTarget',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      halamanTargetLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'halamanTarget',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      halamanTargetBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'halamanTarget',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      harusTesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'harusTes',
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      harusTesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'harusTes',
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      harusTesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'harusTes',
        value: value,
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      harusTesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'harusTes',
        value: value,
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      harusTesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'harusTes',
        value: value,
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      harusTesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'harusTes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      keteranganIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'keterangan',
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      keteranganIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'keterangan',
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      keteranganEqualTo(
    String? value, {
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

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      keteranganGreaterThan(
    String? value, {
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

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      keteranganLessThan(
    String? value, {
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

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      keteranganBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
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

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
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

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      keteranganContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      keteranganMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'keterangan',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      keteranganIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keterangan',
        value: '',
      ));
    });
  }

  QueryBuilder<CheckpointLokal, CheckpointLokal, QAfterFilterCondition>
      keteranganIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'keterangan',
        value: '',
      ));
    });
  }
}

extension CheckpointLokalQueryObject
    on QueryBuilder<CheckpointLokal, CheckpointLokal, QFilterCondition> {}
