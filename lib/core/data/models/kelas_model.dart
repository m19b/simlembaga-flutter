// Ingat: Jalankan build_runner secara manual setelah mengubah file ini.
// flutter pub run build_runner build --delete-conflicting-outputs

import 'package:isar/isar.dart';

part 'kelas_model.g.dart';

@collection
class KelasModel {
  Id idKelas = Isar.autoIncrement;

  String? tingkat;

  @Index()
  int? idKelompok;

  String? namaKelompok;

  List<CheckpointLokal>? checkpoints;
}

@embedded
class CheckpointLokal {
  double? halamanTarget;
  int? harusTes;
  String? keterangan;
}
