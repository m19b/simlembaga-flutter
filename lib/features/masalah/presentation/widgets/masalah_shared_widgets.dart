import 'package:flutter/material.dart';
import 'masalah_constants.dart';

class JenisBadge extends StatelessWidget {
  final String? jenis;
  const JenisBadge({super.key, this.jenis});

  @override
  Widget build(BuildContext context) {
    final color = masalahJenisColor(jenis);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Text(
        masalahJenisLabel(jenis),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class MasalahChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const MasalahChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: masalahBgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: masalahText2Color),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 10, color: masalahText2Color)),
        ],
      ),
    );
  }
}
