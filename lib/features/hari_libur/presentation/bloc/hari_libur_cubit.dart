import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/data/models/hari_libur_model.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/data/repositories/hari_libur_repository.dart';

// ── States ────────────────────────────────────────────────────────────────────
sealed class HariLiburState {}

final class HariLiburInitial extends HariLiburState {}

final class HariLiburLoading extends HariLiburState {}

final class HariLiburLoaded extends HariLiburState {
  final List<HariLiburModel> items;
  final int tahun;
  HariLiburLoaded({required this.items, required this.tahun});
}

final class HariLiburError extends HariLiburState {
  final String message;
  HariLiburError(this.message);
}

// ── Cubit ─────────────────────────────────────────────────────────────────────
class HariLiburCubit extends Cubit<HariLiburState> {
  final HariLiburRepository repository;

  HariLiburCubit({required this.repository}) : super(HariLiburInitial());

  Future<void> fetch({
    required int tahun,
    required int idKelompok,
  }) async {
    if (isClosed) return;
    emit(HariLiburLoading());
    try {
      final items = await repository.getHariLibur(
        tahun: tahun,
        idKelompok: idKelompok,
      );
      if (isClosed) return;
      emit(HariLiburLoaded(items: items, tahun: tahun));
    } catch (e) {
      if (isClosed) return;
      emit(HariLiburError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
