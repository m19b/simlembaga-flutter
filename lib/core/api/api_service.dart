import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manajemen_tahsin_app/features/auth/data/user_model.dart';
import 'package:manajemen_tahsin_app/features/auth/data/general_settings_model.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'dio_client.dart';

/// Centralized API service. Menggunakan Dio dan Stateless Token Authentication.
class ApiService {
  static const String _userKey = 'LOGGED_IN_USER';
  static const _storage = FlutterSecureStorage();

  static void _handleDioError(DioException e) {
    String humanReadableMsg = "Terjadi kesalahan jaringan.";
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      humanReadableMsg = "Koneksi ke server timeout. Gagal terhubung, pastikan server aktif atau IP benar.";
    } else if (e.type == DioExceptionType.connectionError) {
      humanReadableMsg = "Koneksi ditolak oleh server. Pastikan HP dan PC (server) terhubung di jaringan WiFi yang sama, dan IP server benar.";
    } else if (e.response != null) {
      // 1. Coba ambil error spesifik dari backend CI4 (seperti 'Password Salah', 'User tidak ditemukan')
      bool messageExtracted = false;
      try {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message') && data['message'] != null) {
          humanReadableMsg = data['message'];
          messageExtracted = true;
        } else if (data is Map && data.containsKey('error') && data['error'] != null) {
          humanReadableMsg = data['error'].toString();
          messageExtracted = true;
        }
      } catch (_) {}

