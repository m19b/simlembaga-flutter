import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/features/dashboard/data/models/dashboard_model.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/screens/jadwal_kelas_screen.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/screens/jadwal_guru_screen.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/absen_mandiri_screen.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/presentation/hari_libur_screen.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/data/models/hari_libur_model.dart';
import 'package:manajemen_tahsin_app/features/hari_libur/presentation/bloc/hari_libur_cubit.dart';

class DashboardInfoCards extends StatelessWidget {
  final DashboardModel data;
  final Map<String, dynamic> statusAbsen;
  final Future<void> Function() onRefreshStatusAbsen;
  final void Function(String tipe, int idKelompok) onAbsenMandiri;

  const DashboardInfoCards({
    super.key,
    required this.data,
    required this.statusAbsen,
    required this.onRefreshStatusAbsen,
    required this.onAbsenMandiri,
  });

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return '-';
    }
  }

  dynamic _getNextSchedule(List<dynamic> jadwalGuru) {
    if (jadwalGuru.isEmpty) return null;
    int currentDay = DateTime.now().weekday;

    var todaySchedules = jadwalGuru.where((j) => (int.tryParse(j['hari']?.toString() ?? '0') ?? 0) == currentDay).toList();
    if (todaySchedules.isNotEmpty) {
      String currentTime = "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:00";
      var upcomingToday = todaySchedules.where((j) => (j['jam_pulang']?.toString() ?? '23:59:59').compareTo(currentTime) >= 0).toList();
      if (upcomingToday.isNotEmpty) return upcomingToday.first;
    }

    var nextSchedules = jadwalGuru.where((j) => (int.tryParse(j['hari']?.toString() ?? '0') ?? 0) > currentDay).toList();
    if (nextSchedules.isNotEmpty) {
      nextSchedules.sort((a, b) => (int.tryParse(a['hari']?.toString() ?? '0') ?? 0).compareTo((int.tryParse(b['hari']?.toString() ?? '0') ?? 0)));
      return nextSchedules.first;
    }

    var allSorted = List.from(jadwalGuru);
    allSorted.sort((a, b) => (int.tryParse(a['hari']?.toString() ?? '0') ?? 0).compareTo(int.tryParse(b['hari']?.toString() ?? '0') ?? 0));
    if (allSorted.isNotEmpty) return allSorted.first;
    return null;
  }

  Widget _buildJadwalTerdekatCard(BuildContext context, String title, dynamic jadwal, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String timeInfo = 'Tidak ada jadwal';

    if (jadwal != null) {
      int targetDay = int.tryParse(jadwal['hari']?.toString() ?? '0') ?? 0;
      String dayName = _getDayName(targetDay);
      String jamMasuk = jadwal['jam_masuk']?.toString() ?? '-';
      if (jamMasuk.length > 5) jamMasuk = jamMasuk.substring(0, 5);
      String jamPulang = jadwal['jam_pulang']?.toString() ?? '-';
      if (jamPulang.length > 5) jamPulang = jamPulang.substring(0, 5);
      timeInfo = '$dayName\n$jamMasuk - $jamPulang';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              timeInfo,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: jadwal != null ? color : Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbsenCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sudahDatang = statusAbsen['sudah_datang'] == true;
    final sudahPulang = statusAbsen['sudah_pulang'] == true;

    String jamMasuk = statusAbsen['jam_masuk']?.toString() ?? '--:--';
    if (jamMasuk.length > 5) jamMasuk = jamMasuk.substring(0, 5);
    String jamPulang = statusAbsen['jam_keluar']?.toString() ?? '--:--';
    if (jamPulang.length > 5) jamPulang = jamPulang.substring(0, 5);

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AbsenMandiriScreen(
              namaGuru: data.guruName,
              nig: data.nig,
              idKelompok: data.idKelompok,
            ),
          ),
        );
        onRefreshStatusAbsen();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue.shade600.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, color: Colors.blue.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Absen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('M: $jamMasuk', style: TextStyle(fontSize: 11, color: Colors.green.shade600, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('P: $jamPulang', style: TextStyle(fontSize: 11, color: Colors.red.shade600, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: sudahDatang && sudahPulang
                  ? null
                  : () => onAbsenMandiri(sudahDatang ? 'pulang' : 'datang', data.idKelompok),
              style: ElevatedButton.styleFrom(
                backgroundColor: sudahDatang
                    ? (sudahPulang
                          ? (isDark ? const Color(0xFF374151) : Colors.grey.shade200)
                          : Colors.red.shade600)
                    : const Color(0xFF16A34A),
                foregroundColor: sudahDatang ? (sudahPulang ? Colors.grey : Colors.white) : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                sudahDatang ? (sudahPulang ? '✓' : 'Pulang') : 'Masuk',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiburCard(BuildContext context, List<HariLiburModel> allHolidays) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    HariLiburModel? nearest;
    for (var h in allHolidays) {
      if (h.tanggalMulai.compareTo(todayStr) >= 0 || (h.tanggalAkhir.isNotEmpty && h.tanggalAkhir.compareTo(todayStr) >= 0)) {
        nearest = h;
        break;
      }
    }

    String title = 'Libur Terdekat';
    String namaLiburText = 'Tidak ada libur';
    String? dayStr;

    if (nearest != null) {
      final kategoriText = (nearest.kategori != null && nearest.kategori!.isNotEmpty) ? nearest.kategori! : 'Terdekat';
      title = 'Libur $kategoriText';
      namaLiburText = nearest.namaLibur;

      try {
        final parsedMulai = DateTime.parse(nearest.tanggalMulai);
        dayStr = parsedMulai.day.toString();
      } catch (_) {
        dayStr = '-';
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HariLiburScreen()));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade400.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_available, color: Colors.red.shade400, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (nearest == null)
              Text(
                namaLiburText,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: Text(
                      dayStr ?? '-',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      namaLiburText,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade400),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    dynamic nextJadwalKelas = _getNextSchedule(data.jadwalKelas);
    dynamic nextJadwalGuru = _getNextSchedule(data.jadwalGuru);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildJadwalTerdekatCard(context, 'Jadwal Kelas', nextJadwalKelas, Icons.class_outlined, Colors.indigo, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => JadwalKelasScreen(jadwalList: data.jadwalKelas)));
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildJadwalTerdekatCard(context, 'Jadwal Guru', nextJadwalGuru, Icons.person_outline, Colors.teal, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => JadwalGuruScreen(jadwalList: data.jadwalGuru)));
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildAbsenCard(context)),
                const SizedBox(width: 12),
                Expanded(
                  child: BlocBuilder<HariLiburCubit, HariLiburState>(
                    builder: (context, hlState) {
                      if (hlState is HariLiburLoaded) {
                        return _buildLiburCard(context, hlState.items);
                      }
                      return _buildLiburCard(context, []);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
