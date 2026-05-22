import 'package:isar/isar.dart';

part 'hari_libur_model.g.dart';

@collection
class HariLiburModel {
  Id id = Isar.autoIncrement;

  @Index()
  int? tahun;

  @Index()
  int? idKelompok;

  int? idLibur;
  late String keterangan;      // "keterangan" dari CI4
  late String tanggalMulai;    // "tanggal_mulai" format: 'yyyy-MM-dd'
  late String tanggalAkhir;    // "tanggal_akhir" format: 'yyyy-MM-dd'
  String? kategori;            // 'nasional' | 'lembaga' | dsb.
  String? lembaga;             // nama kelompok lembaga

  // ── Safe Parsing dari JSON CI4 ─────────────────────────────────────────────
  static HariLiburModel fromJson(
    Map<String, dynamic> json, {
    required int tahun,
    required int idKelompok,
  }) {
    return HariLiburModel()
      ..tahun = tahun
      ..idKelompok = idKelompok
      ..idLibur = int.tryParse(json['id_libur']?.toString() ?? '')
      ..keterangan = json['keterangan']?.toString() ?? '-'
      ..tanggalMulai = json['tanggal_mulai']?.toString() ?? ''
      ..tanggalAkhir = json['tanggal_akhir']?.toString() ?? ''
      ..kategori = json['kategori']?.toString()
      ..lembaga = json['lembaga']?.toString();
  }

  Map<String, dynamic> toJson() => {
        'id_libur': idLibur,
        'keterangan': keterangan,
        'tanggal_mulai': tanggalMulai,
        'tanggal_akhir': tanggalAkhir,
        'kategori': kategori,
        'lembaga': lembaga,
      };

  /// Parses [tanggalMulai] string ('yyyy-MM-dd') ke DateTime.
  DateTime? get tanggalMulaiDt => DateTime.tryParse(tanggalMulai);

  /// Parses [tanggalAkhir] string ('yyyy-MM-dd') ke DateTime.
  DateTime? get tanggalAkhirDt => DateTime.tryParse(tanggalAkhir);

  /// Convenience: nama yang ditampilkan = keterangan
  String get namaLibur => keterangan;

  /// Convenience: tanggal utama = tanggalMulai
  DateTime? get tanggalDt => tanggalMulaiDt;
}
