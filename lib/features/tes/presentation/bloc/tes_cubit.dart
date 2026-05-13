import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/api_service.dart';
import '../../data/tes_model.dart';
import 'tes_state.dart';

class TesCubit extends Cubit<TesState> {
  TesCubit() : super(TesInitial());

  List<RiwayatTes> _riwayatCache = [];
  bool _hasReachedMax = false;

  Future<void> loadDaftarTes() async {
    emit(TesLoading());
    try {
      // 1. Fetch both endpoints concurrently
      final responses = await Future.wait([
        ApiService.getCalonTes(),
        ApiService.getAntrianTes(),
      ]);

      final calonResponse = responses[0];
      final antrianResponse = responses[1];

      final calonData = calonResponse['data'];
      final antrianData = antrianResponse['data'];

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

      // 2. Merge Both Lists
      final mergedList = [...calonList, ...antrianList];

      emit(TesLoaded(calonTesList: mergedList));
    } catch (e) {
      emit(TesError('Gagal memuat data: ${e.toString().replaceAll('Exception: ', '')}'));
    }
  }

  Future<void> daftarkanTes({
    required String nis,
    required String idKelas,
    required String idKelompok,
  }) async {
    final currentState = state;
    emit(TesLoading());
    try {
      final response = await ApiService.daftarkanTes(
        nis: nis,
        idKelas: idKelas,
        idKelompok: idKelompok,
      );
      emit(TesActionSuccess(response['message'] ?? 'Berhasil mendaftarkan santri'));
      await loadDaftarTes();
    } catch (e) {
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
      final response = await ApiService.batalkanTes(idDaftar: idDaftar);
      emit(TesActionSuccess(response['message'] ?? 'Berhasil membatalkan tes santri'));
      await loadDaftarTes();
    } catch (e) {
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
    bool reload = false
  }) async {
    if (reload) {
      _riwayatCache.clear();
      _hasReachedMax = false;
      emit(TesRiwayatLoading()); // Use independent loading state
    } else {
      if (_hasReachedMax) return;
    }

    try {
      final response = await ApiService.getRiwayatTes(
        status: status,
        tglMulai: tglMulai,
        tglAkhir: tglAkhir,
      );
      
      final rawData = response['data']?['riwayat_test'] ?? response['data']?['riwayat'] ?? response['data'];
      List<RiwayatTes> loadedList = [];
      
      if (rawData is List) {
           loadedList = rawData.map((e) => RiwayatTes.fromJson(e as Map<String, dynamic>)).toList();
      }

      _riwayatCache = loadedList;
      _hasReachedMax = true; // No pagination so fully loaded.

      emit(TesRiwayatLoaded(
        riwayatList: List.of(_riwayatCache),
        hasReachedMax: _hasReachedMax,
      ));
    } catch (e) {
      emit(TesError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
