import 'dart:async';
import 'package:flutter/foundation.dart'; // compute()
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'package:manajemen_tahsin_app/features/absensi/domain/repositories/absensi_repository.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/bloc/absensi_cubit.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/shared/widgets/custom_date_range_field.dart';

// ─── Off-Main-Thread Parser ────────────────────────────────────────────────────
// Fungsi top-level wajib agar compute() bisa menjalankannya di Isolate terpisah.
Map<String, dynamic> _parseRekapData(Map<String, dynamic> rawData) {
  final hariKerja = int.tryParse(rawData['hari_kerja']?.toString() ?? '0') ?? 0;
  final rawRekap = rawData['rekap'];
  final List<Map<String, dynamic>> rekapList = rawRekap is List
      ? rawRekap.whereType<Map>().map((e) {
          final Map<String, dynamic> m = {};
          e.forEach((k, v) => m[k.toString()] = v);
          return m;
        }).toList()
      : [];
  return {'hari_kerja': hariKerja, 'rekap': rekapList};
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

  @override
  void initState() {
    super.initState();
    _tglAkhir = DateTime.now();
    _tglMulai = _tglAkhir!.subtract(const Duration(days: 6));
    _initFilter();
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
      setState(() => _filterLoaded = true);
      _triggerLoad();
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
      appBar: AppBar(
        title: const Text('Rekap Absensi'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        iconTheme: IconThemeData(color: cs.onPrimary),
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
              });
            }
          }
        },
        builder: (context, state) {
          // ── Loading Skeleton saat pertama kali fetch atau parsing ─────────
          if (state is AbsensiLoading || _isParsing) {
            return Column(children: [
              _buildFilterSection(0, cs),
              Expanded(child: _buildSkeletonLoader(cs)),
            ]);
          }

          if (state is AbsensiError) {
            return Column(children: [
              _buildFilterSection(0, cs),
              Expanded(child: ErrorStateWidget(message: state.message, onRetry: _triggerLoad)),
            ]);
          }

          return Column(children: [
            _buildFilterSection(_hariKerja, cs),
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

  // ─── Skeleton Loader ────────────────────────────────────────────────────────
  Widget _buildSkeletonLoader(ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 6,
      itemBuilder: (_, __) => _SkeletonCard(cs: cs),
    );
  }

  Widget _buildFilterSection(int hariKerja, ColorScheme cs) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            flex: 6,
            child: CustomDateRangeField(
              selectedRange: _tglMulai != null && _tglAkhir != null
                  ? DateTimeRange(start: _tglMulai!, end: _tglAkhir!)
                  : null,
              onDateRangeSelected: (range) {
                if (range != null) {
                  setState(() {
                    _tglMulai = range.start;
                    _tglAkhir = range.end;
                  });
                  _triggerLoad();
                }
              },
            ),
          ),
          if (_kelasList.length > 1) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
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
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.secondary.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            Icon(Icons.event_available, color: cs.secondary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Total Hari Kerja: $hariKerja Hari',
              style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSecondaryContainer),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> rekapList, int hariKerja) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: rekapList.length,
      // Ekstrak item ke StatelessWidget terpisah → TIDAK rebuild seluruh list
      itemBuilder: (context, index) => _RekapItem(
        key: ValueKey(rekapList[index]['nis']),
        item: rekapList[index],
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

// ─── Skeleton Card ─────────────────────────────────────────────────────────
class _SkeletonCard extends StatefulWidget {
  final ColorScheme cs;
  const _SkeletonCard({required this.cs});

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final shimmerColor = widget.cs.onSurface.withValues(alpha: _anim.value * 0.12);
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: shimmerColor, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 6),
                    Container(height: 11, width: 80, decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(4))),
                  ]),
                ),
                Container(width: 44, height: 28, decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(20))),
              ]),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (_) => Container(width: 48, height: 36, decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(6)))),
              ),
            ]),
          ),
        );
      },
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
