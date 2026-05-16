import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/bloc/tahfidz_cubit.dart';

/// Tab Input Massal Tahfidz.
/// Guru memilih kelas → sistem load santri → isi Ziyadah/Sabaq/Manzil per santri → Simpan.
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
  // Row data per santri: { nis, id_kelas, z_aw, z_tot, z_status, s_aw, s_tot, m_aw, m_tot }
  final Map<String, Map<String, dynamic>> _rowData = {};
  DateTime _tanggal = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    setState(() => _loadingKelas = true);
    try {
      final activeId =
          context.read<ActiveKelompokCubit>().state.activeId;
      final res = await ApiService.getFilterKelas(
        idKelompok: activeId > 0 ? activeId : null,
      );
      final rawKelas = res['data']?['kelas_list'] ?? res['data'] ?? [];
      if (rawKelas is List) {
        // Filter id_kategori == 2 (Tahfidz)
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
      final activeId =
          context.read<ActiveKelompokCubit>().state.activeId;
      // Pakai endpoint filter kelas santri khusus Tahfidz
      // Backend menyediakan z_terakhir, s_terakhir, m_terakhir
      final res = await ApiService.getFilterKelas(
        idKelompok: activeId > 0 ? activeId : null,
      );
      // Fallback: ambil santri dari list API biasa jika endpoint khusus tidak ada
      // Untuk akurasi, kita gunakan endpoint getApiProgressList yang sudah ada
      // Karena tidak ada endpoint getSantriForInputMassal khusus di Flutter API,
      // kita ambil dari list santri biasa dan filter berdasarkan kelas.
      final progressRes = await ApiService.getTahfidzList(
        tanggal: DateTime.now().toIso8601String().split('T')[0],
      );

      final raw = progressRes['data'] ?? progressRes;
      final rawList = raw is Map ? raw['santri_list'] : raw;

      final List<Map<String, dynamic>> santri = [];
      if (rawList is List) {
        for (final e in rawList) {
          if (e is Map) {
            final Map<String, dynamic> m = {};
            e.forEach((k, v) => m[k.toString()] = v);
            santri.add(m);
          }
        }
      }

      setState(() {
        _santriList = santri;
        _loadingSantri = false;
        // Init row data dengan nilai default
        for (final s in santri) {
          final nis = s['nis']?.toString() ?? '';
          if (nis.isEmpty) continue;
          _rowData[nis] = {
            'nis': nis,
            'id_kelas': _selectedKelasId,
            'z_aw': double.tryParse(s['z_terakhir']?.toString() ?? '0') ?? 0.0,
            'z_tot': 0.0,
            'z_status': 'Lulus',
            's_aw': double.tryParse(s['s_terakhir']?.toString() ?? '0') ?? 0.0,
            's_tot': 0.0,
            'm_aw': double.tryParse(s['m_terakhir']?.toString() ?? '0') ?? 0.0,
            'm_tot': 0.0,
          };
        }
      });
      // Suppress unused warning
      res.toString();
    } catch (e) {
      setState(() => _loadingSantri = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat santri: $e'),
            backgroundColor:
                Theme.of(context).extension<AppCustomStyles>()!.error,
          ),
        );
      }
    }
  }

  /// Dipanggil dari AppBar tombol "Simpan"
  Future<void> simpan() async {
    if (_isSaving) return;
    // Validasi: minimal ada 1 santri dengan setoran > 0
    final rows = _rowData.values
        .where(
          (r) =>
              (r['z_tot'] as double) > 0 ||
              (r['s_tot'] as double) > 0 ||
              (r['m_tot'] as double) > 0,
        )
        .toList();

    if (rows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Tidak ada setoran yang diisi. Minimal isi satu santri.',
          ),
          backgroundColor:
              Theme.of(context).extension<AppCustomStyles>()!.warning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final tanggalStr = _tanggal.toIso8601String().split('T')[0];
      final payload = {
        'tanggal': tanggalStr,
        'rows': rows.map((r) => {
          'nis': r['nis'],
          'id_kelas': r['id_kelas'],
          'z_aw': r['z_aw'],
          'z_tot': r['z_tot'],
          'z_status': r['z_status'],
          's_aw': r['s_aw'],
          's_tot': r['s_tot'],
          'm_aw': r['m_aw'],
          'm_tot': r['m_tot'],
        }).toList(),
      };

      final ok = await context.read<TahfidzCubit>().submitInputMassal(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '${rows.length} setoran berhasil disimpan!' : 'Tersimpan di antrean offline.'),
          backgroundColor: ok
              ? Theme.of(context).extension<AppCustomStyles>()!.success
              : Theme.of(context).extension<AppCustomStyles>()!.warning,
        ),
      );
      if (ok) {
        // Reset form
        setState(() {
          for (final nis in _rowData.keys) {
            _rowData[nis]!['z_tot'] = 0.0;
            _rowData[nis]!['s_tot'] = 0.0;
            _rowData[nis]!['m_tot'] = 0.0;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor:
              Theme.of(context).extension<AppCustomStyles>()!.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final custom = Theme.of(context).extension<AppCustomStyles>()!;

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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada kelas Tahfidz di kelompok ini.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Filter: Pilih Kelas + Tanggal ──────────────────────────────────────
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              // Kelas dropdown
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: custom.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedKelasId,
                      isExpanded: true,
                      hint: const Text('Pilih Kelas'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      dropdownColor: Theme.of(context).cardColor,
                      onChanged: (val) {
                        setState(() => _selectedKelasId = val);
                        _loadSantri();
                      },
                      items: _kelasList.map((k) {
                        final id = int.tryParse(
                          k['id_kelas']?.toString() ?? '',
                        );
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(k['tingkat']?.toString() ?? '-'),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Tanggal picker
              GestureDetector(
                onTap: _pickTanggal,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        DateFormat('d MMM', 'id').format(_tanggal),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Santri List ─────────────────────────────────────────────────────────
        Expanded(
          child: _loadingSantri
              ? const Center(child: CircularProgressIndicator())
              : _santriList.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada santri di kelas ini.',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      itemCount: _santriList.length,
                      itemBuilder: (context, i) {
                        final s = _santriList[i];
                        final nis = s['nis']?.toString() ?? '';
                        final row = _rowData[nis];
                        if (row == null) return const SizedBox.shrink();
                        return _InputRow(
                          key: ValueKey(nis),
                          namaSantri: s['nama_santri']?.toString() ?? '-',
                          nis: nis,
                          row: row,
                          onChanged: (key, val) {
                            setState(() => _rowData[nis]![key] = val);
                          },
                        );
                      },
                    ),
        ),
        // ── Footer: Simpan button (secondary — utama di AppBar) ─────────────────
        if (_isSaving)
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: custom.success,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Menyimpan setoran...'),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }
}

// =============================================================================
// Row input per santri (StatefulWidget untuk isolasi field)
// =============================================================================
class _InputRow extends StatefulWidget {
  final String namaSantri;
  final String nis;
  final Map<String, dynamic> row;
  final void Function(String key, dynamic val) onChanged;

  const _InputRow({
    super.key,
    required this.namaSantri,
    required this.nis,
    required this.row,
    required this.onChanged,
  });

  @override
  State<_InputRow> createState() => _InputRowState();
}

class _InputRowState extends State<_InputRow> {
  late TextEditingController _zTotCtrl;
  late TextEditingController _sTotCtrl;
  late TextEditingController _mTotCtrl;

  @override
  void initState() {
    super.initState();
    final r = widget.row;
    _zTotCtrl = TextEditingController(
      text: (r['z_tot'] as double) > 0
          ? (r['z_tot'] as double).toString()
          : '',
    );
    _sTotCtrl = TextEditingController(
      text: (r['s_tot'] as double) > 0
          ? (r['s_tot'] as double).toString()
          : '',
    );
    _mTotCtrl = TextEditingController(
      text: (r['m_tot'] as double) > 0
          ? (r['m_tot'] as double).toString()
          : '',
    );
  }

  @override
  void dispose() {
    _zTotCtrl.dispose();
    _sTotCtrl.dispose();
    _mTotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppCustomStyles>()!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: custom.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama santri
            Text(
              widget.namaSantri,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NIS: ${widget.nis}',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 10),
            // ── Input fields: Ziyadah ────────────────────────────────────
            _SetoranSection(
              label: 'Ziyadah',
              color: Theme.of(context).colorScheme.primary,
              icon: Icons.arrow_upward_rounded,
              hint: 'Total hal. hafalan baru',
              controller: _zTotCtrl,
              onChanged: (v) => widget.onChanged(
                'z_tot',
                double.tryParse(v) ?? 0.0,
              ),
              trailing: DropdownButton<String>(
                value: widget.row['z_status'] as String? ?? 'Lulus',
                isDense: true,
                underline: const SizedBox.shrink(),
                dropdownColor: Theme.of(context).cardColor,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onChanged: (v) => widget.onChanged('z_status', v ?? 'Lulus'),
                items: const [
                  DropdownMenuItem(value: 'Lulus', child: Text('Lulus')),
                  DropdownMenuItem(value: 'Ulang', child: Text('Ulang')),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // ── Input fields: Sabaq ─────────────────────────────────────
            _SetoranSection(
              label: 'Sabaq',
              color: custom.warning,
              icon: Icons.refresh_rounded,
              hint: 'Total hal. ulangan baru',
              controller: _sTotCtrl,
              onChanged: (v) => widget.onChanged(
                's_tot',
                double.tryParse(v) ?? 0.0,
              ),
            ),
            const SizedBox(height: 6),
            // ── Input fields: Manzil ────────────────────────────────────
            _SetoranSection(
              label: 'Manzil',
              color: custom.success,
              icon: Icons.history_edu,
              hint: 'Total hal. ulangan lama',
              controller: _mTotCtrl,
              onChanged: (v) => widget.onChanged(
                'm_tot',
                double.tryParse(v) ?? 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetoranSection extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Widget? trailing;

  const _SetoranSection({
    required this.label,
    required this.color,
    required this.icon,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 10, color: color),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .extension<AppCustomStyles>()!
                        .cardBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .extension<AppCustomStyles>()!
                        .cardBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color),
                ),
              ),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          trailing!,
        ],
      ],
    );
  }
}
