import 'package:flutter/material.dart';

class PraTahfidzFilterSheet {
  static void show(BuildContext context, String currentSortMode, Function(String) onSortSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
              _buildSortOption(ctx, 'halaman_desc', 'Tertinggi - Terendah (Halaman)', currentSortMode, onSortSelected),
              _buildSortOption(ctx, 'halaman_asc', 'Terendah - Tertinggi (Halaman)', currentSortMode, onSortSelected),
              _buildSortOption(ctx, 'az', 'Nama A - Z', currentSortMode, onSortSelected),
              _buildSortOption(ctx, 'za', 'Nama Z - A', currentSortMode, onSortSelected),
              _buildSortOption(ctx, 'asli', 'Asli', currentSortMode, onSortSelected),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSortOption(
    BuildContext ctx,
    String mode,
    String title,
    String currentSortMode,
    Function(String) onSortSelected,
  ) {
    final isSelected = currentSortMode == mode;
    final primaryColor = Theme.of(ctx).colorScheme.primary;
    return InkWell(
      onTap: () {
        onSortSelected(mode);
        Navigator.pop(ctx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(ctx).dividerColor.withValues(alpha: 0.5),
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
