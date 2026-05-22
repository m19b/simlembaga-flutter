import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';

class MasalahRepository {
  final NetworkInfo networkInfo;
  final LocalDataSource localDataSource;

  MasalahRepository({
    required this.networkInfo,
    required this.localDataSource,
  });

  // ─── HELPERS ──────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _parseList(dynamic resp) {
    final raw = resp['data'];
    if (raw is Map) {
      final list = raw['masalah'];
      if (list is List) {
        return list.whereType<Map>().map((e) {
          final Map<String, dynamic> m = {};
          e.forEach((k, v) => m[k.toString()] = v);
          return m;
        }).toList();
      }
    }
    return [];
  }

  // ─── READ: Cache-Then-Network ─────────────────────────────────────────────
  Future<Map<String, dynamic>> getMasalahList({bool forceRefresh = false}) async {
    const cacheKeyAktif   = 'masalah_aktif';
    const cacheKeySelesai = 'masalah_selesai';

    if (await networkInfo.isConnected) {
      try {
        final results = await Future.wait([
          ApiService.getMasalahAktif(),
          ApiService.getMasalahSelesai(),
        ]);
        final aktif   = _parseList(results[0]);
        final selesai = _parseList(results[1]);

        await localDataSource.cacheData(cacheKeyAktif,   {'items': aktif});
        await localDataSource.cacheData(cacheKeySelesai, {'items': selesai});

        return {'aktif': aktif, 'selesai': selesai};
      } catch (e) {
        // Fallback ke cache
        return _loadFromCache(cacheKeyAktif, cacheKeySelesai);
      }
    }

    return _loadFromCache(cacheKeyAktif, cacheKeySelesai);
  }

  Future<Map<String, dynamic>> _loadFromCache(
    String keyAktif, String keySelesai) async {
    final cAktif   = await localDataSource.getCachedData(keyAktif);
    final cSelesai = await localDataSource.getCachedData(keySelesai);

    if (cAktif != null || cSelesai != null) {
      return {
        'aktif':   _castList(cAktif?['items']),
        'selesai': _castList(cSelesai?['items']),
        'is_offline_fallback': true, // Add flag
      };
    }
    throw Exception('Offline: Data masalah belum ada di cache.');
  }

  List<Map<String, dynamic>> _castList(dynamic raw) {
    if (raw is List) {
      return raw.whereType<Map>().map((e) {
        final Map<String, dynamic> m = {};
        e.forEach((k, v) => m[k.toString()] = v);
        return m;
      }).toList();
    }
    return [];
  }

  // ─── WRITE: Optimistic UI ─────────────────────────────────────────────────
  Future<bool> updateMasalah(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        await ApiService.updateMasalah(
          id: payload['id']?.toString() ?? '',
          status: payload['status']?.toString() ?? '',
          tglSelesai: payload['tgl_selesai']?.toString(),
          catatanSelesai: payload['catatan_selesai']?.toString(),
        );
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/masalah/update', payload);
      }
    }
    return _enqueuePayload('api/guru/masalah/update', payload);
  }

  Future<bool> storeTahapMasalah(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        await ApiService.storeTahapMasalah(
          idMasalah: payload['id_masalah']?.toString() ?? '',
          jenisPenyelesaian: payload['jenis_penyelesaian']?.toString() ?? '',
          tglPenyelesaian: payload['tgl_penyelesaian']?.toString() ?? '',
          keterangan: payload['keterangan']?.toString() ?? '',
          hasilTahap: payload['hasil_tahap']?.toString() ?? '',
        );
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/masalah/tahap', payload);
      }
    }
    return _enqueuePayload('api/guru/masalah/tahap', payload);
  }

  Future<bool> storeMasalah(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        await ApiService.storeMasalah(
          nis: payload['nis']?.toString() ?? '',
          jenisMasalah: payload['jenis_masalah']?.toString() ?? '',
          keterangan: payload['keterangan']?.toString() ?? '',
          tglMasalah: payload['tgl_masalah']?.toString() ?? '',
        );
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/masalah/store', payload);
      }
    }
    return _enqueuePayload('api/guru/masalah/store', payload);
  }

  Future<bool> _enqueuePayload(String endpoint, Map<String, dynamic> payload) async {
    await localDataSource.enqueueRequest(endpoint, payload);
    return true;
  }
}
