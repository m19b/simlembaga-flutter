import 'package:isar/isar.dart';

part 'pra_tahfidz_riwayat_model.g.dart';

@collection
class PraTahfidzRiwayatModel {
  Id id = Isar.autoIncrement;

  @Index()
  String? nis;

  @Index()
  int? idKelas;
  
  @Index()
  int? idKelompok;

  String? tanggal;
  String? sesi;
  double? halAwal;
  double? halAkhir;
  double? totalHal;
  String? statusBacaan;
  String? namaGuru;
  String? sumberInput;
  DateTime? createdAt;

  // Safe Parsing dari API
  static PraTahfidzRiwayatModel fromJson(Map<String, dynamic> json) {
    int? parsedId = int.tryParse(json['id_prestasi_pratahfidz']?.toString() ?? json['id_prestasi']?.toString() ?? '');
    return PraTahfidzRiwayatModel()
      ..id = parsedId ?? Isar.autoIncrement
      ..nis = json['nis']?.toString() ?? ''
      ..idKelas = int.tryParse(json['id_kelas']?.toString() ?? '')
      ..idKelompok = int.tryParse(json['id_kelompok']?.toString() ?? '')
      ..tanggal = json['tanggal']?.toString() ?? ''
      ..sesi = json['sesi']?.toString() ?? ''
      ..halAwal = double.tryParse(json['hal_awal']?.toString() ?? '0') ?? 0.0
      ..halAkhir = double.tryParse(json['hal_akhir']?.toString() ?? '0') ?? 0.0
      ..totalHal = double.tryParse(json['total_hal']?.toString() ?? '0') ?? 0.0
      ..statusBacaan = json['status_bacaan']?.toString() ?? ''
      ..namaGuru = json['nama_guru']?.toString() ?? ''
      ..sumberInput = json['sumber_input']?.toString() ?? ''
      ..createdAt = DateTime.tryParse(json['created_at']?.toString() ?? json['tanggal']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != Isar.autoIncrement) 'id_prestasi_pratahfidz': id,
      'nis': nis,
      'id_kelas': idKelas,
      'id_kelompok': idKelompok,
      'tanggal': tanggal,
      'sesi': sesi,
      'hal_awal': halAwal,
      'hal_akhir': halAkhir,
      'total_hal': totalHal,
      'status_bacaan': statusBacaan,
      'nama_guru': namaGuru,
      'sumber_input': sumberInput,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
