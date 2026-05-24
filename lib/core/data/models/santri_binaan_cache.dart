import 'package:isar/isar.dart';

part 'santri_binaan_cache.g.dart';

@collection
class SantriBinaanCache {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String nis;

  late String nama;

  String? tingkatKelas;

  String? kodeJalur;

  late int idKelas;
}
