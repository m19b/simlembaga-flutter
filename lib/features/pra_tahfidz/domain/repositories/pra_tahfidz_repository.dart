import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:manajemen_tahsin_app/core/api/services/pra_tahfidz_api_service.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/offline_queue.dart';
import 'package:manajemen_tahsin_app/core/data/models/generic_cache.dart';
import 'package:manajemen_tahsin_app/core/data/models/kelas_model.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/data/models/pra_tahfidz_santri_model.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/data/models/pra_tahfidz_riwayat_model.dart';

class PraTahfidzRepository {
  final NetworkInfo networkInfo;

  PraTahfidzRepository({required this.networkInfo});

  Isar get _isar => IsarDb.instance;

  // ────────────────────────────────────────────────────────────────────────────
  // 1. READ: Daftar Santri (Cache-Then-Network dengan Context-Bounded Caching)
  // ────────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getSantriList({
    String? tanggal,
    int? idKelompok,
    List<int>? kelasIds,
    int? sesi,
    String? filterKehadiran,
    bool forceRefresh = false,
  }) async {
    final tgl = tanggal ?? DateTime.now().toIso8601String().split('T')[0];
    final metaCacheKey = 'pratahfidz_meta_${idKelompok}_$tgl';

    Future<Map<String, dynamic>?> loadLocal() async {
      final metaCache = await _isar.genericCaches
          .filter()
          .keyEqualTo(metaCacheKey)
          .findFirst();
      if (metaCache == null) return null;

      List<PraTahfidzSantriModel> santriList;
      if (idKelompok != null) {
        santriList = await _isar.praTahfidzSantriModels
            .filter()
            .idKelompokEqualTo(idKelompok)
            .findAll();
      } else {
        santriList = await _isar.praTahfidzSantriModels.where().findAll();
      }

      if (santriList.isEmpty) return null;

      final mapList = await compute(_mapSantriListToJson, santriList);
      final metaMap = await compute(_parseJsonString, metaCache.dataJson);

      return {
        'filter_meta': metaMap['filter_meta'],
        'jadwal_list': metaMap['jadwal_list'],
        'jadwal_info': metaMap['jadwal_info'],
        'santri_list': mapList,
      };
    }

    if (!forceRefresh) {
      final local = await loadLocal();
      if (local != null) return local;
    }

    if (await networkInfo.isConnected) {
      try {
        final data = await PraTahfidzApiService.getPraTahfidzList(
          tanggal: tgl,
          idKelompok: idKelompok,
          kelasIds: kelasIds,
          sesi: sesi,
          filterKehadiran: filterKehadiran,
        );

        // Parsing berat di background isolate (Anti-Jank)
        final parseResult = await compute(_parseSantriList, {
          'data': data,
          'idKelompok': idKelompok,
        });

        // Simpan ke Isar (Context-Bounded Eviction)
        await _isar.writeTxn(() async {
          if (idKelompok != null) {
            await _isar.praTahfidzSantriModels
                .filter()
                .idKelompokEqualTo(idKelompok)
                .deleteAll();
          }
          await _isar.praTahfidzSantriModels
              .putAll(parseResult['models'] as List<PraTahfidzSantriModel>);

          final gc = GenericCache()
            ..key = metaCacheKey
            ..dataJson = parseResult['metaJson'] as String
            ..updatedAt = DateTime.now();
          await _isar.genericCaches.put(gc);

          // ─── UPSERT KELAS METADATA ──────────────────────────────────
          try {
            final parsedMeta = jsonDecode(parseResult['metaJson'] as String);
            final filterMeta = parsedMeta['filter_meta'];
            if (filterMeta != null && filterMeta['kelas'] is List) {
              for (final k in filterMeta['kelas']) {
                final int kId = int.tryParse(k['id_kelas']?.toString() ?? '') ?? 0;
                if (kId > 0) {
                  final existing = await _isar.kelasModels.get(kId);
                  final updated = existing ?? KelasModel()..idKelas = kId;
                  
                  updated.tingkat = k['tingkat']?.toString() ?? updated.tingkat;
                  updated.idKelompok = idKelompok ?? updated.idKelompok;
                  final kCat = int.tryParse(k['id_kategori']?.toString() ?? '');
                  if (kCat != null) updated.idKategori = kCat;
                  
                  await _isar.kelasModels.put(updated);
                }
              }
            }
          } catch (e) {
            debugPrint('Gagal upsert kelas model: $e');
          }
        });

        return data;
      } catch (e, stacktrace) {
        print('xxxxxxxxxxxxxxxxxxxxxxx ERROR PRA-TAHFIDZ: $e');
        print('xxxxxxxxxxxxxxxxxxxxxxx STACKTRACE: $stacktrace');
        if (e.toString().contains('401')) rethrow;
        final local = await loadLocal();
        if (local != null) return local;
        throw Exception('Gagal memuat data dari server dan cache kosong.');
      }
    }

    final local = await loadLocal();
    if (local != null) return local;
    throw Exception(
        'Tidak ada koneksi internet. Silakan online untuk memuat data awal.');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 2. READ: Detail Santri + Buku Prestasi
  // ────────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDetail(String nis,
      {bool forceRefresh = false}) async {
    final cacheKey = 'pratahfidz_detail_$nis';

    if (!forceRefresh) {
      final cached = await _isar.genericCaches
          .filter()
          .keyEqualTo(cacheKey)
          .findFirst();
      if (cached != null) {
        return await compute(_parseJsonString, cached.dataJson);
      }
    }

    if (await networkInfo.isConnected) {
      try {
        final data = await PraTahfidzApiService.getPraTahfidzDetail(nis);
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
        final cached = await _isar.genericCaches
            .filter()
            .keyEqualTo(cacheKey)
            .findFirst();
        if (cached != null) {
          return await compute(_parseJsonString, cached.dataJson);
        }
        rethrow;
      }
    }

    final cached =
        await _isar.genericCaches.filter().keyEqualTo(cacheKey).findFirst();
    if (cached != null) return await compute(_parseJsonString, cached.dataJson);
    throw Exception('Offline: Detail santri belum tersimpan di cache.');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 3. READ: Dashboard / Grafik Analitik
  // ────────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboard(
    String nis, {
    String? tglDari,
    String? tglSampai,
  }) async {
    if (await networkInfo.isConnected) {
      return PraTahfidzApiService.getPraTahfidzDashboard(nis,
          tglDari: tglDari, tglSampai: tglSampai);
    }
    final cacheKey = 'pratahfidz_dashboard_$nis';
    final cached =
        await _isar.genericCaches.filter().keyEqualTo(cacheKey).findFirst();
    if (cached != null) return await compute(_parseJsonString, cached.dataJson);
    throw Exception('Offline: Data grafik belum tersimpan di cache.');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 4. WRITE: Input Cepat (Optimistic Update + Offline Queue)
  // ────────────────────────────────────────────────────────────────────────────

  Future<bool> inputCepat(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        await PraTahfidzApiService.inputCepatPraTahfidz(payload);
        return true;
      } catch (e) {
        return _enqueuePayload('api/guru/pra-tahfidz/input-cepat', payload);
      }
    }
    return _enqueuePayload('api/guru/pra-tahfidz/input-cepat', payload);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 5. WRITE: Input Massal (Optimistic Update + Offline Queue)
  // ────────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> inputMassal(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        final res = await PraTahfidzApiService.inputMassalPraTahfidz(payload);
        final dataNode = res['data'] is Map ? res['data'] : res;
        final bool isConfirm = dataNode['require_confirmation'] ?? res['require_confirmation'] ?? false;
        final String msg = dataNode['message'] ?? res['message'] ?? 'Data berhasil disimpan';
        return {'success': true, 'require_confirmation': isConfirm, 'message': msg};
      } catch (e) {
        final ok = await _enqueuePayload('api/guru/pra-tahfidz/input-massal', payload);
        return {'success': ok, 'message': ok ? 'Tersimpan offline' : e.toString(), 'require_confirmation': false};
      }
    }
    final ok = await _enqueuePayload('api/guru/pra-tahfidz/input-massal', payload);
    return {'success': ok, 'message': 'Tersimpan offline', 'require_confirmation': false};
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 6. WRITE: Update Riwayat
  // ────────────────────────────────────────────────────────────────────────────

  Future<bool> updateRiwayat(
      int idPrestasi, Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        await PraTahfidzApiService.updatePraTahfidz(idPrestasi, payload);
        return true;
      } catch (e) {
        return _enqueuePayload(
            'api/guru/pra-tahfidz/update/$idPrestasi', payload);
      }
    }
    return _enqueuePayload('api/guru/pra-tahfidz/update/$idPrestasi', payload);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 7. WRITE: Hapus Riwayat
  // ────────────────────────────────────────────────────────────────────────────

  Future<bool> hapusRiwayat(int idPrestasi) async {
    if (await networkInfo.isConnected) {
      try {
        await PraTahfidzApiService.deletePraTahfidz(idPrestasi);
        // Hapus dari Isar (Optimistic)
        await _isar.writeTxn(() async {
          await _isar.praTahfidzRiwayatModels.delete(idPrestasi);
        });
        return true;
      } catch (e) {
        return _enqueuePayload(
            'api/guru/pra-tahfidz/delete/$idPrestasi', {});
      }
    }
    return _enqueuePayload('api/guru/pra-tahfidz/delete/$idPrestasi', {});
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HELPER: Offline Queue
  // ────────────────────────────────────────────────────────────────────────────

  Future<bool> _enqueuePayload(
      String endpoint, Map<String, dynamic> payload) async {
    final request = OfflineQueue()
      ..endpoint = endpoint
      ..payloadJson = await compute(_encodeJsonString, payload)
      ..timestamp = DateTime.now()
      ..status = 'pending';

    await _isar.writeTxn(() async {
      await _isar.offlineQueues.put(request);
    });
    return true; // Optimistic Update
  }

  // HELPER: Cache invalidation untuk santri tertentu
  Future<void> evictDetailCache(String nis) async {
    await _isar.writeTxn(() async {
      await _isar.praTahfidzRiwayatModels
          .filter()
          .nisEqualTo(nis)
          .deleteAll();
    });
  }
}

