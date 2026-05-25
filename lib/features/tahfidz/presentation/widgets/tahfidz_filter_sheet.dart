import 'package:flutter/material.dart';

class TahfidzFilterSheet extends StatelessWidget {
  final String sortMode;
  final ValueChanged<String> onSortChanged;

  const TahfidzFilterSheet({
    super.key,
    required this.sortMode,
    required this.onSortChanged,
  });

  static void show(
    BuildContext context, {
    required String sortMode,
    required ValueChanged<String> onSortChanged,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return TahfidzFilterSheet(
          sortMode: sortMode,
          onSortChanged: onSortChanged,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Urutkan Berdasarkan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSortOption(context, 'halaman_desc', 'Tertinggi - Terendah (Halaman)'),
          _buildSortOption(context, 'halaman_asc', 'Terendah - Tertinggi (Halaman)'),
          _buildSortOption(context, 'az', 'A-Z'),
          _buildSortOption(context, 'za', 'Z-A'),
          _buildSortOption(context, 'asli', 'Asli'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String mode, String title) {
    final isSelected = sortMode == mode;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () {
        onSortChanged(mode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected) Icon(Icons.check, color: primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}
