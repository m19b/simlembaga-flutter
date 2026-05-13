import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/offline_queue.dart';
import 'package:manajemen_tahsin_app/core/data/models/generic_cache.dart';
import 'package:manajemen_tahsin_app/features/progress/data/models/progress_santri_model.dart';
import 'package:manajemen_tahsin_app/features/progress/data/models/riwayat_tahsin_model.dart';

class TahsinRepository {
  final NetworkInfo networkInfo;

  TahsinRepository({
    required this.networkInfo,
  });

  Isar get _isar => IsarDb.instance;

  /// --- TAHAP 1: CACHE-THEN-NETWORK (READ) ---
  
  Future<Map<String, dynamic>> getProgressList({int? idKelompok, int? idKelas, bool forceRefresh = false}) async {
    final metaCacheKey = 'tahsin_meta_${idKelompok}_${idKelas}';

    // Helper untuk load local data
    Future<Map<String, dynamic>?> loadLocal() async {
      final metaCache = await _isar.genericCaches.filter().keyEqualTo(metaCacheKey).findFirst();
      if (metaCache == null) return null;
      
      List<ProgressSantriModel> santriList;
      if (idKelas != null) {
        santriList = await _isar.progressSantriModels.filter().idKelasEqualTo(idKelas).findAll();
      } else if (idKelompok != null) {
        santriList = await _isar.progressSantriModels.filter().idKelompokEqualTo(idKelompok).findAll();
      } else {
        santriList = await _isar.progressSantriModels.where().findAll();
      }

      if (santriList.isEmpty) return null;

      final mapList = await compute(_mapProgressListToJson, santriList);
      final metaMap = await compute(_parseJsonString, metaCache.dataJson);

      return {
        'filter_meta': metaMap['filter_meta'],
        'checkpoints': metaMap['checkpoints'],
        'santri_list': mapList,
      };
    }

    if (!forceRefresh) {
      final local = await loadLocal();
      if (local != null) return local;
    }

    if (await networkInfo.isConnected) {
      try {
        final data = await ApiService.getProgressList(idKelompok: idKelompok, idKelas: idKelas);
        
        // Parsing berat di background isolate
        final parseResult = await compute(_parseProgressList, {
          'data': data,
          'idKelas': idKelas,
          'idKelompok': idKelompok,
        });

        // Simpan asinkron ke Isar
        await _isar.writeTxn(() async {
           // Hapus cache santri lama di filter ini (Context Bounded)
           if (idKelas != null) {
             await _isar.progressSantriModels.filter().idKelasEqualTo(idKelas).deleteAll();
           } else if (idKelompok != null) {
             await _isar.progressSantriModels.filter().idKelompokEqualTo(idKelompok).deleteAll();
           }

           await _isar.progressSantriModels.putAll(parseResult['models'] as List<ProgressSantriModel>);
           
           final gc = GenericCache()
             ..key = metaCacheKey
             ..dataJson = parseResult['metaJson'] as String
             ..updatedAt = DateTime.now();
           await _isar.genericCaches.put(gc);
        });

        return data;
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        final local = await loadLocal();
        if (local != null) return local;
        throw Exception('Gagal memuat data dari server dan cache kosong.');
      }
    }

    final local = await loadLocal();
    if (local != null) return local;
    throw Exception('Tidak ada koneksi internet. Silakan online untuk memuat data awal.');
  }

  Future<Map<String, dynamic>> getProgressDetail(String nis, {bool forceRefresh = false}) async {
    final cacheKey = 'tahsin_progress_detail_\$nis';
    
    if (!forceRefresh) {
      final cachedData = await _isar.genericCaches.filter().keyEqualTo(cacheKey).findFirst();
      if (cachedData != null) return await compute(_parseJsonString, cachedData.dataJson);
    }

    if (await networkInfo.isConnected) {
      try {
        final data = await ApiService.getProgressDetail(nis);
        await _isar.writeTxn(() async {
           final gc = GenericCache()
             ..key = cacheKey
             ..dataJson = await compute(_encodeJsonString, data)
             ..updatedAt = DateTime.now();
           await _isar.genericCaches.put(gc);
        });
        return data;
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        final cachedData = await _isar.genericCaches.filter().keyEqualTo(cacheKey).findFirst();
        if (cachedData != null) return await compute(_parseJsonString, cachedData.dataJson);
        rethrow;
      }
    }
    final cachedData = await _isar.genericCaches.filter().keyEqualTo(cacheKey).findFirst();
    if (cachedData != null) return await compute(_parseJsonString, cachedData.dataJson);
    throw Exception('Offline: Detail santri belum tersimpan di cache.');
  }

