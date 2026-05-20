class UserModel {
  final int id;
  final String username;
  final String email;
  final String group;
  final String? nig;        // Nomor Induk Guru (dari backend)
  final int idKelompok;    // Kelompok/Cabang aktif
  final List<Map<String, dynamic>> kelompokList;
  final String? fotoUser;
  final String? logoMetode;
  final String? logoLembaga;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.group,
    this.nig,
    this.idKelompok = 0,
    this.kelompokList = const [],
    this.fotoUser,
    this.logoMetode,
    this.logoLembaga,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Extract kelompok list if provided by backend
    List<Map<String, dynamic>> parsedKelompokList = [];
    if (json['kelompok_list'] != null) {
      parsedKelompokList = List<Map<String, dynamic>>.from(json['kelompok_list']);
    } else if (json['kelas_diampu'] != null) {
       // Fallback: extract unique kelompok from kelas_diampu if kelompok_list is not provided directly
       final List kelasDiampu = json['kelas_diampu'];
       final Map<int, Map<String, dynamic>> uniqueKelompok = {};
       for (var k in kelasDiampu) {
          final idKlp = k['id_kelompok'] != null ? int.tryParse(k['id_kelompok'].toString()) : null;
          if (idKlp != null && idKlp > 0) {
             uniqueKelompok[idKlp] = {
               'id_kelompok': idKlp,
               'nama_kelompok': k['nama_kelompok'] ?? 'Cabang $idKlp'
             };
          }
       }
       parsedKelompokList = uniqueKelompok.values.toList();
    }

    return UserModel(
      id:          json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      username:    json['username']?.toString() ?? '',
      email:       json['email']?.toString() ?? '',
      group:       json['group']?.toString() ?? 'guru',
      nig:         json['nig']?.toString(),
      idKelompok:  json['id_kelompok'] != null
                     ? int.tryParse(json['id_kelompok'].toString()) ?? 0
                     : 0,
      kelompokList: parsedKelompokList,
      fotoUser:    json['foto_user']?.toString(),
      logoMetode:  json['logo_metode']?.toString(),
      logoLembaga: json['logo_lembaga']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'group': group,
      if (nig != null) 'nig': nig,
      'id_kelompok': idKelompok,
      'kelompok_list': kelompokList,
      if (fotoUser != null) 'foto_user': fotoUser,
      if (logoMetode != null) 'logo_metode': logoMetode,
      if (logoLembaga != null) 'logo_lembaga': logoLembaga,
    };
  }
}
