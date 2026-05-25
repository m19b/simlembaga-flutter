import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/bloc/masalah_cubit.dart';
import 'masalah_constants.dart';
import 'masalah_shared_widgets.dart';
import 'tambah_tindakan_sheet.dart';

class DetailMasalahSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isAktif;
  final bool isAdmin;
  final VoidCallback onRefresh;

  const DetailMasalahSheet({
    super.key,
    required this.item,
    required this.isAktif,
    required this.isAdmin,
    required this.onRefresh,
  });

  @override
  State<DetailMasalahSheet> createState() => _DetailMasalahSheetState();
}

class _DetailMasalahSheetState extends State<DetailMasalahSheet> {
  bool _saving = false;
  final _catatanCtrl = TextEditingController();

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _tandaiSelesai() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await context.read<MasalahCubit>().repository.updateMasalah({
        'id': (widget.item['id_masalah'] ?? widget.item['id']).toString(),
        'status': 'selesai',
        'tgl_selesai': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'catatan_selesai': _catatanCtrl.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      widget.onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Masalah ditandai selesai',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: masalahAccentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showTambahTindakanSheet(BuildContext context, String idMasalah, VoidCallback onRefresh) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TambahTindakanSheet(idMasalah: idMasalah, onSaved: onRefresh),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jenis = widget.item['jenis_masalah']?.toString();
    final barClr = masalahJenisColor(jenis);
    final nama = widget.item['nama_santri']?.toString() ?? '-';
    final nis = widget.item['nis']?.toString() ?? '';
    final kelas = widget.item['kelas']?.toString() ?? widget.item['tingkat']?.toString() ?? '';
    final keterangan = widget.item['deskripsi']?.toString() ?? widget.item['keterangan']?.toString() ?? '';
    final tgl = widget.item['tgl_masalah']?.toString() ?? widget.item['tgl_deteksi']?.toString() ?? '';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Header
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: barClr.withAlpha(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: barClr.withAlpha(22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            masalahJenisIcon(jenis),
                            color: barClr,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nama,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: masalahText1Color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                children: [
                                  MasalahChip(icon: Icons.badge_outlined, text: nis),
                                  if (kelas.isNotEmpty)
                                    MasalahChip(
                                      icon: Icons.school_outlined,
                                      text: kelas,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        JenisBadge(jenis: jenis),
                        const Spacer(),
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: masalahText2Color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tgl,
                          style: const TextStyle(
                            fontSize: 12,
                            color: masalahText2Color,
                          ),
                        ),
                      ],
                    ),
                    if (keterangan.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          keterangan,
                          style: const TextStyle(
                            fontSize: 13,
                            color: masalahText1Color,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Aksi (Hanya tampil jika masalah masih aktif DAN user adalah admin)
              // Histori Penanganan
              if (widget.item['tahap_penyelesaian'] is List &&
                  (widget.item['tahap_penyelesaian'] as List).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Histori Penanganan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: masalahText1Color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Expandable List
                      ...((widget.item['tahap_penyelesaian'] as List).whereType<Map>().map((tahap) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: ExpansionTile(
                            shape: const Border(),
                            title: Text(
                              tahap['jenis_penyelesaian']?.toString() ?? 'Tindakan',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              tahap['tgl_penyelesaian']?.toString() ?? '',
                              style: const TextStyle(fontSize: 11, color: masalahText2Color),
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  tahap['keterangan']?.toString() ?? '-',
                                  style: const TextStyle(fontSize: 13, color: masalahText1Color),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Hasil: ${tahap['hasil_tahap']?.toString() ?? '-'}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                    ],
                  ),
                ),

              // Aksi (Tambah Tindakan / Selesai)
              if (widget.isAktif) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: masalahAccentColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showTambahTindakanSheet(
                            context,
                            (widget.item['id_masalah'] ?? widget.item['id']).toString(),
                            widget.onRefresh);
                      },
                      icon: const Icon(Icons.add_task_rounded, color: masalahAccentColor, size: 18),
                      label: const Text(
                        'Tambah Tindakan',
                        style: TextStyle(
                          color: masalahAccentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.isAdmin) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextField(
                      controller: _catatanCtrl,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14, color: masalahText1Color),
                      decoration: InputDecoration(
                        labelText: 'Catatan penyelesaian (opsional)',
                        labelStyle: const TextStyle(
                          color: masalahText2Color,
                          fontSize: 13,
                        ),
                        hintText: 'Tulis catatan atau tindakan yang dilakukan...',
                        hintStyle: const TextStyle(
                          color: masalahText2Color,
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: masalahAccentColor,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: masalahAccentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _saving ? null : _tandaiSelesai,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                        label: Text(
                          _saving ? 'Menyimpan...' : 'Tandai Selesai',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ] else
                const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
