import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/santri/domain/repositories/santri_repository.dart';

abstract class SantriState {}

class SantriInitial extends SantriState {}

class SantriLoading extends SantriState {}

class SantriLoaded extends SantriState {
  final Map<String, dynamic> data;
  SantriLoaded(this.data);
}

class SantriError extends SantriState {
  final String message;
  SantriError(this.message);
}

class SantriCubit extends Cubit<SantriState> {
  final SantriRepository repository;
  final ActiveKelompokCubit activeKelompokCubit;
  late final StreamSubscription _kelompokSubscription;

  int? _lastIdKelompok;
  int? _lastIdKelas;

  SantriCubit({
    required this.repository,
    required this.activeKelompokCubit,
  }) : super(SantriInitial()) {
    _kelompokSubscription = activeKelompokCubit.stream.listen((kelompokState) {
      if (kelompokState.activeId > 0 && _lastIdKelompok != null) {
        fetchSantriList(idKelompok: kelompokState.activeId, idKelas: _lastIdKelas, forceRefresh: true);
      }
    });
  }

  Future<void> fetchSantriList({int? idKelompok, int? idKelas, bool forceRefresh = false}) async {
    _lastIdKelompok = idKelompok;
    _lastIdKelas = idKelas;
    emit(SantriLoading());
    try {
      final data = await repository.getSantriList(idKelompok: idKelompok, idKelas: idKelas, forceRefresh: forceRefresh);
      emit(SantriLoaded(data));
    } catch (e) {
      emit(SantriError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _kelompokSubscription.cancel();
    return super.close();
  }
}
