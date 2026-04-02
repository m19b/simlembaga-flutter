import 'package:flutter/material.dart';

class BottomEdit extends StatefulWidget {
  final Map<String, dynamic> dataPrestasi;
  final Function(Map<String, dynamic>) onSave;

  const BottomEdit({Key? key, required this.dataPrestasi, required this.onSave})
    : super(key: key);

  @override
  State<BottomEdit> createState() => _BottomEditState();
}

class _BottomEditState extends State<BottomEdit> {
  late int halAwal;
  late int halAkhir;
  late int halTotal;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data dari riwayat yang diklik, gunakan nilai default jika null
    halAwal = int.tryParse(widget.dataPrestasi['hal_awal'].toString()) ?? 1;
    halAkhir = int.tryParse(widget.dataPrestasi['hal_akhir'].toString()) ?? 1;
    halTotal = int.tryParse(widget.dataPrestasi['hal_total'].toString()) ?? 1;
    _hitungTotal();
  }

  void _hitungTotal() {
    // Logika perhitungan total halaman sesuai instruksi
    int total = (halAkhir - halAwal);
    setState(() {
      halTotal = total < 1 ? 1 : total; // Minimal total halaman adalah 1
    });
  }


  void _tambahHalAkhir() {
    setState(() {
      halAkhir++;
      _hitungTotal(); // Total akan otomatis bertambah
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            20, // Agar tidak tertutup keyboard
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Edit Progres Santri",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // --- KONTROL HALAMAN AWAL ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Halaman Awal", style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Text(
                    "$halAwal",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey, // Indikasi readonly
                    ),
                  ),
                  const SizedBox(width: 48), // Padding pengganti icon
                ],
              ),
            ],
          ),

          // --- KONTROL HALAMAN AKHIR ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Halaman Akhir", style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: _kurangHalAkhir,
                  ),
                  Text(
                    "$halAkhir",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.blue,
                    ),
                    onPressed: _tambahHalAkhir,
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 30),

          // --- TOTAL HALAMAN ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Halaman",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$halTotal",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // --- TOMBOL SIMPAN ---
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Update map dengan data baru dan kirim ke parent screen
                Map<String, dynamic> updatedData = Map.from(
                  widget.dataPrestasi,
                );
                updatedData['hal_awal'] = halAwal;
                updatedData['hal_akhir'] = halAkhir;
                updatedData['hal_total'] = halTotal;

                widget.onSave(updatedData);
                Navigator.pop(context); // Tutup bottom sheet
              },
              child: const Text(
                "Simpan Perubahan",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
