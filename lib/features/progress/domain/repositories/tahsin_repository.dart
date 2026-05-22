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
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TahsinRepository {
  final NetworkInfo networkInfo;

  TahsinRepository({required this.networkInfo});

  Isar get _isar => IsarDb.instance;

  /// --- TAHAP 1: CACHE-THEN-NETWORK (READ) ---

  Future<Map<String, dynamic>> getProgressList({
    int? idKelompok,
    int? idKelas,
    String? tanggal,
    String? filterKehadiran,
    int? sesi,
    bool forceRefresh = false,
  }) async {
    final metaCacheKey = 'meta_progress_${idKelompok ?? 0}_${idKelas ?? 0}';

    // Helper untuk merge offline queues ke data list
    Future<List<Map<String, dynamic>>> applyOfflineMerge(
      List<Map<String, dynamic>> sourceList,
    ) async {
      try {
        final offlineQueues = await _isar.offlineQueues
            .filter()
            .endpointContains('input-massal')
            .or()
            .endpointContains('input-cepat')
            .findAll();

        if (offlineQueues.isNotEmpty) {
          final Map<String, int> nisIndexMap = {};
          for (var i = 0; i < sourceList.length; i++) {
            final String mapNis = sourceList[i]['nis']?.toString() ?? '';
            if (mapNis.isNotEmpty) {
              nisIndexMap[mapNis] = i;
            }
          }

          for (var queue in offlineQueues) {
            final payload = jsonDecode(queue.payloadJson);
            List<dynamic> items = [];

            if (payload.containsKey('evaluasi') &&
                payload['evaluasi'] is List) {
              items = payload['evaluasi'];
            } else if (payload.containsKey('hasil') &&
                payload['hasil'] is List) {
              items = payload['hasil'];
            } else if (payload.containsKey('nis')) {
              items = [payload];
            }

            for (var item in items) {
              final String nis = item['nis']?.toString() ?? '';
              final String rawStatus =
                  (item['status_halaman'] ??
                          item['status_terakhir'] ??
                          item['lulus'])
                      ?.toString()
                      .toLowerCase() ??
                  'lulus';
              final bool isLulus = rawStatus == 'lulus' || rawStatus == '1';
              final double halTotal =
                  double.tryParse(item['hal_total']?.toString() ?? '0') ?? 0;
              final String mode =
                  item['mode_belajar']?.toString().toLowerCase() ?? 'reguler';

              if (nis.isNotEmpty) {
                final int? i = nisIndexMap[nis];
                if (i != null) {
                  sourceList[i]['last_status'] =
                      item['status_halaman'] ??
                      item['status_terakhir'] ??
                      item['lulus'] ??
                      'lulus';
                  sourceList[i]['last_mode'] = mode;
                  if (item.containsKey('hal_akhir')) {
                    sourceList[i]['last_hal_akhir'] = item['hal_akhir'];
                  } else if (item.containsKey('halaman_sampai')) {
                    sourceList[i]['last_hal_akhir'] = item['halaman_sampai'];
                  }
                  sourceList[i]['last_hal_total'] = halTotal;

                  if (isLulus && halTotal > 0) {
                    final double currentCapai =
                        double.tryParse(
                          sourceList[i]['capai_hal']?.toString() ?? '0',
                        ) ??
                        0;
                    final double updatedCapai = currentCapai + halTotal;
                    sourceList[i]['capai_hal'] = updatedCapai;
                    sourceList[i]['halaman_terakhir'] = updatedCapai.toString();

                    if (mode == 'latihan') {
                      final double currentLat =
                          double.tryParse(
                            sourceList[i]['lat_sek']?.toString() ?? '0',
                          ) ??
                          0;
                      sourceList[i]['lat_sek'] = currentLat + halTotal;
                    } else if (mode == 'akselerasi') {
                      final double currentAks =
                          double.tryParse(
                            sourceList[i]['capai_aks']?.toString() ?? '0',
                          ) ??
                          0;
                      sourceList[i]['capai_aks'] = currentAks + halTotal;
                    }
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        // Silent catch for offline queue merge failure
      }
      return sourceList;
    }

    // Helper untuk load local data
    Future<Map<String, dynamic>?> loadLocal() async {
      final metaCache = await _isar.genericCaches
          .filter()
          .keyEqualTo(metaCacheKey)
          .findFirst();
      if (metaCache == null) return null;

      List<ProgressSantriModel> santriList;
      if (idKelas != null) {
        santriList = await _isar.progressSantriModels
            .filter()
            .idKelasEqualTo(idKelas)
            .findAll();
      } else if (idKelompok != null) {
        santriList = await _isar.progressSantriModels
            .filter()
            .idKelompokEqualTo(idKelompok)
            .findAll();
      } else {
        santriList = await _isar.progressSantriModels.where().findAll();
      }

      // Allow empty list (don't return null if class is empty)
      var mapList = santriList.isEmpty ? <Map<String, dynamic>>[] : await compute(_mapProgressListToJson, santriList);
      final metaMap = await compute(_parseJsonString, metaCache.dataJson);

      // --- AUTO-PURGE GURU PENGGANTI ---
      final kelasSettings = metaMap['kelas_settings'] ?? <String, dynamic>{};
      if (kelasSettings['status_guru'] == 'pengganti' &&
          kelasSettings['berlaku_sampai'] != null) {
        final berlakuSampaiStr = kelasSettings['berlaku_sampai'].toString();
        // berlaku_sampai adalah YYYY-MM-DD. Tambahkan waktu 23:59:59 agar berlaku penuh di hari itu.
        final berlakuSampai = DateTime.tryParse('$berlakuSampaiStr 23:59:59');
        if (berlakuSampai != null && DateTime.now().isAfter(berlakuSampai)) {
          await _isar.writeTxn(() async {
            if (idKelas != null) {
              await _isar.progressSantriModels
                  .filter()
                  .idKelasEqualTo(idKelas)
                  .deleteAll();
            }
            await _isar.genericCaches.delete(metaCache.id);
          });
          throw Exception(
            'Masa tugas Anda sebagai guru pengganti di kelas ini telah berakhir. Akses ditutup dan data lokal telah dibersihkan.',
          );
        }
      }

      // --- IN-MEMORY MERGE DENGAN OFFLINE QUEUE (CRITICAL) ---
      mapList = await applyOfflineMerge(mapList);

      return {
        'filter_meta': metaMap['filter_meta'],
        'checkpoints': metaMap['checkpoints'],
        'santri_list': mapList,
        // Extra meta persisted since last online sync
        'kelas_settings': metaMap['kelas_settings'] ?? <String, dynamic>{},
        'metode_list': metaMap['metode_list'] ?? <dynamic>[],
        'jadwal_info': metaMap['jadwal_info'] ?? <String, dynamic>{},
        'jadwal_list': metaMap['jadwal_list'] ?? <dynamic>[],
        'catatan_master': metaMap['catatan_master'] ?? <dynamic>[],
      };
    }

    if (!forceRefresh) {
      final local = await loadLocal();
      if (local != null) return local;

      if (LocalNetworkChecker().currentStatus == LocalNetworkStatus.offline) {
        throw Exception(
          'Anda sedang offline dan data lokal belum tersedia. Silakan online untuk memuat data pertama kali.',
        );
      }
    }

    if (await networkInfo.isConnected) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final lastSyncKey =
            'last_sync_progress_${idKelompok ?? 0}_${idKelas ?? 0}';

        final lastSyncTime = prefs.getString(lastSyncKey) ?? '';
        final hasMetaCache = await _isar.genericCaches.filter().keyEqualTo(metaCacheKey).isNotEmpty();
        
        // Safety check: Pastikan data untuk kelompok ini benar-benar ada di lokal.
        // Jika tidak ada, paksa Full Pull agar recover dari state tersimpan dengan idKelompok=null
        bool hasData = true;
        if (idKelompok != null) {
          hasData = await _isar.progressSantriModels.filter().idKelompokEqualTo(idKelompok).isNotEmpty();
        }

        if (lastSyncTime.isEmpty || !hasMetaCache || !hasData) {
          // FULL PULL menggunakan endpoint lama (termasuk metadata)
          final data = await ApiService.getProgressList(
            idKelompok: idKelompok,
            idKelas: idKelas,
            tanggal: tanggal,
            filterKehadiran: filterKehadiran,
            sesi: sesi,
          ).timeout(const Duration(seconds: 15));

          final parseResult = await compute(_parseProgressList, {
            'data': data,
            'idKelas': idKelas,
            'idKelompok': idKelompok,
          });

          await _isar.writeTxn(() async {
            if (idKelas != null) {
              await _isar.progressSantriModels
                  .filter()
                  .idKelasEqualTo(idKelas)
                  .deleteAll();
            } else if (idKelompok != null) {
              await _isar.progressSantriModels
                  .filter()
                  .idKelompokEqualTo(idKelompok)
                  .deleteAll();
            }

            await _isar.progressSantriModels.putAll(
              parseResult['models'] as List<ProgressSantriModel>,
            );

            final gc = GenericCache()
              ..key = metaCacheKey
              ..dataJson = parseResult['metaJson'] as String
              ..updatedAt = DateTime.now();
            await _isar.genericCaches.put(gc);
          });

          final unwrapped = (data['data'] as Map<String, dynamic>?) ?? data;

          // Set last_sync untuk Delta berikutnya
          final serverTime =
              (unwrapped['server_time'] ??
                      DateTime.now().toUtc().toIso8601String())
                  .toString();
          await prefs.setString(lastSyncKey, serverTime);
          if (unwrapped.containsKey('santri_list')) {
            List<dynamic> apiSantriList = unwrapped['santri_list'];
            unwrapped['santri_list'] = await applyOfflineMerge(
              apiSantriList.cast<Map<String, dynamic>>(),
            );
          }
          return unwrapped;
        } else {
          // DELTA PULL
          // Ambil daftar NIS yang ada di lokal untuk cek Left Class Problem
          List<String> existingNis = [];
          if (idKelas != null) {
            final localSantris = await _isar.progressSantriModels
                .filter()
                .idKelasEqualTo(idKelas)
                .findAll();
            existingNis = localSantris
                .map((e) => e.nis)
                .whereType<String>()
                .toList();
          }

          debugPrint("Repository: Fetching Delta Sync started...");
          final deltaData = await ApiService.getDeltaProgress(
            idKelompok: idKelompok,
            idKelas: idKelas,
            lastSync: lastSyncTime,
            existingNis: existingNis,
          ).timeout(const Duration(seconds: 10));
          debugPrint("Repository: CI4 Response received.");

          if (deltaData['success'] == true && deltaData['data'] != null) {
            final List<dynamic> upsertedRaw =
                deltaData['data']['upserted'] ?? [];
            final List<dynamic> deletedRaw = deltaData['data']['deleted'] ?? [];

            final List<ProgressSantriModel> upsertedModels = upsertedRaw.map((
              e,
            ) {
              return ProgressSantriModel.fromJson(
                e as Map<String, dynamic>,
                idKelas: idKelas,
                idKelompok: idKelompok,
              );
            }).toList();

            final List<String> deletedNis = deletedRaw
                .map((e) => e.toString())
                .toList();

            await _isar.writeTxn(() async {
              if (deletedNis.isNotEmpty) {
                await _isar.progressSantriModels
                    .filter()
                    .anyOf(deletedNis, (q, nis) => q.nisEqualTo(nis))
                    .deleteAll();
              }
              if (upsertedModels.isNotEmpty) {
                await _isar.progressSantriModels.putAll(upsertedModels);
              }
            });
            debugPrint("Repository: Data successfully saved to Isar.");

            if (deltaData['server_time'] != null) {
              await prefs.setString(
                lastSyncKey,
                deltaData['server_time'].toString(),
              );
            }

            final localAfterDelta = await loadLocal();
            if (localAfterDelta != null) return localAfterDelta;
          }
        }
      } catch (e, stackTrace) {
        debugPrint("Repository Error in Delta Sync: $e\n$stackTrace");
        if (e.toString().contains('401')) rethrow;
        final local = await loadLocal();
        if (local != null) {
          local['is_offline_fallback'] = true;
          return local;
        }
        throw Exception('Gagal memuat data dari server dan cache kosong. Detail: $e');
      }
    }

    final local = await loadLocal();
    if (local != null) {
      local['is_offline_fallback'] = true;
      return local;
    }
    throw Exception(
      'Tidak ada koneksi internet. Silakan online untuk memuat data awal.',
    );
  }

  Future<Map<String, dynamic>> getProgressDetail(
    String nis, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'tahsin_progress_detail_\$nis';

    if (!forceRefresh) {
      final cachedData = await _isar.genericCaches
          .filter()
          .keyEqualTo(cacheKey)
          .findFirst();
      if (cachedData != null)
        return await compute(_parseJsonString, cachedData.dataJson);
    }

    if (await networkInfo.isConnected) {
      try {
        final data = await ApiService.getProgressDetail(
          nis,
        ).timeout(const Duration(seconds: 10));
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
        final cachedData = await _isar.genericCaches
            .filter()
            .keyEqualTo(cacheKey)
            .findFirst();
        if (cachedData != null) {
          final local = await compute(_parseJsonString, cachedData.dataJson);
          local['is_offline_fallback'] = true;
          return local;
        }
        rethrow;
      }
    }
    final cachedData = await _isar.genericCaches
        .filter()
        .keyEqualTo(cacheKey)
        .findFirst();
    if (cachedData != null) {
      final local = await compute(_parseJsonString, cachedData.dataJson);
      local['is_offline_fallback'] = true;
      return local;
    }
    throw Exception('Offline: Detail santri belum tersimpan di cache.');
  }

  Future<Map<String, dynamic>> getRiwayatGlobal(
    String tanggal, {
    int page = 1,
    int limit = 20,
  }) async {
    // Hybrid Time-Bound Sync: Cache up to 14 days
    final requestedDate = DateTime.tryParse(tanggal) ?? DateTime.now();
    final diffDays = DateTime.now().difference(requestedDate).inDays;
    final isWithin14Days = diffDays >= 0 && diffDays <= 14;

    Future<Map<String, dynamic>?> loadLocalRiwayat() async {
      final startOfDay = DateTime(
        requestedDate.year,
        requestedDate.month,
        requestedDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final query = _isar.riwayatTahsinModels.filter().createdAtBetween(
        startOfDay,
        endOfDay,
      );
      final data = await query.findAll();

      if (data.isEmpty) return null;

      final mapList = await compute(_mapRiwayatListToJson, data);

      int lulus = 0;
      int ulang = 0;
      for (var item in data) {
        if (item.statusHalaman?.toLowerCase() == 'lulus') {
          lulus++;
        } else if (item.statusHalaman?.toLowerCase() == 'ulang') {
          ulang++;
        }
      }

      return {
        'data': {
          'total_eval': data.length,
          'total_lulus': lulus,
          'total_ulang': ulang,
          'riwayat': mapList,
        },
      };
    }

    if (!isWithin14Days) {
      if (await networkInfo.isConnected) {
        return await ApiService.getRiwayatGlobal(
          tanggal,
          page: page,
          limit: limit,
        ).timeout(const Duration(seconds: 10));
      }
      throw Exception(
        'Koneksi internet diperlukan untuk melihat riwayat lebih dari 14 hari.',
      );
    }

    // Try load local first for within 14 days
    final local = await loadLocalRiwayat();
    if (local != null) return local;

    if (await networkInfo.isConnected) {
      try {
        final data = await ApiService.getRiwayatGlobal(
          tanggal,
          page: page,
          limit: limit,
        ).timeout(const Duration(seconds: 10));

        // Background parsing & caching
        if (data['data'] != null && data['data']['riwayat'] != null) {
          final rawList = data['data']['riwayat'] as List;
          final parsedModels = await compute(_parseRiwayatList, {
            'list': rawList,
            'jilidId': 0, // default
          });

          await _isar.writeTxn(() async {
            // Bersihkan data tanggal tersebut lalu replace (Eviction Policy)
            final startOfDay = DateTime(
              requestedDate.year,
              requestedDate.month,
              requestedDate.day,
            );
            final endOfDay = startOfDay.add(const Duration(days: 1));
            await _isar.riwayatTahsinModels
                .filter()
                .createdAtBetween(startOfDay, endOfDay)
                .deleteAll();

            await _isar.riwayatTahsinModels.putAll(parsedModels);
          });
        }
        return data;
      } catch (e) {
        throw Exception('Gagal sinkronisasi riwayat: $e');
      }
    }

    throw Exception('Offline: Riwayat untuk tanggal ini belum tersimpan.');
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
    // MISSION 2 FIX (Fast-Fail): Cek status jaringan instan
    final bool isOnline = await networkInfo.isConnected;
    if (!isOnline) {
      return _enqueuePayload('api/guru/progress/input-massal', payload);
    }

    try {
      final res = await ApiService.inputMassalProgress(payload);
      return res['status'] == 200 || res['success'] == true;
    } catch (e) {
      return _enqueuePayload('api/guru/progress/input-massal', payload);
    }
  }

  Future<bool> inputCepatProgress(Map<String, dynamic> payload) async {
    // MISSION 2 FIX (Fast-Fail): Cek status jaringan instan
    final bool isOnline = await networkInfo.isConnected;
    if (!isOnline) {
      return _enqueuePayload('api/guru/progress/input-cepat', payload);
    }

    try {
      final res = await ApiService.inputCepatProgress(payload);
      return res['status'] == 200 || res['success'] == true;
    } catch (e) {
      return _enqueuePayload('api/guru/progress/input-cepat', payload);
    }
  }

  Future<bool> _enqueuePayload(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
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

  /// Mengecek jumlah input hari ini berdasarkan tanggal dan sesi pada database Isar lokal (RiwayatTahsinModels).
  Future<int> checkExistingProgressCount(List<String> nisList, String tanggal, int? sesi) async {
    int total = 0;
    try {
      for (var nis in nisList) {
        final count = await _isar.riwayatTahsinModels
            .filter()
            .nisEqualTo(nis)
            .tanggalEqualTo(tanggal)
            .sesiEqualTo(sesi)
            .count();
        if (count > 0) {
          total++;
        }
      }
    } catch (e) {
      debugPrint("Error checking existing progress count: $e");
    }
    return total;
  }
}

// --- ISOLATE FUNCTIONS (TOP LEVEL) ---

Map<String, dynamic> _parseProgressList(Map<String, dynamic> args) {
  try {
    final data = args['data'] as Map<String, dynamic>;
    final idKelas = args['idKelas'] as int?;
    final idKelompok = args['idKelompok'] as int?;

    List<ProgressSantriModel> models = [];

    // Karena data berbentuk {"status": 200, "santri_list": [], "filter_meta": {}}
    // atau "data" berbentuk object di dalam response
    final actualData = data['data'] ?? data;
    Map<String, dynamic> metaMap = {};
    var rawList = [];

    if (actualData is Map) {
      metaMap = {
        'filter_meta': actualData['filter_meta'],
        'checkpoints':
            actualData['checkpoints'] ?? actualData['t_kelas_checkpoint'],
        'kelas_settings': actualData['kelas_settings'] ?? <String, dynamic>{},
        'metode_list': actualData['metode_list'] ?? <dynamic>[],
        'jadwal_info': actualData['jadwal_info'] ?? <String, dynamic>{},
        'jadwal_list': actualData['jadwal_list'] ?? <dynamic>[],
        'catatan_master': actualData['catatan_master'] ?? <dynamic>[],
      };

      var santriList = actualData['santri_list'];
      if (santriList is Map && santriList.containsKey('data')) {
        rawList = santriList['data'] ?? [];
      } else if (santriList is List) {
        rawList = santriList;
      }
    } else if (actualData is List) {
      rawList = actualData;
    }

    if (rawList.isNotEmpty) {
      for (var e in rawList) {
        if (e is Map<String, dynamic>) {
          models.add(
            ProgressSantriModel.fromJson(
              e,
              idKelas: idKelas,
              idKelompok: idKelompok,
            ),
          );
        }
      }
    }

    return {'models': models, 'metaJson': jsonEncode(metaMap)};
  } catch (e) {
    throw Exception('Gagal memproses data JSON: $e');
  }
}

List<Map<String, dynamic>> _mapProgressListToJson(
  List<ProgressSantriModel> models,
) {
  return models.map((e) => e.toJson()).toList();
}

List<RiwayatTahsinModel> _parseRiwayatList(Map<String, dynamic> args) {
  try {
    final rawList = args['list'] as List;
    final jilidId = args['jilidId'] as int;
    List<RiwayatTahsinModel> models = [];
    for (var e in rawList) {
      if (e is Map<String, dynamic>) {
        models.add(RiwayatTahsinModel.fromJson(e, jilidId));
      }
    }
    return models;
  } catch (e) {
    return [];
  }
}

List<Map<String, dynamic>> _mapRiwayatListToJson(
  List<RiwayatTahsinModel> models,
) {
  return models.map((e) => e.toJson()).toList();
}

Map<String, dynamic> _parseJsonString(String json) {
  return jsonDecode(json) as Map<String, dynamic>;
}

String _encodeJsonString(Map<String, dynamic> data) {
  return jsonEncode(data);
}
