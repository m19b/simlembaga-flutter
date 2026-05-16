import 'package:flutter/foundation.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/features/dashboard/data/models/dashboard_model.dart';

class DashboardRepository {
  final NetworkInfo networkInfo;
  final LocalDataSource localDataSource;

  DashboardRepository({
    required this.networkInfo,
    required this.localDataSource,
  });

  Future<DashboardModel> getDashboardData({bool forceRefresh = false, int? idKategori}) async {
    final cacheKey = 'dashboard_data_cache_${idKategori ?? 0}';

    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final Map<String, dynamic> responseData = await ApiService.getDashboardGuru(idKategori: idKategori);
        
        // Backend CI4 membungkus data dalam key 'data'
        final Map<String, dynamic> payload =
            (responseData['data'] is Map<String, dynamic>)
                ? responseData['data'] as Map<String, dynamic>
                : responseData;

        // Simpan ke Cache (simpan payload saja, bukan wrapper)
        await localDataSource.cacheData(cacheKey, payload);

        // DEBUG: trace nama_kelas dari API
        assert(() {
          debugPrint('=== DASHBOARD API PAYLOAD ===');
          debugPrint('nama_kelas  : ${payload['nama_kelas']}');
          debugPrint('nama_kelompok: ${payload['nama_kelompok']}');
          debugPrint('id_kategori : ${payload['id_kategori']}');
          debugPrint('total_santri: ${payload['summary']?['total_santri']}');
          return true;
        }());
        
        return DashboardModel.fromJson(payload);
      } catch (e, stackTrace) {
        if (e.toString().contains('401') || e.toString().toLowerCase().contains('unauthorized')) {
          rethrow;
        }
        
        // Log only in debug mode
        assert(() {
          debugPrint('Error fetch dashboard: $e');
          debugPrint('Stack trace: $stackTrace');
          return true;
        }());
        final cachedData = await localDataSource.getCachedData(cacheKey);
        if (cachedData != null) {
          return DashboardModel.fromJson(cachedData);
        }
        throw Exception('Gagal mengambil data dashboard dari server dan cache kosong. Detail: $e');
      }
    }

    // Offline Mode: Ambil dari Cache
    final cachedData = await localDataSource.getCachedData(cacheKey);
    if (cachedData != null) {
      return DashboardModel.fromJson(cachedData);
    }

    throw Exception('Tidak ada koneksi internet dan cache kosong. Silakan online untuk sinkronisasi awal.');
  }
}