  Future<Map<String, dynamic>> getRiwayatGlobal(String tanggal, {int page = 1, int limit = 20}) async {
    // Only cache today's data to streamline storage
    final isToday = tanggal == DateTime.now().toIso8601String().split('T')[0];

    Future<Map<String, dynamic>?> loadLocalRiwayat() async {
       final startOfDay = DateTime.parse(tanggal);
       final endOfDay = startOfDay.add(const Duration(days: 1));
       
       final query = _isar.riwayatTahsinModels.filter().createdAtBetween(startOfDay, endOfDay);
       final data = await query.findAll();
       
       if (data.isEmpty) return null;
       
       final mapList = await compute(_mapRiwayatListToJson, data);
       
       int lulus = 0;
       int ulang = 0;
       for (var item in data) {
         if (item.statusHalaman?.toLowerCase() == 'lulus') lulus++;
         else if (item.statusHalaman?.toLowerCase() == 'ulang') ulang++;
       }

       return {
         'data': {
           'total_eval': data.length,
           'total_lulus': lulus,
           'total_ulang': ulang,
           'riwayat': mapList
         }
       };
    }

    if (!isToday) {
      if (await networkInfo.isConnected) {
        return await ApiService.getRiwayatGlobal(tanggal, page: page, limit: limit);
      }
      throw Exception('Koneksi internet diperlukan untuk melihat riwayat lama.');
    }

    final local = await loadLocalRiwayat();
    if (local != null) return local;

    if (await networkInfo.isConnected) {
      try {
        final data = await ApiService.getRiwayatGlobal(tanggal, page: page, limit: limit);
        
        // Background parsing
        if (data['data'] != null && data['data']['riwayat'] != null) {
          final rawList = data['data']['riwayat'] as List;
          final parsedModels = await compute(_parseRiwayatList, {
            'list': rawList,
            'jilidId': 0 // default
          });

          await _isar.writeTxn(() async {
            // Bersihkan data hari ini lalu replace (Eviction Policy)
            final startOfDay = DateTime.parse(tanggal);
            final endOfDay = startOfDay.add(const Duration(days: 1));
            await _isar.riwayatTahsinModels.filter().createdAtBetween(startOfDay, endOfDay).deleteAll();
            
            await _isar.riwayatTahsinModels.putAll(parsedModels);
          });
        }
        return data;
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        rethrow;
      }
    }
    
    throw Exception('Offline: Riwayat hari ini belum tersimpan di cache.');
  }

  /// --- EVICTION POLICY ---
  /// Menghapus riwayat santri di Isar ketika santri sudah naik jilid atau berstatus lulus.
  Future<void> evictRiwayatSantri(String nis) async {
    await _isar.writeTxn(() async {
      await _isar.riwayatTahsinModels.filter().nisEqualTo(nis).deleteAll();
    });
  }

  /// --- TAHAP 2: OPTIMISTIC UI UPDATE (WRITE) ---

  Future<bool> inputMassalProgress(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        final res = await ApiService.inputMassalProgress(payload);
        return res['status'] == 200;
      } catch (e) {
        return _enqueuePayload('api/guru/tahsin/input-massal', payload); 
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
    final request = OfflineQueue()
      ..endpoint = endpoint
      ..payloadJson = await compute(_encodeJsonString, payload)
      ..timestamp = DateTime.now()
      ..status = 'pending';

    await _isar.writeTxn(() async {
      await _isar.offlineQueues.put(request);
    });
    return true; 
  }
}

// --- ISOLATE FUNCTIONS (TOP LEVEL) ---

Map<String, dynamic> _parseProgressList(Map<String, dynamic> args) {
  final data = args['data'] as Map<String, dynamic>;
  final idKelas = args['idKelas'] as int?;
  final idKelompok = args['idKelompok'] as int?;
  
  List<ProgressSantriModel> models = [];
  
  // Karena data berbentuk {"status": 200, "santri_list": [], "filter_meta": {}}
  // atau "data" berbentuk object di dalam response
  final actualData = data['data'] ?? data;
  Map<String, dynamic> metaMap = {
    'filter_meta': actualData['filter_meta'],
    'checkpoints': actualData['checkpoints'] ?? actualData['t_kelas_checkpoint'],
  };

  final rawList = actualData['santri_list'];
  if (rawList is List) {
    for (var e in rawList) {
      if (e is Map<String, dynamic>) {
        models.add(ProgressSantriModel.fromJson(e, idKelas: idKelas, idKelompok: idKelompok));
      }
    }
  }

  return {
    'models': models,
    'metaJson': jsonEncode(metaMap),
  };
}

List<Map<String, dynamic>> _mapProgressListToJson(List<ProgressSantriModel> models) {
  return models.map((e) => e.toJson()).toList();
}

List<RiwayatTahsinModel> _parseRiwayatList(Map<String, dynamic> args) {
  final rawList = args['list'] as List;
  final jilidId = args['jilidId'] as int;
  List<RiwayatTahsinModel> models = [];
  for (var e in rawList) {
    if (e is Map<String, dynamic>) {
      models.add(RiwayatTahsinModel.fromJson(e, jilidId));
    }
  }
  return models;
}

List<Map<String, dynamic>> _mapRiwayatListToJson(List<RiwayatTahsinModel> models) {
  return models.map((e) => e.toJson()).toList();
}

Map<String, dynamic> _parseJsonString(String json) {
  return jsonDecode(json) as Map<String, dynamic>;
}

String _encodeJsonString(Map<String, dynamic> data) {
  return jsonEncode(data);
}
