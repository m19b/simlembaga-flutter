import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_tahsin_app/core/widgets/base_dashboard_card.dart';

class DashboardKecepatanChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartKecepatan;
  final int totalSantri;

  const DashboardKecepatanChart({
    super.key,
    required this.chartKecepatan,
    required this.totalSantri,
  });

  @override
  Widget build(BuildContext context) {
    if (chartKecepatan.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Pie Chart
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _buildChartSections(isDark),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalSantri',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Santri',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Legends
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildLegends(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections(bool isDark) {
    if (chartKecepatan.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade800,
          value: 100,
          title: '',
          radius: 20,
        ),
      ];
    }

    return chartKecepatan.map((item) {
      final label = _parseLabel(item);
      final value = _parseValue(item);
      final color = _getColorForLabel(label);

      return PieChartSectionData(
        color: color,
        value: value > 0 ? value : 0.001, // Hindari error div 0
        title: '',
        radius: 20,
      );
    }).toList();
  }

  List<Widget> _buildLegends(bool isDark) {
    return chartKecepatan.map((item) {
      final label = _parseLabel(item);
      final pct = _parsePercentage(item);
      final color = _getColorForLabel(label);

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            Text(
              '$pct%',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _parseLabel(Map<String, dynamic> item) {
    return item['label']?.toString() ??
        item['kategori']?.toString() ??
        item['nama']?.toString() ??
        'Unknown';
  }

  double _parseValue(Map<String, dynamic> item) {
    return double.tryParse(item['count']?.toString() ??
            item['jumlah']?.toString() ??
            item['value']?.toString() ??
            '0') ??
        0.0;
  }

  String _parsePercentage(Map<String, dynamic> item) {
    final pct = double.tryParse(item['percentage']?.toString() ??
            item['persentase']?.toString() ??
            item['pct']?.toString() ??
            '0') ??
        0.0;
    return pct.toStringAsFixed(0);
  }

  Color _getColorForLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('sangat cepat')) return const Color(0xFF4CAF50); // Hijau
    if (lower.contains('sangat lambat')) return const Color(0xFFF44336); // Merah
    if (lower.contains('cepat')) return const Color(0xFF2196F3); // Biru
    if (lower.contains('lambat')) return const Color(0xFFFF9800); // Orange
    if (lower.contains('standar') || lower.contains('normal')) return const Color(0xFFFFEB3B); // Kuning
    if (lower.contains('belum')) return const Color(0xFF9E9E9E); // Abu-abu
    
    // Fallback colors based on hash
    final colors = [Colors.purple, Colors.cyan, Colors.teal, Colors.indigo];
    return colors[label.hashCode % colors.length];
  }
}
