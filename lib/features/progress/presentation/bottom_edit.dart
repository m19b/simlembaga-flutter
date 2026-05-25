import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class BottomEdit extends StatefulWidget {
  final Map<String, dynamic> dataPrestasi;
  final Function(Map<String, dynamic>) onSave;
  /// Jika true, hanya field tanggal yang bisa diubah (riwayat lama)
  final bool onlyEditDate;

  const BottomEdit({
    Key? key,
    required this.dataPrestasi,
    required this.onSave,
    this.onlyEditDate = false,
  }) : super(key: key);

  @override
  State<BottomEdit> createState() => _BottomEditState();
}

class _BottomEditState extends State<BottomEdit> {
  late int halAwal;
  late int halAkhir;
  late int halTotal;
  late int jmlKehadiran;
  late DateTime tanggal;

  @override
  void initState() {
    super.initState();
    halAwal = int.tryParse(widget.dataPrestasi['hal_awal'].toString()) ?? 1;
    halAkhir = int.tryParse(widget.dataPrestasi['hal_akhir'].toString()) ?? 1;
    halTotal = int.tryParse(widget.dataPrestasi['hal_total'].toString()) ?? 1;
    jmlKehadiran = int.tryParse(widget.dataPrestasi['jml_kehadiran'].toString()) ?? 1;

    // Parse tanggal dari tgl_simak
    final tglStr = widget.dataPrestasi['tgl_simak']?.toString() ?? '';
    tanggal = DateTime.tryParse(tglStr.split(' ').first) ?? DateTime.now();

    if (!widget.onlyEditDate) _hitungTotal();
  }

  void _hitungTotal() {
    int total = (halAkhir - halAwal);
    setState(() {
      halTotal = total < 1 ? 1 : total;
    });
  }

  void _tambahHalAkhir() {
    setState(() {
      halAkhir++;
      _hitungTotal();
    });
  }

  void _kurangHalAkhir() {
    if (halAkhir > 1) {
      setState(() {
        halAkhir--;
        _hitungTotal();
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2ECC71)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => tanggal = picked);
  }

  @override
  Widget build(BuildContext context) {
    final String judulMode = widget.onlyEditDate ? 'Edit Tanggal Riwayat' : 'Edit Progres Santri';

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Text(
            judulMode,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          if (widget.onlyEditDate) ...[
            const SizedBox(height: 6),
            Text(
              'Hanya perubahan tanggal yang diizinkan untuk riwayat lama.',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade700, fontStyle: FontStyle.italic),
            ),
          ],

          const SizedBox(height: 20),

          // --- FIELD TANGGAL --- (selalu tampil)
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(tanggal),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.edit_outlined, size: 16, color: Colors.grey.shade500),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- KONTROL TATAP MUKA (TM) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tatap Muka (TM)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                    onPressed: () { if (jmlKehadiran > 1) setState(() => jmlKehadiran--); },
                  ),
                  Text(
                    '$jmlKehadiran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                    onPressed: () => setState(() => jmlKehadiran++),
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 24),

          // Tampilkan kontrol hal awal/akhir hanya jika bukan mode onlyEditDate
          if (!widget.onlyEditDate) ...[
            const SizedBox(height: 16),

            // --- KONTROL HALAMAN AWAL ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Halaman Awal', style: TextStyle(fontSize: 15)),
                Row(
                  children: [
                    Text(
                      '$halAwal',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // --- KONTROL HALAMAN AKHIR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Halaman Akhir', style: TextStyle(fontSize: 15)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: _kurangHalAkhir,
                    ),
                    Text(
                      '$halAkhir',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                      onPressed: _tambahHalAkhir,
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 24),

            // --- TOTAL HALAMAN ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Halaman', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$halTotal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // --- TOMBOL SIMPAN ---
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final Map<String, dynamic> updatedData = Map.from(widget.dataPrestasi);
                updatedData['tgl_simak'] = DateFormat('yyyy-MM-dd').format(tanggal);
                if (!widget.onlyEditDate) {
                  updatedData['hal_awal'] = halAwal;
                  updatedData['hal_akhir'] = halAkhir;
                  updatedData['hal_total'] = halTotal;
                }
                updatedData['jml_kehadiran'] = jmlKehadiran;
                widget.onSave(updatedData);
                Navigator.pop(context);
              },
              child: Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
