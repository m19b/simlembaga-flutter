import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/dashboard/data/models/dashboard_model.dart';
import 'package:manajemen_tahsin_app/features/dashboard/domain/repositories/dashboard_repository.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardModel data;
  final bool isRefreshing;
  DashboardLoaded(this.data, {this.isRefreshing = false});
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repository;
  final ActiveKelompokCubit activeKelompokCubit;
  late final StreamSubscription _kelompokSubscription;

  int? activeKategori;

  DashboardCubit({
    required this.repository,
    required this.activeKelompokCubit,
  }) : super(DashboardInitial()) {
    // Listen terhadap perubahan kelompok aktif (Dropdown multi-tenancy)
    _kelompokSubscription = activeKelompokCubit.stream.listen((kelompokState) {
      if (kelompokState.activeId > 0) {
        // Jika kelompok berubah, re-fetch data dashboard
        fetchDashboard(forceRefresh: true);
      }
    });
  }

  Future<void> fetchDashboard({bool forceRefresh = false}) async {
    if (state is DashboardLoading && !forceRefresh) return;
    
    // Cache-Then-Network: Load local data first
    final localData = await repository.getLocalData(activeKategori);
    if (localData != null) {
      emit(DashboardLoaded(localData, isRefreshing: true));
    } else {
      emit(DashboardLoading());
    }

    try {
      final freshData = await repository.fetchFreshData(activeKategori);
      emit(DashboardLoaded(freshData, isRefreshing: false));
    } catch (e) {
      if (localData == null) {
        emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
      } else {
        // Tetap tampilkan data lokal jika gagal narik data baru
        emit(DashboardLoaded(localData, isRefreshing: false));
      }
    }
  }

  void setKategori(int? idKategori) {
    if (activeKategori != idKategori) {
      activeKategori = idKategori;
      fetchDashboard(forceRefresh: true);
    }
  }

  @override
  Future<void> close() {
    _kelompokSubscription.cancel();
    return super.close();
  }
}
