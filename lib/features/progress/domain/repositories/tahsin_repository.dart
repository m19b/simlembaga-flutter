import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';

class TahsinRepository {
  final NetworkInfo networkInfo;
  final LocalDataSource localDataSource;

  TahsinRepository({
    required this.networkInfo,
    required this.localDataSource,
  });

  /// --- TAHAP 1: CACHE-THEN-NETWORK (READ) ---
  
  Future<Map<String, dynamic>> getProgressList({int? idKelompok, int? idKelas, bool forceRefresh = false}) async {
    final cacheKey = 'tahsin_progress_list_${idKelompok}_${idKelas}';

    // Offline-First: Return cache if available and not force refreshing
    if (!forceRefresh) {
      final cachedData = await localDataSource.getCachedData(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }
    }

    if (await networkInfo.isConnected) {
      try {
        final data = await ApiService.getProgressList(idKelompok: idKelompok, idKelas: idKelas);
        await localDataSource.cacheData(cacheKey, data);
        return data;
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        final cachedData = await localDataSource.getCachedData(cacheKey);
        if (cachedData != null) return cachedData;
        throw Exception('Gagal memuat data dari server dan cache kosong.');
      }
    }

    final cachedData = await localDataSource.getCachedData(cacheKey);
    if (cachedData != null) return cachedData;
    throw Exception('Tidak ada koneksi internet. Silakan online untuk memuat data awal.');
  }

  Future<Map<String, dynamic>> getProgressDetail(String nis, {bool forceRefresh = false}) async {
    final cacheKey = 'tahsin_progress_detail_\$nis';
    
    if (!forceRefresh) {
      final cachedData = await localDataSource.getCachedData(cacheKey);
      if (cachedData != null) return cachedData;
    }

    if (await networkInfo.isConnected) {
      try {
        final data = await ApiService.getProgressDetail(nis);
        await localDataSource.cacheData(cacheKey, data);
        return data;
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        final cachedData = await localDataSource.getCachedData(cacheKey);
        if (cachedData != null) return cachedData;
        rethrow;
      }
    }
    final cachedData = await localDataSource.getCachedData(cacheKey);
    if (cachedData != null) return cachedData;
    throw Exception('Offline: Detail santri belum tersimpan di cache.');
  }

  Future<Map<String, dynamic>> getRiwayatGlobal(String tanggal, {int page = 1, int limit = 20}) async {
    final cacheKey = 'tahsin_riwayat_global_${tanggal}_${page}_${limit}';
    
    // Only cache today's data to streamline storage
    final isToday = tanggal == DateTime.now().toIso8601String().split('T')[0];

    if (!isToday) {
      // Don't cache past data, always fetch from network
      if (await networkInfo.isConnected) {
        return await ApiService.getRiwayatGlobal(tanggal, page: page, limit: limit);
      }
      throw Exception('Koneksi internet diperlukan untuk melihat riwayat lama.');
    }

    // For today, use offline-first approach
    final cachedData = await localDataSource.getCachedData(cacheKey);
    if (cachedData != null) return cachedData;

    if (await networkInfo.isConnected) {
      try {
        final data = await ApiService.getRiwayatGlobal(tanggal, page: page, limit: limit);
        await localDataSource.cacheData(cacheKey, data);
        return data;
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        rethrow;
      }
    }
    
    throw Exception('Offline: Riwayat hari ini belum tersimpan di cache.');
  }

  /// --- TAHAP 2: OPTIMISTIC UI UPDATE (WRITE) ---

  Future<bool> inputMassalProgress(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        final res = await ApiService.inputMassalProgress(payload);
        return res['status'] == 200;
      } catch (e) {
        return _enqueuePayload('api/guru/tahsin/input-massal', payload); // Endpoint simulasi
      }
    }
    return _enqueuePayload('api/guru/tahsin/input-massal', payload);
  }

  Future<bool> inputCepatProgress(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        await ApiService.inputCepatProgress(payload);
        return true;
      } catch (e) {
        return _enqueuePayload('api/guru/tahsin/input-cepat', payload);
      }
    }
    return _enqueuePayload('api/guru/tahsin/input-cepat', payload);
  }

  Future<bool> _enqueuePayload(String endpoint, Map<String, dynamic> payload) async {
    // Memasukkan ke antrean Hive queueBox
    await localDataSource.enqueueRequest(endpoint, payload);
    // Return true agar UI menganggap sukses
    return true; 
  }
}
