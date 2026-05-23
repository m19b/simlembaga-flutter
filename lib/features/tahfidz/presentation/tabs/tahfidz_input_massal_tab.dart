import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:manajemen_tahsin_app/core/data/models/generic_cache.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/data/models/tahfidz_santri_model.dart';

import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/bloc/tahfidz_cubit.dart';

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

  // ── State Santri ─────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _santriList = [];
  bool _loadingSantri = false;

  // ── State Form ───────────────────────────────────────────────────────────────
  final Map<String, Map<String, dynamic>> _rowData = {};
  DateTime _tanggal = DateTime.now();
  bool _isSaving = false;

  // ── State Tambahan (Pilar 3) ─────────────────────────────────────────────────
  double _kelipatan = 1.0;
  bool _sortAscending = true;
  final TextEditingController _kelipatanCtrl = TextEditingController(text: '1');

  // ── State Jadwal & Sesi ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> _jadwalListAll = [];
  List<Map<String, dynamic>> _jadwalList = [];
  Map<String, dynamic>? _jadwalInfo;
  int? _selectedSesi;

  // ── State Filter Absen & Meta ────────────────────────────────────────────────
  String _selectedStatusAbsen = 'semua';
  String _tglUpdateCache = '-';

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
      final res = await ApiService.getFilterKelas(
        idKelompok: activeId > 0 ? activeId : null,
      );
      final rawKelas = res['data']?['kelas_list'] ?? res['data'] ?? [];
      if (rawKelas is List) {
        setState(() {
          _kelasList = rawKelas
              .whereType<Map>()
              .map((e) {
                final Map<String, dynamic> m = {};
                e.forEach((k, v) => m[k.toString()] = v);
                return m;
              })
              .where((k) => k['id_kategori']?.toString() == '2')
              .toList();
          _loadingKelas = false;
        });
        if (_kelasList.isNotEmpty) {
          _selectedKelasId = int.tryParse(
            _kelasList.first['id_kelas']?.toString() ?? '',
          );
          await _loadSantri();
        }
      }
    } catch (_) {
      setState(() => _loadingKelas = false);
    }
  }

  Future<void> _loadSantri() async {
    if (_selectedKelasId == null) return;
    setState(() {
      _loadingSantri = true;
      _santriList = [];
      _rowData.clear();
    });
    try {
      final activeId = context.read<ActiveKelompokCubit>().state.activeId;
      final isar = IsarDb.instance;
      
      final metaCacheKey = 'tahfidz_meta_${activeId}_${_tanggal.toIso8601String().split('T')[0]}_${_selectedSesi}_${_selectedStatusAbsen}';
      final metaCache = await isar.genericCaches.filter().keyEqualTo(metaCacheKey).findFirst();
      if (metaCache != null) {
        final metaMap = jsonDecode(metaCache.dataJson);
        final rawJadwalInfo = metaMap['jadwal_info'];
        if (rawJadwalInfo is Map) {
          _jadwalInfo = Map<String, dynamic>.from(rawJadwalInfo);
        } else {
          _jadwalInfo = null;
        }
        final rawJadwalList = metaMap['jadwal_list'];
        if (rawJadwalList is List) {
          _jadwalListAll = rawJadwalList.map((e) => Map<String, dynamic>.from(e)).toList();
        }
        final dt = metaCache.updatedAt;
        _tglUpdateCache = DateFormat('dd MMM yy HH:mm').format(dt);
      }

      int currentDay = _tanggal.weekday;
      _jadwalList = _jadwalListAll.where((j) => j['hari'] == currentDay).toList();
      if (_jadwalList.isNotEmpty && !_jadwalList.any((j) => j['sesi'] == _selectedSesi)) {
        _selectedSesi = _jadwalList.first['sesi'];
        _jadwalInfo = _jadwalList.first;
      } else if (_jadwalList.isEmpty) {
        _selectedSesi = null;
        _jadwalInfo = null;
      }

      final santriModels = activeId > 0
          ? await isar.tahfidzSantriModels.filter().idKelompokEqualTo(activeId).findAll()
          : await isar.tahfidzSantriModels.filter().idKelompokIsNull().findAll();
          
      final santriRaw = santriModels.map((m) => m.toJson()).toList();
      final santri = santriRaw.where((s) {
        return s['id_kelas'] == _selectedKelasId;
      }).toList();

      setState(() {
        _santriList = santri;
        _loadingSantri = false;
        for (final s in santri) {
          final nis = s['nis']?.toString() ?? '';
          if (nis.isEmpty) continue;
          _rowData[nis] = {
            'nis': nis,
            'id_kelas': _selectedKelasId,
            'z_aw': double.tryParse(s['total_ziyadah_hal']?.toString() ?? '0') ?? 0.0,
            'z_ak': double.tryParse(s['total_ziyadah_hal']?.toString() ?? '0') ?? 0.0,
            'z_tot': 0.0,
            'z_status': 'Lulus',
            's_aw': double.tryParse(s['total_sabaq_hal']?.toString() ?? '0') ?? 0.0,
            's_ak': double.tryParse(s['total_sabaq_hal']?.toString() ?? '0') ?? 0.0,
            's_tot': 0.0,
            'm_aw': double.tryParse(s['total_manzil_hal']?.toString() ?? '0') ?? 0.0,
            'm_ak': double.tryParse(s['total_manzil_hal']?.toString() ?? '0') ?? 0.0,
            'm_tot': 0.0,
            'sesi': _selectedSesi ?? 1,
          };
        }
      });
    } catch (e) {
      setState(() => _loadingSantri = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat santri: $e'),
            backgroundColor: Theme.of(context).extension<AppCustomStyles>()!.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
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

  Future<void> _simpanMassal() async {
    if (_rowData.isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final arr = [];
      for (final r in _rowData.values) {
        if (r['z_tot'] > 0 || r['s_tot'] > 0 || r['m_tot'] > 0) {
          arr.add({
            'nis': r['nis'],
            'id_kelas': r['id_kelas'],
            'ziyadah_hal': r['z_tot'],
            'sabaq_hal': r['s_tot'],
            'manzil_hal': r['m_tot'],
            'status_lulus': r['z_status'],
          });
        }
      }

      if (arr.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada data baru yang diinput.')),
          );
        }
        return;
      }

      final payload = {
        'id_kelompok': context.read<ActiveKelompokCubit>().state.activeId,
        'tanggal': _tanggal.toIso8601String().split('T')[0],
        'sesi': _selectedSesi ?? 1,
        'data': arr,
      };

      await ApiService.inputMassalTahfidz(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil menyimpan data massal.'),
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
            Icon(Icons.class_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Tidak ada kelas Tahfidz di kelompok ini.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    Widget globalBar = Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900.withValues(alpha: 0.95) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: primaryColor.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 5)),
        ],
        border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Sync, Date, Sesi, Sort
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text('Sync: $_tglUpdateCache', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor.withValues(alpha: 0.8))),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _pickTanggal,
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: primaryColor),
                        const SizedBox(width: 6),
                        Text(DateFormat('d MMM', 'id').format(_tanggal), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  ),
                ),
                if (_jadwalInfo != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    height: 32,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: _jadwalList.length > 1
                        ? DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedSesi,
                              isDense: true,
                              icon: Icon(Icons.arrow_drop_down, size: 18, color: primaryColor),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedSesi = val;
                                    _jadwalInfo = _jadwalList.firstWhere((j) => j['sesi'] == val);
                                  });
                                  _refreshData();
                                }
                              },
                              items: _jadwalList.map((j) {
                                final sj = j['sesi'] as int;
                                return DropdownMenuItem<int>(value: sj, child: Text('Sesi $sj (${j['jam_mulai']})'));
                              }).toList(),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time_rounded, size: 12, color: primaryColor),
                              const SizedBox(width: 4),
                              Text('Sesi ${_jadwalInfo?['sesi'] ?? 1} (${_jadwalInfo?['jam_mulai'] ?? '-'})', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
                            ],
                          ),
                  ),
                ],
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => setState(() => _sortAscending = !_sortAscending),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        Icon(_sortAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_sharp, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Row 2: Dropdowns & Kelipatan
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Pilih Kelas
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedKelasId,
                      isDense: true,
                      hint: const Text('Pilih Kelas', style: TextStyle(fontSize: 11)),
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      onChanged: (val) {
                        setState(() => _selectedKelasId = val);
                        _loadSantri();
                      },
                      items: _kelasList.map((k) {
                        final id = int.tryParse(k['id_kelas']?.toString() ?? '');
                        return DropdownMenuItem<int>(value: id, child: Text(k['tingkat']?.toString() ?? '-'));
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Status Absen
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatusAbsen,
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedStatusAbsen = val);
                          _refreshData();
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 'semua', child: Text('Semua Santri')),
                        DropdownMenuItem(value: 'kecuali_izin_sakit', child: Text('Kecuali Izin/Sakit')),
                        DropdownMenuItem(value: 'hanya_hadir', child: Text('Hanya Hadir')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Kelipatan Input
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      const Text('Kelipatan:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 40,
                        child: TextFormField(
                          controller: _kelipatanCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                          onChanged: (val) {
                            final k = double.tryParse(val);
                            if (k != null && k > 0) {
                              setState(() => _kelipatan = k);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    List<Map<String, dynamic>> sortedSantri = List.from(_santriList);
    sortedSantri.sort((a, b) {
      final nameA = a['nama_santri']?.toString() ?? '';
      final nameB = b['nama_santri']?.toString() ?? '';
      return _sortAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
    });

    return Column(
      children: [
        globalBar,
        Expanded(
          child: _loadingSantri
              ? const Center(child: CircularProgressIndicator())
              : sortedSantri.isEmpty
                  ? Center(child: Text('Tidak ada santri di kelas ini.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: sortedSantri.length,
                      itemBuilder: (context, i) {
                        final s = sortedSantri[i];
                        final nis = s['nis']?.toString() ?? '';
                        final row = _rowData[nis];
                        if (row == null) return const SizedBox.shrink();
                        return _TahfidzSantriCard(
                          key: ValueKey(nis),
                          index: i,
                          santri: s,
                          row: row,
                          kelipatan: _kelipatan,
                          onChanged: (key, val) {
                            setState(() => _rowData[nis]![key] = val);
                          },
                        );
                      },
                    ),
        ),
        if (_isSaving)
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _TahfidzSantriCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> santri;
  final Map<String, dynamic> row;
  final double kelipatan;
  final void Function(String key, dynamic value) onChanged;

  const _TahfidzSantriCard({
    Key? key,
    required this.index,
    required this.santri,
    required this.row,
    required this.kelipatan,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<_TahfidzSantriCard> createState() => _TahfidzSantriCardState();
}

class _TahfidzSantriCardState extends State<_TahfidzSantriCard> {
  late TextEditingController _zAkhirCtrl;
  late TextEditingController _zTotCtrl;
  late TextEditingController _sAkhirCtrl;
  late TextEditingController _sTotCtrl;
  late TextEditingController _mAkhirCtrl;
  late TextEditingController _mTotCtrl;

  @override
  void initState() {
    super.initState();
    final r = widget.row;
    _zAkhirCtrl = TextEditingController(text: _fmt(r['z_ak']));
    _zTotCtrl = TextEditingController(text: _fmt(r['z_tot']));
    _sAkhirCtrl = TextEditingController(text: _fmt(r['s_ak']));
    _sTotCtrl = TextEditingController(text: _fmt(r['s_tot']));
    _mAkhirCtrl = TextEditingController(text: _fmt(r['m_ak']));
    _mTotCtrl = TextEditingController(text: _fmt(r['m_tot']));
  }

  @override
  void didUpdateWidget(covariant _TahfidzSantriCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row != widget.row) {
      if (_zAkhirCtrl.text != _fmt(widget.row['z_ak'])) _zAkhirCtrl.text = _fmt(widget.row['z_ak']);
      if (_zTotCtrl.text != _fmt(widget.row['z_tot'])) _zTotCtrl.text = _fmt(widget.row['z_tot']);
      if (_sAkhirCtrl.text != _fmt(widget.row['s_ak'])) _sAkhirCtrl.text = _fmt(widget.row['s_ak']);
      if (_sTotCtrl.text != _fmt(widget.row['s_tot'])) _sTotCtrl.text = _fmt(widget.row['s_tot']);
      if (_mAkhirCtrl.text != _fmt(widget.row['m_ak'])) _mAkhirCtrl.text = _fmt(widget.row['m_ak']);
      if (_mTotCtrl.text != _fmt(widget.row['m_tot'])) _mTotCtrl.text = _fmt(widget.row['m_tot']);
    }
  }

  String _fmt(dynamic v) {
    final d = double.tryParse(v?.toString() ?? '0') ?? 0;
    if (d == 0) return '0';
    return d == d.toInt() ? d.toInt().toString() : d.toStringAsFixed(1).replaceAll('.0', '');
  }

  void _onAkhirChanged(String prefix, String val, TextEditingController totalCtrl) {
    final ak = double.tryParse(val) ?? 0;
    final aw = widget.row['${prefix}_aw'] as double;
    final tot = (ak - aw).clamp(0.0, 999.0);
    widget.onChanged('${prefix}_ak', ak);
    widget.onChanged('${prefix}_tot', tot);
    totalCtrl.text = _fmt(tot);
  }

  void _onTotChanged(String prefix, String val, TextEditingController akhirCtrl) {
    final tot = double.tryParse(val) ?? 0;
    final aw = widget.row['${prefix}_aw'] as double;
    final ak = aw + tot;
    widget.onChanged('${prefix}_tot', tot);
    widget.onChanged('${prefix}_ak', ak);
    akhirCtrl.text = _fmt(ak);
  }

  void _addTot(String prefix, double val, TextEditingController totalCtrl, TextEditingController akhirCtrl) {
    final currentTot = widget.row['${prefix}_tot'] as double;
    final newTot = (currentTot + val).clamp(0.0, 999.0);
    _onTotChanged(prefix, newTot.toString(), akhirCtrl);
    totalCtrl.text = _fmt(newTot);
  }

  @override
  void dispose() {
    _zAkhirCtrl.dispose();
    _zTotCtrl.dispose();
    _sAkhirCtrl.dispose();
    _sTotCtrl.dispose();
    _mAkhirCtrl.dispose();
    _mTotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.santri;
    final r = widget.row;
    final idx = widget.index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final nama = s['nama_santri']?.toString() ?? '-';
    final nis = s['nis']?.toString() ?? '-';
    
    // Label JUZ X logic (Pilar 4)
    String rawTingkat = s['tingkat']?.toString() ?? s['nama_kelas']?.toString() ?? '';
    if (rawTingkat.isEmpty || rawTingkat == 'null') rawTingkat = 'TAHFIDZ';
    String badge = rawTingkat;
    if (!badge.toUpperCase().contains('JUZ') && badge.toUpperCase() != 'TAHFIDZ') {
      badge = 'JUZ $badge';
    } else if (badge.toUpperCase() == 'TAHFIDZ') {
      badge = 'TAHFIDZ';
    }

    bool isLulus = r['z_status'] == 'Lulus';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('${idx + 1}', style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(nis, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: isDark ? Colors.indigo.withValues(alpha: 0.2) : Colors.indigo.shade50, borderRadius: BorderRadius.circular(6)),
                            child: Text(badge.toUpperCase(), style: TextStyle(fontSize: 9, color: isDark ? Colors.indigo.shade300 : Colors.indigo, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Rows Input (Pilar 4)
            _TahfidzInputRowBox(
              label: 'Ziyadah',
              color: Colors.blue.shade600,
              icon: Icons.arrow_upward_rounded,
              awal: r['z_aw'] as double,
              akhirCtrl: _zAkhirCtrl,
              totalCtrl: _zTotCtrl,
              kelipatan: widget.kelipatan,
              onAkhirChanged: (v) => _onAkhirChanged('z', v, _zTotCtrl),
              onTotalChanged: (v) => _onTotChanged('z', v, _zAkhirCtrl),
              onAdd: () => _addTot('z', widget.kelipatan, _zTotCtrl, _zAkhirCtrl),
              onSubtract: () => _addTot('z', -widget.kelipatan, _zTotCtrl, _zAkhirCtrl),
            ),
            const SizedBox(height: 8),
            _TahfidzInputRowBox(
              label: 'Sabaq',
              color: Colors.orange.shade600,
              icon: Icons.refresh_rounded,
              awal: r['s_aw'] as double,
              akhirCtrl: _sAkhirCtrl,
              totalCtrl: _sTotCtrl,
              kelipatan: widget.kelipatan,
              onAkhirChanged: (v) => _onAkhirChanged('s', v, _sTotCtrl),
              onTotalChanged: (v) => _onTotChanged('s', v, _sAkhirCtrl),
              onAdd: () => _addTot('s', widget.kelipatan, _sTotCtrl, _sAkhirCtrl),
              onSubtract: () => _addTot('s', -widget.kelipatan, _sTotCtrl, _sAkhirCtrl),
            ),
            const SizedBox(height: 8),
            _TahfidzInputRowBox(
              label: 'Manzil',
              color: Colors.green.shade600,
              icon: Icons.history_edu_rounded,
              awal: r['m_aw'] as double,
              akhirCtrl: _mAkhirCtrl,
              totalCtrl: _mTotCtrl,
              kelipatan: widget.kelipatan,
              onAkhirChanged: (v) => _onAkhirChanged('m', v, _mTotCtrl),
              onTotalChanged: (v) => _onTotChanged('m', v, _mAkhirCtrl),
              onAdd: () => _addTot('m', widget.kelipatan, _mTotCtrl, _mAkhirCtrl),
              onSubtract: () => _addTot('m', -widget.kelipatan, _mTotCtrl, _mAkhirCtrl),
            ),
            
            const SizedBox(height: 16),
            
            // Bottom Action Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final newVal = isLulus ? 'Ulang' : 'Lulus';
                      widget.onChanged('z_status', newVal);
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 44,
                      decoration: BoxDecoration(
                        color: isLulus ? Colors.green.withValues(alpha: 0.12) : (isDark ? Colors.red.withValues(alpha: 0.1) : Colors.red.shade50),
                        border: Border.all(color: isLulus ? Colors.green.shade700 : Colors.red.shade700, width: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isLulus ? Icons.check_rounded : Icons.refresh_rounded, color: isLulus ? Colors.green : Colors.red.shade500, size: 18),
                          const SizedBox(width: 4),
                          Text(isLulus ? 'Lulus' : 'Ulang', style: TextStyle(color: isLulus ? Colors.green : Colors.red.shade600, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                // (Placeholder features removed or commented to save space, keeping structure)
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TahfidzInputRowBox extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final double awal;
  final TextEditingController akhirCtrl;
  final TextEditingController totalCtrl;
  final double kelipatan;
  final ValueChanged<String> onAkhirChanged;
  final ValueChanged<String> onTotalChanged;
  final VoidCallback onAdd;
  final VoidCallback onSubtract;

  const _TahfidzInputRowBox({
    required this.label,
    required this.color,
    required this.icon,
    required this.awal,
    required this.akhirCtrl,
    required this.totalCtrl,
    required this.kelipatan,
    required this.onAkhirChanged,
    required this.onTotalChanged,
    required this.onAdd,
    required this.onSubtract,
  });

  String _fmt(dynamic v) {
    final d = double.tryParse(v?.toString() ?? '0') ?? 0;
    if (d == 0) return '0';
    return d == d.toInt() ? d.toInt().toString() : d.toStringAsFixed(1).replaceAll('.0', '');
  }

  @override
  Widget build(BuildContext context) {
    final strAwal = _fmt(awal);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kiri: Awal
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                  border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2))),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 10, color: color),
                        const SizedBox(width: 2),
                        Text(label, style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(strAwal, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
                    Text('Awal', style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.6), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            // Tengah: Total dgn Tombol -/+ 
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total Hal', style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: onSubtract,
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.remove, size: 16),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          height: 24,
                          width: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.shade100,
                          ),
                          child: TextFormField(
                            controller: totalCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.only(bottom: 8)),
                            onChanged: onTotalChanged,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.add, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Kanan: Akhir
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(9)),
                  border: Border(left: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2))),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Akhir', style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.6), fontWeight: FontWeight.bold)),
                    Container(
                      height: 20,
                      width: 50,
                      alignment: Alignment.center,
                      child: TextFormField(
                        controller: akhirCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.only(bottom: 12)),
                        onChanged: onAkhirChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
