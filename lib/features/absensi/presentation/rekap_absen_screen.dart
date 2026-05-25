import 'dart:async';
import 'package:flutter/foundation.dart'; // compute()
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'package:manajemen_tahsin_app/features/absensi/domain/repositories/absensi_repository.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/bloc/absensi_cubit.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/widgets/app_header_bar.dart';

// ─── Off-Main-Thread Parser ────────────────────────────────────────────────────
// Fungsi top-level wajib agar compute() bisa menjalankannya di Isolate terpisah.
Map<String, dynamic> _parseRekapData(Map<String, dynamic> rawData) {
  final hariKerja = int.tryParse(rawData['hari_kerja']?.toString() ?? '0') ?? 0;
  final rawRekap = rawData['rekap'];
  int totalHadir = 0;
  int totalSakit = 0;
  int totalIzin = 0;
  int totalAlpha = 0;

  final List<Map<String, dynamic>> rekapList = rawRekap is List
      ? rawRekap.whereType<Map>().map((e) {
          final Map<String, dynamic> m = {};
          e.forEach((k, v) => m[k.toString()] = v);
          
          totalHadir += int.tryParse(m['hadir']?.toString() ?? '0') ?? 0;
          totalSakit += int.tryParse(m['sakit']?.toString() ?? '0') ?? 0;
          totalIzin += int.tryParse(m['izin']?.toString() ?? '0') ?? 0;
          totalAlpha += int.tryParse(m['alpha']?.toString() ?? '0') ?? 0;
          
          return m;
        }).toList()
      : [];
      
  return {
    'hari_kerja': hariKerja,
    'rekap': rekapList,
    'total_hadir': totalHadir,
    'total_sakit': totalSakit,
    'total_izin': totalIzin,
    'total_alpha': totalAlpha,
  };
}

/// Halaman Rekap Absensi (NETWORK-ONLY — Dilarang Cache).
/// Data real-time untuk pimpinan. Jika offline, tampilkan [ErrorStateWidget].
class RekapAbsenScreen extends StatelessWidget {
  const RekapAbsenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AbsensiCubit(
        repository: context.read<AbsensiRepository>(),
        activeKelompokCubit: context.read<ActiveKelompokCubit>(),
      ),
      child: const _RekapAbsenView(),
    );
  }
}

class _RekapAbsenView extends StatefulWidget {
  const _RekapAbsenView();

  @override
  State<_RekapAbsenView> createState() => _RekapAbsenViewState();
}

class _RekapAbsenViewState extends State<_RekapAbsenView> {
  DateTime? _tglMulai;
  DateTime? _tglAkhir;
  List<Map<String, dynamic>> _kelasList = [];
  int? _selectedKelasId;
  bool _filterLoaded = false;

  // ─── Parsed state (hasil compute()) ─────────────────────────────────────────
  bool _isParsing = false;
  int _hariKerja = 0;
  List<Map<String, dynamic>> _rekapList = [];
  
  int _totalHadir = 0;
  int _totalSakit = 0;
  int _totalIzin = 0;
  int _totalAlpha = 0;

