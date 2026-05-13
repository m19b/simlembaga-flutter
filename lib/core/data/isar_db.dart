import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:manajemen_tahsin_app/core/data/models/generic_cache.dart';
import 'package:manajemen_tahsin_app/core/data/models/offline_queue.dart';
import 'package:manajemen_tahsin_app/features/progress/data/models/riwayat_tahsin_model.dart';
import 'package:manajemen_tahsin_app/features/progress/data/models/progress_santri_model.dart';

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
      ],
      directory: dir.path,
    );
  }
}
