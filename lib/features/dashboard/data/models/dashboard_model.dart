class DashboardModel {
  final String guruName;
  final String role;
  final String nig;
  final int idKelompok;
  final String namaKelompok;
  final String namaKelas;
  final DashboardSummary summary;
  final List<Map<String, dynamic>> chartKecepatan;
  final List<Map<String, dynamic>> urgentList;
  final List<dynamic> jadwalGuru;
  final List<dynamic> jadwalKelas;
  final List<dynamic> aktivitas7Hari;
  final List<dynamic> inputTerbaru;
  final List<dynamic> daftarTes;
  final List<dynamic> santriList;

  DashboardModel({
    required this.guruName,
    required this.role,
    required this.nig,
    required this.idKelompok,
    required this.namaKelompok,
    required this.namaKelas,
    required this.summary,
    required this.chartKecepatan,
    required this.urgentList,
    required this.jadwalGuru,
    required this.jadwalKelas,
    required this.aktivitas7Hari,
    required this.inputTerbaru,
    required this.daftarTes,
    required this.santriList,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parseListMap(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    }

    return DashboardModel(
      guruName: json['guru_name'] ?? 'Guru',
      role: (json['role']?.toString() ?? 'Guru')
          .replaceAll('Guru Pengajar', 'Guru')
          .replaceAll('Administrator', 'Admin'),
      nig: json['nig'] ?? '',
      idKelompok: int.tryParse(json['id_kelompok']?.toString() ?? '0') ?? 0,
      namaKelompok: json['nama_kelompok'] ?? '-',
      namaKelas: json['nama_kelas'] ?? '-',
      summary: DashboardSummary.fromJson(json['summary'] ?? {}),
      chartKecepatan: parseListMap(json['chart_kecepatan']),
      urgentList: parseListMap(json['urgent_list']),
      jadwalGuru: json['jadwal_guru'] is List ? json['jadwal_guru'] : [],
      jadwalKelas: json['jadwal_kelas'] is List ? json['jadwal_kelas'] : [],
      aktivitas7Hari: json['aktivitas_7hari'] is List
          ? json['aktivitas_7hari']
          : [],
      inputTerbaru: json['input_terbaru'] is List ? json['input_terbaru'] : [],
      daftarTes: json['daftar_tes'] is List ? json['daftar_tes'] : [],
      santriList: json['santri_list'] is List ? json['santri_list'] : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guru_name': guruName,
      'role': role,
      'nig': nig,
      'id_kelompok': idKelompok,
      'nama_kelompok': namaKelompok,
      'nama_kelas': namaKelas,
      'summary': summary.toJson(),
      'chart_kecepatan': chartKecepatan,
      'urgent_list': urgentList,
      'jadwal_guru': jadwalGuru,
      'jadwal_kelas': jadwalKelas,
      'aktivitas_7hari': aktivitas7Hari,
      'input_terbaru': inputTerbaru,
      'daftar_tes': daftarTes,
      'santri_list': santriList,
    };
  }
}

class DashboardSummary {
  final int totalSantri;
  final int hadir;
  final int perluPerhatian;
  final int siapTest;
  final int sudahInput;
  final int belumDiinput;
  final int tidakDisimak;

  DashboardSummary({
    required this.totalSantri,
    required this.hadir,
    required this.perluPerhatian,
    required this.siapTest,
    required this.sudahInput,
    required this.belumDiinput,
    required this.tidakDisimak,
  });

  int _parse(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final s = DashboardSummary(
      totalSantri: 0,
      hadir: 0,
      perluPerhatian: 0,
      siapTest: 0,
      sudahInput: 0,
      belumDiinput: 0,
      tidakDisimak: 0,
    );
    return DashboardSummary(
      totalSantri: s._parse(json['total_santri']),
      hadir: s._parse(json['hadir']),
      perluPerhatian: s._parse(json['perlu_perhatian']),
      siapTest: s._parse(json['siap_test']),
      sudahInput: s._parse(json['sudah_input']),
      belumDiinput: s._parse(json['belum_diinput']),
      tidakDisimak: s._parse(json['tidak_disimak']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_santri': totalSantri,
      'hadir': hadir,
      'perlu_perhatian': perluPerhatian,
      'siap_test': siapTest,
      'sudah_input': sudahInput,
      'belum_diinput': belumDiinput,
      'tidak_disimak': tidakDisimak,
    };
  }
}
