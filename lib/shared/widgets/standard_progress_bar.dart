import 'package:flutter/material.dart';

class StandardProgressBar extends StatelessWidget {
  final String title;
  final IconData icon;
  final double capai;
  final double total;
  final Color color;

  const StandardProgressBar({
    Key? key,
    required this.title,
    required this.icon,
    required this.capai,
    required this.total,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sanitasi data
    final double safeCapai = capai.isNaN || capai.isInfinite ? 0.0 : capai;
    final double safeTotal = total.isNaN || total.isInfinite || total <= 0 ? 1.0 : total;
    final double progress = (safeCapai / safeTotal).clamp(0.0, 1.0);
    final int pct = (progress * 100).round();

    String _f(num v) => v.toString().replaceAll(RegExp(r'\.0$'), '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Expanded(
              child: Text(
                '${_f(safeCapai)}/${_f(safeTotal)} $pct%',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
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
              height: 5,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 5,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
