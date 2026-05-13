class GeneralSettings {
  final String namaAplikasi;
  final String namaLembaga;
  final String? tahunAjaran;
  final String? alamatLembaga;
  final String? telepon;
  final String? email;
  final String? copyright;
  final String? logoAplikasi;
  final String? logoLembaga;

  GeneralSettings({
    required this.namaAplikasi,
    required this.namaLembaga,
    this.tahunAjaran,
    this.alamatLembaga,
    this.telepon,
    this.email,
    this.copyright,
    this.logoAplikasi,
    this.logoLembaga,
  });

  factory GeneralSettings.fromJson(Map<String, dynamic> json) {
    return GeneralSettings(
      namaAplikasi: json['nama_aplikasi'] ?? 'SIM Lembaga',
      namaLembaga: json['nama_lembaga'] ?? '',
      tahunAjaran: json['tahun_ajaran'],
      alamatLembaga: json['alamat_lembaga'],
      telepon: json['telepon'],
      email: json['email'],
      copyright: json['copyright'],
      logoAplikasi: json['logo_aplikasi'],
      logoLembaga: json['logo_lembaga'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_aplikasi': namaAplikasi,
      'nama_lembaga': namaLembaga,
      'tahun_ajaran': tahunAjaran,
      'alamat_lembaga': alamatLembaga,
      'telepon': telepon,
      'email': email,
      'copyright': copyright,
      'logo_aplikasi': logoAplikasi,
      'logo_lembaga': logoLembaga,
    };
  }
}
