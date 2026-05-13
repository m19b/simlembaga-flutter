import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/absen_mandiri_screen.dart';

class DashboardBottomTabs extends StatefulWidget {
  final dynamic data;
  final String currentTime;
  const DashboardBottomTabs({super.key, required this.data, required this.currentTime});

  @override
  State<DashboardBottomTabs> createState() => _DashboardBottomTabsState();
}

String mapSesi(String? sesi) {
  switch (sesi) {
    case '1': return 'Sesi Pagi';
    case '2': return 'Sesi Siang';
    case '3': return 'Sesi Sore';
    case '4': return 'Sesi Malam';
    default: return 'Sesi ${sesi ?? '-'}';
  }
}

class _DashboardBottomTabsState extends State<DashboardBottomTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _statusAbsen = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 0) _fetchStatusAbsen();
    });
    _fetchStatusAbsen();
  }

  Future<void> _fetchStatusAbsen() async {
    try {
      final res = await ApiService.getStatusAbsenMandiri(widget.data.idKelompok);
      if (mounted) setState(() {
        _statusAbsen = (res['data']?['status_absen'] as Map<String, dynamic>?) ?? {};
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleAbsenMandiri(String tipe) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final res = await ApiService.postAbsenMandiri(
        tipe: tipe,
        idKelompok: ActiveKelompokCubit.activeKelompokId,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Berhasil absen $tipe'), backgroundColor: Colors.green));
      _fetchStatusAbsen();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal absen: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _buildAbsensiKehadiran(String name) {
    final sudahDatang = _statusAbsen['sudah_datang'] == true;
    final sudahPulang = _statusAbsen['sudah_pulang'] == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fingerprint, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text('Absensi Kehadiran', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(widget.currentTime, style: GoogleFonts.dmMono(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.2) : Colors.green.shade50,
                  radius: 20,
                  child: Text(name.isNotEmpty ? name[0] : 'A', style: TextStyle(color: isDark ? Colors.greenAccent : Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface)),
                      Text('Absen Mandiri Guru', style: GoogleFonts.dmSans(color: isDark ? Colors.grey.shade400 : const Color(0xFF6B7280), fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: sudahDatang ? null : () => _handleAbsenMandiri('datang'),
                    icon: Icon(Icons.login, color: sudahDatang ? Colors.grey.shade400 : Colors.white, size: 18),
                    label: Text(sudahDatang ? 'Sudah Masuk' : 'Masuk', style: TextStyle(color: sudahDatang ? Colors.grey.shade400 : Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sudahDatang ? (isDark ? const Color(0xFF374151) : Colors.grey.shade200) : const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (sudahDatang && !sudahPulang) ? () => _handleAbsenMandiri('pulang') : null,
                    icon: Icon(Icons.logout, color: (sudahDatang && !sudahPulang) ? Colors.white : Colors.grey.shade500, size: 18),
                    label: Text(sudahPulang ? 'Sudah Pulang' : 'Pulang', style: TextStyle(color: (sudahDatang && !sudahPulang) ? Colors.white : Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (sudahDatang && !sudahPulang) ? const Color(0xFFEF4444) : (isDark ? const Color(0xFF374151) : Colors.grey.shade200),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AbsenMandiriScreen(
                namaGuru: widget.data.guruName,
                nig: widget.data.nig,
                idKelompok: widget.data.idKelompok,
              )));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16A34A).withValues(alpha: 0.1) : Colors.green.shade50,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Tampilkan history absen', style: GoogleFonts.dmSans(color: isDark ? Colors.greenAccent : Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                  Icon(Icons.chevron_right, color: isDark ? Colors.greenAccent : Colors.green.shade700, size: 16)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildJadwalMengajar(List<dynamic> jadwal) {
    if (jadwal.isEmpty) return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text("Tidak ada jadwal mengajar", style: TextStyle(color: Colors.grey))));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: jadwal.length,
      itemBuilder: (context, index) {
        final item = jadwal[index];
        final dayName = ['-', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][int.tryParse(item['hari']?.toString() ?? '0') ?? 0];
        final name = '$dayName, ${mapSesi(item['sesi']?.toString())}';
        final toleransi = item['toleransi_terlambat'] ?? '0';
        final start = item['jam_masuk']?.toString().substring(0, 5) ?? '00:00';
        final end = item['jam_pulang']?.toString().substring(0, 5) ?? '00:00';
        final colors = [Colors.orange, Colors.blue, Colors.green, Colors.purple, Colors.red, Colors.teal];
        final color = colors[index % colors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.3))),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.account_box, color: isDark ? color.shade300 : color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: isDark ? color.shade300 : color.shade700, fontSize: 13)),
                    Text('Toleransi: ${toleransi}mnt', style: GoogleFonts.dmSans(color: isDark ? color.shade200 : color.shade400, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$start - $end', style: GoogleFonts.dmMono(fontWeight: FontWeight.bold, color: isDark ? color.shade300 : color.shade700, fontSize: 13)),
                  Text('Waktu', style: GoogleFonts.dmSans(color: isDark ? color.shade200 : color.shade400, fontSize: 10)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJadwalKelas(List<dynamic> jadwal) {
    if (jadwal.isEmpty) return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text("Tidak ada jadwal kelas", style: TextStyle(color: Colors.grey))));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: jadwal.length,
      itemBuilder: (context, index) {
        final item = jadwal[index];
        final kelas = item['nama_kelas'] ?? 'Kelas';
        final dayName = ['-', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][int.tryParse(item['hari']?.toString() ?? '0') ?? 0];
        final name = '$dayName, ${mapSesi(item['sesi']?.toString())}';
        final start = item['jam_masuk']?.toString().substring(0, 5) ?? '00:00';
        final end = item['jam_pulang']?.toString().substring(0, 5) ?? '00:00';
        final colors = [Colors.blue, Colors.orange, Colors.green, Colors.purple, Colors.red, Colors.teal];
        final color = colors[index % colors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.3))),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.book, color: isDark ? color.shade300 : color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: isDark ? color.shade300 : color.shade700, fontSize: 13)),
                    Text('Kelas: $kelas', style: GoogleFonts.dmSans(color: isDark ? color.shade200 : color.shade400, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$start - $end', style: GoogleFonts.dmMono(fontWeight: FontWeight.bold, color: isDark ? color.shade300 : color.shade700, fontSize: 13)),
                  Text('Waktu', style: GoogleFonts.dmSans(color: isDark ? color.shade200 : color.shade400, fontSize: 10)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
              ),
              labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F4C2A),
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "Absen Saya"),
                Tab(text: "Mengajar"),
                Tab(text: "Kelas"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            switch (_tabController.index) {
              case 0: return _buildAbsensiKehadiran(widget.data.guruName);
              case 1: return _buildJadwalMengajar(widget.data.jadwalGuru);
              case 2: return _buildJadwalKelas(widget.data.jadwalKelas);
              default: return const SizedBox();
            }
          }
        )
      ],
    );
  }
}
