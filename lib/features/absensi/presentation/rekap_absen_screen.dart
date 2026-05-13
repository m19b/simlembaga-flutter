import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'package:manajemen_tahsin_app/features/absensi/domain/repositories/absensi_repository.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/bloc/absensi_cubit.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/shared/widgets/custom_date_range_field.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;
    if (!_filterLoaded) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20))),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Rekap Absensi', style: TextStyle(color: isDark ? textColor : Colors.white)),
        backgroundColor: isDark ? Theme.of(context).colorScheme.surface : const Color(0xFF1B5E20),
        iconTheme: IconThemeData(color: isDark ? textColor : Colors.white),
      ),
      body: BlocBuilder<AbsensiCubit, AbsensiState>(
        builder: (context, state) {
          if (state is AbsensiLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
          }

          if (state is AbsensiError) {
            return Column(
              children: [
                _buildFilterSection(0),
                Expanded(
                  child: ErrorStateWidget(
                    message: state.message,
                    onRetry: _triggerLoad,
                  ),
                ),
              ],
            );
          }

          if (state is AbsensiLoaded) {
            final rawData = state.data['data'];
            final Map<String, dynamic> data = rawData is Map<String, dynamic> ? rawData : {};
            final hariKerja = int.tryParse(data['hari_kerja']?.toString() ?? '0') ?? 0;
            final rawRekap = data['rekap'];
            final rekapList = rawRekap is List
                ? rawRekap.whereType<Map>().map((e) {
                    final Map<String, dynamic> m = {};
                    e.forEach((k, v) => m[k.toString()] = v);
                    return m;
                  }).toList()
                : <Map<String, dynamic>>[];

            return Column(
              children: [
                _buildFilterSection(hariKerja),
                Expanded(
                  child: rekapList.isEmpty ? _buildEmptyState() : _buildList(rekapList, hariKerja),
                ),
              ],
            );
          }

          // AbsensiInitial — belum ada data
          return Column(
            children: [
              _buildFilterSection(0),
              Expanded(child: _buildEmptyState()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(int hariKerja) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        isExpanded: true,
                        value: _selectedKelasId,
                        hint: const Text('Semua Kelas', style: TextStyle(fontSize: 12)),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 16),
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
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1) : Colors.blue[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Total Hari Kerja: $hariKerja Hari',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade300 : Colors.blue[900]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> rekapList, int hariKerja) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: rekapList.length,
      itemBuilder: (context, index) {
        final item = rekapList[index];
        final namaSantri = item['nama_santri']?.toString() ?? 'Tanpa Nama';
        final nis = item['nis']?.toString() ?? '-';
        final hadir = item['hadir']?.toString() ?? '0';
        final izin = item['izin']?.toString() ?? '0';
        final sakit = item['sakit']?.toString() ?? '0';
        final alpa = item['alpha']?.toString() ?? '0';
        final hadirInt = int.tryParse(hadir) ?? 0;
        final double persentase = hariKerja > 0 ? (hadirInt / hariKerja) * 100 : 0.0;

        Color pctColor = Colors.green[700]!;
        if (persentase < 50) {
          pctColor = Colors.red[700]!;
        } else if (persentase < 80) {
          pctColor = Colors.orange[700]!;
        }

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green[50],
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(namaSantri, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text('NIS: $nis', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: pctColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: pctColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${persentase.toStringAsFixed(0)}%',
                        style: TextStyle(color: pctColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(label: 'Hadir', value: hadir, color: Colors.green[700]!),
                    _StatItem(label: 'Sakit', value: sakit, color: Colors.blue[700]!),
                    _StatItem(label: 'Izin', value: izin, color: Colors.orange[700]!),
                    _StatItem(label: 'Alpha', value: alpa, color: Colors.red[700]!),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data rekap\npada tanggal tersebut',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
      ],
    );
  }
}
