import 'widgets/row_state_model.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/bloc/tahsin_cubit.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'widgets/evaluasi_santri_card.dart';
import 'package:manajemen_tahsin_app/shared/widgets/custom_date_field.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/kelas_model.dart';

// --- Design Tokens (Islamic Emerald) ---------------------------------------------
const Color _kHeader = Color(0xFF047857); // Emerald 700
const Color _kText2 = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF10B981); // Emerald 500

// --- Data Model per baris evaluasi --------------------------------------------
class ProgressInputScreen extends StatefulWidget {
  const ProgressInputScreen({super.key});

  @override
  State<ProgressInputScreen> createState() => ProgressInputScreenState();
}

// Sort modes
enum _SortMode { urut, halaman, abjad }

class ProgressInputScreenState extends State<ProgressInputScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<RowStateModel> _rows = [];
  List<Map<String, dynamic>> _catatanMaster = [];
  List<Map<String, dynamic>> _kelompokList = [];
  List<Map<String, dynamic>> _metodeList = [];
  final Map<int, Map<String, dynamic>> _kelasSettings = {};
  int? _selectedKelompokId;
  int? _globalMetodeId;
  bool _showMetode = false;
  bool _showPeraga = false;
  bool _globalGunakanPeraga = false;
  final TextEditingController _globalHalamanPeragaCtrl =
      TextEditingController();
  final TextEditingController _globalKeteranganPeragaCtrl =
      TextEditingController();
  bool _loading = true;

  String _error = '';
  DateTime _tanggal = DateTime.now();
  _SortMode _sortMode = _SortMode.urut;
  bool _isDecimalMode = false;

  Map<String, dynamic>? _jadwalInfo; // hari & sesi dari t_jadwal_kelas
  List<Map<String, dynamic>> _jadwalListAll = []; // Cache semua jadwal dari backend
  List<Map<String, dynamic>> _jadwalList = [];
  int? _selectedSesi;
  String _selectedTingkat = 'Semua';
  String _selectedStatusAbsen = 'semua'; // Filter kelas/tingkat

  // Label hari dan sesi
  static const _hariLabel = {
    1: 'Sen',
    2: 'Sel',
    3: 'Rab',
    4: 'Kam',
    5: 'Jum',
    6: 'Sab',
    7: 'Min',
  };
  static const _sesiLabel = {1: 'Pagi', 2: 'Siang', 3: 'Sore', 4: 'Malam'};

  List<String> get _tingkatOptions {
    final t = _rows
        .map((r) => r.santri['tingkat']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    t.sort();
    return ['Semua', ...t];
  }

  @override
  void initState() {
    super.initState();
    // 1. Amankan variabel filter kritis sebelum memicu load apapun
    _tanggal = DateTime.now();
    _selectedKelompokId = ActiveKelompokCubit.activeKelompokId;
    
    // Jika belum ada nilai di static variable, ambil dari cubit secara langsung
    if (_selectedKelompokId == 0 || _selectedKelompokId == null) {
      final activeState = context.read<ActiveKelompokCubit>().state;
      if (activeState.activeId > 0) {
        _selectedKelompokId = activeState.activeId;
      } else if (activeState.allowedKelompok.isNotEmpty) {
        _selectedKelompokId = int.tryParse(activeState.allowedKelompok.first['id_kelompok']?.toString() ?? '0');
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<TahsinCubit>();
      final currentState = cubit.state;
      
      if (currentState is TahsinLoaded) {
        setState(() {
          _loading = false;
          _error = '';
        });
        _mapDataToRows(currentState.data);
        
        // Pengecekan sinkronisasi filter dengan cache state
        if (cubit.lastIdKelompok != _selectedKelompokId || 
            cubit.lastTanggal != DateFormat('yyyy-MM-dd').format(_tanggal)) {
          _loadSantri();
        }
      } else {
        // Belum ada data sama sekali, fetch baru karena filter _selectedKelompokId sudah valid
        _loadSantri();
      }
    });
  }

  @override
  void dispose() {
    for (var r in _rows) { r.dispose(); }
    _globalHalamanPeragaCtrl.dispose();
    _globalKeteranganPeragaCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSantri({bool forceRefresh = false}) async {
    final tgl = DateFormat('yyyy-MM-dd').format(_tanggal);
    if (_selectedKelompokId == null) return;
    

    
    await context.read<TahsinCubit>().fetchProgressList(
      idKelompok: _selectedKelompokId!,
      idKelas: null,
      forceRefresh: forceRefresh,
      tanggal: tgl,
      filterKehadiran: _selectedStatusAbsen,
      sesi: _selectedSesi,
    );
  }

  void setTanggal(DateTime date) {
    if (date != _tanggal) {
      int newDay = date.weekday; // 1 = Senin, ..., 7 = Minggu
      List<Map<String, dynamic>> filtered = _jadwalListAll.where((j) => j['hari'] == newDay).toList();
      int? newSesi;
      Map<String, dynamic>? newInfo;
      if (filtered.isNotEmpty) {
        newInfo = filtered.first;
        newSesi = newInfo['sesi'];
      }
      setState(() {
        _tanggal = date;
        _jadwalList = filtered;
        _jadwalInfo = newInfo;
        _selectedSesi = newSesi;
      });
      _loadSantri();
    }
  }

  void _mapDataToRows(dynamic raw) {
    if (!mounted) return;
    List<Map<String, dynamic>> list = [];
    try {
      if (raw is Map) {
        // Kelompok list (auto-select first like CI4 frontend)
        if (_kelompokList.isEmpty) {
          final fm = raw['filter_meta'];
          if (fm is Map) {
            final kl = fm['kelompok_list'];
            if (kl is List) {
              _kelompokList = kl.whereType<Map>().map((e) {
                final Map<String, dynamic> m = {};
                e.forEach((k, v) => m[k.toString()] = v);
                return m;
              }).toList();
              // Auto-select first kelompok tanpa reload (backend sudah kembalikan
              // data untuk kelompok pertama sebagai default)
              if (_selectedKelompokId == null && _kelompokList.isNotEmpty) {
                _selectedKelompokId = int.tryParse(
                  _kelompokList.first['id_kelompok']?.toString() ?? '0',
                );
              }
            }
          }
        }
        // Metode list
        final rawMetode = raw['metode_list'];
        if (rawMetode is List) {
          _metodeList = rawMetode.whereType<Map>().map((e) {
            final Map<String, dynamic> m = {};
            e.forEach((k, v) => m[k.toString()] = v);
            return m;
          }).toList();
        }
        // Kelas settings map
        final rawKs = raw['kelas_settings'];
        if (rawKs is Map) {
          rawKs.forEach((k, v) {
            final id = int.tryParse(k.toString()) ?? 0;
            if (v is Map) {
              final Map<String, dynamic> m = {};
              v.forEach((vk, vv) => m[vk.toString()] = vv);
              _kelasSettings[id] = m;
            }
          });
        }
        // Compute global show flags
        _showMetode = _kelasSettings.values.any(
          (s) =>
              (int.tryParse(s['is_metode_belajar']?.toString() ?? '0') ?? 0) ==
              1,
        );
        _showPeraga = _kelasSettings.values.any(
          (s) => (int.tryParse(s['is_peraga']?.toString() ?? '0') ?? 0) == 1,
        );
        // Set default metode from first kelas that has it
        if (_showMetode && _globalMetodeId == null) {
          final ks = _kelasSettings.values.firstWhere(
            (s) =>
                (int.tryParse(s['is_metode_belajar']?.toString() ?? '0') ??
                    0) ==
                1,
            orElse: () => {},
          );
          final defMetode =
              int.tryParse(ks['default_id_metode']?.toString() ?? '0') ?? 0;
          if (defMetode > 0) _globalMetodeId = defMetode;
        }

        final rawJadwalList = raw['jadwal_list'];
        if (rawJadwalList is List) {
          _jadwalListAll = rawJadwalList.map((e) {
            final map = <String, dynamic>{};
            if (e is Map) {
              e.forEach((k, v) => map[k.toString()] = v);
            }
            return map;
          }).toList();
          
          // Re-filter the loaded list based on the current _tanggal
          int currentDay = _tanggal.weekday;
          _jadwalList = _jadwalListAll.where((j) => j['hari'] == currentDay).toList();
        }

        final rawJadwal = raw['jadwal_info'];
        if (rawJadwal is Map && rawJadwal.isNotEmpty) {
          _jadwalInfo = {};
          rawJadwal.forEach((k, v) => _jadwalInfo![k.toString()] = v);
          _selectedSesi = int.tryParse(_jadwalInfo!['sesi']?.toString() ?? '');
        } else {
          _jadwalInfo = null;
        }

        // Validasi _jadwalInfo terhadap _jadwalList yang sudah di filter
        if (_jadwalList.isNotEmpty) {
          bool isValid = _jadwalList.any((j) => j['sesi'] == _selectedSesi);
          if (!isValid) {
            _jadwalInfo = _jadwalList.first;
            _selectedSesi = _jadwalInfo!['sesi'];
          }
        } else {
          _jadwalInfo = null;
          _selectedSesi = null;
        }

        final rawList = raw['santri_list'];
        if (rawList is List && rawList.isNotEmpty) {
          list = rawList.whereType<Map>().map((e) {
            final Map<String, dynamic> m = {};
            e.forEach((k, v) => m[k.toString()] = v);
            return m;
          }).toList();
        }
        final rawCatatan = raw['catatan_master'];
        if (rawCatatan is List) {
          _catatanMaster = rawCatatan.whereType<Map>().map((e) {
            final Map<String, dynamic> m = {};
            e.forEach((k, v) => m[k.toString()] = v);
            return m;
          }).toList();
        }
      } else if (raw is List) {
        list = raw.whereType<Map>().map((e) {
          final Map<String, dynamic> m = {};
          e.forEach((k, v) => m[k.toString()] = v);
          return m;
        }).toList();
      }

      final rows = <RowStateModel>[];
      for (final s in list) {
        final capaiHal =
            double.tryParse(s['capai_hal']?.toString() ?? '0') ?? 0;
        final totalHal =
            double.tryParse(s['total_hal']?.toString() ?? '0') ?? 0;
        final latSek = double.tryParse(s['lat_sek']?.toString() ?? '0') ?? 0;
        final capaiAks =
            double.tryParse(
              (s['capai_aks'] ?? s['capaiAks'])?.toString() ?? '0',
            ) ??
            0;
        final jmlTes = int.tryParse(s['jml_tes']?.toString() ?? '0') ?? 0;

        final nextCP = s['nextCheckpoint'];
        final cpTarget = nextCP != null
            ? (double.tryParse(nextCP['halaman_target']?.toString() ?? '0') ??
                  0)
            : 0.0;
        final isAtCheckpoint = cpTarget > 0 && capaiHal >= cpTarget;
        final isLatihan =
            (isAtCheckpoint || capaiHal >= totalHal) && totalHal > 0;

        String modeBelajar;
        double halAwal;
        final String lastMode = s['last_mode']?.toString() ?? '';
        final String lastStatus = s['last_status']?.toString() ?? '';
        final double lastHalAkhir =
            double.tryParse(s['last_hal_akhir']?.toString() ?? '0') ?? 0;

        // Deteksi akselerasi: jmlTes > 0 (gagal tes) ATAU capai_aks > 0 ATAU last mode = akselerasi
        final bool isAkselerasi =
            jmlTes > 0 || capaiAks > 0 || lastMode == 'akselerasi';

        if (isAkselerasi) {
          modeBelajar = 'akselerasi';
          if (lastMode == 'akselerasi' && lastHalAkhir > 0) {
            halAwal = lastStatus.toLowerCase() == 'lulus'
                ? lastHalAkhir
                : (lastHalAkhir -
                      (double.tryParse(
                            s['last_hal_total']?.toString() ?? '0',
                          ) ??
                          0));
          } else {
            halAwal = capaiAks;
          }
        } else if (isLatihan) {
          modeBelajar = 'latihan';
          if (lastMode == 'latihan' && lastHalAkhir > 0) {
            halAwal = lastStatus.toLowerCase() == 'lulus'
                ? lastHalAkhir
                : (lastHalAkhir -
                      (double.tryParse(
                            s['last_hal_total']?.toString() ?? '0',
                          ) ??
                          0));
          } else {
            halAwal = latSek;
          }
        } else {
          modeBelajar = 'reguler';
          if (lastMode == 'reguler' && lastHalAkhir > 0) {
            halAwal = lastStatus.toLowerCase() == 'lulus'
                ? lastHalAkhir
                : (lastHalAkhir -
                      (double.tryParse(
                            s['last_hal_total']?.toString() ?? '0',
                          ) ??
                          0));
          } else {
            halAwal = capaiHal;
          }
        }

        final row = RowStateModel(
          santri: s,
          halAwal: halAwal,
          jmlTes: jmlTes,
          modeBelajar: modeBelajar,
          nextCheckpoint: nextCP is Map
              ? Map<String, dynamic>.from(nextCP)
              : null,
        );
        rows.add(row);
      }

      // Sort rows so that locked rows go to the bottom
      rows.sort((a, b) {
        final aLocked = a.halTotal == 0.0 ? 1 : 0;
        final bLocked = b.halTotal == 0.0 ? 1 : 0;
        return aLocked.compareTo(bLocked);
      });

      setState(() {
        _rows = rows;
      });
    } catch (e, stackTrace) {
      debugPrint("ProgressInputScreen _mapDataToRows Error: $e\n$stackTrace");
    }
  }

  Future<void> simpan() async {
    // Hanya ambil data dari baris yang sedang ditampilkan (filter aktif)
    final aktif = _sortedRows.where((r) => r.halTotal > 0).toList();
    if (aktif.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak ada data yang valid untuk disimpan. Pastikan ada progres > 0',
          ),
        ),
      );
      return;
    }

    // 1. VALIDASI CHECKPOINT DINAMIS VIA ISAR
    final messenger = ScaffoldMessenger.of(context);
    final repository = context.read<TahsinCubit>().repository;

    for (var r in aktif) {
      final halAkhir = r.halAwal + r.halTotal;
      final totalHal = double.tryParse(r.santri['total_hal']?.toString() ?? '0') ?? 0;
      final mode = r.modeBelajar;
      
      if (mode == 'akselerasi') {
        if (totalHal > 0 && halAkhir > totalHal) {
          messenger.showSnackBar(SnackBar(content: Text('Halaman akhir Akselerasi melebihi batas akhir buku ($totalHal).')));
          return;
        }
      } else {
        // Ambil ID Kelas Santri
        final idKelasSantri = int.tryParse(r.santri['id_kelas']?.toString() ?? '0') ?? 0;
        
        // Ambil Data KelasModel dari Isar
        final kelasLokal = await IsarDb.instance.kelasModels.get(idKelasSantri);
        if (!mounted) return;
        final checkpoints = kelasLokal?.checkpoints ?? [];
        
        // Cari Checkpoint terdekat yang halaman_target >= r.halAwal
        CheckpointLokal? activeCheckpoint;
        for (var cp in checkpoints) {
          if (cp.halamanTarget != null && cp.halamanTarget! >= r.halAwal) {
            activeCheckpoint = cp;
            break;
          }
        }

        final cpTarget = activeCheckpoint?.halamanTarget ?? 0.0;
        final harusTes = activeCheckpoint?.harusTes ?? 0;
        
        final isFinishedReg = (totalHal > 0 && r.halAwal >= totalHal);
        final currentLimit = isFinishedReg ? totalHal : (cpTarget > 0 ? cpTarget : totalHal);
        
        if (currentLimit > 0 && halAkhir > currentLimit) {
          if (isFinishedReg) {
            messenger.showSnackBar(SnackBar(content: Text('Halaman akhir ($halAkhir) melebihi batas akhir buku ($currentLimit).')));
            return;
          } else if (harusTes == 1) {
            // Blokir proses penyimpanan
            await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    const Text('Tertahan Checkpoint', style: TextStyle(color: Colors.red)),
                  ],
                ),
                content: Text(
                  'Santri (NIS: ${r.santri['nis']}) telah mencapai batas halaman ($currentLimit). Wajib menyelesaikan Tes Kenaikan / Ujian sebelum melanjutkan input evaluasi selanjutnya.'
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx), 
                    child: const Text('Mengerti')
                  ),
                ],
              ),
            );
            return;
          } else {
             messenger.showSnackBar(SnackBar(content: Text('Halaman akhir ($halAkhir) melebihi target ($currentLimit).')));
             return;
          }
        }
      }
    }

    // 2. VALIDASI "SIMPAN KE-N" VIA ISAR
    final tglStr = DateFormat('yyyy-MM-dd').format(_tanggal);
    final nisList = aktif.map((r) => r.santri['nis']?.toString() ?? '').toList();
    final countIsar = await repository.checkExistingProgressCount(nisList, tglStr, _selectedSesi);

    if (!mounted) return;

    bool hasProgressToday = countIsar > 0;
    
    if (countIsar == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Penyimpanan'),
          content: const Text('Pastikan data halaman dan status yang Anda masukkan sudah benar. Lanjutkan menyimpan?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kHeader),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Lanjutkan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    } else {
      final ke = countIsar + 1;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              const Text('Konfirmasi Input Ganda'),
            ],
          ),
          content: const Text('Terdapat input pada tanggal yang sama. Anda yakin menyimpan inputan ini?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kHeader),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Ya, Simpan ke-$ke', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    try {
      final payload = <String, dynamic>{
        'tanggal': DateFormat('yyyy-MM-dd').format(_tanggal),
        'evaluasi': aktif.map((r) => r.toPayload()).toList(),
      };
      // Jika konfirmasi setoran ganda disetujui, tandai sebagai force_multiple
      // agar backend tidak melewati data ini karena idempotensi.
      if (hasProgressToday) {
        payload['force_multiple'] = true;
      }
      // Global pengaturan metode & peraga
      if (_showMetode && _globalMetodeId != null) {
        payload['id_metode'] = _globalMetodeId;
      }
      if (_showPeraga) {
        payload['menggunakan_peraga'] = _globalGunakanPeraga ? 1 : 0;
        if (_globalGunakanPeraga) {
          payload['halaman_peraga'] = _globalHalamanPeragaCtrl.text.trim();
          payload['keterangan_peraga'] = _globalKeteranganPeragaCtrl.text
              .trim();
        }
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final cubit = context.read<TahsinCubit>();
      final result = await cubit.submitInputMassal(
        payload,
      );
      
      if (!mounted) return;
      Navigator.pop(context); // Tutup loading

      final bool success = result['success'] == true;
      final String pesan = result['message'] ?? (success ? 'Evaluasi berhasil diproses!' : 'Gagal memproses evaluasi.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: success ? _kAccent : Colors.orange.shade700,
        ),
      );
      // Update halAwal (geser maju) dan reset halTotal ke 0 hanya untuk yang baru saja disimpan
      setState(() {
        for (final r in aktif) {
          // halAwal baru = halAwal lama + halTotal yang tadi disimpan
          final halBaru = r.halAwal + r.halTotal;
          // Update santri map supaya halAwal-nya ikut bergeser
          r.santri['capai_hal'] = halBaru;
          // Geser halAwal ke halaman baru
          r.halAwal = halBaru;
          // Reset form
          r.halTotal = 0;
          r.halCtrl.text = '0';
          r.jmlKehadiran = 1;
          r.tmCtrl.text = '1';
          r.lulus = true;
          r.disimak = true;
          r.catatanGuru = '';
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      // Nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget body = _loading
        ? _buildLoader()
        : _error.isNotEmpty
        ? _buildError()
        : _buildBody();

    return BlocListener<TahsinCubit, TahsinState>(
      listener: (context, state) {
        if (state is TahsinLoaded) {
          setState(() {
            _loading = false;
            _error = '';
          });
          _mapDataToRows(state.data);
          if (state.isOfflineWarning) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Anda sedang offline. Menampilkan data lokal terakhir.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else if (state is TahsinError) {
          setState(() {
            _error = state.message;
            _loading = false;
          });
        } else if (state is TahsinLoading) {
          setState(() {
            _loading = true;
            _error = '';
          });
        }
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Main Body
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  // --- Sort & Filter --------------------------------------------------------
  List<RowStateModel> get _sortedRows {
    final filtered = _selectedTingkat == 'Semua'
        ? List<RowStateModel>.from(_rows)
        : _rows
              .where((r) => r.santri['tingkat']?.toString() == _selectedTingkat)
              .toList();

    final sorted = List<RowStateModel>.from(filtered);
    if (_sortMode == _SortMode.halaman) {
      sorted.sort((a, b) {
        // Latihan lebih tinggi dari reguler
        final aIsLat =
            (double.tryParse(a.santri['capai_hal']?.toString() ?? '0') ?? 0) >=
            (double.tryParse(a.santri['total_hal']?.toString() ?? '1') ?? 1);
        final bIsLat =
            (double.tryParse(b.santri['capai_hal']?.toString() ?? '0') ?? 0) >=
            (double.tryParse(b.santri['total_hal']?.toString() ?? '1') ?? 1);
        if (aIsLat != bIsLat) return aIsLat ? -1 : 1;
        return b.halAwal.compareTo(a.halAwal);
      });
    } else if (_sortMode == _SortMode.abjad) {
      sorted.sort((a, b) {
        final na = (a.santri['nama_santri'] ?? '').toString().toLowerCase();
        final nb = (b.santri['nama_santri'] ?? '').toString().toLowerCase();
        return na.compareTo(nb);
      });
    }
    return sorted;
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Urutkan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final mode in _SortMode.values)
              ListTile(
                dense: true,
                leading: Icon(
                  mode == _SortMode.urut
                      ? Icons.format_list_numbered_rounded
                      : mode == _SortMode.halaman
                      ? Icons.menu_book_rounded
                      : Icons.sort_by_alpha_rounded,
                  color: _sortMode == mode
                      ? _kHeader
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
                title: Text(
                  mode == _SortMode.urut
                      ? 'Urutan Asli'
                      : mode == _SortMode.halaman
                      ? 'Halaman Tertinggi (Latihan dulu)'
                      : 'Abjad Aâ€“Z',
                  style: TextStyle(
                    fontSize: 13,
                    color: _sortMode == mode
                        ? _kHeader
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: _sortMode == mode
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: _sortMode == mode
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: _kHeader,
                        size: 18,
                      )
                    : null,
                onTap: () {
                  setState(() => _sortMode = mode);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final rows = _sortedRows;

    // Global pengaturan (metode & peraga) dan Filter
    Widget globalBar = StatefulBuilder(
      builder: (_, setGlobal) => Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900.withValues(alpha: 0.95)
              : const Color(0xFFF0FDF4), // Warna hijau sangat muda (mencolok)
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _kHeader.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: _kHeader.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Filter Options Row ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Baris 1: Sortir, Date Update Lokal, Tanggal Setor
                Row(
                  children: [
                    // a. Tombol Sortir di kiri
                    IconButton(
                      tooltip: 'Urutkan',
                      onPressed: _showSortMenu,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Stack(
                        children: [
                          const Icon(
                            Icons.sort_rounded,
                            color: _kHeader,
                            size: 24,
                          ),
                          if (_sortMode != _SortMode.urut)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // b. Teks Info Tanggal Update Lokal (tanpa border/kotak besar)
                    Builder(
                      builder: (context) {
                        String tglUpdate = '-';
                        if (rows.isNotEmpty) {
                          DateTime? maxDate;
                          for (var r in rows) {
                            final d = r.santri['tangal_update'];
                            if (d != null && d.toString().isNotEmpty) {
                              final parsed = DateTime.tryParse(d.toString());
                              if (parsed != null) {
                                if (maxDate == null || parsed.isAfter(maxDate)) {
                                  maxDate = parsed;
                                }
                              }
                            }
                          }
                          if (maxDate != null) {
                            tglUpdate = DateFormat('dd MMM yy').format(maxDate);
                          }
                        }
                        return Text(
                          'Sync: $tglUpdate',
                          style: TextStyle(
                            fontSize: 11, 
                            fontWeight: FontWeight.w600, 
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                          ),
                        );
                      }
                    ),
                    const Spacer(),
                    // c. DatePicker (Tanggal Setor) di kanan
                    SizedBox(
                      width: 140, // Lebar fixed agar ringkas
                      child: CustomDateField(
                        selectedDate: _tanggal,
                        isCompact: true,
                        isWhite: false,
                        onDateSelected: (date) {
                          if (date != null) {
                            setTanggal(date);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Baris 2: Filter Lainnya
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                  // Decimal Toggle
                  GestureDetector(
                    onTap: () =>
                        setState(() => _isDecimalMode = !_isDecimalMode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isDecimalMode
                            ? Colors.orange.shade50
                            : Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF374151)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isDecimalMode
                              ? Colors.orange.shade300
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isDecimalMode
                                ? Icons.adjust_rounded
                                : Icons.circle_outlined,
                            size: 14,
                            color: _isDecimalMode
                                ? Colors.orange.shade700
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isDecimalMode ? '0.5' : '1.0',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _isDecimalMode
                                  ? Colors.orange.shade700
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Status Absen Filter (Semua Santri)
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatusAbsen,
                        isDense: true,
                        icon: const Icon(Icons.arrow_drop_down, size: 18),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedStatusAbsen = val);
                            _loadSantri();
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'semua',
                            child: Text('Semua Santri'),
                          ),
                          DropdownMenuItem(
                            value: 'kecuali_izin_sakit',
                            child: Text('Kecuali Izin/Sakit'),
                          ),
                          DropdownMenuItem(
                            value: 'hanya_hadir',
                            child: Text('Hanya Hadir'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // --- Jadwal Sesi (Bila Ada) ---
                  if (_jadwalInfo != null) ...[
                      const SizedBox(width: 10),
                      Container(
                        height: 28,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: _jadwalList.length > 1
                            ? DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _jadwalInfo!['sesi'],
                                  isDense: true,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 16,
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      setState(() => _selectedSesi = newValue);
                                      _loadSantri();
                                    }
                                  },
                                  items: _jadwalList.map((jdwl) {
                                    return DropdownMenuItem<int>(
                                      value: jdwl['sesi'],
                                      child: Text(
                                        '${_hariLabel[jdwl['hari']] ?? ''} - ${_sesiLabel[jdwl['sesi']] ?? ''}',
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            : Text(
                                '${_hariLabel[_jadwalInfo!['hari']] ?? ''} - ${_sesiLabel[_jadwalInfo!['sesi']] ?? ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                      ),
                    ],
                  // Tingkat Filter
                  if (_tingkatOptions.length > 2) ...[
                    const SizedBox(width: 10),                    Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedTingkat,
                          isDense: true,
                          icon: const Icon(Icons.arrow_drop_down, size: 18),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedTingkat = val);
                          },
                          items: _tingkatOptions.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e == 'Semua' ? 'Semua Kelas' : e),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                  // Kelompok Chips
                  if (_kelompokList.length > 1) ...[
                    const SizedBox(width: 10),
                    ..._kelompokList.map((k) {
                      final id =
                          int.tryParse(k['id_kelompok']?.toString() ?? '0') ??
                          0;
                      final isSel = _selectedKelompokId == id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            if (!isSel) {
                              setState(() => _selectedKelompokId = id);
                              _loadSantri();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? _kHeader
                                  : Theme.of(context).brightness ==
                                        Brightness.dark
                                  ? const Color(0xFF374151)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSel
                                    ? _kHeader
                                    : Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Text(
                              k['kelompok']?.toString() ?? '-',
                              style: TextStyle(
                                color: isSel
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                fontWeight: isSel
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                  ],
                ),
              ),
            ],
          ),



            // --- Mode Belajar & Peraga (Bila Aktif) ---
            if (_showMetode || _showPeraga) ...[
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_showMetode && _metodeList.isNotEmpty) ...[
                    Expanded(
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _globalMetodeId,
                            isExpanded: true,
                            isDense: true,
                            hint: const Text(
                              'Metode',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onChanged: (v) =>
                                setState(() => _globalMetodeId = v),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('- Tidak Ada -'),
                              ),
                              ..._metodeList.map(
                                (m) => DropdownMenuItem<int>(
                                  value: int.tryParse(
                                    m['id_metode']?.toString() ?? '0',
                                  ),
                                  child: Text(
                                    m['nama_metode']?.toString() ?? '-',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (_showPeraga) ...[
                    Switch(
                      value: _globalGunakanPeraga,
                      activeThumbColor: _kHeader,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (v) =>
                          setState(() => _globalGunakanPeraga = v),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Peraga',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
              if (_showPeraga && _globalGunakanPeraga) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _globalHalamanPeragaCtrl,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Hal Peraga',
                            labelStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _globalKeteranganPeragaCtrl,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            labelText: 'Keterangan',
                            labelStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _loadSantri(forceRefresh: true),
            color: _kHeader,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
              itemCount: rows.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) return globalBar;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: EvaluasiSantriCard(
                    row: rows[i - 1],
                    index: i - 1,
                    isDecimalMode: _isDecimalMode,
                    onShowCatatan: _showCatatanSheet,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- Loading / Error ------------------------------------------------------
  Widget _buildLoader() => const Padding(
    padding: EdgeInsets.all(16.0),
    child: SkeletonListWidget(itemCount: 8, itemHeight: 120),
  );

  void _showCatatanSheet(RowStateModel row, StateSetter setRow) {
    List<String> selectedCatatan = row.catatanGuru.isNotEmpty
        ? row.catatanGuru.split(', ').where((e) => e.isNotEmpty).toList()
        : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Catatan Master',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih catatan standar untuk santri ini:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_catatanMaster.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Tidak ada template catatan guru untuk kelas ini.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _catatanMaster.map((c) {
                        final str = c['teks_catatan']?.toString() ?? '';
                        if (str.isEmpty) return const SizedBox.shrink();
                        final isSel = selectedCatatan.contains(str);
                        return FilterChip(
                          label: Text(str),
                          selected: isSel,
                          onSelected: (val) {
                            setModalState(() {
                              if (val) {
                                selectedCatatan.add(str);
                              } else {
                                selectedCatatan.remove(str);
                              }
                            });
                          },
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF374151)
                              : Colors.grey.shade100,
                          selectedColor: _kAccent.withValues(alpha: 0.15),
                          checkmarkColor: _kAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                            color: isSel ? _kAccent : _kText2,
                            fontWeight: isSel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setRow(() {
                        row.catatanGuru = selectedCatatan.join(', ');
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kHeader,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Simpan Catatan',
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadSantri,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
            ),
          ],
        ),
      ),
    );
  }
}
