import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/daftar_tes_repository.dart';
import '../../data/tes_model.dart';
import 'tes_state.dart';
import 'package:manajemen_tahsin_app/core/enums/jalur_enum.dart';

class TesCubit extends Cubit<TesState> {
  final DaftarTesRepository repository;
  JalurEnum currentJalur = JalurEnum.tahsin;
  
  TesCubit({required this.repository}) : super(TesInitial());

  List<RiwayatTes> _riwayatCache = [];
  bool _hasReachedMax = false;

  Future<void> loadDaftarTes({bool forceRefresh = false, JalurEnum? jalur}) async {
    if (jalur != null) {
      currentJalur = jalur;
    }
    emit(TesLoading());
    try {
      final data = await repository.getDaftarTes(
        forceRefresh: forceRefresh,
        jalur: currentJalur,
      );

      final calonData = data['calon']?['data'];
      final antrianData = data['antrian']?['data'];

      final calonList = (calonData is Map && calonData['calon_test'] is List)
          ? (calonData['calon_test'] as List)
              .map((e) => CalonTes.fromJson(e as Map<String, dynamic>))
              .toList()
          : <CalonTes>[];

      final antrianList = (antrianData is Map && antrianData['antrian'] is List)
          ? (antrianData['antrian'] as List)
              .map((e) => CalonTes.fromJson(e as Map<String, dynamic>))
              .toList()
          : <CalonTes>[];

      // Merge Both Lists
      final mergedList = [...calonList, ...antrianList];

      if (isClosed) return;
      emit(TesLoaded(calonTesList: mergedList));
    } catch (e) {
      if (isClosed) return;
      emit(TesError('Gagal memuat data: ${e.toString().replaceAll('Exception: ', '')}'));
    }
  }

  Future<void> daftarkanTes({
    required String nis,
    required String idKelas,
    required String idKelompok,
    String? kodeJalur, // Accept kodeJalur overrides
  }) async {
    final currentState = state;
    emit(TesLoading());
    
    // Fallback to current state if null
    final finalKodeJalur = kodeJalur ?? currentJalur.kode;
    
    try {
      final success = await repository.daftarkanTes(
        nis: nis,
        idKelas: idKelas,
        idKelompok: idKelompok,
        kodeJalur: finalKodeJalur,
      );
      if (isClosed) return;
      if (success) {
        emit(TesActionSuccess('Tersimpan di antrean offline.'));
        await loadDaftarTes(forceRefresh: true);
      } else {
        emit(TesError('Gagal mendaftarkan tes.'));
        if (currentState is TesLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      if (isClosed) return;
      emit(TesError(e.toString().replaceAll('Exception: ', '')));
      if (currentState is TesLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> batalkanTes(String idDaftar) async {
    final currentState = state;
    emit(TesLoading());
    try {
      final success = await repository.batalkanTes(idDaftar);
      if (isClosed) return;
      if (success) {
        emit(TesActionSuccess('Tersimpan di antrean offline.'));
        await loadDaftarTes(forceRefresh: true);
      } else {
        emit(TesError('Gagal membatalkan tes.'));
        if (currentState is TesLoaded) {
          emit(currentState);
        }
      }
    } catch (e) {
      if (isClosed) return;
      emit(TesError(e.toString().replaceAll('Exception: ', '')));
      if (currentState is TesLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> loadRiwayatTes({
    String? status, 
    required String tglMulai, 
    required String tglAkhir, 
    JalurEnum? jalur,
    bool reload = false
  }) async {
    if (jalur != null) {
      currentJalur = jalur;
    }
    
    if (reload) {
      _riwayatCache.clear();
      _hasReachedMax = false;
      emit(TesRiwayatLoading()); // Use independent loading state
    } else {
      if (_hasReachedMax) return;
    }

    try {
      final response = await repository.getRiwayatTes(
        status: status,
        tglMulai: tglMulai,
        tglAkhir: tglAkhir,
        jalur: currentJalur,
        forceRefresh: reload,
      );
      
      final rawData = response['data']?['riwayat_test'] ?? response['data']?['riwayat'] ?? response['data'];
      List<RiwayatTes> loadedList = [];
      
      if (rawData is List) {
           loadedList = rawData.map((e) => RiwayatTes.fromJson(e as Map<String, dynamic>)).toList();
      }

      _riwayatCache = loadedList;
      _hasReachedMax = true; // No pagination so fully loaded.

      if (isClosed) return;
      emit(TesRiwayatLoaded(
        riwayatList: List.of(_riwayatCache),
        hasReachedMax: _hasReachedMax,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(TesError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
