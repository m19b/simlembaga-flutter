import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/generic_cache.dart';
import 'package:manajemen_tahsin_app/core/data/models/offline_queue.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/data/models/tahfidz_santri_model.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/data/models/tahfidz_riwayat_model.dart';

class TahfidzRepository {
  final NetworkInfo networkInfo;

  TahfidzRepository({required this.networkInfo});

  Isar get _isar => IsarDb.instance;

  // ===========================================================================
  // 1. GET LIST SANTRI — Cache-Then-Network, Offline-First
  // ===========================================================================

  Future<Map<String, dynamic>> getProgressList({
    int? idKelompok,
    String? tanggal,
    int? sesi,
    String? filterKehadiran,
    bool forceRefresh = false,
  }) async {
    final metaCacheKey = 'tahfidz_meta_${idKelompok}_${tanggal}_${sesi}_${filterKehadiran}';

    Future<Map<String, dynamic>?> loadLocal() async {
      final metaCache = await _isar.genericCaches
          .filter()
          .keyEqualTo(metaCacheKey)
          .findFirst();
      if (metaCache == null) return null;

      List<TahfidzSantriModel> santriList;
      if (idKelompok != null) {
        santriList = await _isar.tahfidzSantriModels
            .filter()
            .idKelompokEqualTo(idKelompok)
            .findAll();
      } else {
        santriList = await _isar.tahfidzSantriModels.where().findAll();
      }
      if (santriList.isEmpty) return null;

      final mapList = await compute(_mapSantriListToJson, santriList);
      final metaMap = await compute(_parseJsonString, metaCache.dataJson);
      return {
        'filter_meta': metaMap['filter_meta'],
        'jadwal_info': metaMap['jadwal_info'],
        'jadwal_list': metaMap['jadwal_list'] ?? [],
        'santri_list': mapList,
      };
    }

    if (!forceRefresh) {
      final local = await loadLocal();
      if (local != null) return local;
    }

    if (await networkInfo.isConnected) {
      try {
        final data = await ApiService.getTahfidzList(
          tanggal: tanggal,
          sesi: sesi,
          filterKehadiran: filterKehadiran,
        );

        // Heavy parsing di isolate
        final parseResult = await compute(_parseSantriList, {
          'data': data,
          'idKelompok': idKelompok,
        });

        // Simpan ke Isar secara asinkron
        await _isar.writeTxn(() async {
          if (idKelompok != null) {
            await _isar.tahfidzSantriModels
                .filter()
                .idKelompokEqualTo(idKelompok)
                .deleteAll();
          }
          await _isar.tahfidzSantriModels
              .putAll(parseResult['models'] as List<TahfidzSantriModel>);

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
    throw Exception(
      'Tidak ada koneksi internet. Silakan online untuk memuat data awal.',
    );
  }

  // ===========================================================================
  // 2. GET DETAIL SANTRI — Cache-Then-Network
  // ===========================================================================

  Future<Map<String, dynamic>> getDetail(
    String nis, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'tahfidz_detail_$nis';

    if (!forceRefresh) {
      final cached = await _isar.genericCaches
          .filter()
          .keyEqualTo(cacheKey)
          .findFirst();
      if (cached != null) return await compute(_parseJsonString, cached.dataJson);
    }

    if (await networkInfo.isConnected) {
      try {
        final data = await ApiService.getTahfidzDetail(nis);
        await _isar.writeTxn(() async {
          final gc = GenericCache()
            ..key = cacheKey
            ..dataJson = await compute(_encodeJsonString, data)
            ..updatedAt = DateTime.now();
          await _isar.genericCaches.put(gc);
        });

        // Simpan riwayat ke koleksi TahfidzRiwayatModel untuk akses offline
        final riwayatRaw = data['data']?['riwayat'] as List?;
        if (riwayatRaw != null && riwayatRaw.isNotEmpty) {
          final models = await compute(
            _parseRiwayatList,
            {'list': riwayatRaw},
          );
          await _isar.writeTxn(() async {
            await _isar.tahfidzRiwayatModels
                .filter()
                .nisEqualTo(nis)
                .deleteAll();
            await _isar.tahfidzRiwayatModels.putAll(models);
          });
        }

        return data;
      } catch (e) {
        if (e.toString().contains('401')) rethrow;
        final cached = await _isar.genericCaches
            .filter()
            .keyEqualTo(cacheKey)
            .findFirst();
        if (cached != null) return await compute(_parseJsonString, cached.dataJson);
        rethrow;
      }
    }
    final cached = await _isar.genericCaches
        .filter()
        .keyEqualTo(cacheKey)
        .findFirst();
    if (cached != null) return await compute(_parseJsonString, cached.dataJson);
    throw Exception('Offline: Detail santri belum tersimpan di cache.');
  }

  // ===========================================================================
  // 3. GET DASHBOARD ANALITIK
  // ===========================================================================

  Future<Map<String, dynamic>> getDashboard(
    String nis, {
    String? tglDari,
    String? tglSampai,
  }) async {
    if (await networkInfo.isConnected) {
      return ApiService.getTahfidzDashboard(
        nis,
        tglDari: tglDari,
        tglSampai: tglSampai,
      );
    }
    throw Exception(
      'Koneksi internet diperlukan untuk melihat grafik analitik.',
    );
  }

  // ===========================================================================
  // 4. INPUT CEPAT (Optimistic — Offline Queue)
  // ===========================================================================

  Future<bool> inputCepat(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        final res = await ApiService.inputCepatTahfidz(payload);
        return res['status'] == 200 || res['status'] == true;
      } catch (e) {
        return _enqueuePayload('api/guru/tahfidz-quran/input-cepat', payload);
      }
    }
    return _enqueuePayload('api/guru/tahfidz-quran/input-cepat', payload);
  }

  // ===========================================================================
  // 5. INPUT MASSAL (Optimistic — Offline Queue)
  // ===========================================================================

  Future<bool> inputMassal(Map<String, dynamic> payload, {int? sesi}) async {
    if (await networkInfo.isConnected) {
      try {
        await ApiService.inputMassalTahfidz(payload);
        return true;
      } catch (e) {
        return _enqueuePayload('api/guru/tahfidz-quran/input-massal', payload, sesi: sesi);
      }
    }
    return _enqueuePayload('api/guru/tahfidz-quran/input-massal', payload, sesi: sesi);
  }

  // ===========================================================================
  // 5b. CHECK EXISTING PROGRESS (Anti-Collision)
  // ===========================================================================

  Future<int> checkExistingProgressCount(
    List<String> nisList,
    String tanggalStr,
    int sesi,
  ) async {
    if (nisList.isEmpty) return 0;
    try {
      final parsedDate = DateTime.tryParse(tanggalStr);
      if (parsedDate == null) return 0;

      // Reset waktu ke 00:00:00 untuk komparasi hari
      final dateOnly = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      final nextDay = dateOnly.add(const Duration(days: 1));

      final existing = await _isar.tahfidzRiwayatModels
          .filter()
          .anyOf(nisList, (q, nis) => q.nisEqualTo(nis))
          .and()
          .tanggalBetween(dateOnly, nextDay, includeUpper: false)
          .and()
          .sesiEqualTo(sesi)
          .count();
      return existing;
    } catch (e) {
      return 0;
    }
  }

  // ===========================================================================
  // 6. UPDATE RIWAYAT
  // ===========================================================================

  Future<bool> updateRiwayat(
    int idPrestasi,
    Map<String, dynamic> data,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await ApiService.updateTahfidz(idPrestasi, data);
        return true;
      } catch (e) {
        return _enqueuePayload(
          'api/guru/tahfidz-quran/update/$idPrestasi',
          data,
        );
      }
    }
    return _enqueuePayload('api/guru/tahfidz-quran/update/$idPrestasi', data);
  }

