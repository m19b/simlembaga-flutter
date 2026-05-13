import 'dart:io';

void main() {
  final file1 = File('lib/features/absensi/presentation/absen_mandiri_screen.dart');
  var content1 = file1.readAsStringSync();

  // 1. App Bar & Scaffold
  content1 = content1.replaceAll(
    '''  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Absensi Mandiri', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: kHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<AbsensiCubit>().fetchAbsenMandiri(idKelompok),
          ),
        ],
      ),''',
    '''  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Absensi Mandiri', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? textColor : Colors.white)),
        backgroundColor: isDark ? Theme.of(context).colorScheme.surface : kHeader,
        iconTheme: IconThemeData(color: isDark ? textColor : Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: isDark ? textColor : Colors.white),
            onPressed: () => context.read<AbsensiCubit>().fetchAbsenMandiri(idKelompok),
          ),
        ],
      ),'''
  );

  // 2. Status Card Header
  content1 = content1.replaceAll(
    '''          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            color: kHeader,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: Text(
                    namaGuru.isNotEmpty ? namaGuru[0].toUpperCase() : 'G',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaGuru.isNotEmpty ? namaGuru : '-',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'NIG: \${nig.isNotEmpty ? nig : '-'}',
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),''',
    '''          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceContainerHighest : kHeader,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : Colors.white).withValues(alpha: 0.15),
                  child: Text(
                    namaGuru.isNotEmpty ? namaGuru[0].toUpperCase() : 'G',
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaGuru.isNotEmpty ? namaGuru : '-',
                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'NIG: \${nig.isNotEmpty ? nig : '-'}',
                        style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : Colors.white).withValues(alpha: 0.6), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),'''
  );

  // 3. Container white => Theme.of(context).cardColor
  content1 = content1.replaceAll('color: Colors.white,', 'color: Theme.of(context).cardColor,');
  
  // 4. Container 0xFFF9FAFB => Theme.of(context).colorScheme.surfaceContainer
  content1 = content1.replaceAll('color: const Color(0xFFF9FAFB),', 'color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceContainer : const Color(0xFFF9FAFB),');

  // 5. Colors.grey.shade200 border => Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)
  content1 = content1.replaceAll('border: Border.all(color: Colors.grey.shade200),', 'border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),');
  content1 = content1.replaceAll('border: Border.all(color: color.shade200),', 'border: Border.all(color: color.shade200.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 1.0)),');

  // 6. Colors.grey.shade...
  content1 = content1.replaceAll('Colors.grey.shade500', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)');
  content1 = content1.replaceAll('Colors.grey.shade600', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)');
  content1 = content1.replaceAll('Colors.grey.shade300', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)');
  content1 = content1.replaceAll('Colors.grey.shade400', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)');
  content1 = content1.replaceAll('Colors.grey.shade100', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)');
  
  // 7. _buildAbsenBtn changes
  content1 = content1.replaceAll(
    '''  Widget _buildAbsenBtn({
    required String label,
    required IconData icon,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {''',
    '''  Widget _buildAbsenBtn({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;'''
  );

  content1 = content1.replaceAll(
    '''          color: enabled ? color : Colors.grey.shade100,''',
    '''          color: enabled ? color : (isDark ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),'''
  );
  content1 = content1.replaceAll(
    '''_buildAbsenBtn(
                          label: sudahDatang ? 'Sudah Masuk' : 'Absen Masuk',''',
    '''_buildAbsenBtn(
                          context: context,
                          label: sudahDatang ? 'Sudah Masuk' : 'Absen Masuk','''
  );
  content1 = content1.replaceAll(
    '''_buildAbsenBtn(
                          label: sudahPulang ? 'Sudah Pulang' : 'Absen Pulang',''',
    '''_buildAbsenBtn(
                          context: context,
                          label: sudahPulang ? 'Sudah Pulang' : 'Absen Pulang','''
  );

  // 8. _JamInfo color fixes
  content1 = content1.replaceAll(
    '''  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: sudah ? color : Colors.grey.shade300, size: 22),
          const SizedBox(height: 4),
          Text(jam, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: sudah ? const Color(0xFF111827) : Colors.grey.shade300)),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }''',
    '''  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: sudah ? color : textColor.withValues(alpha: 0.2), size: 22),
          const SizedBox(height: 4),
          Text(jam, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: sudah ? textColor : textColor.withValues(alpha: 0.3))),
          Text(label, style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.5))),
        ],
      ),
    );
  }'''
  );

  // 9. Fix const Color(0xFF111827)
  content1 = content1.replaceAll('const Color(0xFF111827)', 'Theme.of(context).colorScheme.onSurface');

  // Fix _buildRiwayatSection signature
  content1 = content1.replaceAll(
    'Widget _buildRiwayatSection(List<Map<String, dynamic>> riwayat) {',
    'Widget _buildRiwayatSection(BuildContext context, List<Map<String, dynamic>> riwayat) {'
  );
  content1 = content1.replaceAll(
    '_buildRiwayatSection(riwayatData),',
    '_buildRiwayatSection(context, riwayatData),'
  );
  content1 = content1.replaceAll(
    'color: const Color(0xFF111827),',
    'color: Theme.of(context).colorScheme.onSurface,'
  );

  file1.writeAsStringSync(content1);


  // ================= REKAP ABSEN =================
  final file2 = File('lib/features/absensi/presentation/rekap_absen_screen.dart');
  var content2 = file2.readAsStringSync();

  content2 = content2.replaceAll(
    '''  Widget build(BuildContext context) {
    if (!_filterLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Rekap Absensi'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),''',
    '''  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;
    if (!_filterLoaded) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20))),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Rekap Absensi', style: TextStyle(color: isDark ? textColor : Colors.white)),
        backgroundColor: isDark ? Theme.of(context).colorScheme.surface : const Color(0xFF1B5E20),
        iconTheme: IconThemeData(color: isDark ? textColor : Colors.white),
      ),'''
  );

  content2 = content2.replaceAll(
    'color: Colors.white,',
    'color: Theme.of(context).cardColor,'
  );

  content2 = content2.replaceAll(
    'border: Border.all(color: Colors.grey.shade300),',
    'border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),'
  );

  content2 = content2.replaceAll(
    'color: Colors.blue[50],',
    'color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.blue[50],'
  );
  content2 = content2.replaceAll(
    'border: Border.all(color: Colors.blue[100]!),',
    'border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1) : Colors.blue[100]!),'
  );

  content2 = content2.replaceAll(
    'color: Colors.blue[900]',
    'Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade300 : Colors.blue[900]'
  );

  content2 = content2.replaceAll('Colors.grey[600]', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)');
  content2 = content2.replaceAll('Colors.grey[400]', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)');
  content2 = content2.replaceAll('Colors.grey[700]', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)');

  content2 = content2.replaceAll(
    '''class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
      ],
    );
  }
}''',
    '''class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
      ],
    );
  }
}'''
  );

  file2.writeAsStringSync(content2);
  print('done');
}
