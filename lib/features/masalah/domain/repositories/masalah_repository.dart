import 'package:isar/isar.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/data/models/tahfidz_santri_model.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/data/models/pra_tahfidz_santri_model.dart';
import 'package:manajemen_tahsin_app/features/progress/data/models/progress_santri_model.dart';
import 'package:manajemen_tahsin_app/core/api/services/santri_catatan_api_service.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
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
          SantriCatatanApiService.getMasalahAktif(),
          SantriCatatanApiService.getMasalahSelesai(),
          SantriCatatanApiService.getMasalahPendingApproval(),
        ]);
        final aktif   = _parseList(results[0]);
        final selesai = _parseList(results[1]);
        final pending = _parseList(results[2]);

        final mergedAktif = [...pending, ...aktif];

        await localDataSource.cacheData(cacheKeyAktif,   {'items': mergedAktif});
        await localDataSource.cacheData(cacheKeySelesai, {'items': selesai});

        return {'aktif': mergedAktif, 'selesai': selesai};
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

  // ─── READ: Local DB ───────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getLocalSantri(int activeId) async {
    final isar = IsarDb.instance;
    final List<Map<String, dynamic>> result = [];
    
    if (activeId > 0) {
      final t1 = await isar.tahfidzSantriModels.filter().idKelompokEqualTo(activeId).findAll();
      final t2 = await isar.praTahfidzSantriModels.filter().idKelompokEqualTo(activeId).findAll();
      final t3 = await isar.progressSantriModels.filter().idKelompokEqualTo(activeId).findAll();
      
      for (var s in t1) {
        result.add({
          'nis': s.nis,
          'nama_santri': s.namaSantri,
          'tingkat': s.tingkat ?? s.idKelas?.toString(),
        });
      }
      for (var s in t2) {
        result.add({
          'nis': s.nis,
          'nama_santri': s.namaSantri,
          'tingkat': s.tingkat ?? s.idKelas?.toString(),
        });
      }
      for (var s in t3) {
        result.add({
          'nis': s.nis,
          'nama_santri': s.namaSantri,
          'tingkat': s.tingkat ?? s.idKelas?.toString(),
        });
      }
    }
    
    // Sort alphabet
    result.sort((a, b) => (a['nama_santri'] ?? '').toString().compareTo((b['nama_santri'] ?? '').toString()));
    return result;
  }

  // ─── WRITE: Optimistic UI ─────────────────────────────────────────────────
  Future<bool> updateMasalah(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        await SantriCatatanApiService.updateMasalah(
          id: payload['id']?.toString() ?? '',
          status: payload['status']?.toString() ?? '',
          tglSelesai: payload['tgl_selesai']?.toString(),
          catatanSelesai: payload['catatan_selesai']?.toString(),
        );
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/masalah/update', payload, 'catatan_masalah');
      }
    }
    return _enqueuePayload('api/guru/masalah/update', payload, 'catatan_masalah');
  }

  Future<bool> storeTahapMasalah(Map<String, dynamic> payload) async {
    if (await networkInfo.isConnected) {
      try {
        await SantriCatatanApiService.storeTahapMasalah(
          idMasalah: payload['id_masalah']?.toString() ?? '',
          jenisPenyelesaian: payload['jenis_penyelesaian']?.toString() ?? '',
          tglPenyelesaian: payload['tgl_penyelesaian']?.toString() ?? '',
          keterangan: payload['keterangan']?.toString() ?? '',
          hasilTahap: payload['hasil_tahap']?.toString() ?? '',
        );
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/masalah/tahap', payload, 'catatan_masalah');
      }
    }
    return _enqueuePayload('api/guru/masalah/tahap', payload, 'catatan_masalah');
  }

  Future<bool> storeMasalah(Map<String, dynamic> payload) async {
    // 1. Optimistic insert to cache first
    final newItem = {
      'id_masalah': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'nis': payload['nis'],
      'nama_santri': payload['nama_santri'] ?? 'Santri',
      'kelas': payload['kelas'] ?? '',
      'tingkat': payload['kelas'] ?? '',
      'jenis_masalah': payload['jenis_masalah'],
      'keterangan': payload['keterangan'],
      'deskripsi': payload['keterangan'],
      'tgl_deteksi': payload['tgl_masalah'],
      'tgl_masalah': payload['tgl_masalah'],
      'status': 'Pending Approval',
      'is_syncing': true,
    };
    
    try {
      final cAktif = await localDataSource.getCachedData('masalah_aktif');
      final list = (cAktif != null && cAktif['items'] != null) 
          ? _castList(cAktif['items']) 
          : <Map<String, dynamic>>[];
      list.insert(0, newItem);
      await localDataSource.cacheData('masalah_aktif', {'items': list});
    } catch (_) {}

    if (await networkInfo.isConnected) {
      try {
        await SantriCatatanApiService.storeMasalah(
          nis: payload['nis']?.toString() ?? '',
          jenisMasalah: payload['jenis_masalah']?.toString() ?? '',
          keterangan: payload['keterangan']?.toString() ?? '',
          tglMasalah: payload['tgl_masalah']?.toString() ?? '',
        );
        return true;
      } catch (_) {
        return _enqueuePayload('api/guru/masalah/store', payload, 'catatan_masalah');
      }
    }
    return _enqueuePayload('api/guru/masalah/store', payload, 'catatan_masalah');
  }

  Future<bool> _enqueuePayload(String endpoint, Map<String, dynamic> payload, String type) async {
    payload['type'] = type;
    await localDataSource.enqueueRequest(endpoint, payload, type: type);
    return true;
  }
}
