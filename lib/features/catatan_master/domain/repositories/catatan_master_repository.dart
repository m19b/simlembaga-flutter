import 'package:manajemen_tahsin_app/core/api/services/santri_catatan_api_service.dart';
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
        final resp = await SantriCatatanApiService.getCatatanMaster(
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
    // Optimistic insert
    final newItem = {
      'id_catatan': DateTime.now().millisecondsSinceEpoch,
      'id_kelas': data['id_kelas'],
      'id_kelompok': data['id_kelompok'],
      'teks_catatan': data['teks_catatan'],
      'nama_kelas': '-', // Placeholder for offline UI
      'nama_kelompok': '-',
      'aktif': data['aktif'] == 1 ? 1 : 0, // Keep format compatible with CatatanMasterModel
      'urutan': data['urutan'],
      'is_syncing': true,
    };

    try {
      final String cacheKey = 'catatan_master_all_all_all';
      final cAktif = await localDataSource.getCachedData(cacheKey);
      if (cAktif != null && cAktif['data'] != null && cAktif['data']['catatan'] != null) {
        final list = List<Map<String, dynamic>>.from(
            (cAktif['data']['catatan'] as List).map((e) => Map<String, dynamic>.from(e)));
        list.insert(0, newItem);
        cAktif['data']['catatan'] = list;
        // Gunakan fungsi cacheData (yang menggunakan IsarDb.instance.writeTxn di dalamnya)
        await localDataSource.cacheData(cacheKey, cAktif);
      }
    } catch (_) {}

    if (await networkInfo.isConnected) {
      try {
        await SantriCatatanApiService.storeCatatanMaster(data);
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/catatan-master/store', data);
      }
    }
    return _enqueuePayload('api/guru/catatan-master/store', data);
  }

  Future<bool> updateCatatanMaster(Map<String, dynamic> data) async {
    try {
      final String cacheKey = 'catatan_master_all_all_all';
      final cAktif = await localDataSource.getCachedData(cacheKey);
      if (cAktif != null && cAktif['data'] != null && cAktif['data']['catatan'] != null) {
        final list = List<Map<String, dynamic>>.from(
            (cAktif['data']['catatan'] as List).map((e) => Map<String, dynamic>.from(e)));
        
        final idx = list.indexWhere((e) => e['id_catatan'].toString() == data['id_catatan'].toString());
        if (idx != -1) {
          list[idx]['id_kelas'] = data['id_kelas'];
          list[idx]['id_kelompok'] = data['id_kelompok'];
          list[idx]['teks_catatan'] = data['teks_catatan'];
          list[idx]['urutan'] = data['urutan'];
          list[idx]['aktif'] = data['aktif'] == 1 ? 1 : 0;
          list[idx]['is_syncing'] = true;
          cAktif['data']['catatan'] = list;
          await localDataSource.cacheData(cacheKey, cAktif);
        }
      }
    } catch (_) {}

    if (await networkInfo.isConnected) {
      try {
        await SantriCatatanApiService.updateCatatanMaster(data);
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/catatan-master/update', data);
      }
    }
    return _enqueuePayload('api/guru/catatan-master/update', data);
  }

  Future<bool> deleteCatatanMaster(int idCatatan) async {
    final payload = {'id_catatan': idCatatan};

    try {
      final String cacheKey = 'catatan_master_all_all_all';
      final cAktif = await localDataSource.getCachedData(cacheKey);
      if (cAktif != null && cAktif['data'] != null && cAktif['data']['catatan'] != null) {
        final list = List<Map<String, dynamic>>.from(
            (cAktif['data']['catatan'] as List).map((e) => Map<String, dynamic>.from(e)));
        list.removeWhere((e) => e['id_catatan'].toString() == idCatatan.toString());
        cAktif['data']['catatan'] = list;
        await localDataSource.cacheData(cacheKey, cAktif);
      }
    } catch (_) {}

    if (await networkInfo.isConnected) {
      try {
        await SantriCatatanApiService.deleteCatatanMaster(idCatatan);
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
