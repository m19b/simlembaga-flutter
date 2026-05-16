import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';

/// Widget global untuk memberikan latar belakang header seragam
/// (termasuk warna dinamis AMOLED, garis pembatas bawah, dan ornamen lingkaran).
class GlobalHeaderBackground extends StatelessWidget {
  const GlobalHeaderBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? Colors.black : Theme.of(context).colorScheme.primary;
    final Color onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        // ── Background ──────────────────────────────────
        Container(color: bgColor),
        // ── Garis Bawah Pembatas ────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            color: Theme.of(context).extension<AppCustomStyles>()?.headerBorder ?? 
                   Colors.white.withValues(alpha: 0.15),
          ),
        ),
        // ── Dekorasi lingkaran kanan atas ──────────────
        Positioned(
          right: -20,
          top: -20,
          child: _deco(100, 14, onPrimary),
        ),
        // ── Dekorasi lingkaran kiri bawah ──────────────
        Positioned(
          left: -10,
          bottom: -10,
          child: _deco(60, 8, onPrimary),
        ),
      ],
    );
  }

  Widget _deco(double size, double bw, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: color.withValues(alpha: 0.15),
        width: bw,
      ),
    ),
  );
}
