import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/api/services/tahfidz_api_service.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/tahfidz_screen.dart'
    show formatHal, formatTanggal;

/// Tab 3 — Riwayat global setoran harian seluruh santri Tahfidz.
class TahfidzRiwayatTab extends StatefulWidget {
  const TahfidzRiwayatTab({super.key});

  @override
  State<TahfidzRiwayatTab> createState() => _TahfidzRiwayatTabState();
}

class _TahfidzRiwayatTabState extends State<TahfidzRiwayatTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DateTime _selectedDate = DateTime.now();
  bool _loading = false;
  List<Map<String, dynamic>> _riwayat = [];
  Map<String, dynamic> _summary = {};
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final activeId =
          context.read<ActiveKelompokCubit>().state.activeId;
      final tanggal = _selectedDate.toIso8601String().split('T')[0];
      final res = await TahfidzApiService.getTahfidzList(tanggal: tanggal);
      final raw = res['data'] ?? res;
      final santriList = raw is Map ? (raw['santri_list'] ?? []) : raw;

      // Flatten semua riwayat hari ini dari setiap santri
      final List<Map<String, dynamic>> allRiwayat = [];
      int totalZ = 0, totalS = 0, totalM = 0, totalLulus = 0, totalUlang = 0;

      if (santriList is List) {
        for (final s in santriList) {
          final nis = s['nis']?.toString() ?? '';
          final nama = s['nama_santri']?.toString() ?? '-';
          final riwayatHari = s['riwayat_hari_ini'];
          if (riwayatHari is List) {
            for (final r in riwayatHari) {
              if (r is Map) {
                final Map<String, dynamic> row = {
                  'nis': nis,
                  'nama_santri': nama,
                };
                r.forEach((k, v) => row[k.toString()] = v);
                allRiwayat.add(row);
                totalZ += (double.tryParse(
                          r['setoran_hal_total']?.toString() ?? '0',
                        ) ??
                        0)
                    .toInt();
                totalS += (double.tryParse(
                          r['murojaah_baru_total']?.toString() ?? '0',
                        ) ??
                        0)
                    .toInt();
                totalM += (double.tryParse(
                          r['murojaah_lama_total']?.toString() ?? '0',
                        ) ??
                        0)
                    .toInt();
                if (r['status_lulus']?.toString().toLowerCase() == 'lulus') {
                  totalLulus++;
                } else {
                  totalUlang++;
                }
              }
            }
          }
        }
      }

      setState(() {
        _riwayat = allRiwayat;
        _summary = {
          'total_ziyadah': totalZ,
          'total_sabaq': totalS,
          'total_manzil': totalM,
          'total_lulus': totalLulus,
          'total_ulang': totalUlang,
        };
        _loading = false;
      });

      // suppress unused warning
      activeId.toString();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final custom = Theme.of(context).extension<AppCustomStyles>()!;

    return Column(
      children: [
        // ── Date Picker Header ────────────────────────────────────────────────
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Text(
                'Tanggal:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: custom.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('d MMMM yyyy', 'id').format(_selectedDate),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: custom.success,
                  size: 20,
                ),
                onPressed: _load,
                tooltip: 'Muat Ulang',
              ),
            ],
          ),
        ),
        // ── Summary Stats ─────────────────────────────────────────────────────
        if (!_loading && _error.isEmpty && _riwayat.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: custom.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  label: 'Ziyadah',
                  value: '${_summary['total_ziyadah']} hal',
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icons.arrow_upward_rounded,
                ),
                _SummaryItem(
                  label: 'Sabaq',
                  value: '${_summary['total_sabaq']} hal',
                  color: custom.warning,
                  icon: Icons.refresh_rounded,
                ),
                _SummaryItem(
                  label: 'Manzil',
                  value: '${_summary['total_manzil']} hal',
                  color: custom.success,
                  icon: Icons.history_edu,
                ),
                _SummaryItem(
                  label: 'Lulus',
                  value: '${_summary['total_lulus']}x',
                  color: custom.success,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),
        // ── Content ───────────────────────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
                  ? _buildError()
                  : _riwayat.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada setoran pada tanggal ini.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          itemCount: _riwayat.length,
                          itemBuilder: (context, i) => _RiwayatCard(
                            key: ValueKey(i),
                            data: _riwayat[i],
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _load();
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RiwayatCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppCustomStyles>()!;
    final nama = data['nama_santri']?.toString() ?? '-';
    final tanggal = formatTanggal(data['tanggal']?.toString());
    final ziyadah =
        double.tryParse(data['setoran_hal_total']?.toString() ?? '0') ?? 0;
    final sabaq =
        double.tryParse(data['murojaah_baru_total']?.toString() ?? '0') ?? 0;
    final manzil =
        double.tryParse(data['murojaah_lama_total']?.toString() ?? '0') ?? 0;
    final status = data['status_lulus']?.toString() ?? 'Lulus';
    final isLulus = status.toLowerCase() == 'lulus';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: custom.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tanggal,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    if (ziyadah > 0)
                      _MiniTag(
                        'Z: ${formatHal(ziyadah)} hal',
                        Theme.of(context).colorScheme.primary,
                      ),
                    if (sabaq > 0)
                      _MiniTag('S: ${formatHal(sabaq)} hal', custom.warning),
                    if (manzil > 0)
                      _MiniTag('M: ${formatHal(manzil)} hal', custom.success),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isLulus
                  ? custom.success.withValues(alpha: 0.15)
                  : custom.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isLulus ? custom.success : custom.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String text;
  final Color color;
  const _MiniTag(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
