import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/masalah/domain/repositories/masalah_repository.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/widgets/santri_selection_sheet.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/data/models/pra_tahfidz_santri_model.dart';
import 'package:manajemen_tahsin_app/features/progress/data/models/progress_santri_model.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/data/models/tahfidz_santri_model.dart';

class CatatMasalahBottomSheet extends StatefulWidget {
  const CatatMasalahBottomSheet({super.key});

  @override
  State<CatatMasalahBottomSheet> createState() =>
      _CatatMasalahBottomSheetState();
}

class _CatatMasalahBottomSheetState extends State<CatatMasalahBottomSheet> {
  final TextEditingController _keteranganController = TextEditingController();

  // State — Bug Fix: _selectedSantri tracks the fully-selected item.
  // Validation checks this (non-null) before submitting.
  Map<String, dynamic>? _selectedSantri;
  String? _selectedJenisMasalah;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  final List<String> _listJenisMasalah = [
    'Kehadiran',
    'Keterlambatan Belajar',
    'Tidak Disimak di Rumah',
    'Indisipliner',
    'Akademik',
    'Kesehatan',
    'Lainnya',
  ];

  List<Map<String, dynamic>> _localSantriList = [];

  @override
  void initState() {
    super.initState();
    _loadLocalSantri();
  }

