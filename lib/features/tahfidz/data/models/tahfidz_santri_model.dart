import 'dart:convert';
import 'package:isar/isar.dart';

part 'tahfidz_santri_model.g.dart';

/// Entitas Isar untuk menyimpan daftar santri Tahfidz Al-Qur'an.
/// Field utama sesuai respons API `GET /api/tahfidz-quran`.
@collection
class TahfidzSantriModel {
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

  // Rekap kumulatif (dari t_rekap_tahfidz)
  double? totalZiyadahHal;
  double? mutqinRate;
  double? totalSabaqHal;
  double? totalManzilHal;

  // Status setoran hari ini
  bool? sudahSetor;

  // Raw JSON mentah (seluruh field termasuk riwayat_hari_ini) — untuk offline rebuild
  String? rawJson;

  /// Safe Parsing dari response API `getApiProgressList`
  static TahfidzSantriModel fromJson(
    Map<String, dynamic> json, {
    int? idKelas,
    int? idKelompok,
  }) {
    return TahfidzSantriModel()
      ..nis = json['nis']?.toString() ?? ''
      ..idKelas = idKelas
      ..idKelompok = idKelompok
      ..namaSantri = json['nama_santri']?.toString() ?? '-'
      ..foto = json['foto']?.toString()
      ..tingkat = json['tingkat']?.toString() ?? ''
      ..totalZiyadahHal =
          double.tryParse(json['total_ziyadah_hal']?.toString() ?? '0') ?? 0.0
      ..mutqinRate =
          double.tryParse(json['mutqin_rate']?.toString() ?? '0') ?? 0.0
      ..totalSabaqHal =
          double.tryParse(json['total_sabaq_hal']?.toString() ?? '0') ?? 0.0
      ..totalManzilHal =
          double.tryParse(json['total_manzil_hal']?.toString() ?? '0') ?? 0.0
      ..sudahSetor =
          json['sudah_setor'] == true ||
          json['sudah_setor']?.toString() == '1' ||
          json['sudah_setor']?.toString() == 'true'
      ..rawJson = jsonEncode(json);
  }

  /// Kembalikan full JSON (termasuk riwayat_hari_ini) saat rebuild dari cache
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
      'total_ziyadah_hal': totalZiyadahHal,
      'mutqin_rate': mutqinRate,
      'total_sabaq_hal': totalSabaqHal,
      'total_manzil_hal': totalManzilHal,
      'sudah_setor': sudahSetor,
      'riwayat_hari_ini': <dynamic>[],
    };
  }
}
