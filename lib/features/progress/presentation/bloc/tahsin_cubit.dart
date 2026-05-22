import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/progress/domain/repositories/tahsin_repository.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';

abstract class TahsinState {}

class TahsinInitial extends TahsinState {}

class TahsinLoading extends TahsinState {}

class TahsinLoaded extends TahsinState {
  final Map<String, dynamic> data;
  final bool isOfflineWarning;
  TahsinLoaded(this.data, {this.isOfflineWarning = false});
}

class TahsinError extends TahsinState {
  final String message;
  TahsinError(this.message);
}

class TahsinCubit extends Cubit<TahsinState> with WidgetsBindingObserver {
  final TahsinRepository repository;
  final ActiveKelompokCubit activeKelompokCubit;
  late final StreamSubscription _kelompokSubscription;
  
  // Track parameters for auto re-fetch
  int? _lastIdKelompok;
  int? _lastIdKelas;
  String? _lastTanggal;
  String? _lastFilterKehadiran;
  int? _lastSesi;

  int? get lastIdKelompok => _lastIdKelompok;
  int? get lastIdKelas => _lastIdKelas;
  String? get lastTanggal => _lastTanggal;

  TahsinCubit({
    required this.repository,
    required this.activeKelompokCubit,
  }) : super(TahsinInitial()) {
    WidgetsBinding.instance.addObserver(this);
    // Listen to Kelompok changes (Multi-Tenancy)
    _kelompokSubscription = activeKelompokCubit.stream.listen((kelompokState) {
      if (kelompokState.activeId > 0 && _lastIdKelompok != null) {
        // Trigger re-fetch otomatis dengan filter yang sama
        fetchProgressList(
          idKelompok: kelompokState.activeId, 
          idKelas: _lastIdKelas, 
          tanggal: _lastTanggal,
          filterKehadiran: _lastFilterKehadiran,
          sesi: _lastSesi,
          forceRefresh: true
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_lastIdKelompok != null) {
        fetchProgressList(
          idKelompok: _lastIdKelompok, 
          idKelas: _lastIdKelas, 
          tanggal: _lastTanggal,
          filterKehadiran: _lastFilterKehadiran,
          sesi: _lastSesi,
          forceRefresh: true
        );
      }
    }
  }

  Future<void> fetchProgressList({int? idKelompok, int? idKelas, String? tanggal, String? filterKehadiran, int? sesi, bool forceRefresh = false}) async {
    _lastIdKelompok = idKelompok;
    _lastIdKelas = idKelas;
    _lastTanggal = tanggal;
    _lastFilterKehadiran = filterKehadiran;
    _lastSesi = sesi;

    // Hanya tampilkan loading spinner saat pertama kali atau pull-to-refresh
    // (bukan saat background refresh setelah balik dari detail)
    final isFirstLoad = state is TahsinInitial;
    if (forceRefresh || isFirstLoad) {
      emit(TahsinLoading());
    }

    // Cek jaringan sebelum force refresh
    if (forceRefresh) {
      // Jika indikator saat ini offline, langsung skip ping agar refresh instan dari lokal
      if (LocalNetworkChecker().currentStatus == LocalNetworkStatus.offline) {
        forceRefresh = false;
      } else {
        // Jika indikator online, pastikan dengan ping (meski bisa ada delay 2 detik jika tiba-tiba putus)
        final isOnline = await repository.networkInfo.isConnected;
        if (!isOnline) {
          forceRefresh = false; // Batal hit API, cukup In-Memory Merge
        }
      }
    }

    try {
      if (!forceRefresh) {
        // 1. Emit Cache First
        try {
          final localData = await repository.getProgressList(
              idKelompok: idKelompok, idKelas: idKelas, tanggal: tanggal, filterKehadiran: filterKehadiran, sesi: sesi, forceRefresh: false);
          if (!isClosed) {
            final isOffline = localData['is_offline_fallback'] == true && LocalNetworkChecker().currentStatus == LocalNetworkStatus.offline;
            emit(TahsinLoaded(localData, isOfflineWarning: isOffline));
          }
        } catch (e) {
          // Cache mungkin kosong, biarkan lanjut ke fetch API
        }

        // 2. Fetch API in Background
        if (await repository.networkInfo.isConnected) {
          final freshData = await repository.getProgressList(
              idKelompok: idKelompok, idKelas: idKelas, tanggal: tanggal, filterKehadiran: filterKehadiran, sesi: sesi, forceRefresh: true);
          if (!isClosed) {
            emit(TahsinLoaded(freshData, isOfflineWarning: false));
          }
        }
      } else {
        // Force Refresh Flow (Manual Pull)
        final data = await repository.getProgressList(
            idKelompok: idKelompok, idKelas: idKelas, tanggal: tanggal, filterKehadiran: filterKehadiran, sesi: sesi, forceRefresh: true);
        if (!isClosed) {
          final isOffline = data['is_offline_fallback'] == true;
          emit(TahsinLoaded(data, isOfflineWarning: isOffline));
        }
      }
    } catch (e) {
      if (!isClosed) {
        if (e.toString().contains('401')) {
          emit(TahsinError('Sesi Anda telah habis (401). Silakan login kembali.'));
        } else {
          // Lakukan penyelamatan jika state belum loaded
          if (state is! TahsinLoaded) {
            try {
              final localFallback = await repository.getProgressList(
                  idKelompok: idKelompok, idKelas: idKelas, tanggal: tanggal, filterKehadiran: filterKehadiran, sesi: sesi, forceRefresh: false);
              emit(TahsinLoaded(localFallback, isOfflineWarning: true));
            } catch (_) {
              // Abaikan jika tidak ada data lokal
            }
          }
          // Selalu tampilkan error agar muncul di UI/Snackbar
          emit(TahsinError(e.toString().replaceAll('Exception: ', '')));
        }
      }
    }
  }

  /// Reset state ke Initial agar fetchProgressList berikutnya tampilkan loading spinner
  void resetToInitial() {
    emit(TahsinInitial());
  }

  Future<bool> submitInputMassal(Map<String, dynamic> payload) async {
    // Optimistic UI: tidak reload penuh setelah submit,
    // karena progress_input_screen sudah menggeser halAwal dan mereset form secara lokal.
    // Reload penuh hanya terjadi saat user keluar & kembali, atau pull-to-refresh manual.
    final result = await repository.inputMassalProgress(payload);
    return result;
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _kelompokSubscription.cancel();
    return super.close();
  }
}
