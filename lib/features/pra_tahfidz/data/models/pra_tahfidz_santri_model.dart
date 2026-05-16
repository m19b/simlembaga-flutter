import 'dart:convert';
import 'package:isar/isar.dart';

part 'pra_tahfidz_santri_model.g.dart';

@collection
class PraTahfidzSantriModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? nis;

  @Index()
  int? idKelas;
  
  @Index()
  int? idKelompok;

  String? namaSantri;
  String? foto;
  String? tingkat;
  double? kumulatifHalaman;
  double? pointerHalaman;
  bool? sudahSetor;
  int? totalSetoran;
  String? rawJson;
  
  // Safe Parsing
  static PraTahfidzSantriModel fromJson(Map<String, dynamic> json, {int? idKelas, int? idKelompok}) {
    return PraTahfidzSantriModel()
      ..nis = json['nis']?.toString() ?? ''
      ..idKelas = idKelas
      ..idKelompok = idKelompok
      ..namaSantri = json['nama_santri']?.toString() ?? '-'
      ..foto = json['foto']?.toString()
      ..tingkat = json['tingkat']?.toString() ?? ''
      ..kumulatifHalaman = double.tryParse(json['kumulatif_halaman']?.toString() ?? '0') ?? 0.0
      ..pointerHalaman = double.tryParse(json['pointer_halaman']?.toString() ?? '0') ?? 0.0
      ..sudahSetor = json['sudah_setor'] == true || json['sudah_setor']?.toString() == '1' || json['sudah_setor']?.toString() == 'true'
      ..totalSetoran = int.tryParse(json['total_setoran']?.toString() ?? '0') ?? 0
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
      'foto': foto,
      'tingkat': tingkat,
      'kumulatif_halaman': kumulatifHalaman,
      'pointer_halaman': pointerHalaman,
      'sudah_setor': sudahSetor,
      'total_setoran': totalSetoran,
    };
  }
}
