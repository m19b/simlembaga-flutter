import 'package:isar/isar.dart';

part 'offline_queue.g.dart';

@collection
class OfflineQueue {
  Id id = Isar.autoIncrement;
  
  late String endpoint;
  late String type;
  late String payloadJson;
  late DateTime timestamp;
  late String status;
}
