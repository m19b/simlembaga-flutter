import 'package:intl/intl.dart';

/// Kumpulan helper pemformatan tanggal yang dipakai berulang di banyak fitur.
/// Sebelumnya: dideklarasikan sebagai fungsi lokal `_fmtTgl()` di setiap widget.
class AppDateFormatter {
  AppDateFormatter._();

  /// Format: `12 Jan 2025`
  static String short(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final d = DateTime.parse(raw);
      return DateFormat('d MMM yyyy', 'id_ID').format(d);
    } catch (_) {
      return raw;
    }
  }

  /// Format: `Senin, 12 Januari 2025`
  static String long(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final d = DateTime.parse(raw);
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);
    } catch (_) {
      return raw;
    }
  }

  /// Format: `12/01/2025`
  static String slash(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final d = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return raw;
    }
  }

  /// Format untuk API: `yyyy-MM-dd`
  static String toApi(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// Hitung umur dari tanggal lahir (string yyyy-MM-dd)
  static String age(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final born = DateTime.parse(raw);
      final age = DateTime.now().year - born.year;
      return '$age th';
    } catch (_) {
      return '';
    }
  }
}