      // 2. Jika backend tdk mengirim message khusus, gunakan pesan standar sesuai status error
      if (!messageExtracted) {
        if (e.response?.statusCode == 400) {
          humanReadableMsg = "Permintaan tidak valid (400 Bad Request). Periksa isian Anda.";
        } else if (e.response?.statusCode == 401) {
          humanReadableMsg = "Sesi telah berakhir atau akses ditolak (401). Silakan login kembali.";
        } else if (e.response?.statusCode == 403) {
          humanReadableMsg = "Anda tidak memiliki izin (403 Forbidden).";
        } else if (e.response?.statusCode == 404) {
          humanReadableMsg = "Endpoint (Alamat API) tidak ditemukan di server (404).";
        } else if (e.response?.statusCode == 500) {
          humanReadableMsg = "Terjadi kesalahan sistem internal di aplikasi server (500).";
        } else {
          humanReadableMsg = "Server mengembalikan status: ${e.response?.statusCode}";
        }
      }
    } else {
      humanReadableMsg = "Tidak bisa menghubungi server sama sekali. Periksa kembali IP Server dan pastikan HP terkoneksi WiFi.";
    }
    
    // Log detail error ke console developer (biar tidak hilang untuk debugging programmer)
    debugPrint("=== DETAIL DIO ERROR ===");
    debugPrint("TIPE: ${e.type.name}");
    debugPrint("PESAN: ${e.message}");
    if (e.response != null) {
      debugPrint("STATUS: ${e.response?.statusCode}");
      debugPrint("BALASAN: ${e.response?.data}");
    }
    
    throw Exception(humanReadableMsg);
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────

  static Future<UserModel> login(String identity, String password) async {
    try {
      final client = await DioClient.dio;
      final response = await client.post(
        'api/login',
        data: {'identity': identity, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final data = response.data as Map<String, dynamic>;
      final isSuccess = data['status'] == 200 || data['status'] == true;

      if (response.statusCode == 200 && isSuccess) {
        // Ambil token JWT dari respons (asumsi dikirim di properti 'token')
        // final token = data['token'];
        final token = data['data'] != null ? data['data']['token'] : null;
        if (token != null && token.toString().isNotEmpty) {
          await _storage.write(key: 'jwt_token', value: token.toString());
        }

        // Antisipasi mapping data sesuai standar baru
        final userData = data['data']['user'] ?? data['data'];
        final user = UserModel.fromJson(userData as Map<String, dynamic>);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(user.toJson()));

        // 🌟 PERBAIKAN STUCK DI DASHBOARD LINUX: 
        // Force reset instance Dio/TCP Pool setelah POST login. Caddy di Linux terkadang nge-hang 
        // kalau kita reuse connection yang sama persis sedetik setelah request yang intens.
        DioClient.reset();

        return user;
      } else {
        throw Exception(
          data['message'] ?? 'Login gagal. Periksa kembali data Anda.',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<void> logout() async {
    try {
      final client = await DioClient.dio;
      // Opsional: beritahu server untuk mematikan token jika server mendukung blacklist token
      client.post('api/logout').then((_) {}).catchError((_) {}); // Fire and forget agar UI tidak hang
    } catch (_) {
      // Abaikan error jaringan saat logout
    } finally {
      try {
        // Hapus token JWT lokal
        await _storage.delete(key: 'jwt_token');

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_userKey);
        ActiveKelompokCubit.activeKelompokId = 0; // Bersihkan state kelompk
        DioClient.reset(); // Reset Dio (misal user ganti server IP saat di login screen)
      } catch (e) {
        debugPrint("Gagal membersihkan cache lokal saat logout: $e");
      }
    }
  }

  // ─── Settings & Connection ──────────────────────────────────────────────────

  static Future<GeneralSettings> getGeneralSettings() async {
    try {
      final result = await _get('guru/settings');
      return GeneralSettings.fromJson(result['data']);
    } catch (e) {
      // Return default branding if settings fail to load
      return GeneralSettings(
        namaAplikasi: 'SIM Lembaga',
        namaLembaga: '',
      );
    }
  }

  /// Memanggil endpoint FilterHelperApi untuk mendapatkan daftar kelas (dan kelompok) milik user
  static Future<Map<String, dynamic>> getFilterKelas({int? idKelompok}) async {
    final Map<String, dynamic> q = {};
    if (idKelompok != null && idKelompok > 0) q['id_kelompok'] = idKelompok;
    return _get('guru/filter/kelas', queryParameters: q.isEmpty ? null : q);
  }

  /// Memeriksa apakah server bisa dijangkau dengan timeout pendek (2 detik)
  static Future<void> checkConnection() async {
    try {
      final client = await DioClient.getNewInstanceWithShortTimeout(2);
      // Jika server memberikan status code apapun (termasuk 401/404), berarti server HIDUP dan nyambung internet!
      client.options.validateStatus = (status) => true;
      
      final response = await client.get('api/guru/settings'); 
      debugPrint("Ping Server Sukses. Status Code: ${response.statusCode}");
    } on DioException catch (e) {
      debugPrint("Ping Server Gagal (DioException): ${e.message}");
      _handleDioError(e); // Ini akan melemparkan pesan yang sudah kita buat sebelumnya
    } catch (e) {
      debugPrint("Ping Server Error Umum: $e");
      throw Exception("Gagal menghubungi server. Eror: $e");
    }
  }

  // ─── Dashboard ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDashboardGuru({int? idKategori}) async {
    final Map<String, dynamic> query = {};
    if (idKategori != null && idKategori > 0) query['id_kategori'] = idKategori;
    return _get('guru/dashboard', queryParameters: query.isEmpty ? null : query);
  }

  // ─── Absensi ───────────────────────────────────────────────────────────────

  /// POST /api/guru/absen/scan — Absen via Kamera/RFID/NIS
  static Future<Map<String, dynamic>> scanAbsen(
    String kode,
    String waktu,
  ) async {
    return _post('guru/absen-santri/scan', {'kode': kode, 'waktu': waktu});
  }

  /// GET /api/guru/absen/rekap — Mengambil Rekap Absensi
  static Future<Map<String, dynamic>> getRekapAbsen({
    int? idKelompok,
    int? idKelas,
    String? tglMulai,
    String? tglAkhir,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (idKelompok != null && idKelompok > 0)
      queryParams['id_kelompok'] = idKelompok;
    if (idKelas != null && idKelas > 0) queryParams['id_kelas'] = idKelas;
    if (tglMulai != null && tglMulai.isNotEmpty)
      queryParams['tgl_mulai'] = tglMulai;
    if (tglAkhir != null && tglAkhir.isNotEmpty)
      queryParams['tgl_akhir'] = tglAkhir;

    return _get(
      'guru/absen-santri/rekap',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
  }

  /// GET /api/guru/absen-mandiri — Status absen hari ini + riwayat bulan ini
  static Future<Map<String, dynamic>> getStatusAbsenMandiri(int idKelompok) async {
    return _get(
      'guru/absen-guru',
      queryParameters: idKelompok > 0 ? {'id_kelompok': idKelompok} : null,
    );
  }

  /// POST /api/guru/absen-mandiri/store — Simpan absen datang/pulang
  static Future<Map<String, dynamic>> postAbsenMandiri({
    required String tipe,
    required int idKelompok,
    double? lat,
    double? lng,
  }) async {
    return _post('guru/absen-guru/store', {
      'tipe': tipe,
      'id_kelompok': idKelompok,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
  }


  // ─── Fungsi Baru Untuk Tab Absen Massal ────────────────────────────────────

  static Future<Map<String, dynamic>> getAbsenHarian({
    String? tanggal,
    int? idKelas,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (tanggal != null) queryParams['tanggal'] = tanggal;
    if (idKelas != null) queryParams['id_kelas'] = idKelas;

    return _get(
      'guru/absen-santri',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
  }

  static Future<Map<String, dynamic>> simpanAbsenMassal(
    Map<String, dynamic> payload,
  ) async {
    return _post('guru/absen-santri/simpan', payload);
  }

  // ─── Progres Belajar ───────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getProgressList({String? cari, int? idKelompok, int? idKelas, int page = 1, int limit = 20, String? filterKehadiran, String? tanggal, int? sesi}) async {
    final Map<String, dynamic> q = {'id_kategori': 1, 'page': page, 'limit': limit};
    if (cari != null && cari.isNotEmpty) q['cari'] = cari;
    if (idKelompok != null && idKelompok > 0) q['id_kelompok'] = idKelompok;
    if (idKelas != null && idKelas > 0) q['id_kelas'] = idKelas;
    if (filterKehadiran != null && filterKehadiran.isNotEmpty && filterKehadiran != 'semua') q['filter_kehadiran'] = filterKehadiran;
    if (tanggal != null && tanggal.isNotEmpty) q['tanggal'] = tanggal;
    if (sesi != null) q['sesi'] = sesi;
    return _get('guru/progress', queryParameters: q);
  }

  static Future<Map<String, dynamic>> getProgressDetail(String nis) async {
    return _get('guru/progress/detail/$nis');
  }

  static Future<Map<String, dynamic>> inputCepatProgress(
    Map<String, dynamic> payload,
  ) async {
    return _post('guru/progress/input-cepat', payload);
  }

  static Future<Map<String, dynamic>> inputMassalProgress(
    Map<String, dynamic> payload,
  ) async {
    return _post('guru/progress/input-massal', payload);
  }

  // ─── Riwayat Global ───────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getRiwayatGlobal(String tanggal, {int page = 1, int limit = 20}) async {
    return _get('guru/riwayat-global', queryParameters: {'tanggal': tanggal, 'id_kategori': 1, 'page': page, 'limit': limit});
  }

  static Future<Map<String, dynamic>> getRiwayatGlobalChart(String tglMulai, String tglAkhir) async {
    return _get('guru/riwayat-global/chart', queryParameters: {'tgl_mulai': tglMulai, 'tgl_akhir': tglAkhir});
  }

  // ─── Laporan Prestasi ──────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getLaporanPrestasi({
    String? tglMulai,
    String? tglAkhir,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> q = {'id_kategori': 1, 'page': page, 'limit': limit};
    if (tglMulai != null && tglMulai.isNotEmpty) q['tgl_mulai'] = tglMulai;
    if (tglAkhir != null && tglAkhir.isNotEmpty) q['tgl_akhir'] = tglAkhir;
    return _get('guru/laporan', queryParameters: q);
  }

  static Future<Map<String, dynamic>> getLaporanDetail(String nis) async {
    return _get('guru/laporan/detail/$nis');
  }

  // ─── Prediksi Khataman ─────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getPrediksiKhataman() async {
    return _get('guru/prediksi');
  }

  // ─── Data Santri ────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getSantriList({String? cari, int page = 1, int limit = 20}) async {
    final Map<String, dynamic> q = {'id_kategori': 1, 'page': page, 'limit': limit};
    if (cari != null && cari.isNotEmpty) q['cari'] = cari;
    return _get('guru/santri', queryParameters: q);
  }

  // PERBAIKAN: Tambahkan kata /show/ agar cocok dengan rute CI4
  static Future<Map<String, dynamic>> getSantriDetail(String nis) async {
    return _get('guru/santri/show/$nis');
  }

  // ── DAFTAR TES ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getCalonTes() async {
    return _get('guru/tes/calon');
  }

  static Future<Map<String, dynamic>> daftarkanTes({
    required String nis,
    required String idKelas,
    required String idKelompok,
  }) async {
    return _post('guru/tes/daftarkan', {
      'nis': nis,
      'id_kelas': idKelas,
      'id_kelompok': idKelompok,
    });
  }

  static Future<Map<String, dynamic>> getAntrianTes() async {
    return _get('guru/tes/antrian');
  }

  static Future<Map<String, dynamic>> batalkanTes({required String idDaftar}) async {
    return _post('guru/tes/batalkan', {
      'id_daftar': idDaftar,
    });
  }

  static Future<Map<String, dynamic>> getRiwayatTes({
    String? status,
    required String tglMulai,
    required String tglAkhir,
  }) async {
    final Map<String, dynamic> q = {
      'tgl_mulai': tglMulai,
      'tgl_akhir': tglAkhir,
    };
    if (status != null && status.isNotEmpty) q['status'] = status;
    return _get('guru/tes/riwayat', queryParameters: q);
  }

  // ── MASALAH SANTRI ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getMasalahAktif({int? idKelompok, int? idKelas}) async {
    final Map<String, dynamic> q = {};
    if (idKelompok != null && idKelompok > 0) q['id_kelompok'] = idKelompok;
    if (idKelas != null && idKelas > 0) q['id_kelas'] = idKelas;
    return _get('guru/masalah', queryParameters: q.isEmpty ? null : q);
  }

  static Future<Map<String, dynamic>> getMasalahSelesai({int? idKelompok, int? idKelas}) async {
    final Map<String, dynamic> q = {};
    if (idKelompok != null && idKelompok > 0) q['id_kelompok'] = idKelompok;
    if (idKelas != null && idKelas > 0) q['id_kelas'] = idKelas;
    return _get('guru/masalah/selesai', queryParameters: q.isEmpty ? null : q);
  }

  static Future<Map<String, dynamic>> getMasalahPendingApproval() async {
    return _get('guru/masalah/pending');
  }

  static Future<Map<String, dynamic>> storeMasalah({
    required String nis,
    required String jenisMasalah,
    required String keterangan,
    required String tglMasalah,
  }) async {
    final payload = {
      'nis': nis,
      'jenis_masalah': jenisMasalah,
      'keterangan': keterangan,
      'tgl_deteksi': tglMasalah,
    };
    print("Payload Masalah: $payload");
    return _post('guru/masalah/store', payload);
  }

  static Future<Map<String, dynamic>> updateMasalah({
    required String id,
    required String status,
    String? tglSelesai,
    String? catatanSelesai,
  }) async {
    return _post('guru/masalah/update', {
      'id_masalah': id,
      'status': status,
      if (tglSelesai != null) 'tgl_selesai': tglSelesai,
      if (catatanSelesai != null) 'catatan_selesai': catatanSelesai,
    });
  }

  static Future<Map<String, dynamic>> storeTahapMasalah({
    required String idMasalah,
    required String jenisPenyelesaian,
    required String tglPenyelesaian,
    required String keterangan,
    required String hasilTahap,
  }) async {
    return _post('guru/masalah/storeTahap', {
      'id_masalah': idMasalah,
      'jenis_penyelesaian': jenisPenyelesaian,
      'tgl_penyelesaian': tglPenyelesaian,
      'keterangan': keterangan,
      'hasil_tahap': hasilTahap,
    });
  }

  static Future<Map<String, dynamic>> setujuiMasalah({
    required String id,
  }) async {
    return _post('guru/masalah/setujui', {'id_masalah': id});
  }

  static Future<Map<String, dynamic>> tolakMasalah({
    required String id,
    required String catatan,
  }) async {
    return _post('guru/masalah/tolak', {
      'id_masalah': id,
      'catatan_penolakan': catatan,
    });
  }

  // ─── HTTP Helpers (Internal via Dio) ─────────────────────────────────────────

  static Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final client = await DioClient.dio;
      final fullUrl = '${client.options.baseUrl}api/$endpoint';
      debugPrint("📡 API_GET: $fullUrl");
      if (queryParameters != null) debugPrint("🔍 PARAMS: $queryParameters");

      final response = await client.get(
        'api/$endpoint',
        queryParameters: queryParameters,
      );
      return _parseResponseData(response);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow; // _handleDioError generally throws, this satisfies return type
    }
  }

  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final client = await DioClient.dio;
      final fullUrl = '${client.options.baseUrl}api/$endpoint';
      debugPrint("📡 API_POST: $fullUrl");
      debugPrint("📦 BODY: $body");

      final response = await client.post('api/$endpoint', data: body);
      return _parseResponseData(response);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  static Map<String, dynamic> _parseResponseData(Response response) {
    final data = response.data;
    Map<String, dynamic> parsedData;
    
    if (data is Map<String, dynamic>) {
      parsedData = data;
    } else if (data is Map) {
      parsedData = {};
      data.forEach((key, value) {
        parsedData[key.toString()] = value;
      });
    } else {
      throw Exception('Format respons tidak valid: Bukan JSON Object');
    }

    final isSuccess = parsedData['status'] == 200 || parsedData['status'] == true;
    if (!isSuccess || parsedData['error'] == true) {
      throw Exception(parsedData['message'] ?? 'Gagal memproses permintaan.');
    }
    return parsedData;
  }

  // pencarian santri (untuk form Catat Masalah)
  static Future<List<Map<String, dynamic>>> cariSantri(String query) async {
    try {
      final result = await _get(
        'guru/santri/cari',
        queryParameters: {'q': query},
      );
      final data = result['data'];
      if (data is List) {
        return data.whereType<Map>().map((e) {
          final Map<String, dynamic> safeMap = {};
          e.forEach((key, value) {
            safeMap[key.toString()] = value;
          });
          return safeMap;
        }).toList();
      }
      return [];
    } catch (e) {
      return []; // Return fallback on search failure instead of throwing
    }
  }

  // =========================================================
  // DELETE: Hapus Data Progres
  // =========================================================
  static Future<Map<String, dynamic>> deleteProgress(int idPrestasi) async {
    // Sesuaikan endpoint ini dengan backend (contoh: guru/progress/delete)
    return _post('guru/progress/delete', {'id_prestasi': idPrestasi});
  }

  // =========================================================
  // UPDATE: Edit Data Progres
  // =========================================================
  static Future<Map<String, dynamic>> updateProgress(
    int idPrestasi,
    Map<String, dynamic> data,
  ) async {
    data['id_prestasi'] = idPrestasi;
    return _post('guru/progress/update', data);
  }

  // ─── Catatan Master ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCatatanMaster({
    int? idKelompok,
    int? idKelas,
  }) async {
    final Map<String, dynamic> q = {};
    if (idKelompok != null && idKelompok > 0) q['id_kelompok'] = idKelompok;
    if (idKelas != null && idKelas > 0) q['id_kelas'] = idKelas;
    return _get('guru/catatan-master', queryParameters: q.isEmpty ? null : q);
  }

  static Future<Map<String, dynamic>> storeCatatanMaster(Map<String, dynamic> data) async {
    return _post('guru/catatan-master/store', data);
  }

  static Future<Map<String, dynamic>> updateCatatanMaster(Map<String, dynamic> data) async {
    return _post('guru/catatan-master/update', data);
  }

  static Future<Map<String, dynamic>> deleteCatatanMaster(int idCatatan) async {
    return _post('guru/catatan-master/hapus', {'id_catatan': idCatatan});
  }

  // ─── Hari Libur ─────────────────────────────────────────────────────────────

  /// GET /api/guru/hari-libur?tahun={tahun}
  /// Header wajib X-Active-Kelompok dikirim otomatis oleh DioClient interceptor.
  static Future<Map<String, dynamic>> getHariLibur({
    required int tahun,
    required int idKelompok,
  }) async {
    return _get(
      'guru/hari-libur',
      queryParameters: {'tahun': tahun, 'id_kelompok': idKelompok},
    );
  }

  // ─── Profile ────────────────────────────────────────────────────────────────


  /// GET /api/guru/profile — Ambil data profil pengguna yang sedang login
  static Future<Map<String, dynamic>> getProfile() async {
    return _get('guru/profile');
  }

  /// POST /api/guru/profile/update — Perbarui profil via FormData (multipart)
  static Future<Map<String, dynamic>> updateProfile({
    required Map<String, String> fields,
    File? fotoFile,
  }) async {
    try {
      final client = await DioClient.dio;
      final formData = FormData.fromMap({
        ...fields,
        if (fotoFile != null)
          'foto': await MultipartFile.fromFile(
            fotoFile.path,
            filename: fotoFile.path.split('/').last,
          ),
      });
      debugPrint('📡 API_POST_MULTIPART: api/guru/profile/update');
      final response = await client.post('api/guru/profile/update', data: formData);
      return _parseResponseData(response);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // =========================================================
  // SEND WA REPORT
  // =========================================================
  static Future<Map<String, dynamic>> sendWaReport({
    required String nis,
    required String target,
  }) async {
    return _post('guru/progress/send-wa', {
      'nis': nis,
      'target': target,
    });
  }

  static Future<Map<String, dynamic>> sendKolektifWaReport({
    required String tglMulai,
    required String tglAkhir,
    int? idKelompok,
  }) async {
    return _post('guru/progress/send-kolektif-wa', {
      'tgl_mulai': tglMulai,
      'tgl_akhir': tglAkhir,
      if (idKelompok != null) 'id_kelompok': idKelompok,
    });
  }

  // ─── Pra-Tahfidz ─────────────────────────────────────────────────────────────

  /// GET /api/guru/pra-tahfidz — List santri beserta riwayat setoran hari ini
  static Future<Map<String, dynamic>> getPraTahfidzList({String? tanggal}) async {
    final Map<String, dynamic> q = {};
    if (tanggal != null && tanggal.isNotEmpty) q['tanggal'] = tanggal;
    return _get('guru/pra-tahfidz', queryParameters: q.isEmpty ? null : q);
  }

  /// GET /api/guru/pra-tahfidz/detail/:nis — Detail santri + buku prestasi
  static Future<Map<String, dynamic>> getPraTahfidzDetail(String nis) async {
    return _get('guru/pra-tahfidz/detail/$nis');
  }

  /// GET /api/guru/pra-tahfidz/dashboard/:nis — Data grafik analitik performa
  static Future<Map<String, dynamic>> getPraTahfidzDashboard(
    String nis, {
    String? tglDari,
    String? tglSampai,
  }) async {
    final Map<String, dynamic> q = {};
    if (tglDari != null) q['tgl_dari'] = tglDari;
    if (tglSampai != null) q['tgl_sampai'] = tglSampai;
    return _get('guru/pra-tahfidz/dashboard/$nis', queryParameters: q.isEmpty ? null : q);
  }

  /// POST /api/guru/pra-tahfidz/input-cepat — Simpan setoran tunggal
  static Future<Map<String, dynamic>> inputCepatPraTahfidz(
    Map<String, dynamic> payload,
  ) async {
    return _post('guru/pra-tahfidz/input-cepat', payload);
  }

  /// POST /api/guru/pra-tahfidz/input-massal — Simpan setoran massal
  static Future<Map<String, dynamic>> inputMassalPraTahfidz(
    Map<String, dynamic> payload,
  ) async {
    return _post('guru/pra-tahfidz/input-massal', payload);
  }

  /// POST /api/guru/pra-tahfidz/update/:id — Edit riwayat setoran
  static Future<Map<String, dynamic>> updatePraTahfidz(
    int idPrestasi,
    Map<String, dynamic> data,
  ) async {
    return _post('guru/pra-tahfidz/update/$idPrestasi', data);
  }

  /// POST /api/guru/pra-tahfidz/delete/:id — Hapus riwayat setoran
  static Future<Map<String, dynamic>> deletePraTahfidz(int idPrestasi) async {
    return _post('guru/pra-tahfidz/delete/$idPrestasi', {});
  }

  // ─── Tahfidz Al-Qur'an ──────────────────────────────────────────────────────

  /// GET /api/tahfidz-quran — List santri + evaluasi hari ini (Ziyadah/Sabaq/Manzil)
  static Future<Map<String, dynamic>> getTahfidzList({String? tanggal}) async {
    final Map<String, dynamic> q = {};
    if (tanggal != null && tanggal.isNotEmpty) q['tanggal'] = tanggal;
    return _get('guru/tahfidz-quran', queryParameters: q.isEmpty ? null : q);
  }

  /// GET /api/tahfidz-quran/detail/:nis — Detail Buku Prestasi Santri
  static Future<Map<String, dynamic>> getTahfidzDetail(String nis) async {
    return _get('guru/tahfidz-quran/detail/$nis');
  }

  /// GET /api/tahfidz-quran/dashboard/:nis — Data grafik analitik performa
  static Future<Map<String, dynamic>> getTahfidzDashboard(
    String nis, {
    String? tglDari,
    String? tglSampai,
  }) async {
    final Map<String, dynamic> q = {};
    if (tglDari != null) q['tgl_dari'] = tglDari;
    if (tglSampai != null) q['tgl_sampai'] = tglSampai;
    return _get('guru/tahfidz-quran/dashboard/$nis', queryParameters: q.isEmpty ? null : q);
  }

  /// POST /api/tahfidz-quran/input-cepat — Simpan setoran tunggal
  static Future<Map<String, dynamic>> inputCepatTahfidz(
    Map<String, dynamic> payload,
  ) async {
    return _post('guru/tahfidz-quran/input-cepat', payload);
  }

  /// POST /api/tahfidz-quran/input-massal — Simpan setoran kelas
  static Future<Map<String, dynamic>> inputMassalTahfidz(
    Map<String, dynamic> payload,
  ) async {
    return _post('guru/tahfidz-quran/input-massal', payload);
  }

  /// POST /api/tahfidz-quran/update/:id — Edit riwayat setoran
  static Future<Map<String, dynamic>> updateTahfidz(
    int idPrestasi,
    Map<String, dynamic> data,
  ) async {
    return _post('guru/tahfidz-quran/update/$idPrestasi', data);
  }

  /// POST /api/tahfidz-quran/delete/:id — Hapus riwayat setoran
  static Future<Map<String, dynamic>> deleteTahfidz(
    int idPrestasi,
    String nis,
  ) async {
    return _post('guru/tahfidz-quran/delete/$idPrestasi', {'nis': nis});
  }
}
