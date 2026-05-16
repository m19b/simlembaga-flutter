import 'dart:convert';
import 'package:isar/isar.dart';

part 'progress_santri_model.g.dart';

@collection
class ProgressSantriModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? nis;

  @Index()
  int? idKelas;
  
  @Index()
  int? idKelompok;

  String? namaSantri;
  String? tingkat;
  String? namaKelompok;
  String? halamanTerakhir;
  String? statusTerakhir;
  String? rawJson;
  
  // Safe Parsing
  static ProgressSantriModel fromJson(Map<String, dynamic> json, {int? idKelas, int? idKelompok}) {
    return ProgressSantriModel()
      ..nis = json['nis']?.toString() ?? ''
      ..idKelas = idKelas
      ..idKelompok = idKelompok
      ..namaSantri = json['nama_santri']?.toString() ?? '-'
      ..tingkat = json['tingkat']?.toString() ?? ''
      ..namaKelompok = json['nama_kelompok']?.toString() ?? ''
      ..halamanTerakhir = json['halaman_terakhir']?.toString() ?? ''
      ..statusTerakhir = json['status_terakhir']?.toString() ?? ''
      ..rawJson = jsonEncode(json);
  }

  Map<String, dynamic> toJson() {
    if (rawJson != null && rawJson!.isNotEmpty) {
      try {
        return jsonDecode(rawJson!) as Map<String, dynamic>;
      } catch (_) {}
    }
    return {
      'nis': nis,
      'nama_santri': namaSantri,
      'tingkat': tingkat,
      'nama_kelompok': namaKelompok,
      'halaman_terakhir': halamanTerakhir,
      'status_terakhir': statusTerakhir,
    };
  }
}

