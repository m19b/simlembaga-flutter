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
  DashboardLoaded(this.data);
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repository;
  final ActiveKelompokCubit activeKelompokCubit;
  late final StreamSubscription _kelompokSubscription;

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
    emit(DashboardLoading());
    try {
      final data = await repository.getDashboardData(forceRefresh: forceRefresh);
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _kelompokSubscription.cancel();
    return super.close();
  }
}
