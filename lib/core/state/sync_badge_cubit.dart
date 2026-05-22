import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/offline_queue.dart';

class SyncBadgeCubit extends Cubit<int> {
  StreamSubscription<void>? _watcherSubscription;

  SyncBadgeCubit() : super(0) {
    _init();
  }

  void _init() async {
    final isar = IsarDb.instance;
    // Hitung jumlah awal
    final initialCount = await isar.offlineQueues.count();
    emit(initialCount);

    // Dengarkan perubahan pada tabel offlineQueues secara real-time
    _watcherSubscription = isar.offlineQueues.watchLazy().listen((_) async {
      final count = await isar.offlineQueues.count();
      emit(count);
    });
  }

  @override
  Future<void> close() {
    _watcherSubscription?.cancel();
    return super.close();
  }
}
