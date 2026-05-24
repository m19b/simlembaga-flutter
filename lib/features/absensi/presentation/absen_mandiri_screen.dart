import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'package:manajemen_tahsin_app/features/absensi/domain/repositories/absensi_repository.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/bloc/absensi_cubit.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/widgets/app_header_bar.dart';
/// Halaman Absen Mandiri (OFFLINE-FIRST).
/// Mesin data sudah dipindah ke [AbsensiCubit] + [AbsensiRepository].
/// Widget ini murni UI — tidak ada ApiService inline atau setState manual.
class AbsenMandiriScreen extends StatelessWidget {
  final String namaGuru;
  final String nig;
  final int idKelompok;

  const AbsenMandiriScreen({
    super.key,
    required this.namaGuru,
    required this.nig,
    required this.idKelompok,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AbsensiCubit(
        repository: context.read<AbsensiRepository>(),
        activeKelompokCubit: context.read<ActiveKelompokCubit>(),
      )..fetchAbsenMandiri(idKelompok),
      child: _AbsenMandiriView(
        namaGuru: namaGuru,
        nig: nig,
        idKelompok: idKelompok,
      ),
    );
  }
}

class _AbsenMandiriView extends StatelessWidget {
  final String namaGuru;
  final String nig;
  final int idKelompok;

  const _AbsenMandiriView({
    required this.namaGuru,
    required this.nig,
    required this.idKelompok,
  });

