import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_tahsin_app/features/dashboard/data/models/dashboard_model.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/stat_card.dart';

class DashboardSummary extends StatelessWidget {
  final DashboardModel data;

  const DashboardSummary({super.key, required this.data});

  void _showDetailModal(BuildContext context, String title, Widget content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Flexible(child: content),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          StatCard(
            label: 'Total Santri',
            value: data.summary.totalSantri.toString(),
            icon: Icons.people_outline,
            colors: [Colors.blue.shade400, Colors.blue.shade700],
            onTap: () {
              Map<String, int> kelasCount = {};
              for (var s in data.santriList) {
                String k = s['tingkat']?.toString() ?? 'Lainnya';
                kelasCount[k] = (kelasCount[k] ?? 0) + 1;
              }
              _showDetailModal(
                context,
                'Rincian Total Santri',
                kelasCount.isEmpty
                    ? const Center(child: Text('Data detail tidak tersedia'))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: kelasCount.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                              final i = entry.key;
                              final e = entry.value;
                              return ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${i + 1}.',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.class_, color: Colors.blue, size: 20),
                                    ),
                                  ],
                                ),
                                title: Text('Kelas ${e.key}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                trailing: Text(
                                  '${e.value} Santri',
                                  style: GoogleFonts.dmMono(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
              );
            },
          ),
          const SizedBox(width: 12),
          StatCard(
            label: 'Sudah Absen',
            value: data.summary.hadir.toString(),
            icon: Icons.how_to_reg_rounded,
            colors: const [Color(0xFF34D399), Color(0xFF059669)],
            onTap: () {
              var listHadir = data.santriList.where((s) {
                final h = s['id_kehadiran']?.toString() ?? '0';
                return h != '0';
              }).toList();

              _showDetailModal(
                context,
                'Status Kehadiran',
                listHadir.isEmpty
                    ? Center(child: Text('Belum ada data absensi hari ini. Total hadir di sistem: ${data.summary.hadir}'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: listHadir.length,
                        itemBuilder: (_, i) {
                          final s = listHadir[i];
                          final k = s['id_kehadiran']?.toString() ?? '0';
                          Color c = Colors.grey;
                          String statusText = 'Tanpa Keterangan';
                          if (k == '1') { c = Colors.green; statusText = 'Hadir'; }
                          if (k == '3') { c = Colors.blue; statusText = 'Sakit'; }
                          if (k == '2') { c = Colors.orange; statusText = 'Izin'; }
                          if (k == '4') { c = Colors.red; statusText = 'Alpha'; }

                          return ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${i + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 8),
                                Icon(Icons.person, color: c),
                              ],
                            ),
                            title: Text(s['nama_santri']?.toString() ?? '-'),
                            subtitle: Text('Status: $statusText'),
                            trailing: Text(s['tingkat']?.toString() ?? ''),
                          );
                        },
                      ),
              );
            },
          ),
          const SizedBox(width: 12),
          StatCard(
            label: 'Perlu\nPerhatian',
            value: data.summary.perluPerhatian.toString(),
            icon: Icons.warning_rounded,
            colors: [Colors.red.shade400, Colors.red.shade700],
            onTap: () {
              final list = data.urgentList;
              _showDetailModal(
                context,
                'Perlu Perhatian',
                list.isEmpty
                    ? const Center(child: Text('Tidak ada santri bermasalah'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final s = list[i];
                          return ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${i + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 8),
                                const Icon(Icons.warning, color: Colors.red),
                              ],
                            ),
                            title: Text(s['nama_santri']?.toString() ?? '-'),
                            subtitle: Text(s['jenis_masalah']?.toString() ?? 'Bermasalah'),
                            trailing: Text(s['tingkat']?.toString() ?? ''),
                          );
                        },
                      ),
              );
            },
          ),
          const SizedBox(width: 12),
          StatCard(
            label: 'Siap Test',
            value: data.summary.siapTest.toString(),
            icon: Icons.assignment_turned_in,
            colors: [Colors.orange.shade400, Colors.orange.shade700],
            onTap: () {
              var listSiapTest = data.santriList
                  .where((s) => s['harus_tes'] == 1 || s['harus_tes'] == '1')
                  .toList();
              var list = listSiapTest.isNotEmpty ? listSiapTest : data.daftarTes;

              _showDetailModal(
                context,
                'Santri Siap Test',
                list.isEmpty
                    ? Center(child: Text('Tidak ada data santri siap test secara spesifik. Total siap test sistem: ${data.summary.siapTest}.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final s = list[i];
                          return ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${i + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 8),
                                const Icon(Icons.assignment_turned_in, color: Colors.orange),
                              ],
                            ),
                            title: Text(s['nama_santri']?.toString() ?? '-'),
                            subtitle: Text('Tingkat: ${s['tingkat']?.toString() ?? '-'}'),
                          );
                        },
                      ),
              );
            },
          ),
          const SizedBox(width: 12),
          StatCard(
            label: 'Belum Selesai',
            value: data.summary.belumDiinput.toString(),
            icon: Icons.pending_actions,
            colors: [Colors.purple.shade400, Colors.purple.shade700],
            onTap: () {
              var listBelum = data.santriList.where((s) {
                final isInput = (int.tryParse(s['input_hari_ini']?.toString() ?? '0') ?? 0) > 0;
                return !isInput;
              }).toList();

              _showDetailModal(
                context,
                'Belum Diinput',
                listBelum.isEmpty
                    ? Center(child: Text('Terdapat ${data.summary.belumDiinput} santri yang belum diinput progresnya hari ini.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: listBelum.length,
                        itemBuilder: (_, i) {
                          final s = listBelum[i];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.purple.shade100,
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(s['nama_santri']?.toString() ?? '-'),
                            subtitle: Text('Tingkat: ${s['tingkat']?.toString() ?? '-'}'),
                          );
                        },
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
