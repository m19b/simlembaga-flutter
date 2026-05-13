import 'package:manajemen_tahsin_app/core/api/dio_client.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';

abstract class PresensiRepository {
  Future<Map<String, dynamic>> getPresensiList(int idKelompok, String tingkat);
  Future<bool> submitAbsensi(Map<String, dynamic> payload);
}

class PresensiRepositoryImpl implements PresensiRepository {
  final NetworkInfo networkInfo;
  final LocalDataSource localDataSource;

  PresensiRepositoryImpl({
    required this.networkInfo,
    required this.localDataSource,
  });

  @override
  Future<Map<String, dynamic>> getPresensiList(int idKelompok, String tingkat) async {
    final cacheKey = 'presensi_list_\${idKelompok}_\${tingkat}';

    if (await networkInfo.isConnected) {
      try {
        final dio = await DioClient.dio;
        final response = await dio.post(
          'guru/absensi-santri/ajax-list',
          data: {
            'id_kelompok': idKelompok,
            'tingkat': tingkat,
          },
        );

        if (response.statusCode == 200) {
          final data = response.data;
          // Simpan ke Cache
          await localDataSource.cacheData(cacheKey, data);
          return data;
        }
      } catch (e) {
        // Fallback to cache if server error despite having internet
        final cachedData = await localDataSource.getCachedData(cacheKey);
        if (cachedData != null) return cachedData;
        throw Exception('Gagal mengambil data dan cache kosong');
      }
    }

    // Offline Mode: Ambil dari Cache
    final cachedData = await localDataSource.getCachedData(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    throw Exception('Tidak ada koneksi internet dan cache kosong');
  }

  @override
  Future<bool> submitAbsensi(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        final dio = await DioClient.dio;
        final response = await dio.post(
          'guru/absensi-santri/save',
          data: payload,
        );
        return response.statusCode == 200;
      } catch (e) {
        // Fallback to offline queue if server is unreachable
        return _enqueueAbsensi(payload);
      }
    }

    // Offline Mode: Masukkan ke Queue
    return _enqueueAbsensi(payload);
  }

  Future<bool> _enqueueAbsensi(Map<String, dynamic> payload) async {
    await localDataSource.enqueueRequest('guru/absensi-santri/save', payload);
    // Optimistic UI Update: Berpura-pura berhasil
    return true;
  }
}
