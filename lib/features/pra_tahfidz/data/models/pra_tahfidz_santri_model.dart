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
  double? defaultHal;
  double? totalHal;
  int? wajibTesKenaikan;
  String? rawJson;
  
  // Safe Parsing
  static PraTahfidzSantriModel fromJson(Map<String, dynamic> json, {int? idKelas, int? idKelompok}) {
    return PraTahfidzSantriModel()
      ..nis = json['nis']?.toString() ?? ''
      ..idKelas = idKelas ?? (json['id_kelas'] != null ? int.tryParse(json['id_kelas'].toString()) : null)
      ..idKelompok = idKelompok
      ..namaSantri = json['nama_santri']?.toString() ?? '-'
      ..foto = json['foto']?.toString()
      ..tingkat = json['tingkat']?.toString() ?? ''
      ..kumulatifHalaman = double.tryParse(json['kumulatif_halaman']?.toString() ?? '0') ?? 0.0
      ..pointerHalaman = double.tryParse(json['pointer_halaman']?.toString() ?? '0') ?? 0.0
      ..sudahSetor = json['sudah_setor'] == true || json['sudah_setor']?.toString() == '1' || json['sudah_setor']?.toString() == 'true'
      ..totalSetoran = int.tryParse(json['total_setoran']?.toString() ?? '0') ?? 0
      ..defaultHal = double.tryParse(json['default_hal']?.toString() ?? '1.0') ?? 1.0
      ..totalHal = double.tryParse(json['total_hal']?.toString() ?? '604.0') ?? 604.0
      ..wajibTesKenaikan = int.tryParse(json['wajib_tes_kenaikan']?.toString() ?? '0') ?? 0
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
      'default_hal': defaultHal,
      'total_hal': totalHal,
      'wajib_tes_kenaikan': wajibTesKenaikan,
    };
  }
}
