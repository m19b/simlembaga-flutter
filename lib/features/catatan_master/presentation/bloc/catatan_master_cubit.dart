import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/data/catatan_master_model.dart';
import 'catatan_master_state.dart';

class CatatanMasterCubit extends Cubit<CatatanMasterState> {
  CatatanMasterCubit() : super(CatatanMasterInitial());

  Map<String, dynamic> _cachedFilterMeta = {};

  Future<void> loadCatatan({int? idKelompok, int? idKelas}) async {
    try {
      if (!isClosed && state is! CatatanMasterLoaded) {
        emit(CatatanMasterLoading());
      }

      final resp = await ApiService.getCatatanMaster(
        idKelompok: idKelompok,
        idKelas: idKelas,
      );

      final List<dynamic> rawList = resp['data']['catatan'] ?? [];
      final List<CatatanMaster> list =
          rawList.map((e) => CatatanMaster.fromJson(e)).toList();

      // Caching filter meta jika ada di response
      if (resp['data']['filter_meta'] != null) {
        _cachedFilterMeta = resp['data']['filter_meta'];
      }

      if (!isClosed) {
        emit(CatatanMasterLoaded(
          catatan: list,
          filterMeta: _cachedFilterMeta,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(CatatanMasterError(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  Future<void> addCatatan(Map<String, dynamic> data) async {
    await _performAction(() => ApiService.storeCatatanMaster(data), 'Catatan berhasil ditambahkan');
  }

  Future<void> updateCatatan(Map<String, dynamic> data) async {
    await _performAction(() => ApiService.updateCatatanMaster(data), 'Catatan berhasil diperbarui');
  }

  Future<void> deleteCatatan(int idCatatan) async {
    await _performAction(() => ApiService.deleteCatatanMaster(idCatatan), 'Catatan berhasil dihapus');
  }

  Future<void> _performAction(Future<dynamic> Function() action, String successMsg) async {
    final currentState = state;
    if (currentState is CatatanMasterLoaded) {
      try {
        if (!isClosed) emit(CatatanMasterActionProgress(_cachedFilterMeta));
        await action();
        // Reload after success
        await loadCatatan();
        if (!isClosed && state is CatatanMasterLoaded) {
          emit((state as CatatanMasterLoaded).copyWith(message: successMsg));
        }
      } catch (e) {
        if (!isClosed) {
          emit(CatatanMasterLoaded(
            catatan: currentState.catatan,
            filterMeta: currentState.filterMeta,
            message: 'Error: ${e.toString().replaceAll('Exception: ', '')}',
          ));
        }
      }
    }
  }
}
