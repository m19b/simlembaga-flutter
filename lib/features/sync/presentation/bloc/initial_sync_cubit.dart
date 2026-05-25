import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/data/repositories/hari_libur_repository.dart';
import 'package:manajemen_tahsin_app/features/progress/domain/repositories/tahsin_repository.dart';
import 'package:manajemen_tahsin_app/features/santri/domain/repositories/santri_repository.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/generic_cache.dart';
import 'package:manajemen_tahsin_app/features/progress/data/models/progress_santri_model.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/domain/repositories/pra_tahfidz_repository.dart' as import_pra_tahfidz;
import 'initial_sync_state.dart';

class InitialSyncCubit extends Cubit<InitialSyncState> {
  final SantriRepository santriRepository;
  final TahsinRepository tahsinRepository;
  final HariLiburRepository hariLiburRepository;

  InitialSyncCubit({
    required this.santriRepository,
    required this.tahsinRepository,
    required this.hariLiburRepository,
  }) : super(InitialSyncInitial());

  Future<void> runInitialSync() async {
    emit(InitialSyncInitial()); // Reset state agar listener bisa merespon ulang
    try {
      final activeKelompokId = ActiveKelompokCubit.activeKelompokId;

      // MISSION 2 FIX (Fast-Fail Initial Sync)
      final isOnline = await tahsinRepository.networkInfo.isConnected;
      if (!isOnline) {
        final cacheCount = IsarDb.instance.progressSantriModels.countSync();
        if (cacheCount > 0) {
          emit(const InitialSyncSuccess("Berjalan dalam mode offline (Bypass Offline)"));
          return;
        } else {
          throw Exception("Anda sedang offline dan belum ada data lokal. Silakan online untuk memuat data awal.");
        }
      }

      // 1. Menyiapkan sesi
      emit(const InitialSyncInProgress(0.1, "Menyiapkan sesi..."));
      await Future.delayed(const Duration(milliseconds: 500)); // Simulasi jeda animasi

      // 2. Data Santri
      emit(const InitialSyncInProgress(0.4, "Mengunduh data santri..."));
      await santriRepository.getSantriList(
        idKelompok: activeKelompokId,
        idKelas: null, // Ambil semua kelas
        forceRefresh: true,
      );

      // 3. Progress Belajar
      emit(const InitialSyncInProgress(0.7, "Menyinkronkan progres terakhir..."));
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      if (activeKelompokId == 3) {
        // PRA TAHFIDZ
        import_pra_tahfidz.PraTahfidzRepository(
          networkInfo: tahsinRepository.networkInfo,
        ).getSantriList(
          idKelompok: activeKelompokId,
          tanggal: today,
          forceRefresh: true,
        ).catchError((_) => <String, dynamic>{}); // ignore error if any so sync can continue
      } else {
        // TAHSIN & LAINNYA
        await tahsinRepository.getProgressList(
          idKelompok: activeKelompokId,
          idKelas: null, // Ambil semua kelas
          tanggal: today,
          forceRefresh: true,
        );
      }

      // 4. Hari Libur
      emit(const InitialSyncInProgress(0.9, "Memfinalisasi data..."));
      final currentYear = DateTime.now().year;
      await hariLiburRepository.getHariLibur(
        tahun: currentYear,
        idKelompok: activeKelompokId,
      );

      // 5. Selesai
      emit(const InitialSyncInProgress(1.0, "Selesai!"));
      await Future.delayed(const Duration(seconds: 1)); // Jeda 1 detik sesuai spesifikasi
      
      emit(const InitialSyncSuccess("Sinkronisasi berhasil"));
    } catch (e) {
      try {
        final cacheCount = await IsarDb.instance.genericCaches.count();
        if (cacheCount > 0) {
          emit(const InitialSyncSuccess("Berjalan dalam mode offline (Data lokal tersedia)"));
          return;
        }
      } catch (_) {}
      emit(InitialSyncFailure(e.toString()));
    }
  }
}
