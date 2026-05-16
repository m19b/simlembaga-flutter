import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/data/models/hari_libur_model.dart';

class HariLiburRepository {
  final NetworkInfo networkInfo;

  const HariLiburRepository({required this.networkInfo});

  // ── Public: Offline-First GET ──────────────────────────────────────────────
  Future<List<HariLiburModel>> getHariLibur({
    required int tahun,
    required int idKelompok,
  }) async {
    final isOnline = await networkInfo.isConnected;

    // Gunakan kelompokId dari static (sama dengan interceptor header)
    final headerKelompokId = ActiveKelompokCubit.activeKelompokId;
    debugPrint('[HariLiburRepo] tahun=$tahun, paramId=$idKelompok, headerId=$headerKelompokId');

    if (isOnline) {
      try {
        final resp = await ApiService.getHariLibur(
          tahun: tahun,
          idKelompok: idKelompok,
        );

        debugPrint('[HariLiburRepo] === RAW RESPONSE KEYS: ${resp.keys}');

        // Parse response: resp = {status, error, message, data}
        // data = {tahun, id_kelompok, total_data, hari_libur: [...]}
        List rawList = [];
        final dataField = resp['data'];
        if (dataField is Map) {
          rawList = (dataField['hari_libur'] as List?) ?? [];
          debugPrint('[HariLiburRepo] === data.hari_libur count: ${rawList.length}');
        } else if (dataField is List) {
          rawList = dataField;
          debugPrint('[HariLiburRepo] === data IS List, count: ${rawList.length}');
        } else {
          debugPrint('[HariLiburRepo] === data type: ${dataField.runtimeType} — UNEXPECTED');
        }

        if (rawList.isNotEmpty) {
          debugPrint('[HariLiburRepo] === Sample item: ${rawList.first}');
        }

        final models = rawList.whereType<Map>().map((e) {
          final safe = <String, dynamic>{};
          e.forEach((k, v) => safe[k.toString()] = v);
          return HariLiburModel.fromJson(safe,
              tahun: tahun, idKelompok: headerKelompokId);
        }).toList();

        debugPrint('[HariLiburRepo] === Parsed models: ${models.length}');

        // Cache ke Isar
        await IsarDb.instance.writeTxn(() async {
          await IsarDb.instance.hariLiburModels
              .filter()
              .tahunEqualTo(tahun)
              .deleteAll();
          await IsarDb.instance.hariLiburModels.putAll(models);
        });

        debugPrint('[HariLiburRepo] === Returning ${models.length} items');
        return models;
      } catch (e, stack) {
        debugPrint('[HariLiburRepo] ❌ Online fetch FAILED: $e');
        debugPrint('[HariLiburRepo] Stack: $stack');
        return _fromIsar(tahun: tahun);
      }
    }

    debugPrint('[HariLiburRepo] === OFFLINE mode, reading Isar');
    return _fromIsar(tahun: tahun);
  }

  // ── Private: Read from Isar ────────────────────────────────────────────────
  Future<List<HariLiburModel>> _fromIsar({required int tahun}) async {
    final items = await IsarDb.instance.hariLiburModels
        .filter()
        .tahunEqualTo(tahun)
        .sortByTanggalMulai()
        .findAll();
    debugPrint('[HariLiburRepo] === Isar returned ${items.length} items');
    return items;
  }
}
