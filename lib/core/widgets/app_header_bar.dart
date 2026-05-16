import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_header_background.dart';

/// AppBar kustom yang dipakai di seluruh halaman fitur (DataSantri, Masalah, dll).
/// Menghindari duplikasi kode dekoratif yang sama persis di setiap modul.
class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final double height;
  final List<Widget>? actions;
  final Widget? bottom;
  final double bottomHeight;
  final Widget? customTitle;
  final bool showBackButton;

  const AppHeaderBar({
    super.key,
    this.title = '',
    this.subtitle = '',
    this.height = 48,
    this.actions,
    this.bottom,
    this.bottomHeight = 0,
    this.customTitle,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(height + bottomHeight);

  @override
  Widget build(BuildContext context) {
    final Color onPrimary = Theme.of(context).colorScheme.onPrimary;

    return PreferredSize(
      preferredSize: preferredSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Background & Ornamen Global ────────────────
          const Positioned.fill(
            child: GlobalHeaderBackground(),
          ),
          // ── AppBar content ────────────────────────────────────
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: height,
                  child: AppBar(
                    toolbarHeight: height,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    foregroundColor: onPrimary,
                    iconTheme: IconThemeData(color: onPrimary),
                    actionsIconTheme: IconThemeData(color: onPrimary),
                    centerTitle: false,
                    automaticallyImplyLeading: showBackButton,
                    leading: showBackButton ? IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: onPrimary, size: 20),
                      onPressed: () => Navigator.maybePop(context),
                    ) : null,
                    title: customTitle ?? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: onPrimary.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    actions: actions,
                  ),
                ),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
