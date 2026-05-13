import 'dart:convert';
import 'package:flutter/material.dart';

class ProgressSegmentItem {
  final double flex;
  final Color color;

  ProgressSegmentItem({required this.flex, required this.color});
}

class MultiSegmentProgressBar extends StatelessWidget {
  final String title;
  final IconData icon;
  final double capai;
  final double total;
  final List<dynamic>? checkpoints; // Data checkpoints santri
  final Color baseColor; // Warna text/icon base
  final Widget? trailingText;

  const MultiSegmentProgressBar({
    Key? key,
    required this.title,
    required this.icon,
    required this.capai,
    required this.total,
    this.checkpoints,
    required this.baseColor,
    this.trailingText,
  }) : super(key: key);

  /// Helper Murni: Hitung segment warna
  /// - Jika <= targetCP1: 1 Segmen warna Ungu/Indigo
  /// - Jika > targetCP1: 2 Segmen (1 sebesar target CP1 warna Indigo, sisanya Hijau)
  /// - Khusus judul Akselerasi: selalu pakai merah jika tidak ada checkpoints logic
  static List<ProgressSegmentItem> calculateSegments(
    double capai,
    double total,
    dynamic rawCheckpoints,
    String title,
    Color baseColor,
  ) {
    final double safeTotal = total <= 0 ? 1.0 : total;
    final double safeCapai = capai.clamp(0.0, safeTotal);

    if (safeCapai == 0) return [];

    final bool isAkselerasi = title.toLowerCase().contains('akselerasi') || title.toLowerCase().contains('aks');
    if (isAkselerasi) {
      return [ProgressSegmentItem(flex: safeCapai / safeTotal, color: const Color(0xFFEA5455))];
    }

    final List<Color> palette = [
      const Color(0xFF6610F2), // 1. Ungu/Indigo
      const Color(0xFF00CFE8), // 2. Cyan/Info
      const Color(0xFF28C76F), // 3. Hijau/Success
      const Color(0xFFFF9F43), // 4. Orange/Warning
      const Color(0xFF7367F0), // 5. Primary
    ];

    List<dynamic> checkpoints = [];
    if (rawCheckpoints is List) {
      checkpoints = rawCheckpoints;
    } else if (rawCheckpoints is String) {
      try {
        checkpoints = jsonDecode(rawCheckpoints) as List<dynamic>;
      } catch (_) {}
    }

    List<double> cpTargets = [];
    for (var cp in checkpoints) {
      if (cp is Map) {
        final target = double.tryParse(cp['halaman_target']?.toString() ?? '0') ?? 0.0;
        if (target > 0) cpTargets.add(target);
      }
    }
    cpTargets.sort();

    if (cpTargets.isEmpty) {
      return [ProgressSegmentItem(flex: safeCapai / safeTotal, color: palette[0])];
    }

    List<ProgressSegmentItem> result = [];
    double currentStart = 0.0;
    int colorIdx = 0;

    for (var target in cpTargets) {
      if (target <= currentStart) continue;
      if (safeCapai <= currentStart) break;

      double segmentEnd = target < safeCapai ? target : safeCapai;
      double segmentFlex = (segmentEnd - currentStart) / safeTotal;
      if (segmentFlex > 0) {
        result.add(ProgressSegmentItem(flex: segmentFlex, color: palette[colorIdx % palette.length]));
        currentStart = segmentEnd;
        colorIdx++;
      }

      if (safeCapai <= target) break;
    }

    if (safeCapai > currentStart) {
      double segmentFlex = (safeCapai - currentStart) / safeTotal;
      if (segmentFlex > 0) {
        result.add(ProgressSegmentItem(flex: segmentFlex, color: palette[colorIdx % palette.length]));
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Sanitasi aman
    final double safeCapai = capai.isNaN || capai.isInfinite ? 0.0 : capai;
    final double safeTotal = total.isNaN || total.isInfinite || total <= 0 ? 1.0 : total;
    
    final segments = calculateSegments(safeCapai, safeTotal, checkpoints, title, baseColor);
    final double progress = (safeCapai / safeTotal).clamp(0.0, 1.0);
    final int pct = (progress * 100).round();

    String _f(num v) => v.toString().replaceAll(RegExp(r'\.0$'), '');
    final String pctText = pct >= 100 ? ' (Tuntas)' : ' $pct%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: baseColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: baseColor,
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: 4),
              trailingText!,
            ],
            Expanded(
              child: Text(
                '${_f(safeCapai)}/${_f(safeTotal)}$pctText',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: pct >= 100 ? const Color(0xFF28C76F) : Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 6,
              width: constraints.maxWidth,
              clipBehavior: Clip.antiAlias, // Radius dipotong rapi
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: segments.map((seg) {
                  return Container(
                    width: constraints.maxWidth * seg.flex,
                    height: 6,
                    color: seg.color,
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