  bool _isBulanIni = true;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _setBulanIni();
    _initFilter();
  }

  void _setBulanIni() {
    final now = DateTime.now();
    _tglMulai = DateTime(now.year, now.month, 1);
    _tglAkhir = DateTime(now.year, now.month + 1, 0);
  }

  void _setBulanLalu() {
    final now = DateTime.now();
    _tglMulai = DateTime(now.year, now.month - 1, 1);
    _tglAkhir = DateTime(now.year, now.month, 0);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _initFilter() async {
    try {
      final repo = context.read<AbsensiRepository>();
      final filterResp = await repo.getFilterKelas();
      final rawData = filterResp['data'];
      if (rawData is Map) {
        final kl = rawData['kelas_list'];
        if (kl is List) {
          setState(() {
            _kelasList = kl.whereType<Map>().map((e) {
              final Map<String, dynamic> m = {};
              e.forEach((k, v) => m[k.toString()] = v);
              return m;
            }).toList();
          });
        }
      }
    } catch (_) {
      // Abaikan error filter, lanjut muat data utama
    } finally {
      if (mounted) {
        setState(() => _filterLoaded = true);
        _triggerLoad();
      }
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  void _triggerLoad() {
    final mulai = _tglMulai != null ? _formatDate(_tglMulai!) : null;
    final akhir = _tglAkhir != null ? _formatDate(_tglAkhir!) : null;
    if (mulai != null && akhir != null) {
      context.read<AbsensiCubit>().fetchRekapAbsen(mulai, akhir, idKelas: _selectedKelasId);
    }
  }

  /// Parsing data di Isolate terpisah agar Main UI Thread tidak freeze.
  Future<void> _parseOnIsolate(Map<String, dynamic> rawData) async {
    if (!mounted) return;
    setState(() => _isParsing = true);
    try {
      final result = await compute(_parseRekapData, rawData);
      if (!mounted) return;
      setState(() {
        _hariKerja = result['hari_kerja'] as int;
        _rekapList = result['rekap'] as List<Map<String, dynamic>>;
        _totalHadir = result['total_hadir'] as int;
        _totalSakit = result['total_sakit'] as int;
        _totalIzin = result['total_izin'] as int;
        _totalAlpha = result['total_alpha'] as int;
        _isParsing = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isParsing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (!_filterLoaded) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppHeaderBar(
        title: _isSearching ? '' : 'Rekap Absensi',
        customTitle: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: TextStyle(color: cs.onPrimary, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau NIS...',
                  hintStyle: TextStyle(color: cs.onPrimary.withValues(alpha: 0.6), fontSize: 16),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchCtrl.clear();
                  _searchQuery = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          )
        ],
      ),
      body: BlocConsumer<AbsensiCubit, AbsensiState>(
        listenWhen: (_, current) => current is AbsensiLoaded || current is AbsensiError,
        listener: (context, state) {
          if (state is AbsensiLoaded) {
            final rawData = state.data['data'];
            if (rawData is Map<String, dynamic>) {
              _parseOnIsolate(rawData);
            } else {
              setState(() {
                _hariKerja = 0;
                _rekapList = [];
                _totalHadir = 0;
                _totalSakit = 0;
                _totalIzin = 0;
                _totalAlpha = 0;
              });
            }
          }
        },
        builder: (context, state) {
          // ── Loading Skeleton saat pertama kali fetch atau parsing ─────────
          if (state is AbsensiLoading || _isParsing) {
            return Column(children: [
              _buildFilterSection(0, cs),
              Expanded(child: const GlobalSkeletonWidget()),
            ]);
          }

          if (state is AbsensiError) {
            return Column(children: [
              _buildFilterSection(0, cs),
              Expanded(child: GlobalErrorWidget(message: state.message, onRetry: _triggerLoad)),
            ]);
          }

          return Column(children: [
            _buildFilterSection(_hariKerja, cs),
            _buildGlobalSummary(cs),
            Expanded(
              child: _rekapList.isEmpty
                  ? _buildEmptyState(cs)
                  : _buildList(_rekapList, _hariKerja),
            ),
          ]);
        },
      ),
    );
  }



  Widget _buildFilterSection(int hariKerja, ColorScheme cs) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            flex: 5,
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Bulan Ini', style: TextStyle(fontSize: 12))),
                ButtonSegment(value: false, label: Text('Bulan Lalu', style: TextStyle(fontSize: 12))),
              ],
              selected: {_isBulanIni},
              onSelectionChanged: (val) {
                setState(() {
                  _isBulanIni = val.first;
                  if (_isBulanIni) {
                    _setBulanIni();
                  } else {
                    _setBulanLalu();
                  }
                });
                _triggerLoad();
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          if (_kelasList.length > 1) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: _selectedKelasId,
                    hint: const Text('Semua Kelas', style: TextStyle(fontSize: 12)),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurface.withValues(alpha: 0.5), size: 16),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Semua Kelas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      ..._kelasList.map((k) {
                        final id = int.tryParse(k['id_kelas']?.toString() ?? '0') ?? 0;
                        final t = k['tingkat']?.toString() ?? '-';
                        final n = k['nama_kelompok']?.toString() ?? '';
                        return DropdownMenuItem<int?>(
                          value: id,
                          child: Text('Kelas $t ${n.isNotEmpty ? "($n)" : ""}', style: const TextStyle(fontSize: 12)),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedKelasId = val);
                      _triggerLoad();
                    },
                  ),
                ),
              ),
            ),
          ],
        ]),
      ]),
    );
  }

  Widget _buildGlobalSummary(ColorScheme cs) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.analytics_rounded, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text('Total Global Kelas', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onPrimaryContainer)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$_hariKerja Hari Kerja', style: TextStyle(color: cs.onPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(label: 'Hadir', value: _totalHadir.toString(), color: Colors.green.shade700),
                _StatItem(label: 'Sakit', value: _totalSakit.toString(), color: Colors.blue.shade700),
                _StatItem(label: 'Izin', value: _totalIzin.toString(), color: Colors.orange.shade700),
                _StatItem(label: 'Alpha', value: _totalAlpha.toString(), color: Colors.red.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> rekapList, int hariKerja) {
    final filtered = rekapList.where((e) {
      if (_searchQuery.isEmpty) return true;
      final name = (e['nama_santri']?.toString() ?? '').toLowerCase();
      final nis = (e['nis']?.toString() ?? '').toLowerCase();
      return name.contains(_searchQuery) || nis.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text('Santri tidak ditemukan', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _RekapItem(
        key: ValueKey(filtered[index]['nis']),
        item: filtered[index],
        index: index,
        hariKerja: hariKerja,
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.event_busy, size: 64, color: cs.onSurface.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text(
          'Tidak ada data rekap\npada tanggal tersebut',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: cs.onSurface.withValues(alpha: 0.6)),
        ),
      ]),
    );
  }
}

