import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/generic_cache.dart';
import 'package:manajemen_tahsin_app/core/data/models/kelas_model.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/data/models/pra_tahfidz_santri_model.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/bloc/pra_tahfidz_cubit.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/widgets/pra_tahfidz_input_row.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/widgets/tahfidz_header_widget.dart';

class PraTahfidzInputMassalTab extends StatefulWidget {
  const PraTahfidzInputMassalTab({super.key});

  @override
  State<PraTahfidzInputMassalTab> createState() => PraTahfidzInputMassalTabState();
}

class PraTahfidzInputMassalTabState extends State<PraTahfidzInputMassalTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // ── State Kelas ──────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _kelasList = [];
  int? _selectedKelasId;
  bool _loadingKelas = true;

  // ── State Santri ─────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _santriList = [];
  bool _loadingSantri = false;

  // ── State Form ───────────────────────────────────────────────────────────────
  final Map<String, Map<String, dynamic>> _rowData = {};
  final Map<String, TextEditingController> _awalCtrls = {};
  final Map<String, TextEditingController> _akhirCtrls = {};
  final Map<String, TextEditingController> _totalCtrls = {};

  DateTime _tanggal = DateTime.now();
  bool isSaving = false;

  // ── State Tambahan ─────────────────────────────────────────────────
  double _kelipatan = 1.0;
  String _sortMode = 'asli';
  final TextEditingController _kelipatanCtrl = TextEditingController(text: '1');

  // ── State Jadwal & Sesi ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> _jadwalListAll = [];
  List<Map<String, dynamic>> _jadwalList = [];
  int? _selectedSesi;

  // ── State Filter Absen & Meta ────────────────────────────────────────────────
  String _selectedStatusAbsen = 'semua';
  String _tglUpdateCache = 'Belum Sinkron';
  bool _isInitialFetchDone = false;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  @override
  void dispose() {
    _kelipatanCtrl.dispose();
    for (final c in _awalCtrls.values) {
      c.dispose();
    }
    for (final c in _akhirCtrls.values) {
      c.dispose();
    }
    for (final c in _totalCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadKelas({int? idKelompok}) async {
    final activeId = idKelompok ?? context.read<ActiveKelompokCubit>().state.activeId;
    if (activeId <= 0) {
      setState(() {
        _loadingKelas = false;
        _kelasList = [];
        _selectedKelasId = null;
      });
      return;
    }

    setState(() => _loadingKelas = true);
    try {
      final isar = IsarDb.instance;

      final kelasModels = await isar.kelasModels
          .filter()
          .idKelompokEqualTo(activeId)
          .group((q) => q.idKategoriEqualTo(3).or().tingkatContains('LEVEL').or().tingkatContains('Level'))
          .findAll();

      final rawKelas = kelasModels
          .map(
            (k) => {
              'id_kelas': k.idKelas.toString(),
              'tingkat': k.tingkat ?? '-',
            },
          )
          .toList();

      if (rawKelas.isEmpty) {
        rawKelas.add({
          'id_kelas': '-1',
          'tingkat': 'Belum ada kelas Pra-Tahfidz',
        });
      }

      if (!mounted) return;
      setState(() {
        _kelasList = rawKelas;
        _loadingKelas = false;
      });

      if (_kelasList.isNotEmpty) {
        _selectedKelasId = int.tryParse(
          _kelasList.first['id_kelas']?.toString() ?? '',
        );
        if (_selectedKelasId != -1) {
          if (!_isInitialFetchDone) {
            _isInitialFetchDone = true;
            _refreshData();
          } else {
            await _loadSantri();
          }
        } else {
          setState(() {
            _santriList = [];
            _loadingSantri = false;
          });
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingKelas = false);
    }
  }

  void _showUrutkanBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
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
              const Text(
                'Urutkan Berdasarkan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSortOption(
                ctx,
                'halaman_desc',
                'Tertinggi - Terendah (Halaman)',
              ),
              _buildSortOption(
                ctx,
                'halaman_asc',
                'Terendah - Tertinggi (Halaman)',
              ),
              _buildSortOption(ctx, 'az', 'Nama A - Z'),
              _buildSortOption(ctx, 'za', 'Nama Z - A'),
              _buildSortOption(ctx, 'asli', 'Asli'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext ctx, String mode, String title) {
    final isSelected = _sortMode == mode;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () {
        setState(() => _sortMode = mode);
        Navigator.pop(ctx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected) Icon(Icons.check, color: primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSantri() async {
    final activeId = context.read<ActiveKelompokCubit>().state.activeId;
    if (activeId <= 0) return;
    if (_selectedKelasId == null) return;
    if (!mounted) return;
    setState(() {
      _loadingSantri = true;
      _santriList = [];
      _rowData.clear();
    });

    try {
      final isar = IsarDb.instance;
      final activeId = context.read<ActiveKelompokCubit>().state.activeId;
      final idKelompok = activeId > 0 ? activeId : null;

      final metaCacheKey =
          'pratahfidz_meta_${idKelompok}_${_tanggal.toIso8601String().split('T')[0]}_${_selectedSesi}_$_selectedStatusAbsen';
      final metaCache = await isar.genericCaches
          .filter()
          .keyEqualTo(metaCacheKey)
          .findFirst();

      if (metaCache != null) {
        final metaMap = jsonDecode(metaCache.dataJson);
        final rawJadwalList = metaMap['jadwal_list'];
        if (rawJadwalList is List) {
          _jadwalListAll = rawJadwalList
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }

        final tglUpdateStr = metaMap['tanggal_update'];
        if (tglUpdateStr != null) {
          _tglUpdateCache = tglUpdateStr.toString();
        } else {
          final dt = metaCache.updatedAt;
          _tglUpdateCache = DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingSantri = false;
            _santriList = [];
          });
        }
        return;
      }

      _jadwalList = List.from(_jadwalListAll);
      if (_jadwalList.isNotEmpty &&
          !_jadwalList.any((j) => j['sesi'] == _selectedSesi)) {
        _selectedSesi = _jadwalList.first['sesi'];
      } else if (_jadwalList.isEmpty) {
        _selectedSesi = null;
      }

      final santriModels = activeId > 0
          ? await isar.praTahfidzSantriModels
                .filter()
                .idKelompokEqualTo(activeId)
                .findAll()
          : await isar.praTahfidzSantriModels
                .filter()
                .idKelompokIsNull()
                .findAll();

      final filteredModels = santriModels.where((s) => s.idKelas == _selectedKelasId).toList();
      final santri = filteredModels.map((m) => m.toJson()).toList();

      print('rrrrrrrrrrrrrrrrrrrrrrr FILTERING: Total Isar = ${santriModels.length} | Cocok ID $_selectedKelasId = ${santri.length}');

      if (!mounted) return;

      // Bersihkan controller lama
      for (final c in _awalCtrls.values) {
        c.dispose();
      }
      for (final c in _akhirCtrls.values) {
        c.dispose();
      }
      for (final c in _totalCtrls.values) {
        c.dispose();
      }
      _awalCtrls.clear();
      _akhirCtrls.clear();
      _totalCtrls.clear();

      setState(() {
        _santriList = santri;
        _loadingSantri = false;
        for (final s in santri) {
          final nis = s['nis']?.toString() ?? '';
          if (nis.isEmpty) continue;

          final hal =
              double.tryParse(s['pointer_halaman']?.toString() ?? '0') ?? 0.0;

          _rowData[nis] = {
            'nis': nis,
            'id_kelas': _selectedKelasId,
            'hal_awal': hal,
            'hal_akhir': hal,
            'total_hal': 0.0,
            'status_bacaan': 'Sesuai Target',
            'sesi': _selectedSesi ?? 1,
          };

          _awalCtrls[nis] = TextEditingController(text: _fmtVal(hal));
          _akhirCtrls[nis] = TextEditingController(text: _fmtVal(hal));
          _totalCtrls[nis] = TextEditingController(text: _fmtVal(0.0));
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingSantri = false);
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _loadingSantri = true);
    try {
      final idKelompok = context.read<ActiveKelompokCubit>().state.activeId;
      List<int> kelasIds = [];
      if (_selectedKelasId != null && _selectedKelasId != -1) {
        kelasIds = [_selectedKelasId!];
      }
      await context.read<PraTahfidzCubit>().fetchSantriList(
        idKelompok: idKelompok,
        kelasIds: kelasIds.isEmpty ? null : kelasIds,
        sesi: _selectedSesi,
        tanggal: _tanggal.toIso8601String().split('T')[0],
        forceRefresh: true,
      );
    } catch (e) {
      debugPrint("Error refresh: $e");
    }
    await _loadSantri();
  }

  void _pickTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _tanggal) {
      setState(() => _tanggal = picked);
      _refreshData();
    }
  }

  Future<void> simpanMassal() async {
    FocusScope.of(context).unfocus(); // Tutup keyboard
    if (_rowData.isEmpty) return;

    setState(() => isSaving = true);

    try {
      final List<Map<String, dynamic>> arr = [];
      for (final r in _rowData.values) {
        arr.add({
          'nis': r['nis'],
          'id_kelas': r['id_kelas'],
          'sesi': r['sesi'],
          'hal_awal': r['hal_awal'],
          'hal_akhir': r['hal_akhir'],
          'hal_total': r['total_hal'],
          'status_bacaan': r['status_bacaan'],
        });
      }

      if (arr.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada santri untuk diinput.')),
          );
        }
        if (mounted) setState(() => isSaving = false);
        return;
      }

      final payload = {
        'id_kelompok': context.read<ActiveKelompokCubit>().state.activeId,
        'tanggal': _tanggal.toIso8601String().split('T')[0],
        'sesi': int.tryParse(_selectedSesi?.toString() ?? '1') ?? 1,
        'rows': arr,
      };

      await context.read<PraTahfidzCubit>().submitInputMassal(payload);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showDoubleInputConfirmation(BuildContext context, String message, Map<String, dynamic> payload) {
    showDialog(
      context: context,
      barrierDismissible: false, // WAJIB FALSE AGAR LAYAR TERKUNCI
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Konfirmasi Setoran 🔄", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Tembak ulang API dengan bypass (forceSave: true)
                context.read<PraTahfidzCubit>().submitInputMassal(payload, forceSave: true);
              },
              child: const Text("Ya, Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final activeId = context.watch<ActiveKelompokCubit>().state.activeId;
    if (activeId <= 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                "Silakan pilih Kelompok / Cabang di menu Header/Dashboard terlebih dahulu.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<ActiveKelompokCubit, ActiveKelompokState>(
          listener: (context, state) {
            if (state.activeId > 0) {
              _loadKelas(idKelompok: state.activeId);
            }
          },
        ),
        BlocListener<PraTahfidzCubit, PraTahfidzState>(
          listener: (context, state) {
        if (state is PraTahfidzLoaded) {
          final actualData = state.data['data'] ?? state.data;

          final rawJadwalList = actualData['jadwal_list'];
          if (rawJadwalList is List) {
            _jadwalListAll = rawJadwalList
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          }

          final rawSantriList = actualData['santri_list'];
          String? maxTglUpdate;
          if (rawSantriList is List) {
            for (final s in rawSantriList) {
              if (s is Map && s['tanggal_update'] != null) {
                final tgl = s['tanggal_update'].toString();
                if (maxTglUpdate == null || tgl.compareTo(maxTglUpdate) > 0) {
                  maxTglUpdate = tgl;
                }
              }
            }
          }

          if (maxTglUpdate != null) {
            try {
              final dt = DateTime.parse(maxTglUpdate);
              _tglUpdateCache = DateFormat('d MMM yyyy', 'id_ID').format(dt);
            } catch (_) {
              _tglUpdateCache = maxTglUpdate;
            }
          } else {
            _tglUpdateCache = 'Belum Sinkron';
          }

          _jadwalList = List.from(_jadwalListAll);
          if (_jadwalList.isNotEmpty &&
              !_jadwalList.any((j) => j['sesi'] == _selectedSesi)) {
            _selectedSesi = _jadwalList.first['sesi'];
          } else if (_jadwalList.isEmpty) {
            _selectedSesi = null;
          }

          _loadSantri();
        } else if (state is PraTahfidzSubmitting) {
          setState(() => isSaving = true);
        } else if (state is PraTahfidzSubmitError) {
          setState(() => isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is PraTahfidzConfirmationRequired) {
          setState(() => isSaving = false);
          // DILARANG KERAS MEMANGGIL SNACKBAR ATAU REFRESH DATA DI SINI!
          // WAJIB panggil fungsi Pop-Up penahan layar:
          _showDoubleInputConfirmation(context, state.message, state.payload);
        } else if (state is PraTahfidzSubmitSuccess) {
          setState(() {
            isSaving = false;
            _rowData.clear(); // Bersihkan map internal
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _refreshData();
        }
      },
        ),
      ],
      child: _loadingKelas 
        ? const Center(child: CircularProgressIndicator())
        : Builder(
        builder: (context) {
          Widget globalBar = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                // Tombol Simpan telah dipindahkan ke AppBar Utama
              TahfidzHeaderWidget(
                isDark: isDark,
                primaryColor: primaryColor,
                tglUpdateCache: _tglUpdateCache,
                tanggal: _tanggal,
                selectedKelasId: _selectedKelasId,
                kelasList: _kelasList,
                selectedSesi: _selectedSesi,
                jadwalList: _jadwalList,
                selectedStatusAbsen: _selectedStatusAbsen,
                kelipatanCtrl: _kelipatanCtrl,
                onUrutkanTap: () => _showUrutkanBottomSheet(context),
                onTanggalTap: _pickTanggal,
                onKelasChanged: (val) {
                  if (val != null && val != _selectedKelasId) {
                    setState(() => _selectedKelasId = val);
                    _refreshData();
                  }
                },
                onSesiChanged: (val) {
                  if (val != null && val != _selectedSesi) {
                    setState(() => _selectedSesi = val);
                    _refreshData();
                  }
                },
                onStatusAbsenChanged: (val) {
                  final strVal = val ? 'hanya_hadir' : 'semua';
                  if (strVal != _selectedStatusAbsen) {
                    setState(() => _selectedStatusAbsen = strVal);
                    _refreshData();
                  }
                },
                onKelipatanChanged: (val) {
                  final k = double.tryParse(val);
                  if (k != null && k >= 1.0) {
                    setState(() => _kelipatan = k);
                  }
                },
              ),
            ],
          );

          List<Map<String, dynamic>> sortedSantri = List.from(_santriList);
          if (_sortMode != 'asli') {
            sortedSantri.sort((a, b) {
              if (_sortMode == 'halaman_desc' || _sortMode == 'halaman_asc') {
                final awA =
                    double.tryParse(a['pointer_halaman']?.toString() ?? '0') ??
                    0;
                final awB =
                    double.tryParse(b['pointer_halaman']?.toString() ?? '0') ??
                    0;
                return _sortMode == 'halaman_desc'
                    ? awB.compareTo(awA)
                    : awA.compareTo(awB);
              } else if (_sortMode == 'za') {
                return (b['nama_santri']?.toString() ?? '').compareTo(
                  a['nama_santri']?.toString() ?? '',
                );
              }
              return (a['nama_santri']?.toString() ?? '').compareTo(
                b['nama_santri']?.toString() ?? '',
              );
            });
          }

          return Stack(
            children: [
              if (_loadingSantri || _loadingKelas)
                const Center(child: CircularProgressIndicator())
              else if (_kelasList.isEmpty)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: globalBar,
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Kelas Pra-Tahfidz belum dikonfigurasi. Hubungi Admin.',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: globalBar,
                    ),
                    Expanded(
                      child: BlocBuilder<PraTahfidzCubit, PraTahfidzState>(
                        buildWhen: (previous, current) {
                          return current is PraTahfidzLoading || 
                                 current is PraTahfidzLoaded || 
                                 current is PraTahfidzError;
                        },
                        builder: (context, state) {
                          if (state is PraTahfidzLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (state is PraTahfidzLoaded) {
                            final actualData = state.data['data'] ?? state.data;
                            final rawList = actualData['santri_list'] as List<dynamic>? ?? [];
                            final models = rawList.map((e) => PraTahfidzSantriModel.fromJson(e as Map<String, dynamic>)).toList();
                            final filteredModels = models.where((s) => s.idKelas == _selectedKelasId).toList();
                            
                            if (filteredModels.isEmpty) {
                              return const Center(child: Text("Tidak ada santri di kelas ini.", style: TextStyle(fontWeight: FontWeight.w500)));
                            }

                            List<PraTahfidzSantriModel> sortedModels = List.from(filteredModels);
                            if (_sortMode != 'asli') {
                              sortedModels.sort((a, b) {
                                if (_sortMode == 'halaman_desc' || _sortMode == 'halaman_asc') {
                                  final awA = a.pointerHalaman ?? 0.0;
                                  final awB = b.pointerHalaman ?? 0.0;
                                  return _sortMode == 'halaman_desc' ? awB.compareTo(awA) : awA.compareTo(awB);
                                } else if (_sortMode == 'za') {
                                  return (b.namaSantri ?? '').compareTo(a.namaSantri ?? '');
                                }
                                return (a.namaSantri ?? '').compareTo(b.namaSantri ?? '');
                              });
                            }
                            
                            return ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                              itemCount: sortedModels.length,
                                itemBuilder: (context, index) {
                                  final santriModel = sortedModels[index];
                                  
                                final santriMap = santriModel.toJson();
                                final nis = santriModel.nis ?? '';
                                
                                // Cegah blank jika controller belum sempat terbuat oleh _loadSantri
                                var row = _rowData[nis];
                                if (row == null) {
                                  final hal = santriModel.pointerHalaman ?? 0.0;
                                  row = {
                                    'nis': nis,
                                    'id_kelas': _selectedKelasId,
                                    'hal_awal': hal,
                                    'hal_akhir': hal,
                                    'total_hal': 0.0,
                                    'status_bacaan': 'Sesuai Target',
                                    'sesi': _selectedSesi ?? 1,
                                  };
                                  _rowData[nis] = row;
                                  _awalCtrls[nis] = TextEditingController(text: _fmtVal(hal));
                                  _akhirCtrls[nis] = TextEditingController(text: _fmtVal(hal));
                                  _totalCtrls[nis] = TextEditingController(text: _fmtVal(0.0));
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _PraTahfidzCardItem(
                                    santri: santriMap,
                                    row: row,
                                    awalCtrl: _awalCtrls[nis]!,
                                    akhirCtrl: _akhirCtrls[nis]!,
                                    totalCtrl: _totalCtrls[nis]!,
                                    kelipatan: _kelipatan,
                                  ),
                                );
                              },
                            );
                          }
                          // Fallback jika state error/initial (menggunakan cache dari _loadSantri)
                          if (_santriList.isEmpty) {
                            return const Center(child: Text("Tidak ada santri di kelas ini.", style: TextStyle(fontWeight: FontWeight.w500)));
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: _santriList.length,
                            itemBuilder: (context, index) {
                              final santri = _santriList[index];
                              final nis = santri['nis']?.toString() ?? '';
                              final row = _rowData[nis];
                              if (row == null) return const SizedBox.shrink();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                  child: _PraTahfidzCardItem(
                                    santri: santri,
                                    row: row,
                                    awalCtrl: _awalCtrls[nis]!,
                                    akhirCtrl: _akhirCtrls[nis]!,
                                    totalCtrl: _totalCtrls[nis]!,
                                    kelipatan: _kelipatan,
                                  ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PraTahfidzCardItem extends StatefulWidget {
  final Map<String, dynamic> santri;
  final Map<String, dynamic> row;
  final TextEditingController awalCtrl;
  final TextEditingController akhirCtrl;
  final TextEditingController totalCtrl;
  final double kelipatan;

  const _PraTahfidzCardItem({
    Key? key,
    required this.santri,
    required this.row,
    required this.awalCtrl,
    required this.akhirCtrl,
    required this.totalCtrl,
    required this.kelipatan,
  }) : super(key: key);

  @override
  State<_PraTahfidzCardItem> createState() => _PraTahfidzCardItemState();
}

class _PraTahfidzCardItemState extends State<_PraTahfidzCardItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.totalCtrl.text == '0' || widget.totalCtrl.text.isEmpty) {
      final defaultHal = double.tryParse(widget.santri['default_hal']?.toString() ?? '1.0') ?? 1.0;
      if (defaultHal > 0) {
        widget.totalCtrl.text = _fmtVal(defaultHal);
        widget.row['total_hal'] = defaultHal;
        widget.row['hal_akhir'] = widget.row['hal_awal'] + defaultHal;
        widget.akhirCtrl.text = _fmtVal(widget.row['hal_akhir']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final santri = widget.santri;
    final row = widget.row;
    final nis = santri['nis']?.toString() ?? '-';
    final nama = santri['nama_santri']?.toString() ?? '-';
    final tingkat = santri['tingkat']?.toString() ?? '-';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    const statusOptions = ['Sesuai Target', 'Kurang', 'Lebih'];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          nis,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.indigo.withValues(alpha: 0.2)
                                : Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tingkat,
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark
                                  ? Colors.indigo.shade300
                                  : Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: StatefulBuilder(
                  builder: (context, setStateDropdown) {
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: row['status_bacaan'],
                        isDense: true,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface,
                        ),
                        icon: const Icon(Icons.arrow_drop_down, size: 16),
                        onChanged: (val) {
                          if (val != null) {
                            setStateDropdown(() => row['status_bacaan'] = val);
                            row['status_bacaan'] = val; 
                          }
                        },
                        items: statusOptions
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final double maxTotalHal = double.tryParse(widget.santri['total_hal']?.toString() ?? '604') ?? 604;
              final double pointerHal = double.tryParse(widget.santri['pointer_halaman']?.toString() ?? '0') ?? 0;
              final int wajibTes = int.tryParse(widget.santri['wajib_tes_kenaikan']?.toString() ?? '0') ?? 0;
              final bool isSiapTes = (pointerHal >= maxTotalHal) && (wajibTes == 1);

              return PraTahfidzInputRow(
                awal: row['hal_awal'],
                awalCtrl: widget.awalCtrl,
                akhirCtrl: widget.akhirCtrl,
                totalCtrl: widget.totalCtrl,
                kelipatan: widget.kelipatan,
                isSiapTes: isSiapTes,
                onAwalChanged: (val) {}, 
                onAkhirChanged: (val) {
                  double akhir = double.tryParse(val) ?? 0;
                  if (akhir > maxTotalHal) akhir = maxTotalHal;

                  final t = akhir - row['hal_awal'];
                  row['hal_akhir'] = akhir;
                  row['total_hal'] = t;
                  
                  final newTotalStr = _fmtVal(t);
                  if (widget.totalCtrl.text != newTotalStr) {
                    widget.totalCtrl.text = newTotalStr;
                  }
                  final newAkhirStr = _fmtVal(akhir);
                  if (widget.akhirCtrl.text != newAkhirStr) {
                    widget.akhirCtrl.value = TextEditingValue(text: newAkhirStr, selection: TextSelection.collapsed(offset: newAkhirStr.length));
                  }
                },
                onTotalChanged: (val) {
                  double tot = double.tryParse(val) ?? 0;
                  double ak = row['hal_awal'] + tot;
                  
                  if (ak > maxTotalHal) {
                    ak = maxTotalHal;
                    tot = ak - row['hal_awal'];
                  }

                  row['total_hal'] = tot;
                  row['hal_akhir'] = ak;
                  
                  final newAkhirStr = _fmtVal(ak);
                  if (widget.akhirCtrl.text != newAkhirStr) {
                    widget.akhirCtrl.text = newAkhirStr;
                  }
                  final newTotalStr = _fmtVal(tot);
                  if (widget.totalCtrl.text != newTotalStr) {
                    widget.totalCtrl.value = TextEditingValue(text: newTotalStr, selection: TextSelection.collapsed(offset: newTotalStr.length));
                  }
                },
                onAdd: () {
                  double newTot = row['total_hal'] + widget.kelipatan;
                  double ak = row['hal_awal'] + newTot;
                  
                  if (ak > maxTotalHal) {
                    ak = maxTotalHal;
                    newTot = ak - row['hal_awal'];
                  }

                  row['total_hal'] = newTot;
                  row['hal_akhir'] = ak;
                  
                  widget.totalCtrl.text = _fmtVal(newTot);
                  widget.akhirCtrl.text = _fmtVal(ak);
                },
                onSubtract: () {
                  final newTot = row['total_hal'] - widget.kelipatan;
                  if (newTot < 0) return;
                  final ak = row['hal_awal'] + newTot;
                  row['total_hal'] = newTot;
                  row['hal_akhir'] = ak;
                  
                  widget.totalCtrl.text = _fmtVal(newTot);
                  widget.akhirCtrl.text = _fmtVal(ak);
                },
              );
            }
          ),
        ],
      ),
    );
  }
}

String _fmtVal(dynamic v) {
  final d = double.tryParse(v?.toString() ?? '0') ?? 0;
  if (d == 0) return '';
  return d == d.toInt()
      ? d.toInt().toString()
      : d.toStringAsFixed(1).replaceAll('.0', '');
}
