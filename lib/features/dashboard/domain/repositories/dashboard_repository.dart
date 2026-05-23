import 'dart:convert';

import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/features/dashboard/data/models/dashboard_model.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/generic_cache.dart';
import 'package:isar/isar.dart';

class DashboardRepository {
  final NetworkInfo networkInfo;

  DashboardRepository({
    required this.networkInfo,
  });

  Future<DashboardModel?> getLocalData(int? idKategori) async {
    final cacheKey = 'dashboard_data_cache_${idKategori ?? 0}';
    final isar = IsarDb.instance;
    final cache = await isar.genericCaches.filter().keyEqualTo(cacheKey).findFirst();
    if (cache != null) {
      try {
        final payload = json.decode(cache.dataJson) as Map<String, dynamic>;
        return DashboardModel.fromJson(payload);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<DashboardModel> fetchFreshData(int? idKategori) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      throw Exception('Tidak ada koneksi internet.');
    }

    final cacheKey = 'dashboard_data_cache_${idKategori ?? 0}';
    final isar = IsarDb.instance;

    final Map<String, dynamic> responseData = await ApiService.getDashboardGuru(idKategori: idKategori);
    
    final Map<String, dynamic> payload =
        (responseData['data'] is Map<String, dynamic>)
            ? responseData['data'] as Map<String, dynamic>
            : responseData;

    await isar.writeTxn(() async {
      final gc = GenericCache()
        ..key = cacheKey
        ..dataJson = json.encode(payload)
        ..updatedAt = DateTime.now();
      await isar.genericCaches.put(gc);
    });

    return DashboardModel.fromJson(payload);
  }
}
