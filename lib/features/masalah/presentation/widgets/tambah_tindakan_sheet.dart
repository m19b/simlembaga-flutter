import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/bloc/masalah_cubit.dart';

class TambahTindakanSheet extends StatefulWidget {
  final String idMasalah;
  final VoidCallback onSaved;
  const TambahTindakanSheet({super.key, required this.idMasalah, required this.onSaved});

  @override
  State<TambahTindakanSheet> createState() => _TambahTindakanSheetState();
}

class _TambahTindakanSheetState extends State<TambahTindakanSheet> {
  final _keteranganCtrl = TextEditingController();
  String? _jenisPenyelesaian;
  String? _hasilTahap;
  DateTime _tglPenyelesaian = DateTime.now();
  bool _saving = false;

  static const _jenisOptions = [
    'Via Chat/Telepon',
    'Kunjungan ke Rumah',
    'Pemanggilan Orang Tua',
    'Konseling Langsung',
    'Lainnya'
  ];

  static const _hasilOptions = [
    'Belum Ada Perubahan',
    'Ada Perbaikan',
    'Masalah Terselesaikan'
  ];

  @override
  void dispose() {
    _keteranganCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_jenisPenyelesaian == null || _hasilTahap == null || _keteranganCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Lengkapi semua field!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<MasalahCubit>().repository.storeTahapMasalah({
        'id_masalah': widget.idMasalah,
        'jenis_penyelesaian': _jenisPenyelesaian!,
        'tgl_penyelesaian': DateFormat('yyyy-MM-dd').format(_tglPenyelesaian),
        'keterangan': _keteranganCtrl.text.trim(),
        'hasil_tahap': _hasilTahap!,
      });

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Tindakan berhasil ditambahkan',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      String errMsg = e.toString().replaceAll('Exception: ', '');

      // Khusus untuk error 403 atau Akses Ditolak
      if (errMsg.toLowerCase().contains('akses ditolak') || errMsg.contains('403')) {
        errMsg = 'Akses Ditolak: Anda tidak memiliki izin untuk menambahkan tindakan pada masalah ini.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errMsg,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tambah Tindakan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              // Filter Dropdown: Jenis Penyelesaian
              DropdownButtonFormField<String>(
                value: _jenisPenyelesaian,
                decoration: InputDecoration(
                  labelText: 'Jenis Penyelesaian',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _jenisOptions.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => _jenisPenyelesaian = val),
              ),
              const SizedBox(height: 16),
              // TextField: Tgl Penyelesaian
              InkWell(
                onTap: () async {
                  final dt = await showDatePicker(
                    context: context,
                    initialDate: _tglPenyelesaian,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (dt != null) {
                    setState(() => _tglPenyelesaian = dt);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal Penyelesaian',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(DateFormat('dd MMM yyyy').format(_tglPenyelesaian)),
                ),
              ),
              const SizedBox(height: 16),
              // TextField: Keterangan
              TextField(
                controller: _keteranganCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Keterangan / Intisari',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              // Dropdown: Hasil Tahap
              DropdownButtonFormField<String>(
                value: _hasilTahap,
                decoration: InputDecoration(
                  labelText: 'Hasil Tahap',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _hasilOptions.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => _hasilTahap = val),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Simpan Tindakan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
