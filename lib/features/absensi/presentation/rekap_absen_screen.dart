import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/absen_screen.dart';

class RekapAbsenScreen extends StatefulWidget {
  const RekapAbsenScreen({super.key});

  @override
  State<RekapAbsenScreen> createState() => _RekapAbsenScreenState();
}

class _RekapAbsenScreenState extends State<RekapAbsenScreen> {
  DateTime? _tglMulai;
  DateTime? _tglAkhir;
  late Future<Map<String, dynamic>> _rekapFuture;

  @override
  void initState() {
    super.initState();
    _tglAkhir = DateTime.now();
    _tglMulai = _tglAkhir!.subtract(const Duration(days: 6));
    _loadRekap();
  }

  void _loadRekap() {
    final tglMulaiStr = _tglMulai != null
        ? '${_tglMulai!.year}-${_tglMulai!.month.toString().padLeft(2, '0')}-${_tglMulai!.day.toString().padLeft(2, '0')}'
        : null;
    final tglAkhirStr = _tglAkhir != null
        ? '${_tglAkhir!.year}-${_tglAkhir!.month.toString().padLeft(2, '0')}-${_tglAkhir!.day.toString().padLeft(2, '0')}'
        : null;

    setState(() {
      _rekapFuture = ApiService.getRekapAbsen(
        tglMulai: tglMulaiStr,
        tglAkhir: tglAkhirStr,
      );
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_tglMulai ?? DateTime.now())
        : (_tglAkhir ?? DateTime.now());

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B5E20), // Header & Button Color
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (isStart) {
        _tglMulai = pickedDate;
        if (_tglAkhir != null && _tglAkhir!.isBefore(_tglMulai!)) {
          _tglAkhir = _tglMulai;
        }
      } else {
        _tglAkhir = pickedDate;
        if (_tglMulai != null && _tglMulai!.isAfter(_tglAkhir!)) {
          _tglMulai = _tglAkhir;
        }
      }
      _loadRekap();
    }
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return 'Pilih Tanggal';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Rekap Absensi'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _rekapFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final data = snapshot.data?['data'] as Map<String, dynamic>? ?? {};
          final hariKerja = data['hari_kerja'] as int? ?? 0;
          final rekapList =
              (data['rekap'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
              [];

          return Column(
            children: [
              _buildFilterSection(hariKerja),
              Expanded(
                child: rekapList.isEmpty
                    ? _buildEmptyState()
                    : _buildList(rekapList, hariKerja),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(int hariKerja) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _DateFilterButton(
                  label: 'Tanggal Mulai',
                  dateText: _formatDateForDisplay(_tglMulai),
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DateFilterButton(
                  label: 'Tanggal Akhir',
                  dateText: _formatDateForDisplay(_tglAkhir),
                  onTap: () => _selectDate(context, false),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.print, color: Color(0xFF2E7D32)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fitur cetak laporan sedang dikembangkan',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Total Hari Kerja: $hariKerja Hari',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> rekapList, int hariKerja) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: rekapList.length,
      itemBuilder: (context, index) {
        final item = rekapList[index];
        final namaSantri = item['nama_santri']?.toString() ?? 'Tanpa Nama';
        final nis = item['nis']?.toString() ?? '-';

        // 1. Kunci dari API Huruf Kecil (sesuai di AbsenSantriModel CI4)
        final hadir = item['hadir']?.toString() ?? '0';
        final izin = item['izin']?.toString() ?? '0';
        final sakit = item['sakit']?.toString() ?? '0';
        final alpa = item['alpha']?.toString() ?? '0';

        // 2. Hitung persentase manual (Hadir / hariKerja) x 100
        final hadirInt = int.tryParse(hadir) ?? 0;
        final double persentase = hariKerja > 0
            ? (hadirInt / hariKerja) * 100
            : 0.0;

        Color pctColor = Colors.green[700]!;
        if (persentase < 50) {
          pctColor = Colors.red[700]!;
        } else if (persentase < 80) {
          pctColor = Colors.orange[700]!;
        }

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Nama & Percentage)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green[50],
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            namaSantri,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'NIS: $nis',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: pctColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: pctColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${persentase.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: pctColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                // Stats Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      label: 'Hadir',
                      value: hadir,
                      color: Colors.green[700]!,
                    ),
                    _StatItem(
                      label: 'Sakit',
                      value: sakit,
                      color: Colors.blue[700]!,
                    ),
                    _StatItem(
                      label: 'Izin',
                      value: izin,
                      color: Colors.orange[700]!,
                    ),
                    _StatItem(
                      label: 'Alpha',
                      value: alpa,
                      color: Colors.red[700]!,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data rekap\npada tanggal tersebut',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRekap,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  final String label;
  final String dateText;
  final VoidCallback onTap;

  const _DateFilterButton({
    required this.label,
    required this.dateText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dateText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.calendar_today, size: 16, color: Colors.green[800]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
