// ============================================================================
// WIDGET TAB ABSEN MASSAL — ANTI-JANK EDITION
// Optimasi: Row sebagai StatefulWidget terpisah agar rebuild HANYA pada baris
// yang diubah, bukan seluruh list. Ini solusi UI Jank yang sesungguhnya.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/features/absensi/domain/repositories/absensi_repository.dart';
import 'package:manajemen_tahsin_app/core/enums/jalur_enum.dart';

class AbsenMassalTab extends StatefulWidget {
  const AbsenMassalTab({super.key});

  @override
  State<AbsenMassalTab> createState() => AbsenMassalTabState();
}

class AbsenMassalTabState extends State<AbsenMassalTab> {
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMsg = '';
  List<dynamic> _santriList = [];
  String _tanggal = DateTime.now().toString().substring(0, 10);
  JalurEnum _selectedJalur = JalurEnum.tahsin;

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
      final repo = context.read<AbsensiRepository>();
      final res = await repo.getAbsenHarian(_tanggal, '', kodeJalur: _selectedJalur.kode); // idKelas default kosong di Absen Massal jika tidak dipilih
      final Map<String, dynamic> resData = res['data'] ?? res;
      final rawList = resData['santri'] ?? [];

      // ── DEDUP: pastikan tidak ada santri double berdasarkan NIS ──
      final Map<String, dynamic> dedupMap = {};
      for (var s in rawList) {
        final nis = s['nis']?.toString() ?? '';
        if (nis.isNotEmpty && !dedupMap.containsKey(nis)) {
          dedupMap[nis] = s;
        }
      }
      _santriList = dedupMap.values.toList();

      _absenState.clear();
      for (var s in _santriList) {
        final nis = s['nis'].toString();
        final rawId = s['id_kehadiran'];
        final isTersimpan = rawId != null && rawId.toString().isNotEmpty && rawId.toString() != 'null';
        _absenState[nis] = {
          'id_kehadiran': int.tryParse(rawId?.toString() ?? '') ?? 1,
          'catatan': s['keterangan'] ?? '',
          'is_tersimpan': isTersimpan,
          'id_kelas': s['id_kelas'],
        };
      }
    } catch (e) {
      _errorMsg = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> simpan() async {
    if (_santriList.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    final absenPayload = _absenState.entries.map((e) => {
      'nis': e.key,
      'id_kehadiran': e.value['id_kehadiran'],
      'catatan': e.value['catatan'],
      'id_kelas': e.value['id_kelas'],
    }).toList();

    final payload = {'tanggal': _tanggal, 'absen': absenPayload};

    try {
      final repo = context.read<AbsensiRepository>();
      final isSuccess = await repo.simpanAbsenMassal(payload);
      
      if (!mounted) return;
      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(child: Text('Absen massal di-upsert sukses (atau tersimpan di antrean offline)!')),
          ]),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Gagal menyimpan absen massal.'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ));
      }
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

    int tersimpan = 0;
    int belum = 0;
    for (var state in _absenState.values) {
      if (state['is_tersimpan'] == true) {
        tersimpan++;
      } else {
        belum++;
      }
    }

    return Stack(children: [
      Column(children: [
        // CARD WRAPPER FILTER
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Info Tersimpan / Belum
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Text('$tersimpan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    const SizedBox(width: 12),
                    Icon(Icons.pending, size: 14, color: Colors.orange.shade600),
                    const SizedBox(width: 4),
                    Text('$belum', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                  ],
                ),
                
                // Dropdown Jalur
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<JalurEnum>(
                      isDense: true,
                      value: _selectedJalur,
                      icon: Icon(Icons.arrow_drop_down, size: 16, color: cs.primary),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary),
                      onChanged: (JalurEnum? newVal) {
                        if (newVal != null) {
                          setState(() => _selectedJalur = newVal);
                          _fetchData();
                        }
                      },
                      items: JalurEnum.values.map((jalur) {
                        return DropdownMenuItem<JalurEnum>(value: jalur, child: Text(jalur.nama));
                      }).toList(),
                    ),
                  ),
                ),
                
                // Tanggal
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
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
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                      color: cs.primary.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('d/M/yyyy').format(DateTime.parse(_tanggal)),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cs.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
  void didUpdateWidget(_AbsenMassalRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika data dari luar berubah (sehabis disave & difetch ulang), update state lokal
    if (widget.absenState != oldWidget.absenState) {
      _localState = Map.from(widget.absenState);
      if (_catatanCtrl.text != (_localState['catatan']?.toString() ?? '')) {
        _catatanCtrl.text = _localState['catatan']?.toString() ?? '';
      }
    }
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _localState['is_tersimpan'] == true ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _localState['is_tersimpan'] == true ? 'Tersimpan' : 'Belum',
                style: TextStyle(
                  color: _localState['is_tersimpan'] == true ? Colors.green.shade800 : Colors.orange.shade800,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
