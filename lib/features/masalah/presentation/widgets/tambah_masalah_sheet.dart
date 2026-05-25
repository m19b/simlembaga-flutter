import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:manajemen_tahsin_app/features/masalah/presentation/bloc/masalah_cubit.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/masalah/presentation/widgets/santri_selection_sheet.dart';
import 'masalah_constants.dart';

class TambahMasalahSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const TambahMasalahSheet({super.key, required this.onSaved});

  @override
  State<TambahMasalahSheet> createState() => _TambahMasalahSheetState();
}

class _TambahMasalahSheetState extends State<TambahMasalahSheet> {
  final _formKey = GlobalKey<FormState>();

  // Autocomplete santri
  final _namaCtrl = TextEditingController();
  final _keteranganCtrl = TextEditingController();
  String? _selectedNis;
  String? _selectedKelas;

  String? _jenisMasalah;
  DateTime _tglMasalah = DateTime.now();
  bool _saving = false;

  static const _jenisList = [
    'Kehadiran',
    'Keterlambatan Belajar',
    'Tidak Disimak di Rumah',
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
      int activeId = 0;
      try {
        activeId = context.read<ActiveKelompokCubit>().state.activeId;
      } catch (e) {
        // Fallback
        activeId = 0;
      }

      final result = await context.read<MasalahCubit>().getLocalSantri(activeId);
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

  @override
  void dispose() {
    _namaCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedNis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Pilih santri dari daftar saran',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<MasalahCubit>().repository.storeMasalah({
        'nis': _selectedNis!,
        'nama_santri': _namaCtrl.text,
        'kelas': _selectedKelas ?? '',
        'jenis_masalah': _jenisMasalah!,
        'keterangan': _keteranganCtrl.text.trim(),
        'tgl_masalah': DateFormat('yyyy-MM-dd').format(_tglMasalah),
      });
      if (!mounted) return;
      // BUG FIX: Capture messenger BEFORE pop — context becomes invalid after Navigator.pop
      final messenger = ScaffoldMessenger.of(context);
      final onSaved = widget.onSaved;
      Navigator.pop(context);
      onSaved();
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Masalah berhasil dicatat',
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
      final msg = e.toString().replaceAll('Exception: ', '');
      final isApproval =
          msg.toLowerCase().contains('approval') ||
          msg.toLowerCase().contains('persetujuan') ||
          msg.toLowerCase().contains('pending');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApproval
                ? 'Masalah diajukan dan menunggu persetujuan admin.'
                : msg,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: isApproval
              ? Colors.orange.shade600
              : Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      if (isApproval) {
        // Snackbar already shown above. Just close sheet and refresh.
        final onSaved = widget.onSaved;
        Navigator.pop(context);
        onSaved();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark
        ? theme.colorScheme.surface
        : const Color(0xFFF8FAFC);
    final inputColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : Colors.white;
    final textColor = isDark ? theme.colorScheme.onSurface : masalahText1Color;
    final labelColor = isDark ? theme.colorScheme.onSurfaceVariant : masalahText2Color;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFE5E7EB);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: isDark
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                )
              : null,
        ),
        child: Form(
          key: _formKey,
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
                        color: isDark
                            ? Colors.grey.shade700
                            : const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                // Header sheet
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: masalahHeaderColor.withAlpha(18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: masalahHeaderColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catat Masalah Baru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Isi form di bawah dengan lengkap',
                            style: TextStyle(fontSize: 12, color: labelColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Form fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Cari santri
                      _formLabel(context, 'Santri'),
                      InkWell(
                        onTap: () async {
                          if (_localSantriList.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Data santri lokal kosong atau sedang dimuat.',
                                ),
                                backgroundColor: Colors.orange.shade700,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          final selected =
                              await showModalBottomSheet<Map<String, dynamic>>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (ctx) => SantriSelectionSheet(
                                  santriList: _localSantriList,
                                ),
                              );
                          if (selected != null) {
                            setState(() {
                              _selectedNis = selected['nis']?.toString();
                              _namaCtrl.text =
                                  selected['nama_santri']?.toString() ?? '';
                              _selectedKelas =
                                  selected['tingkat']?.toString() ??
                                  selected['kelas']?.toString() ??
                                  '';
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: inputColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_search_rounded,
                                color: masalahAccentColor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _namaCtrl.text.isEmpty
                                      ? 'Ketik NIS atau nama santri...'
                                      : _namaCtrl.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _namaCtrl.text.isEmpty
                                        ? labelColor
                                        : textColor,
                                    fontWeight: _namaCtrl.text.isEmpty
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Jenis masalah
                      _formLabel(context, 'Jenis Masalah'),
                      DropdownButtonFormField<String>(
                        initialValue: _jenisMasalah,
                        isExpanded: true,
                        hint: Text(
                          'Pilih jenis masalah',
                          style: TextStyle(color: labelColor, fontSize: 13),
                        ),
                        style: TextStyle(fontSize: 14, color: textColor),
                        dropdownColor: inputColor,
                        decoration: _inputDeco(
                          context,
                          hint: '',
                          icon: Icons.category_outlined,
                        ).copyWith(hintText: null),
                        items: _jenisList
                            .map(
                              (j) => DropdownMenuItem(
                                value: j,
                                child: Row(
                                  children: [
                                    Icon(
                                      masalahJenisIcon(j),
                                      size: 16,
                                      color: masalahJenisColor(j),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(j),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _jenisMasalah = v),
                        validator: (v) =>
                            v == null ? 'Pilih jenis masalah' : null,
                      ),
                      const SizedBox(height: 14),
                      // Tanggal
                      _formLabel(context, 'Tanggal Deteksi'),
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _tglMasalah,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) setState(() => _tglMasalah = d);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: inputColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: masalahAccentColor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                DateFormat(
                                  'EEEE, d MMMM yyyy',
                                  'id_ID',
                                ).format(_tglMasalah),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Keterangan
                      _formLabel(context, 'Keterangan / Deskripsi'),
                      TextFormField(
                        controller: _keteranganCtrl,
                        maxLines: 4,
                        style: TextStyle(fontSize: 14, color: textColor),
                        decoration: _inputDeco(
                          context,
                          hint: 'Tuliskan detail masalah yang terdeteksi...',
                          icon: Icons.notes_rounded,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Keterangan wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      // Tombol simpan
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: masalahHeaderColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _saving ? null : _simpan,
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
                                  Icons.save_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          label: Text(
                            _saving ? 'Menyimpan...' : 'Simpan Masalah',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Form helpers --------------------------------------------------------------
Widget _formLabel(BuildContext context, String text) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final labelColor = isDark
      ? Theme.of(context).colorScheme.onSurfaceVariant
      : masalahText2Color;
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: labelColor,
          letterSpacing: 0.3,
        ),
      ),
    ),
  );
}

InputDecoration _inputDeco(
  BuildContext context, {
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final fillColor = isDark
      ? Theme.of(context).colorScheme.surfaceContainerHigh
      : Colors.white;
  final hintColor = isDark
      ? Theme.of(context).colorScheme.onSurfaceVariant
      : masalahText2Color;
  final borderColor = isDark
      ? Colors.white.withValues(alpha: 0.1)
      : const Color(0xFFE5E7EB);

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: hintColor, fontSize: 13),
    prefixIcon: Icon(icon, color: masalahAccentColor, size: 18),
    suffixIcon: suffix != null
        ? Padding(padding: const EdgeInsets.all(12), child: suffix)
        : null,
    filled: true,
    fillColor: fillColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: masalahAccentColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade400),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
    ),
  );
}