  Future<void> _loadLocalSantri() async {
    try {
      final isar = IsarDb.instance;
      final List<Map<String, dynamic>> result = [];
      int activeId = 0;
      
      try {
        activeId = context.read<ActiveKelompokCubit>().state.activeId;
      } catch (e) {
        // Fallback jika tidak ada context provider ActiveKelompokCubit
        activeId = 0;
      }

      if (activeId > 0) {
        final t1 = await isar.tahfidzSantriModels.filter().idKelompokEqualTo(activeId).findAll();
        final t2 = await isar.praTahfidzSantriModels.filter().idKelompokEqualTo(activeId).findAll();
        final t3 = await isar.progressSantriModels.filter().idKelompokEqualTo(activeId).findAll();
        for (var s in t1) { result.add({'nis': s.nis, 'nama_santri': s.namaSantri, 'tingkat': s.tingkat ?? s.idKelas?.toString()}); }
        for (var s in t2) { result.add({'nis': s.nis, 'nama_santri': s.namaSantri, 'tingkat': s.tingkat ?? s.idKelas?.toString()}); }
        for (var s in t3) { result.add({'nis': s.nis, 'nama_santri': s.namaSantri, 'tingkat': s.tingkat ?? s.namaKelompok}); }
      } else {
        final t1 = await isar.tahfidzSantriModels.where().findAll();
        final t2 = await isar.praTahfidzSantriModels.where().findAll();
        final t3 = await isar.progressSantriModels.where().findAll();
        for (var s in t1) { result.add({'nis': s.nis, 'nama_santri': s.namaSantri, 'tingkat': s.tingkat ?? s.idKelas?.toString()}); }
        for (var s in t2) { result.add({'nis': s.nis, 'nama_santri': s.namaSantri, 'tingkat': s.tingkat ?? s.idKelas?.toString()}); }
        for (var s in t3) { result.add({'nis': s.nis, 'nama_santri': s.namaSantri, 'tingkat': s.tingkat ?? s.namaKelompok}); }
      }

      final Map<String, Map<String, dynamic>> uniqueMap = {};
      for (var s in result) {
        if (s['nis'] != null && s['nis'].toString().isNotEmpty) {
          uniqueMap[s['nis'].toString()] = s;
        }
      }

      if (mounted) {
        setState(() {
          _localSantriList = uniqueMap.values.toList();
        });
      }
    } catch (e) {
      debugPrint('Error load local santri: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    const listBulan = [
      '',
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    const listHari = [
      '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    return '${listHari[date.weekday]}, ${date.day} ${listBulan[date.month]} ${date.year}';
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? theme.colorScheme.surface : Colors.white;
    final inputFill = isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white;
    final inputBorder = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.shade300;
    final textMain = isDark ? theme.colorScheme.onSurface : const Color(0xFF111827);
    final textSub = isDark ? theme.colorScheme.onSurfaceVariant : Colors.grey.shade600;
    final handleColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    const accentGreen = Color(0xFF16A34A);

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: inputBorder),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: accentGreen, width: 1.5),
      ),
      hintStyle: TextStyle(color: textSub, fontSize: 14),
    );

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1) : null,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: accentGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catat Masalah Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                      ),
                      Text(
                        'Isi form di bawah dengan lengkap',
                        style: TextStyle(
                          fontSize: 13,
                          color: textSub,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Field 1: Santri (Autocomplete)
              Text('Santri', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSub)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  if (_localSantriList.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Data santri lokal kosong atau sedang dimuat.'),
                        backgroundColor: Colors.orange.shade700,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  final selected = await showModalBottomSheet<Map<String, dynamic>>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => SantriSelectionSheet(santriList: _localSantriList),
                  );
                  if (selected != null) {
                    setState(() {
                      _selectedSantri = selected;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: inputBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_search_outlined, color: accentGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedSantri?['nama_santri'] ?? 'Pilih Santri...',
                          style: TextStyle(
                            fontSize: 14, 
                            color: _selectedSantri == null ? textSub : textMain,
                            fontWeight: _selectedSantri == null ? FontWeight.normal : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Field 2: Jenis Masalah
              Text('Jenis Masalah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSub)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedJenisMasalah,
                dropdownColor: inputFill,
                hint: Text(
                  'Pilih jenis masalah',
                  style: TextStyle(color: textSub, fontSize: 14),
                ),
                style: TextStyle(fontSize: 14, color: textMain),
                decoration: inputDecoration.copyWith(
                  prefixIcon: const Icon(
                    Icons.category_outlined,
                    color: accentGreen,
                  ),
                ),
                icon: Icon(Icons.arrow_drop_down, color: textSub),
                items: _listJenisMasalah.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: 14, color: textMain)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedJenisMasalah = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Field 3: Tanggal Deteksi
              Text('Tanggal Deteksi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSub)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: inputBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: accentGreen,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(_selectedDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Field 4: Keterangan / Deskripsi
              Text('Keterangan / Deskripsi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSub)),
              const SizedBox(height: 8),
              TextField(
                controller: _keteranganController,
                maxLines: 4,
                style: TextStyle(fontSize: 14, color: textMain),
                decoration: inputDecoration.copyWith(
                  hintText: 'Tuliskan detail masalah yang terdeteksi...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes, color: accentGreen),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit & Cancel Buttons
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text('Batal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              // Bug Fix: Validate _selectedSantri (not a text field value)
                              if (_selectedSantri == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Pilih santri dari daftar saran terlebih dahulu!'),
                                    backgroundColor: Colors.red.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (_selectedJenisMasalah == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Pilih jenis masalah terlebih dahulu!'),
                                    backgroundColor: Colors.red.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                return;
                              }

                              setState(() => _isSaving = true);

                              final tglStr =
                                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

                              try {
                                final payload = {
                                  'nis': _selectedSantri!['nis'].toString(),
                                  'nama_santri': _selectedSantri!['nama_santri']?.toString() ?? '',
                                  'kelas': _selectedSantri!['tingkat']?.toString() ?? _selectedSantri!['kelas']?.toString() ?? '',
                                  'jenis_masalah': _selectedJenisMasalah!,
                                  'keterangan': _keteranganController.text.trim(),
                                  'tgl_masalah': tglStr,
                                };
                                await context.read<MasalahRepository>().storeMasalah(payload);
                                
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Tersimpan di antrean offline'),
                                    backgroundColor: Colors.green.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                Navigator.pop(context, true);
                              } catch (e) {
                                if (!context.mounted) return;
                                setState(() => _isSaving = false);
                                final msg = e.toString().replaceFirst('Exception: ', '');
                                final isApproval = msg.toLowerCase().contains('approval') ||
                                    msg.toLowerCase().contains('persetujuan') ||
                                    msg.toLowerCase().contains('pending');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isApproval
                                          ? 'Masalah diajukan dan menunggu persetujuan admin.'
                                          : msg,
                                    ),
                                    backgroundColor: isApproval
                                        ? Colors.orange.shade600
                                        : Colors.red.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                if (isApproval) Navigator.pop(context, true);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, size: 20),
                      label: Text(
                        _isSaving ? 'Menyimpan...' : 'Simpan Masalah',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
