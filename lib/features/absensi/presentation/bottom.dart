// ============================================================================
// WIDGET TAB ABSEN MASSAL
// ============================================================================

import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:intl/intl.dart';


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

    // Filter data khusus untuk disubmit API secara massal
    final absenPayload = _absenState.entries.map((e) => {
      'nis': e.key,
      'id_kehadiran': e.value['id_kehadiran'],
      'catatan': e.value['catatan'],
    }).toList();

    final payload = {
      'tanggal': _tanggal,
      'absen': absenPayload,
    };

    try {
      final res = await ApiService.simpanAbsenMassal(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(res['message'] ?? 'Absen massal di-upsert sukses!')),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _fetchData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _santriList.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
    }

    if (_errorMsg.isNotEmpty && _santriList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMsg, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            // Bar Pemilih Tanggal
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range, color: Color(0xFF1B5E20), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _tanggal,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
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

            // List View Absen Massal
            Expanded(
              child: _santriList.isEmpty
                  ? const Center(child: Text("Tidak ada santri di kelas Anda."))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100, top: 8),
                      itemCount: _santriList.length,
                      itemBuilder: (ctx, i) {
                        final santri = _santriList[i];
                        final nis = santri['nis'].toString();
                        final state = _absenState[nis]!;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blueGrey.shade50,
                                      child: Text(
                                        '${i + 1}',
                                        style: const TextStyle(
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            santri['nama_santri'] ?? santri['nama_panggilan'] ?? '-',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF1B5E20),
                                            ),
                                          ),
                                          Text(
                                            'NIS: $nis',
                                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Pilihan Tombol 4 Status
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildRadio(nis, state, 1, 'Hadir', Colors.green),
                                    _buildRadio(nis, state, 2, 'Sakit', Colors.amber.shade700),
                                    _buildRadio(nis, state, 3, 'Izin', Colors.blue),
                                    _buildRadio(nis, state, 4, 'Alpha', Colors.red),
                                  ],
                                ),
                                
                                // Field Keterangan dinamis
                                if (state['id_kehadiran'] != 1) ...[
                                  const SizedBox(height: 12),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Tuliskan keterangan detail...',
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                    ),
                                    controller: TextEditingController(text: state['catatan'])
                                      ..selection = TextSelection.collapsed(offset: state['catatan'].length),
                                    onChanged: (val) {
                                      state['catatan'] = val;
                                    },
                                  ),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        
        // Tombol Simpan Melayang
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4)),
              ],
            ),
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isSaving ? const SizedBox() : const Icon(Icons.save),
                label: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        'Simpan Absen Massal',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                onPressed: _isSaving ? null : _simpan,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadio(
    String nis,
    Map<String, dynamic> state,
    int idKehadiran,
    String label,
    Color color,
  ) {
    final bool isSelected = state['id_kehadiran'] == idKehadiran;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            state['id_kehadiran'] = idKehadiran;
            if (idKehadiran == 1) state['catatan'] = '';
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : Colors.grey.shade300),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
