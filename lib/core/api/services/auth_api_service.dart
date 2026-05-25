import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:manajemen_tahsin_app/features/auth/data/user_model.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/core/api/dio_client.dart';
import 'package:manajemen_tahsin_app/core/api/global_interceptor.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/kelas_model.dart';
import 'package:manajemen_tahsin_app/core/api/core_api_client.dart';

/// Domain service khusus untuk Authentication & Profile
class AuthApiService {
  static const String _userKey = 'LOGGED_IN_USER';
  static const _storage = FlutterSecureStorage();

  static Future<UserModel> login(String identity, String password) async {
    // 🌟 FAST-FAIL OFFLINE CHECK
    final isOnline = LocalNetworkChecker().currentStatus == LocalNetworkStatus.online;
    if (!isOnline) {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(_userKey);
      final cachedPassword = await _storage.read(key: 'cached_password');
      
      if (userStr != null && userStr.isNotEmpty && cachedPassword != null) {
        final user = UserModel.fromJson(json.decode(userStr));
        if ((user.username == identity || user.email == identity) && password == cachedPassword) {
          final dummyToken = 'OFFLINE_CACHE_TOKEN';
          GlobalInterceptor.setToken(dummyToken);
          DioClient.reset();
          return user; 
        } else {
          throw Exception('Username atau password yang Anda masukkan salah.');
        }
      } else {
        throw Exception('Anda sedang offline dan belum pernah login sebelumnya. Silakan sambungkan ke server.');
      }
    }

    try {
      final client = await DioClient.getNewInstanceWithShortTimeout(3);
      final response = await client.post(
        'api/login',
        data: {'identity': identity, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final data = response.data as Map<String, dynamic>;
      final isSuccess = data['status'] == 200 || data['status'] == true;

      if (response.statusCode == 200 && isSuccess) {
        final token = data['data'] != null ? data['data']['token'] : null;
        if (token != null && token.toString().isNotEmpty) {
          GlobalInterceptor.setToken(token.toString());
          await _storage.write(key: 'jwt_token', value: token.toString());
        }

        await _storage.write(key: 'cached_password', value: password);

        final userData = data['data']['user'] ?? data['data'];
        final user = UserModel.fromJson(userData as Map<String, dynamic>);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(user.toJson()));
        if (user.fotoUser != null) {
          await prefs.setString('cached_foto_profil', user.fotoUser!);
        }
        await prefs.setString('cached_nama_guru', user.username);

        final rawGuru = data['data']['guru'];
        if (rawGuru != null && rawGuru['kelas_diampu'] != null) {
          final listDiampu = rawGuru['kelas_diampu'] as List;
          final List<KelasModel> kelasListToSave = [];

          for (var k in listDiampu) {
            if (k is Map) {
              final idKelas = int.tryParse(k['id_kelas']?.toString() ?? '0') ?? 0;
              final km = KelasModel()
                ..idKelas = idKelas
                ..tingkat = k['tingkat']?.toString()
                ..idKelompok = int.tryParse(k['id_kelompok']?.toString() ?? '0')
                ..idKategori = int.tryParse(k['id_kategori']?.toString() ?? '0')
                ..namaKelompok = k['nama_kelompok']?.toString();

              if (k['checkpoints'] != null && k['checkpoints'] is List) {
                final List<CheckpointLokal> cpList = [];
                for (var c in k['checkpoints']) {
                  if (c is Map) {
                    final cp = CheckpointLokal()
                      ..halamanTarget = double.tryParse(c['halaman_target']?.toString() ?? '0')
                      ..harusTes = int.tryParse(c['harus_tes']?.toString() ?? '0')
                      ..keterangan = c['keterangan']?.toString();
                    cpList.add(cp);
                  }
                }
                km.checkpoints = cpList;
              }
              kelasListToSave.add(km);
            }
          }

          if (kelasListToSave.isNotEmpty) {
            IsarDb.instance.writeTxnSync(() {
              IsarDb.instance.kelasModels.putAllSync(kelasListToSave);
            });
          }
        }

        DioClient.reset();
        return user;
      } else {
        throw Exception(data['message'] ?? 'Login gagal. Periksa kembali data Anda.');
      }
    } on DioException catch (e) {
      CoreApiClient.handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<void> logout() async {
    try {
      final client = await DioClient.dio;
      client.post('api/logout').then((_) {}).catchError((_) {});
    } catch (_) {
    } finally {
      try {
        GlobalInterceptor.clearToken();
        await _storage.delete(key: 'jwt_token');
        ActiveKelompokCubit.activeKelompokId = 0;
        DioClient.reset();
      } catch (e) {
        debugPrint("Gagal membersihkan cache lokal saat logout: $e");
      }
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final cacheKey = 'profile_data';
    final isOnline = LocalNetworkChecker().currentStatus == LocalNetworkStatus.online;

    if (isOnline) {
      try {
        final resp = await CoreApiClient.get('guru/profile');
        await LocalDataSourceImpl().cacheData(cacheKey, resp);
        return resp;
      } catch (e) {
        final cached = await LocalDataSourceImpl().getCachedData(cacheKey);
        if (cached != null) {
          cached['is_offline_fallback'] = true;
          return cached;
        }
        rethrow;
      }
    } else {
      final cached = await LocalDataSourceImpl().getCachedData(cacheKey);
      if (cached != null) {
        cached['is_offline_fallback'] = true;
        return cached;
      } else {
        throw Exception('Tidak ada koneksi internet dan profil belum tersimpan secara offline.');
      }
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required Map<String, String> fields,
    File? fotoFile,
  }) async {
    try {
      final client = await DioClient.dio;
      final formData = FormData.fromMap({
        ...fields,
        if (fotoFile != null)
          'foto': await MultipartFile.fromFile(fotoFile.path, filename: fotoFile.path.split('/').last),
      });
      debugPrint('rrrrrrrrrrrrrrrrrrrrrrr API_POST_MULTIPART: api/guru/profile/update');
      final response = await client.post('api/guru/profile/update', data: formData);
      return CoreApiClient.parseResponseData(response);
    } on DioException catch (e) {
      CoreApiClient.handleDioError(e);
      rethrow;
    }
  }

  static Future<void> checkConnection({int timeoutSeconds = 5}) async {
    try {
      final client = await DioClient.getNewInstanceWithShortTimeout(timeoutSeconds);
      final response = await client.post('api/login', options: Options(validateStatus: (status) => true));
      debugPrint("Ping Server Sukses. Status Code: \${response.statusCode}");
      if (response.data is! Map) {
        throw Exception("Server terhubung, tapi tidak merespons dalam format sistem.");
      }
    } on DioException catch (e) {
      debugPrint("Ping Server Gagal (DioException): \${e.message}");
      CoreApiClient.handleDioError(e);
    } catch (e) {
      debugPrint("Ping Server Error Umum: \$e");
      throw Exception("Gagal menghubungi server. Error: \$e");
    }
  }
}
