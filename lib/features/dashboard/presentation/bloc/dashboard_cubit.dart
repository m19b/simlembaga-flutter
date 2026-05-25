import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/dashboard/data/models/dashboard_model.dart';
import 'package:manajemen_tahsin_app/features/dashboard/domain/repositories/dashboard_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardModel data;
  final bool isRefreshing;

  /// Daftar kategori yang tersedia dari master data (ekstrak dinamis).
  final List<Map<String, dynamic>> availableKategori;

  /// Daftar kelas yang tersedia, sudah terfilter oleh kategori aktif.
  final List<Map<String, dynamic>> availableKelas;

  /// Kelas yang sedang dipilih; null = "Semua Kelas".
  final Map<String, dynamic>? selectedKelas;

  DashboardLoaded(
    this.data, {
    this.isRefreshing = false,
    this.availableKategori = const [],
    this.availableKelas = const [],
    this.selectedKelas,
  });
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repository;
  final ActiveKelompokCubit activeKelompokCubit;
  late final StreamSubscription _kelompokSubscription;

  /// Filter Level-1: Kategori yang sedang aktif (null = Semua Modul).
  int? activeKategori;

  /// Filter Level-2: Kelas yang sedang aktif (null = Semua Kelas).
  Map<String, dynamic>? activeKelas;

  DashboardModel? _masterData;

  DashboardCubit({
    required this.repository,
    required this.activeKelompokCubit,
  }) : super(DashboardInitial()) {
    _kelompokSubscription = activeKelompokCubit.stream.listen((kelompokState) {
      if (kelompokState.activeId > 0) {
        fetchDashboard(forceRefresh: true);
      }
    });
  }

  // ─── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetchDashboard({bool forceRefresh = false}) async {
    if (state is DashboardLoading && !forceRefresh) return;

    final localData = await repository.getLocalData(null);
    if (localData != null) {
      _masterData = localData;
      
      // [AUTO-SET KELOMPOK SAAT LOKAL]
      // Jika activeId masih 0, otomatis set ke idKelompok dari data lokal
      if (activeKelompokCubit.state.activeId <= 0 && localData.idKelompok > 0) {
        activeKelompokCubit.changeKelompok(localData.idKelompok);
      }
      
      _applyFilters(isRefreshing: true);
    } else {
      emit(DashboardLoading());
    }

    try {
      final freshData = await repository.fetchFreshData(null);
      _masterData = freshData;

      // [AUTO-SET KELOMPOK SAAT LOGIN/APP START]
      // Jika activeId masih 0 (baru login), otomatis set ke idKelompok dari response Dashboard
      if (activeKelompokCubit.state.activeId <= 0 && freshData.idKelompok > 0) {
        activeKelompokCubit.changeKelompok(freshData.idKelompok);
      }

      _applyFilters(isRefreshing: false);
    } catch (e) {
      if (_masterData == null) {
        emit(DashboardError(e.toString().replaceAll('Exception: ', '')));
      } else {
        _applyFilters(isRefreshing: false);
      }
    }
  }

  // ─── Public Setters (dari UI Dropdown) ─────────────────────────────────────

  /// Dipanggil saat Dropdown Kategori berubah.
  /// WAJIB reset `activeKelas` ke null (Cascading Reset).
  void setKategori(int? idKategori) {
    if (activeKategori == idKategori) return;
    activeKategori = idKategori;
    activeKelas = null; // ← Cascading Reset: kelas direset otomatis
    if (_masterData != null) {
      _applyFilters();
    } else {
      fetchDashboard();
    }
  }

  /// Dipanggil saat Dropdown Kelas berubah.
  void setKelas(Map<String, dynamic>? kelas) {
    activeKelas = kelas;
    if (_masterData != null) {
      _applyFilters();
    }
  }

  // ─── Core Filter Engine ────────────────────────────────────────────────────

  /// Entry-point tunggal untuk seluruh proses filter offline.
  void _applyFilters({bool isRefreshing = false}) {
    if (_masterData == null) return;

    final availableKategori = _extractKategoriDinamis();
    final availableKelas = _extractKelasDinamis(activeKategori);

    // Validasi: jika kelas aktif tidak ada di daftar kelas baru, reset
    final selectedKelas = _validateSelectedKelas(activeKelas, availableKelas);
    activeKelas = selectedKelas; // sinkronkan state internal

    // Step-1: filter by Kategori
    final afterKategori = _filterByKategori(_masterData!, activeKategori);

    // Step-2: filter by Kelas (jika dipilih)
    final filteredSantri = selectedKelas == null
        ? afterKategori.santriList
        : afterKategori.santriList
            .where((s) => _matchesKelas(s, selectedKelas))
            .toList();

    final filteredUrgent = selectedKelas == null
        ? afterKategori.urgentList
        : afterKategori.urgentList
            .where((u) => _matchesKelas(u, selectedKelas))
            .toList();

    final filteredJadwalGuru = selectedKelas == null
        ? afterKategori.jadwalGuru
        : afterKategori.jadwalGuru
            .where((j) => _matchesKelas(j, selectedKelas))
            .toList();

    final filteredJadwalKelas = selectedKelas == null
        ? afterKategori.jadwalKelas
        : afterKategori.jadwalKelas
            .where((j) => _matchesKelas(j, selectedKelas))
            .toList();

    final filteredDaftarTes = selectedKelas == null
        ? afterKategori.daftarTes
        : afterKategori.daftarTes
            .where((t) => _matchesKelas(t, selectedKelas))
            .toList();

    final filteredAktivitas = afterKategori.aktivitas7Hari; // tidak perlu filter kelas
    final filteredInputTerbaru = selectedKelas == null
        ? afterKategori.inputTerbaru
        : afterKategori.inputTerbaru
            .where((i) => _matchesKelas(i, selectedKelas))
            .toList();

    // Step-3: Agregasi client-side
    final newSummary = _computeSummary(filteredSantri, filteredUrgent);

    final filteredData = DashboardModel(
      guruName: _masterData!.guruName,
      role: _masterData!.role,
      nig: _masterData!.nig,
      idKelompok: _masterData!.idKelompok,
      namaKelompok: _masterData!.namaKelompok,
      namaKelas: selectedKelas != null
          ? (selectedKelas['tingkat']?.toString() ?? 'Kelas')
          : _masterData!.namaKelas,
      summary: newSummary,
      chartKecepatan: _masterData!.chartKecepatan,
      urgentList: filteredUrgent,
      jadwalGuru: filteredJadwalGuru,
      jadwalKelas: filteredJadwalKelas,
      aktivitas7Hari: filteredAktivitas,
      inputTerbaru: filteredInputTerbaru,
      daftarTes: filteredDaftarTes,
      santriList: filteredSantri,
    );

    emit(DashboardLoaded(
      filteredData,
      isRefreshing: isRefreshing,
      availableKategori: availableKategori,
      availableKelas: availableKelas,
      selectedKelas: selectedKelas,
    ));
  }

  // ─── Legacy public method (dipertahankan untuk kompatibilitas) ─────────────
  void filterDashboardLokal(int? idKategori, {bool isRefreshing = false}) {
    activeKategori = idKategori;
    _applyFilters(isRefreshing: isRefreshing);
  }

  // ─── Filter Helpers ────────────────────────────────────────────────────────

  /// Filter `DashboardModel` hanya berdasarkan kategori (Level-1).
  DashboardModel _filterByKategori(DashboardModel master, int? idKategori) {
    if (idKategori == null) return master;

    return DashboardModel(
      guruName: master.guruName,
      role: master.role,
      nig: master.nig,
      idKelompok: master.idKelompok,
      namaKelompok: master.namaKelompok,
      namaKelas: master.namaKelas,
      summary: master.summary,
      chartKecepatan: master.chartKecepatan,
      urgentList: master.urgentList
          .where((u) => _matchesKategori(u, idKategori))
          .toList(),
      jadwalGuru: master.jadwalGuru
          .where((j) => _matchesKategori(j, idKategori))
          .toList(),
      jadwalKelas: master.jadwalKelas
          .where((j) => _matchesKategori(j, idKategori))
          .toList(),
      aktivitas7Hari: master.aktivitas7Hari
          .where((a) => _matchesKategori(a, idKategori))
          .toList(),
      inputTerbaru: master.inputTerbaru
          .where((i) => _matchesKategori(i, idKategori))
          .toList(),
      daftarTes: master.daftarTes
          .where((t) => _matchesKategori(t, idKategori))
          .toList(),
      santriList: master.santriList
          .where((s) => _matchesKategori(s, idKategori))
          .toList(),
    );
  }

  bool _matchesKategori(dynamic item, int? idKategori) {
    if (idKategori == null) return true;
    if (item is Map) {
      final itemKat = item['id_kategori']?.toString() ??
          (item['kelas'] is Map ? item['kelas']['id_kategori']?.toString() : null);
      return itemKat == idKategori.toString();
    }
    return true;
  }

  bool _matchesKelas(dynamic item, Map<String, dynamic> kelas) {
    if (item is! Map) return true;
    final idKelas = kelas['id_kelas']?.toString();
    if (idKelas == null) return true;
    // Cocokkan via id_kelas pada item, atau via tingkat sebagai fallback
    final itemIdKelas = item['id_kelas']?.toString();
    if (itemIdKelas != null) return itemIdKelas == idKelas;
    // Fallback: cocokkan tingkat
    final tingkat = kelas['tingkat']?.toString();
    return item['tingkat']?.toString() == tingkat;
  }

  // ─── Ekstraksi Dinamis ─────────────────────────────────────────────────────

  List<Map<String, dynamic>> _extractKategoriDinamis() {
    if (_masterData == null) return [{'id': null, 'nama': 'Semua Modul'}];

    final Set<int> uniqueIds = {};
    final List<Map<String, dynamic>> listKategori = [
      {'id': null, 'nama': 'Semua Modul'}
    ];

    void process(dynamic item) {
      if (item is Map) {
        final idKatStr = item['id_kategori']?.toString() ??
            (item['kelas'] is Map ? item['kelas']['id_kategori']?.toString() : null);
        if (idKatStr != null) {
          final idKat = int.tryParse(idKatStr);
          if (idKat != null && !uniqueIds.contains(idKat)) {
            uniqueIds.add(idKat);
            String nama = 'Kategori $idKat';
            if (idKat == 1) nama = '📚 Tahsin';
            if (idKat == 2) nama = '📖 Tahfidz';
            if (idKat == 3) nama = '🌱 Pra Tahfidz';
            listKategori.add({'id': idKat, 'nama': nama});
          }
        }
      }
    }

    for (var s in _masterData!.santriList) {
      process(s);
    }
    for (var jk in _masterData!.jadwalKelas) {
      process(jk);
    }

    return listKategori;
  }

  /// Ekstrak daftar kelas unik dari master data, difilter oleh kategori aktif.
  List<Map<String, dynamic>> _extractKelasDinamis(int? idKategori) {
    if (_masterData == null) return [];

    final Map<String, Map<String, dynamic>> uniqueKelas = {};

    void processItem(dynamic item) {
      if (item is! Map) return;
      // Filter kategori dulu (jika dipilih)
      if (idKategori != null) {
        final itemKat = item['id_kategori']?.toString() ??
            (item['kelas'] is Map ? item['kelas']['id_kategori']?.toString() : null);
        if (itemKat != idKategori.toString()) return;
      }
      final idKelas = item['id_kelas']?.toString();
      final tingkat = item['tingkat']?.toString();
      if (idKelas != null && tingkat != null && !uniqueKelas.containsKey(idKelas)) {
        uniqueKelas[idKelas] = {
          'id_kelas': idKelas,
          'tingkat': tingkat,
          'id_kategori': item['id_kategori']?.toString(),
        };
      }
    }

    for (var s in _masterData!.santriList) {
      processItem(s);
    }
    for (var jk in _masterData!.jadwalKelas) {
      processItem(jk);
    }

    // Urutkan berdasarkan tingkat (nama kelas)
    final sorted = uniqueKelas.values.toList()
      ..sort((a, b) => (a['tingkat'] ?? '').compareTo(b['tingkat'] ?? ''));

    return sorted;
  }

  /// Pastikan kelas aktif masih ada di daftar kelas terbaru, jika tidak → null.
  Map<String, dynamic>? _validateSelectedKelas(
    Map<String, dynamic>? current,
    List<Map<String, dynamic>> availableKelas,
  ) {
    if (current == null) return null;
    final idKelas = current['id_kelas']?.toString();
    final stillExists = availableKelas.any((k) => k['id_kelas']?.toString() == idKelas);
    return stillExists ? current : null;
  }

  // ─── Agregasi ──────────────────────────────────────────────────────────────

  DashboardSummary _computeSummary(
    List<dynamic> santriList,
    List<dynamic> urgentList,
  ) {
    final int totalSantri = santriList.length;
    final int hadir = santriList.where((s) {
      final idKehadiran = s['id_kehadiran']?.toString();
      return idKehadiran != null && idKehadiran != '0';
    }).length;
    final int perluPerhatian = urgentList.length;
    final int siapTest = santriList.where((s) {
      return s['harus_tes']?.toString() == '1';
    }).length;
    final int sudahInput = santriList.where((s) {
      final inp = int.tryParse(s['input_hari_ini']?.toString() ?? '0') ?? 0;
      return inp > 0;
    }).length;
    final int belumDiinput = totalSantri - sudahInput;
    final int tidakDisimak = santriList.where((s) {
      return s['disimak']?.toString() == '0';
    }).length;

    return DashboardSummary(
      totalSantri: totalSantri,
      hadir: hadir,
      perluPerhatian: perluPerhatian,
      siapTest: siapTest,
      sudahInput: sudahInput,
      belumDiinput: belumDiinput,
      tidakDisimak: tidakDisimak,
    );
  }

  @override
  Future<void> close() {
    _kelompokSubscription.cancel();
    return super.close();
  }
}
