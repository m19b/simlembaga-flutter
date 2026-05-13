import 'package:isar/isar.dart';

part 'generic_cache.g.dart';

@collection
class GenericCache {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true, replace: true)
  late String key;
  
  late String dataJson;
  late DateTime updatedAt;
}
