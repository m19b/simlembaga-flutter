import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';

class CatatMasalahBottomSheet extends StatefulWidget {
  const CatatMasalahBottomSheet({super.key});

  @override
  State<CatatMasalahBottomSheet> createState() =>
      _CatatMasalahBottomSheetState();
}

class _CatatMasalahBottomSheetState extends State<CatatMasalahBottomSheet> {
  // Input Controllers
  final TextEditingController _keteranganController = TextEditingController();

  // State
  Map<String, dynamic>? _selectedSantri;
  String? _selectedJenisMasalah;
  DateTime _selectedDate = DateTime.now();

  // Dummy List Jenis Masalah
  final List<String> _listJenisMasalah = [
    'Indisipliner',
    'Akademik',
    'Kesehatan',
    'Lainnya',
  ];

  // Fungsi Pilih Tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF16A34A), // Warna hijau SIM Tahsin
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Format Tanggal Manual (karena package intl mungkin tidak terimport)
  String _formatDate(DateTime date) {
    const listBulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    const listHari = [
      '',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    String namaHari = listHari[date.weekday];
    String namaBulan = listBulan[date.month];

    return '$namaHari, ${date.day} $namaBulan ${date.year}';
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Styling constants
    final labelStyle = GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade600,
    );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
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
              // Handle Bottom Sheet
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
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
                      color: const Color(0xFF16A34A).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF16A34A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catat Masalah Baru',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Isi form di bawah dengan lengkap',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Field 1: Santri (Autocomplete)
              Text('Santri', style: labelStyle),
              const SizedBox(height: 8),
              if (_selectedSantri == null)
                Autocomplete<Map<String, dynamic>>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    final keyword = textEditingValue.text;
                    if (keyword.length < 2) return <Map<String, dynamic>>[];
                    try {
                      final list = await ApiService.cariSantri(keyword);
                      return list as Iterable<Map<String, dynamic>>;
                    } catch (_) {
                      return <Map<String, dynamic>>[];
                    }
                  },
                  displayStringForOption: (option) =>
                      option['nama_santri'] as String,
                  onSelected: (suggestion) {
                    setState(() {
                      _selectedSantri = suggestion;
                    });
                  },
                  fieldViewBuilder:
                      (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: inputDecoration.copyWith(
                            hintText: 'Ketik NIS atau nama santri...',
                            prefixIcon: const Icon(
                              Icons.person_search_outlined,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        );
                      },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        shadowColor: Colors.black.withOpacity(0.1),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                            maxWidth: 380,
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length > 3 ? 3 : options.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey.shade100,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  option['nama_santri'] as String,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  '${option['nis']} • ${option['kelas']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                )
              else
                // Selected Santri Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          _selectedSantri!['nama_santri'][0].toUpperCase(),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedSantri!['nama_santri'],
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NIS: ${_selectedSantri!['nis']} • Kelas: ${_selectedSantri!['kelas']}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _selectedSantri = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Field 2: Jenis Masalah
              Text('Jenis Masalah', style: labelStyle),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedJenisMasalah,
                hint: Text(
                  'Pilih jenis masalah',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                decoration: inputDecoration.copyWith(
                  prefixIcon: const Icon(
                    Icons.category_outlined,
                    color: Color(0xFF16A34A),
                  ),
                ),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                items: _listJenisMasalah.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: GoogleFonts.inter(fontSize: 14)),
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
              Text('Tanggal Deteksi', style: labelStyle),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(_selectedDate),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Field 4: Keterangan / Deskripsi
              Text('Keterangan / Deskripsi', style: labelStyle),
              const SizedBox(height: 8),
              TextField(
                controller: _keteranganController,
                maxLines: 4,
                decoration: inputDecoration.copyWith(
                  hintText: 'Tuliskan detail masalah yang terdeteksi...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60), // Align icon to top
                    child: Icon(Icons.notes, color: Color(0xFF16A34A)),
                  ),
                ),
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_selectedSantri == null ||
                        _selectedJenisMasalah == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pilih Santri dan Jenis Masalah terlebih dahulu!',
                          ),
                        ),
                      );
                      return;
                    }

                    // Simpan data (Implementasi ke API)
                    final dataToSave = {
                      'id_santri': _selectedSantri!['id'],
                      'nis': _selectedSantri!['nis'],
                      'nama': _selectedSantri!['nama_santri'],
                      'jenis_masalah': _selectedJenisMasalah,
                      'tanggal_deteksi': _selectedDate.toIso8601String(),
                      'keterangan': _keteranganController.text,
                    };

                    Navigator.pop(context, dataToSave);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF0F5132,
                    ), // Dark Green matching the image
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.save_outlined, size: 20),
                  label: Text(
                    'Simpan Masalah',
                    style: GoogleFonts.inter(
                      fontSize: 16,
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
