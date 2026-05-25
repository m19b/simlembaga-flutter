import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:manajemen_tahsin_app/core/api/services/santri_catatan_api_service.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/generic_cache.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/data/models/offline_queue.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/enums/jalur_enum.dart';

class DaftarTesRepository {
  final NetworkInfo networkInfo;
  final LocalDataSource localDataSource;
  
  DaftarTesRepository({
    required this.networkInfo,
    required this.localDataSource,
  });

  Isar get _isar => IsarDb.instance;
  
  // 1. GET CALON & ANTRIAN
  Future<Map<String, dynamic>> getDaftarTes({
    bool forceRefresh = false,
    JalurEnum? jalur,
  }) async {
    final String jalurSuffix = jalur?.kode ?? '';
    final String cacheKeyCalon = 'tes_calon_cache_$jalurSuffix';
    final String cacheKeyAntrian = 'tes_antrian_cache_$jalurSuffix';
    
    Future<Map<String, dynamic>?> loadLocal() async {
      final calonCache = await _isar.genericCaches.filter().keyEqualTo(cacheKeyCalon).findFirst();
      final antrianCache = await _isar.genericCaches.filter().keyEqualTo(cacheKeyAntrian).findFirst();
      
      if (calonCache != null && antrianCache != null) {
        final calonData = await compute(_parseJsonString, calonCache.dataJson);
        final antrianData = await compute(_parseJsonString, antrianCache.dataJson);
        return {
          'calon': calonData,
          'antrian': antrianData,
        };
      }
      return null;
    }
    
    if (!forceRefresh) {
      final local = await loadLocal();
      if (local != null) return local;
    }
    
    if (await networkInfo.isConnected) {
      try {
        final responses = await Future.wait([
          SantriCatatanApiService.getCalonTes(kodeJalur: jalur?.kode),
          SantriCatatanApiService.getAntrianTes(kodeJalur: jalur?.kode),
        ]);
        
        final calonResponse = responses[0];
        final antrianResponse = responses[1];
        
        await _isar.writeTxn(() async {
          final gcCalon = GenericCache()
            ..key = cacheKeyCalon
            ..dataJson = await compute(_encodeJsonString, calonResponse)
            ..updatedAt = DateTime.now();
            
          final gcAntrian = GenericCache()
            ..key = cacheKeyAntrian
            ..dataJson = await compute(_encodeJsonString, antrianResponse)
            ..updatedAt = DateTime.now();
            
          await _isar.genericCaches.putAll([gcCalon, gcAntrian]);
        });
        
        return {
          'calon': calonResponse,
          'antrian': antrianResponse,
        };
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

  // 2. GET RIWAYAT
  Future<Map<String, dynamic>> getRiwayatTes({
    String? status, 
    required String tglMulai, 
    required String tglAkhir,
    JalurEnum? jalur,
    bool forceRefresh = false,
  }) async {
    final String jalurSuffix = jalur?.kode ?? '';
    final cacheKey = 'tes_riwayat_${tglMulai}_${tglAkhir}_$jalurSuffix';
    
    Future<Map<String, dynamic>?> loadLocal() async {
      final cache = await _isar.genericCaches.filter().keyEqualTo(cacheKey).findFirst();
      if (cache != null) {
        return await compute(_parseJsonString, cache.dataJson);
      }
      return null;
    }

    if (!forceRefresh) {
      final local = await loadLocal();
      if (local != null) return local;
    }

    if (await networkInfo.isConnected) {
      try {
        final response = await SantriCatatanApiService.getRiwayatTes(
          status: status,
          tglMulai: tglMulai,
          tglAkhir: tglAkhir,
          kodeJalur: jalur?.kode,
        );
        
        await _isar.writeTxn(() async {
          final gc = GenericCache()
            ..key = cacheKey
            ..dataJson = await compute(_encodeJsonString, response)
            ..updatedAt = DateTime.now();
          await _isar.genericCaches.put(gc);
        });
        
        return response;
      } catch (e) {
         if (e.toString().contains('401')) rethrow;
         final local = await loadLocal();
         if (local != null) return local;
         throw Exception('Gagal memuat riwayat.');
      }
    }
    
    final local = await loadLocal();
    if (local != null) return local;
    throw Exception('Tidak ada koneksi internet.');
  }

  // 3. DAFTARKAN TES
  Future<bool> daftarkanTes({
    required String nis,
    required String idKelas,
    required String idKelompok,
    required String kodeJalur,
  }) async {
    final payload = {
      'nis': nis,
      'id_kelas': idKelas,
      'id_kelompok': idKelompok,
      'kode_jalur': kodeJalur,
    };
    
    if (await networkInfo.isConnected) {
      try {
         await SantriCatatanApiService.daftarkanTes(
           nis: nis,
           idKelas: idKelas,
           idKelompok: idKelompok,
           kodeJalur: kodeJalur,
         );
         return true;
      } catch (e) {
         await _optimisticUpdateDaftar(nis, kodeJalur);
         return _enqueuePayload('api/guru/tes/daftarkan', payload, 'daftar_tes');
      }
    }
    await _optimisticUpdateDaftar(nis, kodeJalur);
    return _enqueuePayload('api/guru/tes/daftarkan', payload, 'daftar_tes');
  }

  // 4. BATALKAN TES
  Future<bool> batalkanTes(String idDaftar) async {
    final payload = {'id_daftar': idDaftar};
    if (await networkInfo.isConnected) {
      try {
        await SantriCatatanApiService.batalkanTes(idDaftar: idDaftar);
        return true;
      } catch (e) {
        return await _handleOfflineBatal(idDaftar, payload);
      }
    }
    return await _handleOfflineBatal(idDaftar, payload);
  }

  Future<bool> _handleOfflineBatal(String idDaftar, Map<String, dynamic> payload) async {
    if (idDaftar.startsWith('offline_')) {
      final nis = idDaftar.replaceAll('offline_', '');
      await _isar.writeTxn(() async {
        final pending = await _isar.offlineQueues.filter().endpointEqualTo('api/guru/tes/daftarkan').findAll();
        for (var req in pending) {
          final reqPayload = jsonDecode(req.payloadJson);
          if (reqPayload['nis'] == nis) {
            await _isar.offlineQueues.delete(req.id);
          }
        }
      });
    } else {
      await _enqueuePayload('api/guru/tes/batalkan', payload, 'daftar_tes');
    }
    await _optimisticUpdateBatal(idDaftar);
    return true;
  }

  // 5. OFFLINE QUEUE HELPER
  Future<bool> _enqueuePayload(String endpoint, Map<String, dynamic> payload, String type) async {
    payload['type'] = type;
    await localDataSource.enqueueRequest(endpoint, payload, type: type);
    return true;
  }

  // 6. OPTIMISTIC UPDATES
  Future<void> _optimisticUpdateDaftar(String nis, String kodeJalur) async {
    final String cacheKeyCalon = 'tes_calon_cache_$kodeJalur';
    final String cacheKeyAntrian = 'tes_antrian_cache_$kodeJalur';
    
    final calonCache = await _isar.genericCaches.filter().keyEqualTo(cacheKeyCalon).findFirst();
    final antrianCache = await _isar.genericCaches.filter().keyEqualTo(cacheKeyAntrian).findFirst();
    
    if (calonCache != null && antrianCache != null) {
      final calonData = jsonDecode(calonCache.dataJson);
      final antrianData = jsonDecode(antrianCache.dataJson);
      
      Map<String, dynamic>? santri;
      if (calonData['data'] != null && calonData['data']['calon_test'] != null) {
        final List calonList = calonData['data']['calon_test'];
        final index = calonList.indexWhere((e) => e['nis'] == nis);
        if (index != -1) {
          santri = calonList.removeAt(index);
          calonData['data']['calon_test'] = calonList;
        }
      }
      
      if (santri != null) {
        santri['id_daftar'] = 'offline_$nis';
        santri['kode_jalur'] = kodeJalur;
        santri['status'] = 'Menunggu';
        santri['tgl_daftar'] = DateTime.now().toIso8601String().substring(0, 10);
        
        if (antrianData['data'] != null && antrianData['data']['antrian'] != null) {
          final List antrianList = antrianData['data']['antrian'];
          antrianList.add(santri);
          antrianData['data']['antrian'] = antrianList;
        }
        
        await _isar.writeTxn(() async {
          calonCache.dataJson = jsonEncode(calonData);
          antrianCache.dataJson = jsonEncode(antrianData);
          await _isar.genericCaches.putAll([calonCache, antrianCache]);
        });
      }
    }
  }

  Future<void> _optimisticUpdateBatal(String idDaftar) async {
    final antrianCaches = await _isar.genericCaches.filter().keyStartsWith('tes_antrian_cache_').findAll();
    for (var antrianCache in antrianCaches) {
      final antrianData = jsonDecode(antrianCache.dataJson);
      if (antrianData['data'] != null && antrianData['data']['antrian'] != null) {
        final List antrianList = antrianData['data']['antrian'];
        final index = antrianList.indexWhere((e) => e['id_daftar'].toString() == idDaftar);
        if (index != -1) {
          final santri = antrianList.removeAt(index);
          antrianData['data']['antrian'] = antrianList;
          
          final suffix = antrianCache.key.replaceFirst('tes_antrian_cache_', '');
          final calonCache = await _isar.genericCaches.filter().keyEqualTo('tes_calon_cache_$suffix').findFirst();
          if (calonCache != null) {
            final calonData = jsonDecode(calonCache.dataJson);
            if (calonData['data'] != null && calonData['data']['calon_test'] != null) {
              final List calonList = calonData['data']['calon_test'];
              santri.remove('id_daftar');
              santri.remove('status');
              santri.remove('tgl_daftar');
              calonList.add(santri);
              calonData['data']['calon_test'] = calonList;
              
              await _isar.writeTxn(() async {
                calonCache.dataJson = jsonEncode(calonData);
                antrianCache.dataJson = jsonEncode(antrianData);
                await _isar.genericCaches.putAll([calonCache, antrianCache]);
              });
            }
          }
          break;
        }
      }
    }
  }
}

// ISOLATE HELPERS
Map<String, dynamic> _parseJsonString(String json) => jsonDecode(json) as Map<String, dynamic>;
String _encodeJsonString(Map<String, dynamic> data) => jsonEncode(data);
