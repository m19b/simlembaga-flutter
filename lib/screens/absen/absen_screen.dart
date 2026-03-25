import 'package:flutter/material.dart';

/// AbsenScreen — Halaman Absensi Santri dengan 2 metode:
/// Tab 1: Manual (input langsung)
/// Tab 2: Scan / RFID
class AbsenScreen extends StatelessWidget {
  const AbsenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          title: const Text('Absensi Santri'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.edit_note), text: 'Manual'),
              Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scan / RFID'),
            ],
          ),
        ),
        body: const TabBarView(children: [_ManualTab(), _ScanTab()]),
      ),
    );
  }
}

// ─── Tab 1: Manual ────────────────────────────────────────────────────────────
class _ManualTab extends StatefulWidget {
  const _ManualTab();

  @override
  State<_ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends State<_ManualTab> {
  // TODO: Ganti dengan data santri dari API
  final List<Map<String, dynamic>> _santriList = List.generate(
    5,
    (i) => {
      'nis': '240100${i + 1}',
      'nama': 'Santri Contoh ${i + 1}',
      'status':
          null, // null = belum diisi, 'H'=Hadir,'S'=Sakit,'I'=Izin,'A'=Alpa
    },
  );

  final List<String> _statusOptions = ['H', 'S', 'I', 'A'];
  final Map<String, Color> _statusColors = {
    'H': Colors.green,
    'S': Colors.blue,
    'I': Colors.orange,
    'A': Colors.red,
  };
  final Map<String, String> _statusLabels = {
    'H': 'Hadir',
    'S': 'Sakit',
    'I': 'Izin',
    'A': 'Alpa',
  };

  void _submitAbsen() {
    final belumDiisi = _santriList.where((s) => s['status'] == null).length;
    if (belumDiisi > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$belumDiisi santri belum ditandai statusnya'),
          backgroundColor: Colors.orange[700],
        ),
      );
      return;
    }
    // TODO: kirim data ke API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Absensi berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tanggal
        Container(
          width: double.infinity,
          color: Colors.green[50],
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Hari ini: ${_formattedDate()}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
        ),
        // Daftar Santri
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _santriList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, i) {
              final santri = _santriList[i];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green[100],
                        radius: 18,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              santri['nama'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'NIS: ${santri['nis']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status Buttons
                      Wrap(
                        spacing: 4,
                        children: _statusOptions.map((s) {
                          final selected = santri['status'] == s;
                          final color = _statusColors[s]!;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _santriList[i]['status'] = s),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: selected
                                    ? color
                                    : color.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: color),
                              ),
                              child: Center(
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: selected ? Colors.white : color,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Legend + Submit
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _statusLabels.entries.map((e) {
                  final color = _statusColors[e.key]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: color, radius: 6),
                        const SizedBox(width: 4),
                        Text(
                          e.value,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _submitAbsen,
                  icon: const Icon(Icons.save_alt),
                  label: const Text(
                    'Simpan Absensi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

// ─── Tab 2: Scan / RFID ───────────────────────────────────────────────────────
class _ScanTab extends StatelessWidget {
  const _ScanTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Fitur Scan / RFID',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Akan segera tersedia.\nHubungkan dengan perangkat RFID reader.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.bluetooth_searching),
            label: const Text('Hubungkan Perangkat'),
          ),
        ],
      ),
    );
  }
}
