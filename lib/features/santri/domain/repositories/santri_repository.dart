import 'package:manajemen_tahsin_app/core/api/services/santri_catatan_api_service.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';

class SantriRepository {
  final NetworkInfo networkInfo;
  final LocalDataSource localDataSource;

  SantriRepository({
    required this.networkInfo,
    required this.localDataSource,
  });

  /// --- TAHAP 1: CACHE-THEN-NETWORK (READ) ---
  
  Future<Map<String, dynamic>> getSantriList({int? idKelompok, int? idKelas, bool forceRefresh = false}) async {
    final cacheKey = 'santri_list_\${idKelompok}_\${idKelas}';

    if (await networkInfo.isConnected) {
      try {
        final data = await SantriCatatanApiService.getSantriList(); // Adaptasikan jika API support filter
        await localDataSource.cacheData(cacheKey, data);
        return data;
      } catch (e) {
        final cachedData = await localDataSource.getCachedData(cacheKey);
        if (cachedData != null) return cachedData;
        throw Exception('Gagal memuat daftar santri dari server dan cache kosong.');
      }
    }

    final cachedData = await localDataSource.getCachedData(cacheKey);
    if (cachedData != null) return cachedData;
    throw Exception('Offline: Daftar santri belum tersedia di cache.');
  }

  Future<Map<String, dynamic>> getSantriDetail(String nis) async {
    final cacheKey = 'santri_detail_\$nis';

    if (await networkInfo.isConnected) {
      try {
        final data = await SantriCatatanApiService.getSantriDetail(nis);
        await localDataSource.cacheData(cacheKey, data);
        return data;
      } catch (e) {
        final cachedData = await localDataSource.getCachedData(cacheKey);
        if (cachedData != null) return cachedData;
        throw e;
      }
    }

    final cachedData = await localDataSource.getCachedData(cacheKey);
    if (cachedData != null) return cachedData;
    throw Exception('Offline: Detail santri belum tersedia di cache.');
  }
}
