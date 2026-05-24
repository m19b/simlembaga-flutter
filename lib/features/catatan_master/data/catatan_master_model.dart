class CatatanMaster {
  final int idCatatan;
  final int idKelas;
  final int idKelompok;
  final String teksCatatan;
  final String namaKelas;
  final String namaKelompok;
  final String namaKategori;
  final bool aktif;
  final int urutan;

  CatatanMaster({
    required this.idCatatan,
    required this.idKelas,
    required this.idKelompok,
    required this.teksCatatan,
    required this.namaKelas,
    required this.namaKelompok,
    this.namaKategori = '',
    required this.aktif,
    required this.urutan,
  });

  factory CatatanMaster.fromJson(Map<String, dynamic> json) {
    return CatatanMaster(
      idCatatan: int.tryParse(json['id_catatan']?.toString() ?? '0') ?? 0,
      idKelas: int.tryParse(json['id_kelas']?.toString() ?? '0') ?? 0,
      idKelompok: int.tryParse(json['id_kelompok']?.toString() ?? '0') ?? 0,
      teksCatatan: json['teks_catatan']?.toString() ?? '',
      namaKelas: json['nama_kelas']?.toString() ?? '',
      namaKelompok: json['nama_kelompok']?.toString() ?? '',
      namaKategori: json['nama_kategori']?.toString() ?? '',
      aktif: (int.tryParse(json['aktif']?.toString() ?? '0') ?? 0) == 1,
      urutan: int.tryParse(json['urutan']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_catatan': idCatatan,
        'id_kelas': idKelas,
        'id_kelompok': idKelompok,
        'teks_catatan': teksCatatan,
        'urutan': urutan,
        'aktif': aktif ? 1 : 0,
      };
}
