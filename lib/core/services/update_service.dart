import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'dart:io';

class UpdateEntity {
  final bool isAvailable;
  final String latestVersion;
  final String releaseNotes;
  final String downloadUrl;

  UpdateEntity({
    required this.isAvailable,
    required this.latestVersion,
    required this.releaseNotes,
    required this.downloadUrl,
  });
}

class UpdateService {
  final Dio _dio;
  
  UpdateService(this._dio);

  Future<UpdateEntity> checkForUpdate() async {
    try {
      // 1. Dapatkan versi lokal (current version)
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = Version.parse(packageInfo.version);

      // 2. Fetch data dari endpoint CI4
      // Gunakan instance Dio yang sudah memiliki baseUrl
      final response = await _dio.get('/api/v1/update/check');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        final latestVersionStr = data['latest_version'] ?? '1.0.0';
        final latestVersion = Version.parse(latestVersionStr);
        
        // 3. Bandingkan versi
        final isAvailable = latestVersion > currentVersion;

        return UpdateEntity(
          isAvailable: isAvailable,
          latestVersion: latestVersionStr,
          releaseNotes: data['release_notes'] ?? 'Pembaruan aplikasi tersedia. Silakan update untuk fitur terbaru.',
          downloadUrl: data['download_url'] ?? '',
        );
      }
      
      throw Exception('Gagal mendapatkan informasi update dari server');
      
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Koneksi timeout saat mengecek update');
      }
      throw Exception('Kesalahan jaringan: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }
}
