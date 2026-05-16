import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/bloc/pra_tahfidz_cubit.dart';

/// Tab 1: Input Massal setoran harian untuk semua santri sekaligus
class PraTahfidzInputMassalTab extends StatefulWidget {
  const PraTahfidzInputMassalTab({super.key});

  @override
  State<PraTahfidzInputMassalTab> createState() =>
      _PraTahfidzInputMassalTabState();
}

class _PraTahfidzInputMassalTabState extends State<PraTahfidzInputMassalTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _santriList = [];
  final Map<String, TextEditingController> _halTotalCtrl = {};
  final Map<String, TextEditingController> _halAwalCtrl = {};
  final Map<String, String> _statusBacaan = {};

  // Global jml dibaca — mempengaruhi seluruh baris sekaligus
  final TextEditingController _globalCtrl = TextEditingController();

  DateTime _tanggal = DateTime.now();
  String _sesi = 'Pagi';
  bool _submitting = false;

  static const List<String> _sesiList = ['Pagi', 'Sore', 'Malam'];
  static const List<String> _statusList = ['Sesuai Target', 'Kurang', 'Lebih'];

  // ── Format halaman: tidak tampilkan ".0" jika tidak ada desimal ──────────
  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    // Hapus trailing nol, contoh: 20.50 → 20.5
    return v.toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  // ── Listener global jml dibaca → broadcast ke semua baris ─────────────────
  void _onGlobalChanged() {
    final val = _globalCtrl.text;
    for (final ctrl in _halTotalCtrl.values) {
      if (ctrl.text != val) ctrl.text = val;
    }
  }

  @override
  void initState() {
    super.initState();
    _globalCtrl.addListener(_onGlobalChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFromState());
  }

  void _initFromState() {
    final state = context.read<PraTahfidzCubit>().state;
    if (state is PraTahfidzLoaded) _buildSantriList(state.data);
  }

  void _buildSantriList(Map<String, dynamic> data) {
    final actualData = data['data'] ?? data;
    final rawList = actualData['santri_list'];
    if (rawList is! List) return;

    final list = rawList.whereType<Map>().map((e) {
      final Map<String, dynamic> m = {};
      e.forEach((k, v) => m[k.toString()] = v);
      return m;
    }).toList();

    setState(() {
      _santriList = list;
      for (final s in list) {
        final nis = s['nis']?.toString() ?? '';
        final pointer =
            double.tryParse(s['pointer_halaman']?.toString() ?? '0') ?? 0.0;
        _halAwalCtrl.putIfAbsent(
            nis, () => TextEditingController(text: _fmt(pointer)));
        _halTotalCtrl.putIfAbsent(nis, () => TextEditingController());
        _statusBacaan.putIfAbsent(nis, () => 'Sesuai Target');
      }
    });
  }

  Future<void> _pickTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _tanggal = picked);
  }

  Future<void> _refresh() async {
    final tanggal = DateFormat('yyyy-MM-dd').format(_tanggal);
    await context.read<PraTahfidzCubit>().fetchSantriList(
          tanggal: tanggal,
          forceRefresh: true,
        );
  }

  Future<void> _simpan() async {
    final rows = <Map<String, dynamic>>[];
    for (final s in _santriList) {
      final nis = s['nis']?.toString() ?? '';
      final halTotal =
          double.tryParse(_halTotalCtrl[nis]?.text.trim() ?? '') ?? 0;
      if (halTotal <= 0) continue;

      final halAwal =
          double.tryParse(_halAwalCtrl[nis]?.text.trim() ?? '0') ?? 0;
      rows.add({
        'nis': nis,
        'hal_awal': halAwal,
        'hal_total': halTotal,
        'status_bacaan': _statusBacaan[nis] ?? 'Sesuai Target',
      });
    }

    if (rows.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Belum ada setoran yang diisi.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() => _submitting = true);
    final ok = await context.read<PraTahfidzCubit>().submitInputMassal({
      'tanggal': DateFormat('yyyy-MM-dd').format(_tanggal),
      'sesi': _sesi,
      'rows': rows,
    });

    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? '${rows.length} setoran berhasil disimpan.'
          : 'Gagal menyimpan. Coba lagi.'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));

    if (ok) {
      // Reset: mulai_hal = mulai_hal + jml_dibaca, jml_dibaca = 0
      for (final row in rows) {
        final nis = row['nis']?.toString() ?? '';
        final halAwal = (row['hal_awal'] as num?)?.toDouble() ?? 0;
        final halTotal = (row['hal_total'] as num?)?.toDouble() ?? 0;
        _halAwalCtrl[nis]?.text = _fmt(halAwal + halTotal);
        _halTotalCtrl[nis]?.clear();
      }
      _globalCtrl.clear();
    }
  }

  @override
  void dispose() {
    _globalCtrl.removeListener(_onGlobalChanged);
    _globalCtrl.dispose();
    for (final c in _halAwalCtrl.values) c.dispose();
    for (final c in _halTotalCtrl.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final styles = Theme.of(context).extension<AppCustomStyles>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return BlocListener<PraTahfidzCubit, PraTahfidzState>(
      listener: (context, state) {
        if (state is PraTahfidzLoaded) _buildSantriList(state.data);
      },
      child: Column(
        children: [
          // ── Header Atas: Filter + Tombol Simpan ─────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                // Tanggal
                _DateButton(
                  tanggal: _tanggal,
                  onTap: _pickTanggal,
                  styles: styles,
                  cs: cs,
                ),
                const SizedBox(width: 8),
                // Sesi
                _SesiDropdown(
                  sesi: _sesi,
                  sesiList: _sesiList,
                  styles: styles,
                  cs: cs,
                  onChanged: (v) => setState(() => _sesi = v),
                ),
                const SizedBox(width: 8),
                // Global Jml Dibaca — pengganti posisi tombol Simpan lama
                Expanded(
                  child: SizedBox(
                    height: 37,
                    child: TextField(
                      controller: _globalCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontSize: 12, color: cs.onSurface),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Jml Dibaca (Hal) — semua santri',
                        hintStyle: TextStyle(
                            fontSize: 10,
                            color: cs.onSurface.withValues(alpha: 0.4)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: styles.cardBorder)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: cs.primary.withValues(alpha: 0.5))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: cs.primary, width: 1.5)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // ── Tombol Simpan (kanan atas) ───────────────────────────
                SizedBox(
                  height: 37,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      elevation: 0,
                    ),
                    onPressed: _submitting ? null : _simpan,
                    icon: _submitting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_rounded, size: 16),
                    label: Text(_submitting ? '...' : 'Simpan',
                        style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),

          // ── Daftar Santri ───────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _santriList.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.group_off_rounded,
                                  size: 56,
                                  color: cs.onSurface.withValues(alpha: 0.25)),
                              const SizedBox(height: 12),
                              Text('Belum ada data santri.',
                                  style: TextStyle(
                                      color: cs.onSurface.withValues(alpha: 0.5))),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: _santriList.length,
                      itemBuilder: (ctx, i) {
                        final s = _santriList[i];
                        final nis = s['nis']?.toString() ?? '';
                        return _InputMassalRow(
                          key: ValueKey(nis),
                          index: i,
                        santri: s,
                        halAwalCtrl: _halAwalCtrl[nis]!,
                        halTotalCtrl: _halTotalCtrl[nis]!,
                        statusBacaan: _statusBacaan[nis]!,
                        statusList: _statusList,
                        styles: styles,
                        onStatusChanged: (v) =>
                            setState(() => _statusBacaan[nis] = v),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widget: Tombol Tanggal ───────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  final DateTime tanggal;
  final VoidCallback onTap;
  final AppCustomStyles styles;
  final ColorScheme cs;

  const _DateButton(
      {required this.tanggal,
      required this.onTap,
      required this.styles,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 37,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: styles.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, size: 14, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              DateFormat('dd MMM yyyy').format(tanggal),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widget: Dropdown Sesi ────────────────────────────────────────────────

class _SesiDropdown extends StatelessWidget {
  final String sesi;
  final List<String> sesiList;
  final AppCustomStyles styles;
  final ColorScheme cs;
  final ValueChanged<String> onChanged;

  const _SesiDropdown(
      {required this.sesi,
      required this.sesiList,
      required this.styles,
      required this.cs,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: styles.cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: sesi,
          isDense: true,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface),
          dropdownColor: cs.surface,
          items: sesiList
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ── Sub-widget: Row per santri ───────────────────────────────────────────────

class _InputMassalRow extends StatelessWidget {
  final int index;
  final Map<String, dynamic> santri;
  final TextEditingController halAwalCtrl;
  final TextEditingController halTotalCtrl;
  final String statusBacaan;
  final List<String> statusList;
  final AppCustomStyles styles;
  final ValueChanged<String> onStatusChanged;

  const _InputMassalRow({
    super.key,
    required this.index,
    required this.santri,
    required this.halAwalCtrl,
    required this.halTotalCtrl,
    required this.statusBacaan,
    required this.statusList,
    required this.styles,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: styles.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama & NIS
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text('${index + 1}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: cs.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      santri['nama_santri']?.toString() ?? '-',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: cs.onSurface),
                    ),
                    Text(
                      'NIS: ${santri['nis'] ?? '-'} · ${santri['tingkat'] ?? ''}',
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Mulai Hal
              Expanded(
                child: _FieldColumn(
                  label: 'Mulai Hal.',
                  child: TextField(
                    controller: halAwalCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(fontSize: 13, color: cs.onSurface),
                    decoration: _inputDeco(cs, styles,
                        focused:
                            BorderSide(color: cs.primary.withValues(alpha: 0.8), width: 1.5)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Jml Dibaca
              Expanded(
                child: _FieldColumn(
                  label: 'Jml Dibaca (Hal)',
                  child: TextField(
                    controller: halTotalCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(fontSize: 13, color: cs.onSurface),
                    decoration: _inputDeco(cs, styles,
                        hint: '0 = Lewati',
                        focused: BorderSide(color: styles.success, width: 1.5)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Status
              Expanded(
                child: _FieldColumn(
                  label: 'Status',
                  child: Container(
                    height: 37,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: styles.cardBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: statusBacaan,
                        isDense: true,
                        isExpanded: true,
                        style: TextStyle(fontSize: 11, color: cs.onSurface),
                        dropdownColor: cs.surface,
                        items: statusList
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) onStatusChanged(v);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(ColorScheme cs, AppCustomStyles styles,
      {String? hint, required BorderSide focused}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle:
          TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: styles.cardBorder)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: cs.primary.withValues(alpha: 0.4))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: focused),
    );
  }
}

// ── Helper: Label + Field ────────────────────────────────────────────────────

class _FieldColumn extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldColumn({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55))),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
