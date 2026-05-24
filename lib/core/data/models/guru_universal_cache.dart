import 'package:isar/isar.dart';

part 'guru_universal_cache.g.dart';

@collection
class GuruUniversalCache {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String nig;

  late String nama;
}
