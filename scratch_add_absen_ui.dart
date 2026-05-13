import 'dart:io';

void main() {
  final f = File('lib/features/progress/presentation/progress_input_screen.dart');
  if (f.existsSync()) {
    String c = f.readAsStringSync();
    
    // Add state variable _selectedStatusAbsen
    if (!c.contains('String _selectedStatusAbsen = \'semua\';')) {
      c = c.replaceAll(
        'String _selectedTingkat = \'Semua\';',
        'String _selectedTingkat = \'Semua\';\n  String _selectedStatusAbsen = \'semua\';'
      );
    }
    
    // Pass to ApiService.getProgressList
    c = c.replaceAll(
      'final resp = await ApiService.getProgressList(\n        idKelompok: _selectedKelompokId,\n      );',
      'final resp = await ApiService.getProgressList(\n        idKelompok: _selectedKelompokId,\n        filterKehadiran: _selectedStatusAbsen,\n        tanggal: DateFormat(\'yyyy-MM-dd\').format(_tanggal),\n      );'
    );
    
    // Fix Dropdown rendering
    final absenDropdown = '''
                  // Status Absen Filter
                  const SizedBox(width: 8),
                  Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatusAbsen,
                        isDense: true,
                        icon: const Icon(Icons.arrow_drop_down, size: 16),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedStatusAbsen = val);
                            _loadSantri();
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'semua', child: Text('Semua Santri')),
                          DropdownMenuItem(value: 'kecuali_izin_sakit', child: Text('Kecuali Izin/Sakit')),
                          DropdownMenuItem(value: 'hanya_hadir', child: Text('Hanya Hadir')),
                        ],
                      ),
                    ),
                  ),
''';

    if (!c.contains('// Status Absen Filter')) {
      c = c.replaceAll(
        '// Tingkat Filter',
        absenDropdown + '\n                  // Tingkat Filter'
      );
    }
    
    f.writeAsStringSync(c);
    print('progress_input_screen.dart updated with Status Absen filter!');
  }
}
