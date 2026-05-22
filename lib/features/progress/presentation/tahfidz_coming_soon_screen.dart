import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  
  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF065F46),
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.green.shade400 : const Color(0xFF065F46)).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 64,
                  color: isDark ? Colors.green.shade400 : const Color(0xFF065F46),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Segera Hadir',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.green.shade400 : const Color(0xFF065F46),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Modul $title sedang dalam tahap pengembangan.\nFitur ini akan segera tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.amber.withValues(alpha: 0.1) : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.amber.shade700.withValues(alpha: 0.3) : Colors.amber.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.construction_rounded, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Under Development',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Kembali'),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.green.shade400 : const Color(0xFF065F46),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