  // ===========================================================================
  // 7. HAPUS RIWAYAT
  // ===========================================================================

  Future<bool> hapusRiwayat(int idPrestasi, String nis) async {
    if (await networkInfo.isConnected) {
      try {
        await ApiService.deleteTahfidz(idPrestasi, nis);
        // Hapus dari cache lokal juga
        await _isar.writeTxn(() async {
          await _isar.tahfidzRiwayatModels.delete(idPrestasi);
        });
        return true;
      } catch (e) {
        return _enqueuePayload(
          'api/guru/tahfidz-quran/delete/$idPrestasi',
          {'nis': nis},
        );
      }
    }
    return _enqueuePayload(
      'api/guru/tahfidz-quran/delete/$idPrestasi',
      {'nis': nis},
    );
  }

  // ===========================================================================
  // PRIVATE: Offline Queue Helper
  // ===========================================================================

  Future<bool> _enqueuePayload(
    String endpoint,
    Map<String, dynamic> payload, {
    int? sesi,
  }) async {
    if (sesi != null) {
      payload['sesi'] = sesi;
    }
    
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

// =============================================================================
// TOP-LEVEL ISOLATE FUNCTIONS
// =============================================================================

Map<String, dynamic> _parseSantriList(Map<String, dynamic> args) {
  final data = args['data'] as Map<String, dynamic>;
  final idKelompok = args['idKelompok'] as int?;

  final actualData = data['data'] ?? data;
  final Map<String, dynamic> metaMap = {
    'filter_meta': actualData['filter_meta'],
  };

  var rawList = actualData['santri_list'];

  final List<TahfidzSantriModel> models = [];
  if (rawList is List) {
    for (final e in rawList) {
      if (e is Map<String, dynamic>) {
        models.add(
          TahfidzSantriModel.fromJson(e, idKelompok: idKelompok),
        );
      }
    }
  }

  return {
    'models': models,
    'metaJson': jsonEncode(metaMap),
  };
}

List<Map<String, dynamic>> _mapSantriListToJson(
  List<TahfidzSantriModel> models,
) {
  return models.map((e) => e.toJson()).toList();
}

List<TahfidzRiwayatModel> _parseRiwayatList(Map<String, dynamic> args) {
  final rawList = args['list'] as List;
  final List<TahfidzRiwayatModel> models = [];
  for (final e in rawList) {
    if (e is Map<String, dynamic>) {
      models.add(TahfidzRiwayatModel.fromJson(e));
    }
  }
  return models;
}

Map<String, dynamic> _parseJsonString(String json) {
  return jsonDecode(json) as Map<String, dynamic>;
}

String _encodeJsonString(Map<String, dynamic> data) {
  return jsonEncode(data);
}
