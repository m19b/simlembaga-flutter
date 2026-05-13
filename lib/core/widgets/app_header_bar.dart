import 'package:flutter/material.dart';

const Color _kHeader = Color(0xFF0F4C2A);

/// AppBar kustom yang dipakai di seluruh halaman fitur (DataSantri, Masalah, dll).
/// Menghindari duplikasi kode dekoratif yang sama persis di setiap modul.
class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final double height;
  final List<Widget>? actions;
  final Widget? bottom;
  final double bottomHeight;

  const AppHeaderBar({
    super.key,
    required this.title,
    this.subtitle = '',
    this.height = 100,
    this.actions,
    this.bottom,
    this.bottomHeight = 0,
  });

  @override
  Size get preferredSize => Size.fromHeight(height + bottomHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        color: _kHeader,
        child: SafeArea(
          child: Stack(
            children: [
              // ── Dekorasi lingkaran (sama di semua layar) ──────────────
              Positioned(right: -30, top: -30, child: _deco(150, 22)),
              Positioned(left: -20, bottom: -20, child: _deco(100, 16)),
              // ── Konten ────────────────────────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (subtitle.isNotEmpty)
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (actions != null) ...actions!,
                      ],
                    ),
                  ),
                  if (bottom != null) bottom!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deco(double size, double bw) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.10),
        width: bw,
      ),
    ),
  );
}
