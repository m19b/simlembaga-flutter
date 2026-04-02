import 'dart:io';

void main() {
  final file = File('lib/screens/home/dashboard_screen.dart');
  var content = file.readAsStringSync();

  // 1. Add import
  if (!content.contains('import ''../santri/data_santri_screen.dart'';')) {
    content = content.replaceFirst(
        'import ''../absen/absen_screen.dart'';',
        'import ''../absen/absen_screen.dart'';\nimport ''../santri/data_santri_screen.dart'';');
  }

  // 2. Fix the MenuCategoryGrid
  content = content.replaceFirst(
'''      _MenuItem(
        icon: Icons.people_outline_rounded,
        label: 'Data\\nSantri',
        baseColor: Colors.blueGrey.shade600,
        onTap: () {},
      ),''',
'''      _MenuItem(
        icon: Icons.people_outline_rounded,
        label: 'Data\\nSantri',
        baseColor: Colors.blueGrey.shade600,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataSantriScreen())),
      ),''');

  // 3. Replace _buildUrgentList and remove its helpers
  // _buildUrgentList goes from line 509 to somewhere before _buildMenuSection.
  final startIndex = content.indexOf('  Widget _buildUrgentList(List<Map<String, dynamic>> list) {');
  final endIndex = content.indexOf('  Widget _buildMenuSection(VoidCallback logout) {');

  if (startIndex != -1 && endIndex != -1) {
    print('Found section to replace');
    final newUrgentList = '''  Widget _buildUrgentList(List<Map<String, dynamic>> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.people_alt_rounded, color: Color(0xFF0F4C2A), size: 20),
              const SizedBox(width: 8),
              Text(
                "Akses Data Santri",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataSantriScreen())),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.people_outline_rounded, color: Colors.blueGrey.shade600, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Data Santri", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text("Kelola daftar & profil seluruh santri.", style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

''';
    content = content.replaceRange(startIndex, endIndex, newUrgentList);
  } else {
    print('Could not find start/end bounds for urgent list replacement');
  }

  file.writeAsStringSync(content);
}