  // ── GPS Helper (Anti-Freeze + 5s Timeout) ───────────────────────────────────
  //
  // Seluruh fungsi ini berjalan async tanpa memblokir UI Thread.
  // Jika GPS tidak berhasil dalam 5 detik, kembalikan null (absen tanpa koordinat).
  Future<Position?> _getPosition(BuildContext context) async {
    try {
      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!context.mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                '📍 Layanan GPS tidak aktif. Mohon nyalakan GPS Anda.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'PENGATURAN',
              textColor: Colors.white,
              onPressed: Geolocator.openLocationSettings,
            ),
          ),
        );
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!context.mounted) return null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '⚠️ Izin lokasi ditolak. Absensi dilanjutkan tanpa koordinat.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!context.mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                '🚫 Izin lokasi ditolak permanen. Absensi dilanjutkan tanpa koordinat.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'BUKA PENGATURAN',
              textColor: Colors.white,
              onPressed: Geolocator.openAppSettings,
            ),
          ),
        );
        return null;
      }

      // Coba ambil posisi terakhir yang diketahui sebagai fallback
      Position? lastPos;
      try {
        lastPos = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      // Ambil posisi saat ini dengan timeout 5 detik
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception('GPS timeout'),
        );
      } catch (_) {
        // Timeout atau error → gunakan posisi terakhir (atau null)
        return lastPos;
      }
    } catch (e) {
      debugPrint('Geolocator error: $e');
      return null;
    }
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  // GPS diambil di sini (UI layer) agar cubit tidak perlu tahu soal Geolocator.
  // Tombol sudah dalam state ActionLoading saat GPS sedang diambil.
  Future<void> _absen(
    BuildContext context,
    String tipe,
    Map<String, dynamic> currentStatus,
    List<Map<String, dynamic>> currentRiwayat,
  ) async {
    // Tampilkan GPS loading state segera — tombol berubah jadi spinner
    context.read<AbsensiCubit>().setActionLoading(
          status: currentStatus,
          riwayat: currentRiwayat,
        );

    // Ambil GPS dengan timeout — tidak memblokir UI
    final Position? pos = await _getPosition(context);
    if (!context.mounted) return;

    // Kirim ke cubit (online atau offline queue otomatis)
    await context.read<AbsensiCubit>().submitAbsenMandiri(
          tipe: tipe,
          idKelompok: idKelompok,
          lat: pos?.latitude,
          lng: pos?.longitude,
          currentStatus: currentStatus,
          currentRiwayat: currentRiwayat,
        );
  }

  Future<void> _confirmAbsenPulang(
    BuildContext context,
    Map<String, dynamic> status,
    List<Map<String, dynamic>> riwayat,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Absen Pulang', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin melakukan absen pulang sekarang?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yakin, Pulang', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      _absen(context, 'pulang', status, riwayat);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppHeaderBar(
        title: 'Absensi Mandiri',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () =>
                context.read<AbsensiCubit>().fetchAbsenMandiri(idKelompok),
          ),
        ],
      ),
      body: BlocConsumer<AbsensiCubit, AbsensiState>(
        listener: (context, state) {
          if (state is AbsenMandiriSubmitSuccess) {
            final cs = Theme.of(context).colorScheme;
            // Offline queue → warna berbeda agar guru tahu data pending
            final Color bgColor = state.savedOffline
                ? Colors.blueGrey.shade700
                : state.isWarning
                    ? Colors.orange.shade700
                    : cs.primary;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: bgColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is AbsensiError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final cs = Theme.of(context).colorScheme;
          if (state is AbsensiLoading) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          }

          if (state is AbsensiError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () =>
                  context.read<AbsensiCubit>().fetchAbsenMandiri(idKelompok),
            );
          }

          Map<String, dynamic> statusData = {};
          List<Map<String, dynamic>> riwayatData = [];
          bool isActionLoading = false;

          if (state is AbsenMandiriLoaded) {
            statusData = state.status;
            riwayatData = state.riwayat;
          } else if (state is AbsensiActionLoading) {
            statusData = state.status;
            riwayatData = state.riwayat;
            isActionLoading = true;
          } else if (state is AbsenMandiriSubmitSuccess) {
            if (!state.savedOffline) {
              // Online sukses → cubit sudah re-fetch, tampilkan spinner sebentar
              return Center(child: CircularProgressIndicator(color: cs.primary));
            }
            // Offline queue → UI sudah menampilkan snackbar, biarkan tampilan data lama
          }

          final sudahDatang = statusData['sudah_datang'] == true;
          final sudahPulang = statusData['sudah_pulang'] == true;
          final jamMasuk = statusData['jam_masuk']?.toString();
          final jamKeluar = statusData['jam_keluar']?.toString();
          final totalTelat = int.tryParse(statusData['total_telat_menit']?.toString() ?? '0') ?? 0;
          final totalCepat = int.tryParse(statusData['total_cepat_menit']?.toString() ?? '0') ?? 0;
          final totalCepatDatang = int.tryParse(statusData['total_cepat_datang_menit']?.toString() ?? '0') ?? 0;
          final totalTelatPulang = int.tryParse(statusData['total_telat_pulang_menit']?.toString() ?? '0') ?? 0;

          return RefreshIndicator(
            color: cs.primary,
            onRefresh: () =>
                context.read<AbsensiCubit>().fetchAbsenMandiri(idKelompok),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusCard(
                    context,
                    sudahDatang: sudahDatang,
                    sudahPulang: sudahPulang,
                    jamMasuk: jamMasuk,
                    jamKeluar: jamKeluar,
                    totalTelat: totalTelat,
                    totalCepat: totalCepat,
                    totalCepatDatang: totalCepatDatang,
                    totalTelatPulang: totalTelatPulang,
                    isActionLoading: isActionLoading,
                    currentStatus: statusData,
                    currentRiwayat: riwayatData,
                  ),
                  const SizedBox(height: 20),
                  _buildRiwayatSection(context, riwayatData),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── UI Builders ──────────────────────────────────────────────────────────────

  Widget _buildStatusCard(
    BuildContext context, {
    required bool sudahDatang,
    required bool sudahPulang,
    String? jamMasuk,
    String? jamKeluar,
    required int totalTelat,
    required int totalCepat,
    required int totalCepatDatang,
    required int totalTelatPulang,
    required bool isActionLoading,
    required Map<String, dynamic> currentStatus,
    required List<Map<String, dynamic>> currentRiwayat,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            color: cs.primaryContainer,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: cs.onPrimaryContainer.withValues(alpha: 0.15),
                  child: Text(
                    namaGuru.isNotEmpty ? namaGuru[0].toUpperCase() : 'G',
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaGuru.isNotEmpty ? namaGuru : '-',
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'NIG: ${nig.isNotEmpty ? nig : '-'}',
                        style: TextStyle(
                          color: cs.onPrimaryContainer.withValues(alpha: 0.65),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status jam masuk / pulang
          Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(child: _JamInfo(label: 'Jam Masuk', jam: _fmtJam(jamMasuk), icon: Icons.login_rounded, color: cs.primary, sudah: sudahDatang)),
                Container(width: 1, height: 40, color: cs.outline.withValues(alpha: 0.2)),
                Expanded(child: _JamInfo(label: 'Jam Pulang', jam: _fmtJam(jamKeluar), icon: Icons.logout_rounded, color: cs.error, sudah: sudahPulang)),
              ],
            ),
          ),

          // Rekap telat / cepat bulan ini
          if (totalTelat > 0 || totalCepat > 0 || totalCepatDatang > 0 || totalTelatPulang > 0)
            Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceContainer : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics_outlined, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 10),
                        Text('Bulan Ini:', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (totalTelat > 0) _MiniChip(label: 'Telat Masuk $totalTelat mnt', icon: Icons.schedule, color: Colors.red),
                        if (totalCepatDatang > 0) _MiniChip(label: 'Cepat Hadir $totalCepatDatang mnt', icon: Icons.directions_run, color: Colors.green),
                        if (totalCepat > 0) _MiniChip(label: 'Pulang Cepat $totalCepat mnt', icon: Icons.directions_walk, color: Colors.orange),
                        if (totalTelatPulang > 0) _MiniChip(label: 'Lembur / Telat Pulang $totalTelatPulang mnt', icon: Icons.more_time, color: Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: isActionLoading
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          color: cs.primary,
                          backgroundColor: cs.primaryContainer,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📍 Mengambil lokasi GPS...',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildAbsenBtn(
                          context: context,
                          label: sudahDatang ? 'Sudah Masuk' : 'Absen Masuk',
                          icon: Icons.login_rounded,
                          color: cs.primary,
                          enabled: !sudahDatang,
                          onTap: () => _absen(
                              context, 'datang', currentStatus, currentRiwayat),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAbsenBtn(
                          context: context,
                          label: sudahPulang ? 'Sudah Pulang' : 'Absen Pulang',
                          icon: Icons.logout_rounded,
                          color: cs.error,
                          enabled: sudahDatang && !sudahPulang,
                          onTap: () => _confirmAbsenPulang(
                              context, currentStatus, currentRiwayat),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsenBtn({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: enabled ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(color: enabled ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatSection(BuildContext context, List<Map<String, dynamic>> riwayat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Riwayat Bulan Ini',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ),
        if (riwayat.isEmpty)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text('Belum ada riwayat bulan ini', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)))),
            ),
          )
        else
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: riwayat.asMap().entries.map((e) {
                final i = e.key;
                final r = e.value;
                final kehadiran = r['kehadiran']?.toString() ?? '-';
                final clr = _badgeColor(kehadiran);
                final menitTerlambat = int.tryParse(r['menit_terlambat']?.toString() ?? '0') ?? 0;
                final menitCepat = int.tryParse(r['menit_cepat']?.toString() ?? '0') ?? 0;
                final menitCepatDatang = int.tryParse(r['menit_cepat_datang']?.toString() ?? '0') ?? 0;
                final menitTelatPulang = int.tryParse(r['menit_telat_pulang']?.toString() ?? '0') ?? 0;
                final badgeText = kehadiran.toLowerCase() == 'tanpa keterangan' ? 'Alpha' : kehadiran;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: clr.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              kehadiran.toLowerCase() == 'hadir' ? Icons.check_circle_outline : Icons.cancel_outlined,
                              color: clr,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_formatTanggal(r['tanggal']?.toString()), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(
                                  '${_fmtJam(r['jam_masuk']?.toString())} → ${_fmtJam(r['jam_keluar']?.toString())}',
                                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                                ),
                                if (kehadiran.toLowerCase() == 'hadir' &&
                                    (menitTerlambat > 0 || menitCepat > 0 || menitCepatDatang > 0 || menitTelatPulang > 0)) ...[
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (menitTerlambat > 0) _RiwayatChip(label: '⏱️ Telat $menitTerlambat Mnt', color: Colors.red),
                                      if (menitCepatDatang > 0) _RiwayatChip(label: '🏃 Cepat Hadir $menitCepatDatang Mnt', color: Colors.green),
                                      if (menitCepat > 0) _RiwayatChip(label: '🏃 Pulang Cepat $menitCepat Mnt', color: Colors.orange),
                                      if (menitTelatPulang > 0) _RiwayatChip(label: '🌙 Lembur $menitTelatPulang Mnt', color: Colors.blue),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: clr.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(badgeText, style: TextStyle(color: clr, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    if (i < riwayat.length - 1)
                      Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), indent: 16, endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ── Formatters ────────────────────────────────────────────────────────────────

  String _fmtJam(String? raw) {
    if (raw == null || raw.isEmpty) return '--:--';
    final parts = raw.split(':');
    return parts.length >= 2 ? '${parts[0]}:${parts[1]}' : raw;
  }

  String _formatTanggal(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Color _badgeColor(String kehadiran) => switch (kehadiran.toLowerCase()) {
        'hadir' => Colors.green.shade600,
        'sakit' => Colors.blue.shade400,
        'izin' => Colors.amber.shade600,
        _ => Colors.red.shade600,
      };
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _JamInfo extends StatelessWidget {
  final String label, jam;
  final IconData icon;
  final Color color;
  final bool sudah;

  const _JamInfo({
    required this.label,
    required this.jam,
    required this.icon,
    required this.color,
    required this.sudah,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: sudah ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), size: 22),
          const SizedBox(height: 4),
          Text(jam, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: sudah ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2))),
          Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}

/// Mini chip untuk blok rekap "Bulan Ini" di status card.
class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final MaterialColor color;

  const _MiniChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade200.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 1.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.shade700),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Mini chip untuk baris riwayat absen.
class _RiwayatChip extends StatelessWidget {
  final String label;
  final MaterialColor color;

  const _RiwayatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.shade200.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 1.0)),
      ),
      child: Text(label, style: TextStyle(color: color.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
