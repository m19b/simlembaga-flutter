import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

abstract class LocalDataSource {
  Future<void> cacheData(String key, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedData(String key);
  Future<void> clearCache();
  
  Future<void> enqueueRequest(String endpoint, Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> getQueue();
  Future<void> removeFromQueue(int index);
  Future<void> clearQueue();
}

class LocalDataSourceImpl implements LocalDataSource {
  final Box cacheBox = Hive.box('cacheBox');
  final Box queueBox = Hive.box('queueBox');

  @override
  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    await cacheBox.put(key, jsonEncode(data));
  }

  @override
  Future<Map<String, dynamic>?> getCachedData(String key) async {
    final cachedString = cacheBox.get(key);
    if (cachedString != null) {
      return jsonDecode(cachedString);
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await cacheBox.clear();
  }

  @override
  Future<void> enqueueRequest(String endpoint, Map<String, dynamic> payload) async {
    final request = {
      'endpoint': endpoint,
      'payload': payload,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'pending',
    };
    await queueBox.add(jsonEncode(request));
  }

  @override
  Future<List<Map<String, dynamic>>> getQueue() async {
    final items = <Map<String, dynamic>>[];
    for (var i = 0; i < queueBox.length; i++) {
      final jsonString = queueBox.getAt(i);
      if (jsonString != null) {
        final item = jsonDecode(jsonString);
        item['index'] = i; // Save index to know which to remove
        items.add(item);
      }
    }
    return items;
  }

  @override
  Future<void> removeFromQueue(int index) async {
    await queueBox.deleteAt(index);
  }

  @override
  Future<void> clearQueue() async {
    await queueBox.clear();
  }
}
