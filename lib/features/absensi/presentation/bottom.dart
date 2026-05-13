// ============================================================================
// WIDGET TAB ABSEN MASSAL — ANTI-JANK EDITION
// Optimasi: Row sebagai StatefulWidget terpisah agar rebuild HANYA pada baris
// yang diubah, bukan seluruh list. Ini solusi UI Jank yang sesungguhnya.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';

class AbsenMassalTab extends StatefulWidget {
  const AbsenMassalTab({super.key});

  @override
  State<AbsenMassalTab> createState() => _AbsenMassalTabState();
}

class _AbsenMassalTabState extends State<AbsenMassalTab> {
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMsg = '';
  List<dynamic> _santriList = [];
  String _tanggal = DateTime.now().toString().substring(0, 10);

  // Format Map absenState -> NIS : { 'id_kehadiran': 1, 'catatan': '' }
  final Map<String, Map<String, dynamic>> _absenState = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      final res = await ApiService.getAbsenHarian(tanggal: _tanggal);
      final Map<String, dynamic> resData = res['data'] ?? res;
      _santriList = resData['santri'] ?? [];

      _absenState.clear();
      for (var s in _santriList) {
        final nis = s['nis'].toString();
        _absenState[nis] = {
          'id_kehadiran': int.tryParse(s['id_kehadiran']?.toString() ?? '') ?? 1,
          'catatan': s['catatan_absen'] ?? '',
        };
      }
    } catch (e) {
      _errorMsg = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _simpan() async {
    if (_santriList.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    final absenPayload = _absenState.entries.map((e) => {
      'nis': e.key,
      'id_kehadiran': e.value['id_kehadiran'],
      'catatan': e.value['catatan'],
    }).toList();

    final payload = {'tanggal': _tanggal, 'absen': absenPayload};

    try {
      final res = await ApiService.simpanAbsenMassal(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(res['message'] ?? 'Absen massal di-upsert sukses!')),
        ]),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ));
      _fetchData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading && _santriList.isEmpty) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    if (_errorMsg.isNotEmpty && _santriList.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.wifi_off, size: 64, color: cs.onSurface.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(_errorMsg, style: TextStyle(color: cs.error), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchData, child: const Text('Coba Lagi')),
        ]),
      );
    }

    return Stack(children: [
      Column(children: [
        // ── Bar Tanggal ──────────────────────────────────────────────────────
        Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.date_range, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(_tanggal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_calendar, size: 16),
                label: const Text('Ubah'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.parse(_tanggal),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    _tanggal = picked.toString().substring(0, 10);
                    _fetchData();
                  }
                },
              ),
            ],
          ),
        ),

        // ── List View ANTI-JANK: Setiap baris adalah widget terpisah ─────────
        Expanded(
          child: _santriList.isEmpty
              ? Center(child: Text('Tidak ada santri di kelas Anda.', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100, top: 8),
                  itemCount: _santriList.length,
                  // ✅ KUNCI ANTI-JANK: itemBuilder hanya rebuild untuk index yang berubah
                  itemBuilder: (ctx, i) {
                    final santri = _santriList[i];
                    final nis = santri['nis'].toString();
                    return _AbsenMassalRow(
                      key: ValueKey(nis), // Stable key agar Flutter tidak rebuild ulang
                      index: i,
                      santri: santri,
                      nis: nis,
                      absenState: _absenState[nis]!,
                      // Callback: saat baris berubah, HANYA update Map state, tidak rebuild seluruh list
                      onStateChanged: (newState) {
                        _absenState[nis] = newState;
                        // TIDAK ada setState() di sini → tidak rebuild seluruh ListView!
                      },
                    );
                  },
                ),
        ),
      ]),

      // ── Tombol Simpan Melayang ────────────────────────────────────────────
      Positioned(
        left: 0, right: 0, bottom: 0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, -4))],
          ),
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isSaving ? const SizedBox() : const Icon(Icons.save),
              label: _isSaving
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Text('Simpan Absen Massal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _isSaving ? null : _simpan,
            ),
          ),
        ),
      ),
    ]);
  }
}

// ============================================================================
// BARIS ABSEN — StatefulWidget TERPISAH
// Rebuild HANYA terjadi di sini saat tombol status ditekan.
// Parent ListView TIDAK ikut rebuild.
// ============================================================================
class _AbsenMassalRow extends StatefulWidget {
  final int index;
  final dynamic santri;
  final String nis;
  final Map<String, dynamic> absenState;
  final ValueChanged<Map<String, dynamic>> onStateChanged;

  const _AbsenMassalRow({
    super.key,
    required this.index,
    required this.santri,
    required this.nis,
    required this.absenState,
    required this.onStateChanged,
  });

  @override
  State<_AbsenMassalRow> createState() => _AbsenMassalRowState();
}

class _AbsenMassalRowState extends State<_AbsenMassalRow> {
  late Map<String, dynamic> _localState;
  late TextEditingController _catatanCtrl;

  @override
  void initState() {
    super.initState();
    _localState = Map.from(widget.absenState);
    _catatanCtrl = TextEditingController(text: _localState['catatan']?.toString() ?? '');
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  void _updateKehadiran(int idKehadiran) {
    setState(() {
      _localState['id_kehadiran'] = idKehadiran;
      if (idKehadiran == 1) {
        _localState['catatan'] = '';
        _catatanCtrl.clear();
      }
    });
    widget.onStateChanged(_localState);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header Santri ───────────────────────────────────────────────
          Row(children: [
            CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Text('${widget.index + 1}', style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  widget.santri['nama_santri'] ?? widget.santri['nama_panggilan'] ?? '-',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface),
                ),
                Text('NIS: ${widget.nis}', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 12)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),

          // ── 4 Tombol Status ──────────────────────────────────────────────
          Row(children: [
            _StatusBtn(label: 'Hadir',  idKehadiran: 1, current: _localState['id_kehadiran'], color: Colors.green,           onTap: _updateKehadiran),
            _StatusBtn(label: 'Sakit',  idKehadiran: 3, current: _localState['id_kehadiran'], color: Colors.blue,            onTap: _updateKehadiran),
            _StatusBtn(label: 'Izin',   idKehadiran: 2, current: _localState['id_kehadiran'], color: Colors.amber.shade700,  onTap: _updateKehadiran),
            _StatusBtn(label: 'Alpha',  idKehadiran: 4, current: _localState['id_kehadiran'], color: Colors.red,             onTap: _updateKehadiran),
          ]),

          // ── Field Keterangan (hanya muncul jika bukan Hadir) ─────────────
          if (_localState['id_kehadiran'] != 1) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _catatanCtrl,
              decoration: InputDecoration(
                hintText: 'Tuliskan keterangan detail...',
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
                ),
              ),
              onChanged: (val) {
                _localState['catatan'] = val;
                widget.onStateChanged(_localState);
              },
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Tombol Status (Hadir/Sakit/Izin/Alpha) ──────────────────────────────────
class _StatusBtn extends StatelessWidget {
  final String label;
  final int idKehadiran;
  final int current;
  final Color color;
  final ValueChanged<int> onTap;

  const _StatusBtn({
    required this.label,
    required this.idKehadiran,
    required this.current,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isSelected = current == idKehadiran;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(idKehadiran),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : cs.outline.withValues(alpha: 0.4)),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
