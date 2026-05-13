import 'package:isar/isar.dart';

part 'riwayat_tahsin_model.g.dart';

@collection
class RiwayatTahsinModel {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('jilidId')])
  String? nis;

  @Index()
  int? jilidId;

  String? namaSantri;
  String? tingkat;
  String? namaKelompok;
  String? namaGuru;
  String? statusHalaman;
  String? modeBelajar;
  DateTime? createdAt;

  // Safe Parsing dari API dengan Mapping Primary Key
  static RiwayatTahsinModel fromJson(Map<String, dynamic> json, int currentJilidId) {
    int? parsedId = int.tryParse(json['id']?.toString() ?? '');
    return RiwayatTahsinModel()
      ..id = parsedId ?? Isar.autoIncrement
      ..jilidId = currentJilidId
      ..nis = json['nis']?.toString() ?? ''
      ..namaSantri = json['nama_santri']?.toString() ?? '-'
      ..tingkat = json['tingkat']?.toString() ?? ''
      ..namaKelompok = json['nama_kelompok']?.toString() ?? ''
      ..namaGuru = json['nama_guru']?.toString() ?? '-'
      ..statusHalaman = json['status_halaman']?.toString() ?? ''
      ..modeBelajar = json['mode_belajar']?.toString() ?? ''
      ..createdAt = DateTime.tryParse(json['created_at']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != Isar.autoIncrement) 'id': id,
      'nis': nis,
      'nama_santri': namaSantri,
      'tingkat': tingkat,
      'nama_kelompok': namaKelompok,
      'nama_guru': namaGuru,
      'status_halaman': statusHalaman,
      'mode_belajar': modeBelajar,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