// ─── TOP-LEVEL ISOLATE FUNCTIONS ─────────────────────────────────────────────

Map<String, dynamic> _parseSantriList(Map<String, dynamic> args) {
  try {
    final parsedData = args['data'] as Map<String, dynamic>;
    final idKelompok = args['idKelompok'] as int?;

    // Pastikan membaca dari key 'data' sesuai instruksi
    final responseData = parsedData['data'] ?? parsedData;

    final metaMap = {
      'filter_meta': responseData['filter_meta'],
      'jadwal_list': responseData['jadwal_list'] ?? [],
      'jadwal_info': responseData['jadwal_info'],
    };

  var santriRaw = responseData['santri_list'];
  if (santriRaw is Map && santriRaw.containsKey('data')) {
    santriRaw = santriRaw['data'];
  }

  final List<PraTahfidzSantriModel> models = [];
  if (santriRaw is List) {
    for (final e in santriRaw) {
      if (e is Map<String, dynamic>) {
        models.add(PraTahfidzSantriModel.fromJson(
          e,
          idKelompok: idKelompok,
        ));
      }
    }
  }

    return {
      'models': models,
      'metaJson': jsonEncode(metaMap),
    };
  } catch (e, stacktrace) {
    print('xxxxxxxxxxxxxxxxxxxxxxx ERROR PRA-TAHFIDZ _parseSantriList: $e');
    print('xxxxxxxxxxxxxxxxxxxxxxx STACKTRACE: $stacktrace');
    rethrow;
  }
}

List<Map<String, dynamic>> _mapSantriListToJson(
    List<PraTahfidzSantriModel> models) {
  return models.map((e) => e.toJson()).toList();
}



Map<String, dynamic> _parseJsonString(String jsonStr) {
  return jsonDecode(jsonStr) as Map<String, dynamic>;
}

String _encodeJsonString(Map<String, dynamic> data) {
  return jsonEncode(data);
}
