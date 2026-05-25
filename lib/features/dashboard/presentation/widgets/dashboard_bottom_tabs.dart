import 'package:flutter/material.dart';


String mapSesi(String? sesi) {
  switch (sesi) {
    case '1':
      return 'Sesi Pagi';
    case '2':
      return 'Sesi Siang';
    case '3':
      return 'Sesi Sore';
    case '4':
      return 'Sesi Malam';
    default:
      return 'Sesi ${sesi ?? '-'}';
  }
}

/// Sudah tidak dipakai — absensi kehadiran dipindahkan ke card di DashboardScreen.
class DashboardBottomTabs extends StatelessWidget {
  final dynamic data;
  final DateTime currentTime;
  const DashboardBottomTabs({
    super.key,
    required this.data,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
