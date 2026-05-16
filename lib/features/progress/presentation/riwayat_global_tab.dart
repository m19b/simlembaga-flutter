import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'package:manajemen_tahsin_app/features/progress/presentation/bottom_edit.dart';

import 'package:manajemen_tahsin_app/features/progress/domain/repositories/tahsin_repository.dart';

const Color kPrimary = Color(0xFF16A34A); // Green
const Color kDanger = Color(0xFFEF4444); // Red/Orange
const Color kBg = Color(0xFFF3F4F6);
const Color kHeaderColor = Color(0xFF0F4C2A); // Dark Green

class RiwayatGlobalTab extends StatefulWidget {
  final TahsinRepository repository;
  
  const RiwayatGlobalTab({super.key, required this.repository});

  @override
  State<RiwayatGlobalTab> createState() => _RiwayatGlobalTabState();
}

class _RiwayatGlobalTabState extends State<RiwayatGlobalTab> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        // Toggle Switch ala Rangkuman Pendapatan Ojol
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            indicatorColor: kPrimary,
            indicatorWeight: 3,
            labelColor: kPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: "Hari"),
              Tab(text: "Minggu"),
            ],
          ),
        ),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(), // swipe can interfere with horizontal chart
            children: [
              _HariSubTab(repository: widget.repository),
              _MingguSubTab(repository: widget.repository),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── SUB-TAB: HARI ─────────────────────────────────────────────────────────
class _HariSubTab extends StatefulWidget {
  final TahsinRepository repository;
  const _HariSubTab({required this.repository});

  @override
  State<_HariSubTab> createState() => _HariSubTabState();
}

class _HariSubTabState extends State<_HariSubTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _dates = [];
  
  bool _isLoading = true;
  String _error = '';
  int _totalRecord = 0;
  int _totalLulus = 0;
  int _totalUlang = 0;
  List<Map<String, dynamic>> _riwayatLengkap = [];

  @override
  void initState() {
    super.initState();
    // Setup 14 hari ke belakang
    _dates = List.generate(14, (i) => DateTime.now().subtract(Duration(days: i))).reversed.toList();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = ''; });

    try {
      final tglStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final resp = await widget.repository.getRiwayatGlobal(tglStr);
      final data = resp['data'] ?? {};

      setState(() {
        _totalRecord = int.tryParse(data['total_eval']?.toString() ?? '0') ?? 0;
        _totalLulus = int.tryParse(data['total_lulus']?.toString() ?? '0') ?? 0;
        _totalUlang = int.tryParse(data['total_ulang']?.toString() ?? '0') ?? 0;
        final rawList = data['riwayat'];
        if (rawList is List) {
          _riwayatLengkap = rawList.whereType<Map>().map((e) {
            final Map<String, dynamic> m = {};
            e.forEach((k, v) => m[k.toString()] = v);
            return m;
          }).toList();
        } else {
          _riwayatLengkap = [];
        }
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;
      debugPrint('Error in RiwayatGlobalTab._loadData: $e\n$stackTrace');
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete(int idPrestasi) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Riwayat?'),
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteProgress(idPrestasi);
        _loadData(); // Refresh list
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Riwayat berhasil dihapus')));
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  void _handleEdit(Map<String, dynamic> item) {
    // Siapkan data untuk BottomEdit
    final Map<String, dynamic> dataForEdit = Map.from(item);
    // Sesuaikan nama field jika berbeda
    dataForEdit['tgl_simak'] = item['tanggal'] ?? item['created_at'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BottomEdit(
        dataPrestasi: dataForEdit,
        // Cek apakah ini riwayat hari ini atau bukan
        onlyEditDate: DateFormat('yyyy-MM-dd').format(_selectedDate) != DateFormat('yyyy-MM-dd').format(DateTime.now()),
        onSave: (updatedData) async {
          try {
            await ApiService.updateProgress(int.parse(item['id_prestasi'].toString()), updatedData);
            _loadData(); // Refresh
            if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Riwayat berhasil diperbarui')));
            }
          } catch (e) {
            if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal update: $e'), backgroundColor: Colors.red));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Horizontal Date Scroller
          Container(
            color: Theme.of(context).cardColor,
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              // Start at the end (newest)
              controller: ScrollController(initialScrollOffset: 14 * 60.0), 
              itemCount: _dates.length,
              itemBuilder: (context, i) {
                final d = _dates[i];
                final isSelected = d.year == _selectedDate.year && d.month == _selectedDate.month && d.day == _selectedDate.day;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = d);
                    _loadData();
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? kPrimary : Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('MMM').format(d), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                        const SizedBox(height: 4),
                        Text('${d.day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Header Total
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text('Lulus', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                          const SizedBox(height: 8),
                          Text('$_totalLulus', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kPrimary)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
                    Expanded(
                      child: Column(
                        children: [
                          Text('Ulang', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                          const SizedBox(height: 8),
                          Text('$_totalUlang', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kDanger)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_totalRecord > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Rincian Riwayat Harian', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 11)),
                      ],
                    ),
                  )
              ],
            ),
          ),
          
          // List
          Expanded(
            child: _isLoading 
                ? const Padding(padding: EdgeInsets.all(16.0), child: SkeletonListWidget(itemCount: 5, itemHeight: 80))
                : _error.isNotEmpty 
                  ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
                  : _riwayatLengkap.isEmpty
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                          const SizedBox(height: 8),
                          Text('Belum ada evaluasi untuk hari ini', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                        ],
                      ))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _riwayatLengkap.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final item = _riwayatLengkap[i];
                          final isLulus = item['status_halaman']?.toString().toLowerCase() == 'lulus';
                          String waktuText = '-';
                          if (item['created_at'] != null) {
                             try {
                               waktuText = DateFormat('HH:mm').format(DateTime.parse(item['created_at'].toString()));
                             } catch(e) {}
                          }
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0,2))],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Waktu
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)),
                                  child: Text(waktuText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['nama_santri']?.toString() ?? '-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(item['nis']?.toString() ?? '-', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(4)),
                                            child: Text('${item['tingkat'] ?? ''} ${item['nama_kelompok'] ?? ''}'.trim(), style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Oleh: ${item['nama_guru'] ?? '-'}', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isLulus ? kPrimary.withValues(alpha: 0.1) : kDanger.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6)
                                      ),
                                      child: Text(isLulus ? 'LULUS' : 'ULANG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isLulus ? kPrimary : kDanger)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(item['mode_belajar']?.toString().toUpperCase() ?? '-', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue.shade600),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          onPressed: () => _handleEdit(item),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade600),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          onPressed: () => _handleDelete(int.parse(item['id_prestasi'].toString())),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }
}

// ─── SUB-TAB: MINGGU ───────────────────────────────────────────────────────
class _MingguSubTab extends StatefulWidget {
  final TahsinRepository repository;
  const _MingguSubTab({required this.repository});

  @override
  State<_MingguSubTab> createState() => _MingguSubTabState();
}

class _MingguSubTabState extends State<_MingguSubTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  // Rentang 4 minggu terakhir (Default = 1 Bulan)
  // Index 0: 3 minggu lalu -> Index 3: Minggu ini
  late List<DateTimeRange> _ranges;
  int _selectedIndex = 3;
  
  bool _isLoading = true;
  String _error = '';
  int _totalLulusChart = 0;
  int _totalUlangChart = 0;
  List<Map<String, dynamic>> _chartData = [];

  @override
  void initState() {
    super.initState();
    _initRanges();
    _loadData();
  }

  void _initRanges() {
    final now = DateTime.now();
    // Temukan senin minggu ini
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    
    _ranges = List.generate(4, (i) {
      // i = 0 (3 wks ago), 1 (2 wks ago), 2 (1 wk ago), 3 (this wk)
      final weeksAgo = 3 - i;
      final start = currentMonday.subtract(Duration(days: weeksAgo * 7));
      final end = start.add(const Duration(days: 6));
      return DateTimeRange(start: start, end: end);
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = ''; });

    try {
      final range = _ranges[_selectedIndex];
      final tglMulai = DateFormat('yyyy-MM-dd').format(range.start);
      final tglAkhir = DateFormat('yyyy-MM-dd').format(range.end);
      
      final resp = await ApiService.getRiwayatGlobalChart(tglMulai, tglAkhir);
      final data = resp['data'] ?? {};

      setState(() {
        _totalLulusChart = int.tryParse(data['total_lulus']?.toString() ?? '0') ?? 0;
        _totalUlangChart = int.tryParse(data['total_ulang']?.toString() ?? '0') ?? 0;
        final rawChart = data['chart'];
        if (rawChart is List) {
          _chartData = rawChart.whereType<Map>().map((e) {
            final Map<String, dynamic> m = {};
            e.forEach((k, v) => m[k.toString()] = v);
            return m;
          }).toList();
        } else {
          _chartData = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Horizontal Week Scroller + Filter Btn
          Container(
            color: Theme.of(context).cardColor,
            height: 70,
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _ranges.length,
                    controller: ScrollController(initialScrollOffset: 150.0), // agak ke kanan
                    itemBuilder: (context, i) {
                      final r = _ranges[i];
                      final isSelected = i == _selectedIndex;
                      final txt = '${DateFormat('d MMM').format(r.start)} - ${DateFormat('d MMM').format(r.end)}';
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedIndex = i);
                          _loadData();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? kPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? kPrimary : Theme.of(context).dividerColor),
                          ),
                          alignment: Alignment.center,
                          child: Text(txt, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface)),
                        ),
                      );
                    },
                  ),
                ),

              ],
            ),
          ),
          
          // Header Total (Ringkasan Kelulusan)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            color: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ringkasan Kelulusan Peserta', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Minggu Ini: $_totalLulusChart Lulus / $_totalUlangChart Tidak Lulus', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
              ],
            ),
          ),
          
          // Chart
          Expanded(
            child: Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(20),
              child: _isLoading
                ? const Padding(padding: EdgeInsets.all(16.0), child: SkeletonListWidget(itemCount: 5, itemHeight: 200))
                : _error.isNotEmpty
                  ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
                  : _chartData.isEmpty
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, size: 48, color: Theme.of(context).dividerColor),
                          Text('Data tidak tersedia', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                        ],
                      ))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text('Grafik Evaluasi Mingguan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                           const SizedBox(height: 24),
                           Expanded(
                             child: BarChart(
                               BarChartData(
                                 alignment: BarChartAlignment.spaceAround,
                                 maxY: _getMaxY(),
                                 barTouchData: BarTouchData(
                                   enabled: true,
                                   touchTooltipData: BarTouchTooltipData(
                                      getTooltipColor: (_) => Colors.transparent,
                                      tooltipPadding: EdgeInsets.zero,
                                      tooltipMargin: 2,
                                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                        final data = _chartData[groupIndex];
                                        final lulus = data['lulus']?.toString() ?? '0';
                                        final ulang = data['ulang']?.toString() ?? '0';
                                        return BarTooltipItem(
                                          '',
                                          const TextStyle(),
                                          children: [
                                            TextSpan(text: lulus, style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                                            TextSpan(text: ' / ', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 13)),
                                            TextSpan(text: ulang, style: const TextStyle(color: kDanger, fontWeight: FontWeight.bold, fontSize: 13)),
                                          ],
                                        );
                                      }
                                   )
                                 ),
                                 titlesData: FlTitlesData(
                                   show: true,
                                   bottomTitles: AxisTitles(
                                     sideTitles: SideTitles(
                                       showTitles: true,
                                       getTitlesWidget: (value, meta) {
                                         final idx = value.toInt();
                                         if (idx >= 0 && idx < _chartData.length) {
                                           final hari = _chartData[idx]['hari']?.toString() ?? '';
                                           return Padding(
                                             padding: const EdgeInsets.only(top: 6.0),
                                              child: Text(hari, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                                           );
                                         }
                                         return const SizedBox.shrink();
                                       },
                                       reservedSize: 28,
                                     ),
                                   ),
                                   leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                 ),
                                 borderData: FlBorderData(show: false),
                                 gridData: FlGridData(
                                   show: true,
                                   drawVerticalLine: false,
                                   horizontalInterval: 4,
                                   getDrawingHorizontalLine: (value) => FlLine(
                                     color: Colors.grey.withValues(alpha: 0.1),
                                     strokeWidth: 1,
                                   ),
                                 ),
                                 barGroups: _chartData.asMap().entries.map((e) {
                                   final ix = e.key;
                                   final data = e.value;
                                   final lulus = double.tryParse(data['lulus']?.toString() ?? '0') ?? 0;
                                   final ulang = double.tryParse(data['ulang']?.toString() ?? '0') ?? 0;
                                   
                                   // Stacked Bar Chart: Ulang on bottom, Lulus on top
                                   return BarChartGroupData(
                                     x: ix,
                                     barRods: [
                                       BarChartRodData(
                                         toY: lulus + ulang, 
                                         width: 40, // Lebar balok lebih besar
                                         borderRadius: BorderRadius.circular(4),
                                         rodStackItems: [
                                           BarChartRodStackItem(0, ulang, kDanger),
                                           BarChartRodStackItem(ulang, ulang + lulus, kPrimary),
                                         ]
                                       ),
                                     ],
                                     showingTooltipIndicators: [0],
                                   );
                                 }).toList(),
                               )
                             ),
                           ),
                           const SizedBox(height: 16),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               _buildLegend(kPrimary, 'Lulus'),
                               const SizedBox(width: 24),
                               _buildLegend(kDanger, 'Ulang'),
                             ],
                           )
                        ],
                      )
            ),
          )
        ],
      )
    );
  }

  double _getMaxY() {
    double max = 0;
    for (var d in _chartData) {
      double lulus = double.tryParse(d['lulus']?.toString() ?? '0') ?? 0;
      double ulang = double.tryParse(d['ulang']?.toString() ?? '0') ?? 0;
      if (lulus + ulang > max) max = lulus + ulang;
    }
    return max + 5; // buffer
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}
