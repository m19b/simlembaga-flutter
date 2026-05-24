import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:manajemen_tahsin_app/core/data/models/generic_cache.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/data/models/tahfidz_santri_model.dart';

import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/api/services/santri_catatan_api_service.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/bloc/tahfidz_cubit.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/domain/repositories/tahfidz_repository.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/widgets/tahfidz_header_widget.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/widgets/tahfidz_santri_card.dart';

class TahfidzInputMassalTab extends StatefulWidget {
  const TahfidzInputMassalTab({super.key});

  @override
  State<TahfidzInputMassalTab> createState() => TahfidzInputMassalTabState();
}

class TahfidzInputMassalTabState extends State<TahfidzInputMassalTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // ── State Kelas ──────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _kelasList = [];
  int? _selectedKelasId;
  bool _loadingKelas = true;
  List<Map<String, dynamic>> _catatanMaster = [];

  // ── State Santri ─────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _santriList = [];
  bool _loadingSantri = false;

  // ── State Form ───────────────────────────────────────────────────────────────
  final Map<String, Map<String, dynamic>> _rowData = {};
  DateTime _tanggal = DateTime.now();
  bool _isSaving = false;

  // ── State Tambahan (Pilar 3) ─────────────────────────────────────────────────
  double _kelipatan = 1.0;
  String _sortMode = 'az';
  final TextEditingController _kelipatanCtrl = TextEditingController(text: '1');

  // ── State Jadwal & Sesi ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> _jadwalListAll = [];
  List<Map<String, dynamic>> _jadwalList = [];
  int? _selectedSesi;

  // ── State Filter Absen & Meta ────────────────────────────────────────────────
  String _selectedStatusAbsen = 'semua';
  String _tglUpdateCache = 'Belum Sinkron';

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  @override
  void dispose() {
    _kelipatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadKelas() async {
    setState(() => _loadingKelas = true);
    try {
      final activeId = context.read<ActiveKelompokCubit>().state.activeId;
      final isar = IsarDb.instance;
      
      final santriModels = activeId > 0
          ? await isar.tahfidzSantriModels.filter().idKelompokEqualTo(activeId).findAll()
          : await isar.tahfidzSantriModels.where().findAll();

      final Map<int, String> uniqueKelas = {};
      for (final s in santriModels) {
        if (s.idKelas != null && s.tingkat != null) {
          uniqueKelas[s.idKelas!] = s.tingkat!;
        }
      }

      final rawKelas = uniqueKelas.entries.map((e) => {
        'id_kelas': e.key.toString(),
        'tingkat': e.value,
      }).toList();

      if (!mounted) return;
      setState(() {
        _kelasList = rawKelas;
        _loadingKelas = false;
      });
      
      if (_kelasList.isNotEmpty) {
        _selectedKelasId = int.tryParse(
          _kelasList.first['id_kelas']?.toString() ?? '',
        );
        _loadCatatanMaster();
        await _loadSantri();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingKelas = false);
    }
  }

  Future<void> _loadCatatanMaster() async {
    if (_selectedKelasId == null) return;
    try {
      final isar = IsarDb.instance;
      final activeId = context.read<ActiveKelompokCubit>().state.activeId;
      final cacheKey = 'catatan_master_${activeId}_${_selectedKelasId}_2'; // 2 = Tahfidz
      
      final cache = await isar.genericCaches.filter().keyEqualTo(cacheKey).findFirst();
      
      if (cache != null) {
        final list = jsonDecode(cache.dataJson);
        if (list is List) {
          if (mounted) {
            setState(() {
              _catatanMaster = list.map((e) => Map<String, dynamic>.from(e)).toList();
            });
          }
        }
      } else {
        final res = await SantriCatatanApiService.getCatatanMaster(
          idKelompok: activeId,
          idKelas: _selectedKelasId,
          idKategori: 2,
        );
        final list = res['data']?['catatan_master'];
        if (list is List) {
          if (mounted) {
            setState(() {
              _catatanMaster = list.map((e) => Map<String, dynamic>.from(e)).toList();
            });
          }
          final newCache = GenericCache()
            ..key = cacheKey
            ..dataJson = jsonEncode(list)
            ..updatedAt = DateTime.now();
          await isar.writeTxn(() async {
            await isar.genericCaches.put(newCache);
          });
        }
      }
    } catch (_) {}
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
              _buildSortOption(ctx, 'halaman_desc', 'Tertinggi - Terendah (Halaman)'),
              _buildSortOption(ctx, 'halaman_asc', 'Terendah - Tertinggi (Halaman)'),
              _buildSortOption(ctx, 'az', 'A-Z'),
              _buildSortOption(ctx, 'za', 'Z-A'),
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
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            if (isSelected) Icon(Icons.check, color: primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSantri() async {
    if (_selectedKelasId == null) return;
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
          'tahfidz_meta_${idKelompok}_${_tanggal.toIso8601String().split('T')[0]}_${_selectedSesi}_$_selectedStatusAbsen';
      debugPrint('rrrrrrrrrrrrrrrrrrrrrrr [_loadSantri] Mencari metaCacheKey: $metaCacheKey');
      final metaCache = await isar.genericCaches
          .filter()
          .keyEqualTo(metaCacheKey)
          .findFirst();
      if (metaCache != null) {
        debugPrint('✅ [_loadSantri] Meta cache DITEMUKAN!');
        final metaMap = jsonDecode(metaCache.dataJson);
        final rawJadwalList = metaMap['jadwal_list'];
        if (rawJadwalList is List) {
          _jadwalListAll = rawJadwalList
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          debugPrint(
            '✅ [_loadSantri] _jadwalListAll terisi: ${_jadwalListAll.length} jadwal',
          );
        }

        final tglUpdateStr = metaMap['tanggal_update'];
        if (tglUpdateStr != null) {
          _tglUpdateCache = tglUpdateStr.toString();
          debugPrint(
            'ℹ️ [_loadSantri] Tgl Update dari metaMap: $_tglUpdateCache',
          );
        } else {
          final dt = metaCache.updatedAt;
          _tglUpdateCache = DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
          debugPrint(
            'ℹ️ [_loadSantri] Tgl Update fallback dari updatedAt: $_tglUpdateCache',
          );
        }
      } else {
        debugPrint(
          '❌ [_loadSantri] Meta cache TIDAK DITEMUKAN! Triggering _refreshData()',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _refreshData();
        });
      }

      // Tampilkan semua jadwal di _jadwalListAll
      _jadwalList = List.from(_jadwalListAll);
      if (_jadwalList.isNotEmpty &&
          !_jadwalList.any((j) => j['sesi'] == _selectedSesi)) {
        debugPrint(
          '⚠️ [_loadSantri] _selectedSesi ($_selectedSesi) tidak ada di _jadwalList. Mengganti ke ${_jadwalList.first['sesi']}',
        );
        _selectedSesi = _jadwalList.first['sesi'];
      } else if (_jadwalList.isEmpty) {
        debugPrint(
          '⚠️ [_loadSantri] _jadwalList KOSONG, _selectedSesi diset null',
        );
        _selectedSesi = null;
      }
      final santriModels = activeId > 0
          ? await isar.tahfidzSantriModels
                .filter()
                .idKelompokEqualTo(activeId)
                .findAll()
          : await isar.tahfidzSantriModels
                .filter()
                .idKelompokIsNull()
                .findAll();

      final santriRaw = santriModels.map((m) => m.toJson()).toList();
      final santri = santriRaw.where((s) {
        return s['id_kelas'] == _selectedKelasId;
      }).toList();

      if (!mounted) return;
      setState(() {
        _santriList = santri;
        _loadingSantri = false;
        for (final s in santri) {
          final nis = s['nis']?.toString() ?? '';
          if (nis.isEmpty) continue;
          _rowData[nis] = {
            'nis': nis,
            'id_kelas': _selectedKelasId,
            'z_aw':
                double.tryParse(s['total_ziyadah_hal']?.toString() ?? '0') ??
                0.0,
            'z_ak':
                double.tryParse(s['total_ziyadah_hal']?.toString() ?? '0') ??
                0.0,
            'z_tot': 0.0,
            'z_status': 'Lulus',
            's_aw':
                double.tryParse(s['total_sabaq_hal']?.toString() ?? '0') ?? 0.0,
            's_ak':
                double.tryParse(s['total_sabaq_hal']?.toString() ?? '0') ?? 0.0,
            's_tot': 0.0,
            'm_aw':
                double.tryParse(s['total_manzil_hal']?.toString() ?? '0') ??
                0.0,
            'm_ak':
                double.tryParse(s['total_manzil_hal']?.toString() ?? '0') ??
                0.0,
            'm_tot': 0.0,
            'sesi': _selectedSesi ?? 1,
            'catatan': '',
            'disimak': '1',
          };
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingSantri = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat santri: $e'),
            backgroundColor: Theme.of(
              context,
            ).extension<AppCustomStyles>()!.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _loadingSantri = true);
    try {
      final activeId = context.read<ActiveKelompokCubit>().state.activeId;
      await context.read<TahfidzCubit>().fetchProgressList(
        idKelompok: activeId > 0 ? activeId : null,
        tanggal: _tanggal.toIso8601String().split('T')[0],
        sesi: _selectedSesi,
        filterKehadiran: _selectedStatusAbsen,
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

  Future<void> simpan() async => await _simpanMassal();

  Future<void> _simpanMassal() async {
    if (_santriList.isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final List<Map<String, dynamic>> arr = [];
      for (final s in _santriList) {
        final nis = s['nis']?.toString() ?? '';
        if (nis.isEmpty) continue;

        final r = _rowData[nis];
        if (r != null) {
          arr.add({
            'nis': r['nis'],
            'id_kelas': r['id_kelas'],
            'sesi': r['sesi'],
            'z_aw': r['z_aw'],
            's_aw': r['s_aw'],
            'm_aw': r['m_aw'],
            'z_tot': r['z_tot'],
            's_tot': r['s_tot'],
            'm_tot': r['m_tot'],
            'z_status': r['z_status'],
            'catatan': r['catatan'] ?? '',
            'disimak': r['disimak'] ?? '1',
          });
        } else {
          arr.add({
            'nis': nis,
            'id_kelas': _selectedKelasId,
            'sesi': _selectedSesi ?? 1,
            'z_aw': double.tryParse(s['total_ziyadah_hal']?.toString() ?? '0') ?? 0.0,
            's_aw': double.tryParse(s['total_sabaq_hal']?.toString() ?? '0') ?? 0.0,
            'm_aw': double.tryParse(s['total_manzil_hal']?.toString() ?? '0') ?? 0.0,
            'z_tot': 0.0,
            's_tot': 0.0,
            'm_tot': 0.0,
            'z_status': 'Lulus',
            'catatan': '',
            'disimak': '1',
          });
        }
      }

      if (arr.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada santri untuk diinput.')),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      final payload = {
        'id_kelompok': context.read<ActiveKelompokCubit>().state.activeId,
        'tanggal': _tanggal.toIso8601String().split('T')[0],
        'sesi': _selectedSesi ?? 1,
        'rows': arr,
      };

      await context.read<TahfidzRepository>().saveInputMassalOffline(
        payload,
        List<Map<String, dynamic>>.from(arr),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tersimpan di antrean offline'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (_loadingKelas) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_kelasList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.class_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada kelas Tahfidz di kelompok ini.',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return BlocListener<TahfidzCubit, TahfidzState>(
      listener: (context, state) {
        if (state is TahfidzLoaded) {
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

          setState(() {});
          _loadSantri();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Builder(
          builder: (context) {
            Widget globalBar = TahfidzHeaderWidget(
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
                setState(() => _selectedKelasId = val);
                _loadCatatanMaster();
                _loadSantri();
              },
              onSesiChanged: (val) {
                if (val != null) {
                  setState(() => _selectedSesi = val);
                  _refreshData();
                }
              },
              onStatusAbsenChanged: (val) {
                setState(() => _selectedStatusAbsen = val ? 'hanya_hadir' : 'semua');
                _refreshData();
              },
              onKelipatanChanged: (val) {
                final k = double.tryParse(val);
                if (k != null && k >= 1.0) {
                  setState(() => _kelipatan = k);
                }
              },
            );

            List<Map<String, dynamic>> sortedSantri = List.from(_santriList);
            if (_sortMode != 'asli') {
              sortedSantri.sort((a, b) {
                if (_sortMode == 'halaman_desc' || _sortMode == 'halaman_asc') {
                  final awA = double.tryParse(a['total_ziyadah_hal']?.toString() ?? '0') ?? 0;
                  final awB = double.tryParse(b['total_ziyadah_hal']?.toString() ?? '0') ?? 0;
                  return _sortMode == 'halaman_desc' ? awB.compareTo(awA) : awA.compareTo(awB);
                } else if (_sortMode == 'za') {
                  return (b['nama_santri']?.toString() ?? '').compareTo(a['nama_santri']?.toString() ?? '');
                }
                return (a['nama_santri']?.toString() ?? '').compareTo(b['nama_santri']?.toString() ?? '');
              });
            }

            return Stack(
              children: [
                _loadingSantri
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 80),
                        itemCount: sortedSantri.length + 1,
                        itemBuilder: (context, i) {
                          if (i == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: globalBar,
                            );
                          }
                          final s = sortedSantri[i - 1];
                          final nis = s['nis']?.toString() ?? '';
                          final row = _rowData[nis];
                          if (row == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: TahfidzSantriCard(
                              key: ValueKey(nis),
                              index: i - 1,
                              santri: s,
                              row: row,
                              kelipatan: _kelipatan,
                              catatanMaster: _catatanMaster,
                              onChanged: (key, val) {
                                setState(() => _rowData[nis]![key] = val);
                              },
                            ),
                          );
                        },
                      ),
                if (_isSaving)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
