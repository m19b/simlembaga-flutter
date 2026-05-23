import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';

class CatatanMasterRepository {
  final NetworkInfo networkInfo;
  final LocalDataSource localDataSource;

  CatatanMasterRepository({
    required this.networkInfo,
    required this.localDataSource,
  });

  // ─── READ ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getCatatanMaster({
    int? idKelompok,
    int? idKelas,
    int? idKategori,
    bool forceRefresh = false,
  }) async {
    final String cacheKey = 'catatan_master_${idKelompok ?? 'all'}_${idKelas ?? 'all'}_${idKategori ?? 'all'}';

    if (await networkInfo.isConnected) {
      try {
        final resp = await ApiService.getCatatanMaster(
          idKelompok: idKelompok,
          idKelas: idKelas,
          idKategori: idKategori,
        );

        // Cache response
        await localDataSource.cacheData(cacheKey, resp);
        return resp;
      } catch (e) {
        // Fallback to cache on error
        return _loadFromCache(cacheKey);
      }
    }

    return _loadFromCache(cacheKey);
  }

  Future<Map<String, dynamic>> _loadFromCache(String cacheKey) async {
    final cached = await localDataSource.getCachedData(cacheKey);
    if (cached != null) {
      cached['is_offline_fallback'] = true;
      return cached;
    }
    throw Exception('Offline: Data catatan master belum ada di cache.');
  }

  // ─── WRITE ────────────────────────────────────────────────────────────────
  Future<bool> storeCatatanMaster(Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        await ApiService.storeCatatanMaster(data);
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/catatan-master/store', data);
      }
    }
    return _enqueuePayload('api/guru/catatan-master/store', data);
  }

  Future<bool> updateCatatanMaster(Map<String, dynamic> data) async {
    if (await networkInfo.isConnected) {
      try {
        await ApiService.updateCatatanMaster(data);
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/catatan-master/update', data);
      }
    }
    return _enqueuePayload('api/guru/catatan-master/update', data);
  }

  Future<bool> deleteCatatanMaster(int idCatatan) async {
    final payload = {'id_catatan': idCatatan};
    if (await networkInfo.isConnected) {
      try {
        await ApiService.deleteCatatanMaster(idCatatan);
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/catatan-master/hapus', payload);
      }
    }
    return _enqueuePayload('api/guru/catatan-master/hapus', payload);
  }

  Future<bool> _enqueuePayload(String endpoint, Map<String, dynamic> payload) async {
    await localDataSource.enqueueRequest(endpoint, payload);
    return true;
  }
}
