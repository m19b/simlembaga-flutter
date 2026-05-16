import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:manajemen_tahsin_app/core/data/models/generic_cache.dart';
import 'package:manajemen_tahsin_app/core/data/models/offline_queue.dart';
import 'package:manajemen_tahsin_app/features/progress/data/models/riwayat_tahsin_model.dart';
import 'package:manajemen_tahsin_app/features/progress/data/models/progress_santri_model.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/data/models/hari_libur_model.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/data/models/pra_tahfidz_santri_model.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/data/models/pra_tahfidz_riwayat_model.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/data/models/tahfidz_santri_model.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/data/models/tahfidz_riwayat_model.dart';

class IsarDb {
  static late Isar instance;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    instance = await Isar.open(
      [
        GenericCacheSchema,
        OfflineQueueSchema,
        RiwayatTahsinModelSchema,
        ProgressSantriModelSchema,
        HariLiburModelSchema,
        PraTahfidzSantriModelSchema,
        PraTahfidzRiwayatModelSchema,
        TahfidzSantriModelSchema,
        TahfidzRiwayatModelSchema,
      ],
      directory: dir.path,
    );
  }
}
