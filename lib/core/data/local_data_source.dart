import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/generic_cache.dart';
import 'package:manajemen_tahsin_app/core/data/models/offline_queue.dart';

abstract class LocalDataSource {
  Future<void> cacheData(String key, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedData(String key);
  Future<void> clearCache();
  
  Future<void> enqueueRequest(String endpoint, Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> getQueue();
  Future<void> removeFromQueue(int id);
  Future<void> clearQueue();
}

class LocalDataSourceImpl implements LocalDataSource {
  Isar get _isar => IsarDb.instance;

  @override
  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    final cache = GenericCache()
      ..key = key
      ..dataJson = jsonEncode(data)
      ..updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.genericCaches.put(cache);
    });
  }

  @override
  Future<Map<String, dynamic>?> getCachedData(String key) async {
    final cache = await _isar.genericCaches.filter().keyEqualTo(key).findFirst();
    if (cache != null) {
      return jsonDecode(cache.dataJson);
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await _isar.writeTxn(() async {
      await _isar.genericCaches.clear();
    });
  }

  @override
  Future<void> enqueueRequest(String endpoint, Map<String, dynamic> payload) async {
    final request = OfflineQueue()
      ..endpoint = endpoint
      ..payloadJson = jsonEncode(payload)
      ..timestamp = DateTime.now()
      ..status = 'pending';

    await _isar.writeTxn(() async {
      await _isar.offlineQueues.put(request);
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getQueue() async {
    final items = await _isar.offlineQueues.where().findAll();
    return items.map((e) {
      final payload = jsonDecode(e.payloadJson) as Map<String, dynamic>;
      return {
        'id': e.id, // Using Isar ID instead of index
        'endpoint': e.endpoint,
        'payload': payload,
        'timestamp': e.timestamp.toIso8601String(),
        'status': e.status,
      };
    }).toList();
  }

  @override
  Future<void> removeFromQueue(int id) async {
    await _isar.writeTxn(() async {
      await _isar.offlineQueues.delete(id);
    });
  }

  @override
  Future<void> clearQueue() async {
    await _isar.writeTxn(() async {
      await _isar.offlineQueues.clear();
    });
  }
}
