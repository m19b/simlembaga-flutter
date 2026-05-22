import 'package:isar/isar.dart';

part 'tahfidz_riwayat_model.g.dart';

/// Entitas Isar untuk menyimpan riwayat setoran harian santri Tahfidz.
/// Field sesuai dengan respons API detail / riwayat dari `t_prestasi_tahfidz`.
@collection
class TahfidzRiwayatModel {
  Id id = Isar.autoIncrement;

  @Index()
  String? nis;

  @Index()
  DateTime? tanggal;

  @Index()
  int? idKelas;

  @Index()
  int? idKelompok;

  @Index()
  int? sesi;

  // ── Ziyadah (Hafalan Baru = setoran) ────────────────────────────────────────
  double? ziyadahAwal;
  double? ziyadahTotal;
  double? ziyadahAkhir;
  String? statusLulus; // 'Lulus' | 'Ulang'

  // ── Sabaq (Ulangan Baru = murojaah_baru) ────────────────────────────────────
  double? sabaqAwal;
  double? sabaqTotal;
  double? sabaqAkhir;

  // ── Manzil (Ulangan Lama = murojaah_lama) ───────────────────────────────────
  double? manzilAwal;
  double? manzilTotal;
  double? manzilAkhir;

  // Meta
  String? namaGuru;

  /// Safe Parsing dari respons detail API (field cocok dengan `t_prestasi_tahfidz`)
  static TahfidzRiwayatModel fromJson(Map<String, dynamic> json) {
    final parsedId =
        int.tryParse(json['id_prestasi_tahfidz']?.toString() ?? '') ??
        int.tryParse(json['id_prestasi']?.toString() ?? '');
    return TahfidzRiwayatModel()
      ..id = parsedId ?? Isar.autoIncrement
      ..nis = json['nis']?.toString() ?? ''
      ..tanggal = DateTime.tryParse(json['tanggal']?.toString() ?? '')
      ..idKelas = int.tryParse(json['id_kelas']?.toString() ?? '')
      ..idKelompok = int.tryParse(json['id_kelompok']?.toString() ?? '')
      ..sesi = int.tryParse(json['sesi']?.toString() ?? '1')
      ..ziyadahAwal =
          double.tryParse(json['setoran_hal_awal']?.toString() ?? '0') ?? 0.0
      ..ziyadahTotal =
          double.tryParse(json['setoran_hal_total']?.toString() ?? '0') ?? 0.0
      ..ziyadahAkhir =
          double.tryParse(json['setoran_hal_akhir']?.toString() ?? '0') ?? 0.0
      ..statusLulus = json['status_lulus']?.toString() ?? 'Lulus'
      ..sabaqAwal =
          double.tryParse(json['murojaah_baru_awal']?.toString() ?? '0') ?? 0.0
      ..sabaqTotal =
          double.tryParse(
            json['murojaah_baru_total']?.toString() ?? '0',
          ) ??
          0.0
      ..sabaqAkhir =
          double.tryParse(
            json['murojaah_baru_akhir']?.toString() ?? '0',
          ) ??
          0.0
      ..manzilAwal =
          double.tryParse(json['murojaah_lama_awal']?.toString() ?? '0') ?? 0.0
      ..manzilTotal =
          double.tryParse(
            json['murojaah_lama_total']?.toString() ?? '0',
          ) ??
          0.0
      ..manzilAkhir =
          double.tryParse(
            json['murojaah_lama_akhir']?.toString() ?? '0',
          ) ??
          0.0
      ..namaGuru = json['nama_guru']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != Isar.autoIncrement) 'id_prestasi_tahfidz': id,
      'nis': nis,
      'tanggal': tanggal?.toIso8601String(),
      'id_kelas': idKelas,
      'id_kelompok': idKelompok,
      'sesi': sesi,
      'setoran_hal_awal': ziyadahAwal,
      'setoran_hal_total': ziyadahTotal,
      'setoran_hal_akhir': ziyadahAkhir,
      'status_lulus': statusLulus,
      'murojaah_baru_awal': sabaqAwal,
      'murojaah_baru_total': sabaqTotal,
      'murojaah_baru_akhir': sabaqAkhir,
      'murojaah_lama_awal': manzilAwal,
      'murojaah_lama_total': manzilTotal,
      'murojaah_lama_akhir': manzilAkhir,
      'nama_guru': namaGuru,
    };
  }
}
