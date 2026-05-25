import 'package:flutter/material.dart';

// --- Design Tokens -------------------------------------------------------------
const Color masalahHeaderColor = Color(0xFF0F4C2A);
const Color masalahBgColor = Color(0xFFF3F4F6);
const Color masalahText1Color = Color(0xFF111827);
const Color masalahText2Color = Color(0xFF6B7280);
const Color masalahAccentColor = Color(0xFF16A34A);

// Warna per jenis masalah
Color masalahJenisColor(String? jenis) {
  switch (jenis) {
    case 'Kehadiran':
      return const Color(0xFFEF4444);
    case 'Keterlambatan Belajar':
      return const Color(0xFFF59E0B);
    case 'Tidak Disimak di Rumah':
      return const Color(0xFF8B5CF6);
    default:
      return const Color(0xFF6B7280);
  }
}

IconData masalahJenisIcon(String? jenis) {
  switch (jenis) {
    case 'Kehadiran':
      return Icons.event_busy_rounded;
    case 'Keterlambatan Belajar':
      return Icons.trending_down_rounded;
    case 'Tidak Disimak di Rumah':
      return Icons.hearing_disabled_rounded;
    default:
      return Icons.info_outline_rounded;
  }
}

String masalahJenisLabel(String? jenis) => jenis ?? 'Lainnya';