// ─── Item Rekap (StatelessWidget — zero rebuild overhead) ───────────────────
class _RekapItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final int hariKerja;

  const _RekapItem({super.key, required this.item, required this.index, required this.hariKerja});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final namaSantri = item['nama_santri']?.toString() ?? 'Tanpa Nama';
    final nis = item['nis']?.toString() ?? '-';
    final hadir = item['hadir']?.toString() ?? '0';
    final izin = item['izin']?.toString() ?? '0';
    final sakit = item['sakit']?.toString() ?? '0';
    final alpa = item['alpha']?.toString() ?? '0';
    final hadirInt = int.tryParse(hadir) ?? 0;
    final double persentase = hariKerja > 0 ? (hadirInt / hariKerja) * 100 : 0.0;

    Color pctColor;
    if (persentase < 50) {
      pctColor = cs.error;
    } else if (persentase < 80) {
      pctColor = Colors.orange.shade700;
    } else {
      pctColor = Colors.green.shade700;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Text('${index + 1}', style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(namaSantri, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('NIS: $nis', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6))),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: pctColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: pctColor.withValues(alpha: 0.3)),
              ),
              child: Text('${persentase.toStringAsFixed(0)}%', style: TextStyle(color: pctColor, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ]),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(label: 'Hadir', value: hadir, color: Colors.green.shade700),
              _StatItem(label: 'Sakit', value: sakit, color: Colors.blue.shade700),
              _StatItem(label: 'Izin', value: izin, color: Colors.orange.shade700),
              _StatItem(label: 'Alpha', value: alpa, color: Colors.red.shade700),
            ],
          ),
        ]),
      ),
    );
  }
}


// ─── Stat Item ─────────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
    ]);
  }
}
