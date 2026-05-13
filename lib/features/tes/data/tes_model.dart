class KeuanganDetail {
  final String idPiutang;
  final String noPiutang;
  final String keterangan;
  final double sisaPiutang;

  KeuanganDetail({
    required this.idPiutang,
    required this.noPiutang,
    required this.keterangan,
    required this.sisaPiutang,
  });

  factory KeuanganDetail.fromJson(Map<String, dynamic> json) {
    return KeuanganDetail(
      idPiutang: json['id_piutang']?.toString() ?? '',
      noPiutang: json['no_piutang']?.toString() ?? '',
      keterangan: json['keterangan']?.toString() ?? '',
      sisaPiutang: double.tryParse(json['sisa_piutang']?.toString() ?? '0') ?? 0,
    );
  }
}

class Keuangan {
  final bool adaTunggakan;
  final String pesan;
  final List<KeuanganDetail>? detail;

  Keuangan({
    required this.adaTunggakan,
    required this.pesan,
    this.detail,
  });

  factory Keuangan.fromJson(Map<String, dynamic> json) {
    bool isTunggak = false;
    if (json['ada_tunggakan'] != null) {
      if (json['ada_tunggakan'] is bool) {
        isTunggak = json['ada_tunggakan'];
      } else if (json['ada_tunggakan'] is String) {
        isTunggak = json['ada_tunggakan'].toString().toLowerCase() == 'true' || json['ada_tunggakan'] == '1';
      } else if (json['ada_tunggakan'] is int) {
        isTunggak = json['ada_tunggakan'] == 1;
      }
    }

    List<KeuanganDetail>? parsedDetail;
    if (json['detail'] is List) {
      parsedDetail = (json['detail'] as List).whereType<Map>().map((e) => KeuanganDetail.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    return Keuangan(
      adaTunggakan: isTunggak,
      pesan: json['pesan']?.toString() ?? '',
      detail: parsedDetail,
    );
  }
}

class CalonTes {
  final String nis;
  final String namaSantri;
  final String foto;
  final String tingkat;
  final int idKelas;
  final int idKelompok;
  final int sisaHal;
  final int latSek;
  final int targetLatihan;
  final Keuangan? keuangan;
  final List<dynamic> bocor;
  
  final bool isTerdaftar;
  final String? idDaftar;

  CalonTes({
    required this.nis,
    required this.namaSantri,
    required this.foto,
    required this.tingkat,
    required this.idKelas,
    required this.idKelompok,
    required this.sisaHal,
    required this.latSek,
    required this.targetLatihan,
    this.keuangan,
    this.bocor = const [],
    required this.isTerdaftar,
    this.idDaftar,
  });

  factory CalonTes.fromJson(Map<String, dynamic> json) {
    return CalonTes(
      nis: json['nis']?.toString() ?? '',
      namaSantri: json['nama_santri']?.toString() ?? '',
      foto: json['foto']?.toString() ?? '',
      tingkat: json['tingkat']?.toString() ?? '',
      idKelas: int.tryParse(json['id_kelas']?.toString() ?? '0') ?? 0,
      idKelompok: int.tryParse(json['id_kelompok']?.toString() ?? '0') ?? 0,
      sisaHal: int.tryParse(json['sisa_hal']?.toString() ?? '0') ?? 0,
      latSek: int.tryParse(json['lat_sek']?.toString() ?? '0') ?? 0,
      targetLatihan: int.tryParse(json['target_latihan']?.toString() ?? '0') ?? 0,
      keuangan: json['keuangan'] != null ? Keuangan.fromJson(json['keuangan']) : null,
      bocor: json['bocor'] is List ? List<dynamic>.from(json['bocor']) : [],
      isTerdaftar: json['isTerdaftar'] == true || json['id_daftar'] != null,
      idDaftar: json['id_daftar']?.toString(),
    );
  }
}

class RiwayatTes {
  final String idRiwayat;
  final String nis;
  final String namaSantri;
  final String foto;
  final String jilid;
  final String statusKelulusan;
  final String tglTest;
  final String? keterangan;
  final String tglDaftar;
  final String namaPendaftar;

  final String kelasAsal;
  final String kelompok;
  final String naikKe;
  final String penguji;

  RiwayatTes({
    required this.idRiwayat,
    required this.nis,
    required this.namaSantri,
    required this.foto,
    required this.jilid,
    required this.statusKelulusan,
    required this.tglTest,
    this.keterangan,
    required this.kelasAsal,
    required this.kelompok,
    required this.naikKe,
    required this.penguji,
    required this.tglDaftar,
    required this.namaPendaftar,
  });

  factory RiwayatTes.fromJson(Map<String, dynamic> json) {
    return RiwayatTes(
      idRiwayat: json['id_riwayat']?.toString() ?? json['id_tes']?.toString() ?? json['id']?.toString() ?? '',
      nis: json['nis']?.toString() ?? '',
      namaSantri: json['nama_santri']?.toString() ?? '',
      foto: json['foto']?.toString() ?? '',
      jilid: json['tingkat_dari']?.toString() ?? json['jilid']?.toString() ?? json['tingkat']?.toString() ?? '',
      statusKelulusan: json['status_lulus']?.toString() ?? json['status_kelulusan']?.toString() ?? json['status']?.toString() ?? '',
      tglTest: json['tgl_tes']?.toString() ?? json['tgl_test']?.toString() ?? json['tanggal']?.toString() ?? '',
      keterangan: json['catatan']?.toString() ?? json['keterangan']?.toString(),
      kelasAsal: json['tingkat_dari']?.toString() ?? '-',
      kelompok: json['nama_kelompok']?.toString() ?? '-',
      naikKe: json['tingkat_naik']?.toString() ?? '-',
      penguji: json['nama_penguji']?.toString() ?? json['nama_pentest']?.toString() ?? '-',
      tglDaftar: json['tgl_daftar']?.toString() ?? '-',
      namaPendaftar: json['nama_pendaftar']?.toString() ?? '-',
    );
  }
}
