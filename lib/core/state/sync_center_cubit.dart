import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/offline_queue.dart';
import 'package:isar/isar.dart';

class SyncCenterState {
  final int totalAntrean;
  final List<OfflineQueue> daftarAntrean;

  SyncCenterState({required this.totalAntrean, required this.daftarAntrean});
}

class SyncCenterCubit extends Cubit<SyncCenterState> {
  StreamSubscription<void>? _watcherSubscription;

  SyncCenterCubit() : super(SyncCenterState(totalAntrean: 0, daftarAntrean: [])) {
    _init();
  }

  void _init() async {
    final isar = IsarDb.instance;
    // Initial fetch
    await _fetchData(isar);

    // Watch for changes in real-time
    _watcherSubscription = isar.offlineQueues.watchLazy().listen((_) async {
      await _fetchData(isar);
    });
  }

  Future<void> _fetchData(Isar isar) async {
    final antrean = await isar.offlineQueues.where().findAll();
    emit(SyncCenterState(
      totalAntrean: antrean.length,
      daftarAntrean: antrean,
    ));
  }

  @override
  Future<void> close() {
    _watcherSubscription?.cancel();
    return super.close();
  }
}
