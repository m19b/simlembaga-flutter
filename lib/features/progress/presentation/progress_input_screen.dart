import 'widgets/row_state_model.dart';
import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:manajemen_tahsin_app/shared/widgets/custom_date_field.dart';
import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'widgets/evaluasi_santri_card.dart';

// --- Design Tokens (Islamic Emerald) ---------------------------------------------
const Color _kHeader = Color(0xFF047857); // Emerald 700
const Color _kText1 = Color(0xFF111827);
const Color _kText2 = Color(0xFF6B7280);
const Color _kAccent = Color(0xFF10B981); // Emerald 500

// --- Data Model per baris evaluasi --------------------------------------------
class ProgressInputScreen extends StatefulWidget {
  const ProgressInputScreen({super.key});
  @override
  State<ProgressInputScreen> createState() => _ProgressInputScreenState();
}

// Sort modes
enum _SortMode { urut, halaman, abjad }

class _ProgressInputScreenState extends State<ProgressInputScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<RowStateModel> _rows = [];
  List<Map<String, dynamic>> _catatanMaster = [];
  List<Map<String, dynamic>> _kelompokList = [];
  List<Map<String, dynamic>> _metodeList = [];
  Map<int, Map<String, dynamic>> _kelasSettings = {};
  int? _selectedKelompokId;
  int? _globalMetodeId;
  bool _showMetode = false;
  bool _showPeraga = false;
  bool _globalGunakanPeraga = false;
  final TextEditingController _globalHalamanPeragaCtrl =
      TextEditingController();
  final TextEditingController _globalKeteranganPeragaCtrl =
      TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String _error = '';
  DateTime _tanggal = DateTime.now();
  _SortMode _sortMode = _SortMode.urut;
  bool _isDecimalMode = false;
  int _simpanCount = 0; // Counter: berapa kali sudah disimpan
  Map<String, dynamic>? _jadwalInfo; // hari & sesi dari t_jadwal_kelas
  List<Map<String, dynamic>> _jadwalList = [];
  int? _selectedSesi;
  String _selectedTingkat = 'Semua';
  String _selectedStatusAbsen = 'semua'; // Filter kelas/tingkat

  // Label hari dan sesi
  static const _hariLabel = {
    1: 'Sen',
    2: 'Sel',
    3: 'Rab',
    4: 'Kam',
    5: 'Jum',
    6: 'Sab',
    7: 'Min',
  };
  static const _sesiLabel = {1: 'Pagi', 2: 'Siang', 3: 'Sore', 4: 'Malam'};

  List<String> get _tingkatOptions {
    final t = _rows
        .map((r) => r.santri['tingkat']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    t.sort();
    return ['Semua', ...t];
  }

  @override
  void initState() {
    super.initState();
    // Delay load to prevent blocking tab transition animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSantri();
    });
  }

  @override
  void dispose() {
    for (var r in _rows) r.dispose();
    _globalHalamanPeragaCtrl.dispose();
    _globalKeteranganPeragaCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSantri() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
      _rows = [];
    });
    try {
      final cacheKey = 'progress_input_${_selectedKelompokId}_${_selectedStatusAbsen}_${_selectedSesi}_${_tanggal.toIso8601String().split('T')[0]}';
      final isOnline = await NetworkInfoImpl(InternetConnectionChecker.instance).isConnected;
      
      dynamic raw;
      
      if (isOnline) {
        final resp = await ApiService.getProgressList(
          idKelompok: _selectedKelompokId,
          filterKehadiran: _selectedStatusAbsen,
          sesi: _selectedSesi,
          tanggal: DateFormat('yyyy-MM-dd').format(_tanggal),
        );
        raw = resp['data'];
        
        // Simpan ke cache untuk offline
        if (raw != null) {
          await LocalDataSourceImpl().cacheData(cacheKey, resp);
        }
      } else {
        // Ambil dari cache jika offline
        final cachedData = await LocalDataSourceImpl().getCachedData(cacheKey);
        if (cachedData != null) {
          raw = cachedData['data'];
        } else {
          throw Exception("Offline: Tidak ada data cache untuk tanggal ini.");
        }
      }
      List<Map<String, dynamic>> list = [];

      if (raw is Map) {
        // Kelompok list (auto-select first like CI4 frontend)
        if (_kelompokList.isEmpty) {
          final fm = raw['filter_meta'];
          if (fm is Map) {
            final kl = fm['kelompok_list'];
            if (kl is List) {
              _kelompokList = kl.whereType<Map>().map((e) {
                final Map<String, dynamic> m = {};
                e.forEach((k, v) => m[k.toString()] = v);
                return m;
              }).toList();
              // Auto-select first kelompok tanpa reload (backend sudah kembalikan
              // data untuk kelompok pertama sebagai default)
              if (_selectedKelompokId == null && _kelompokList.isNotEmpty) {
                _selectedKelompokId = int.tryParse(
                  _kelompokList.first['id_kelompok']?.toString() ?? '0',
                );
              }
            }
          }
        }
        // Metode list
        final rawMetode = raw['metode_list'];
        if (rawMetode is List) {
          _metodeList = rawMetode.whereType<Map>().map((e) {
            final Map<String, dynamic> m = {};
            e.forEach((k, v) => m[k.toString()] = v);
            return m;
          }).toList();
        }
        // Kelas settings map
        final rawKs = raw['kelas_settings'];
        if (rawKs is Map) {
          rawKs.forEach((k, v) {
            final id = int.tryParse(k.toString()) ?? 0;
            if (v is Map) {
              final Map<String, dynamic> m = {};
              v.forEach((vk, vv) => m[vk.toString()] = vv);
              _kelasSettings[id] = m;
            }
          });
        }
        // Compute global show flags
        _showMetode = _kelasSettings.values.any(
          (s) => (int.tryParse(s['is_metode_belajar']?.toString() ?? '0') ?? 0) == 1,
        );
        _showPeraga = _kelasSettings.values.any(
          (s) => (int.tryParse(s['is_peraga']?.toString() ?? '0') ?? 0) == 1,
        );
        // Set default metode from first kelas that has it
        if (_showMetode && _globalMetodeId == null) {
          final ks = _kelasSettings.values.firstWhere(
            (s) => (int.tryParse(s['is_metode_belajar']?.toString() ?? '0') ?? 0) == 1,
            orElse: () => {},
          );
          final defMetode =
              int.tryParse(ks['default_id_metode']?.toString() ?? '0') ?? 0;
          if (defMetode > 0) _globalMetodeId = defMetode;
        }

        final rawJadwal = raw['jadwal_info'];
        if (rawJadwal is Map) {
          _jadwalInfo = {};
          rawJadwal.forEach((k, v) => _jadwalInfo![k.toString()] = v);
          _selectedSesi = int.tryParse(_jadwalInfo!['sesi']?.toString() ?? '');
        }

        final rawJadwalList = raw['jadwal_list'];
        if (rawJadwalList is List) {
          _jadwalList = rawJadwalList.map((e) {
            final map = <String, dynamic>{};
            if (e is Map) {
              e.forEach((k, v) => map[k.toString()] = v);
            }
            return map;
          }).toList();
        }

        final rawList = raw['santri_list'];
        if (rawList is List && rawList.isNotEmpty) {
          list = rawList.whereType<Map>().map((e) {
            final Map<String, dynamic> m = {};
            e.forEach((k, v) => m[k.toString()] = v);
            return m;
          }).toList();
        }
        final rawCatatan = raw['catatan_master'];
        if (rawCatatan is List) {
          _catatanMaster = rawCatatan.whereType<Map>().map((e) {
            final Map<String, dynamic> m = {};
            e.forEach((k, v) => m[k.toString()] = v);
            return m;
          }).toList();
        }
      } else if (raw is List) {
        list = raw.whereType<Map>().map((e) {
          final Map<String, dynamic> m = {};
          e.forEach((k, v) => m[k.toString()] = v);
          return m;
        }).toList();
      }

      final rows = <RowStateModel>[];
      for (final s in list) {
        final capaiHal =
            double.tryParse(s['capai_hal']?.toString() ?? '0') ?? 0;
        final totalHal =
            double.tryParse(s['total_hal']?.toString() ?? '0') ?? 0;
        final latSek = double.tryParse(s['lat_sek']?.toString() ?? '0') ?? 0;
        final capaiAks = double.tryParse(
              (s['capai_aks'] ?? s['capaiAks'])?.toString() ?? '0') ?? 0;
        final jmlTes = int.tryParse(s['jml_tes']?.toString() ?? '0') ?? 0;

        final nextCP = s['nextCheckpoint'];
        final cpTarget = nextCP != null
            ? (double.tryParse(nextCP['halaman_target']?.toString() ?? '0') ??
                  0)
            : 0.0;
        final isAtCheckpoint = cpTarget > 0 && capaiHal >= cpTarget;
        final isLatihan =
            (isAtCheckpoint || capaiHal >= totalHal) && totalHal > 0;

        String modeBelajar;
        double halAwal;
        final String lastMode = s['last_mode']?.toString() ?? '';
        // Deteksi akselerasi: jmlTes > 0 (gagal tes) ATAU capai_aks > 0 ATAU last mode = akselerasi
        final bool isAkselerasi = jmlTes > 0 || capaiAks > 0 || lastMode == 'akselerasi';
        if (isAkselerasi) {
          modeBelajar = 'akselerasi';
          halAwal = capaiAks;
        } else if (isLatihan) {
          modeBelajar = 'latihan';
          halAwal = latSek;
        } else {
          modeBelajar = 'reguler';
          halAwal = capaiHal;
        }

        final row = RowStateModel(
          santri: s,
          halAwal: halAwal,
          jmlTes: jmlTes,
          modeBelajar: modeBelajar,
          nextCheckpoint: nextCP is Map
              ? Map<String, dynamic>.from(nextCP)
              : null,
        );
        rows.add(row);
      }

      // Sort rows so that locked rows go to the bottom
      rows.sort((a, b) {
        final aLocked = a.halTotal == 0.0 ? 1 : 0;
        final bLocked = b.halTotal == 0.0 ? 1 : 0;
        return aLocked.compareTo(bLocked);
      });

      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _simpan() async {
    // Hanya ambil data dari baris yang sedang ditampilkan (filter aktif)
    final aktif = _sortedRows.where((r) => r.halTotal > 0).toList();
    if (aktif.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak ada data yang valid untuk disimpan. Pastikan ada progres > 0',
          ),
        ),
      );
      return;
    }

    // Jika sudah pernah simpan, tampilkan konfirmasi
    if (_simpanCount > 0) {
      final ke = _simpanCount + 1;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text('Simpan ke-$ke?'),
            ],
          ),
          content: Text(
            'Data evaluasi untuk tanggal ini sudah disimpan $_simpanCount kali.\n\nApakah Anda yakin ingin menyimpan lagi?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kHeader,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Ya, Simpan ke-$ke',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _saving = true);
    try {
      final payload = <String, dynamic>{
        'tanggal': DateFormat('yyyy-MM-dd').format(_tanggal),
        'evaluasi': aktif.map((r) => r.toPayload()).toList(),
      };
      // Global pengaturan metode & peraga
      if (_showMetode && _globalMetodeId != null)
        payload['id_metode'] = _globalMetodeId;
      if (_showPeraga) {
        payload['menggunakan_peraga'] = _globalGunakanPeraga ? 1 : 0;
        if (_globalGunakanPeraga) {
          payload['halaman_peraga'] = _globalHalamanPeragaCtrl.text.trim();
          payload['keterangan_peraga'] = _globalKeteranganPeragaCtrl.text
              .trim();
        }
      }

      final isOnline = await NetworkInfoImpl(InternetConnectionChecker.instance).isConnected;
      
      String pesan = 'Evaluasi berhasil disimpan!';
      if (isOnline) {
        final res = await ApiService.inputMassalProgress(payload);
        if (res['message'] != null) pesan = res['message'];
      } else {
        await LocalDataSourceImpl().enqueueRequest('api/guru/progress/input-massal', payload);
        pesan = 'Anda sedang offline. Data dimasukkan ke antrean sinkronisasi!';
      }
      
      if (!mounted) return;

      _simpanCount++;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: isOnline ? _kAccent : Colors.orange.shade700,
        ),
      );
      // Update halAwal (geser maju) dan reset halTotal ke 0 hanya untuk yang baru saja disimpan
      setState(() {
        for (final r in aktif) {
          // halAwal baru = halAwal lama + halTotal yang tadi disimpan
          final halBaru = r.halAwal + r.halTotal;
          // Update santri map supaya halAwal-nya ikut bergeser
          r.santri['capai_hal'] = halBaru;
          // Geser halAwal ke halaman baru
          r.halAwal = halBaru;
          // Reset form
          r.halTotal = 0;
          r.halCtrl.text = '0';
          r.jmlKehadiran = 1;
          r.tmCtrl.text = '1';
          r.lulus = true;
          r.disimak = true;
          r.catatanGuru = '';
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget body = _loading
        ? _buildLoader()
        : _error.isNotEmpty
        ? _buildError()
        : _buildBody();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _kHeader,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'Evaluasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_loading && _error.isEmpty) ...[
            if (_jadwalInfo != null)
              SizedBox(
                height: 32,
                child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _jadwalList.length > 1
                    ? DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _jadwalInfo!['sesi'],
                          isDense: true,
                          icon: const Icon(Icons.arrow_drop_down, color: _kHeader, size: 16),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _kHeader,
                          ),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedSesi = newValue;
                              });
                              _loadSantri();
                            }
                          },
                          items: _jadwalList.map((jdwl) {
                            return DropdownMenuItem<int>(
                              value: jdwl['sesi'],
                              child: Text('${_hariLabel[jdwl['hari']] ?? ''} - ${_sesiLabel[jdwl['sesi']] ?? ''}'),
                            );
                          }).toList(),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '${_hariLabel[_jadwalInfo!['hari']] ?? ''} - ${_sesiLabel[_jadwalInfo!['sesi']] ?? ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _kHeader,
                          ),
                        ),
                      ),
                ),
              ),

            // -- Tanggal (Di Kanan Atas) --
            CustomDateField(
              selectedDate: _tanggal,
              isCompact: true,
              isWhite: true,
              onDateSelected: (date) {
                if (date != null && date != _tanggal) {
                  setState(() {
                    _tanggal = date;
                    _selectedSesi = null; // reset sesi agar menyesuaikan hari baru
                  });
                  _loadSantri();
                }
              },
            ),

            // -- Simpan Button --
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: _saving ? null : _simpan,
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _kHeader,
                        ),
                      )
                    : const Icon(Icons.save, color: _kHeader, size: 18),
                label: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: _kHeader,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // -- Sub-header: Sort, Decimal Toggle, Hari/Sesi --
          if (!_loading && _error.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  // Sort button
                  IconButton(
                    tooltip: 'Urutkan',
                    onPressed: _showSortMenu,
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.sort_rounded,
                          color: _kHeader,
                          size: 22,
                        ),
                        if (_sortMode != _SortMode.urut)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Decimal Toggle
                  GestureDetector(
                    onTap: () =>
                        setState(() => _isDecimalMode = !_isDecimalMode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _isDecimalMode
                            ? Colors.orange.shade50
                            : Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF374151)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isDecimalMode
                              ? Colors.orange.shade300
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isDecimalMode
                                ? Icons.adjust_rounded
                                : Icons.circle_outlined,
                            size: 14,
                            color: _isDecimalMode
                                ? Colors.orange.shade700
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isDecimalMode ? '0.5' : '1.0',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _isDecimalMode
                                  ? Colors.orange.shade700
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

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
                          DropdownMenuItem(
                            value: 'semua',
                            child: Text('Semua Santri'),
                          ),
                          DropdownMenuItem(
                            value: 'kecuali_izin_sakit',
                            child: Text('Kecuali Izin/Sakit'),
                          ),
                          DropdownMenuItem(
                            value: 'hanya_hadir',
                            child: Text('Hanya Hadir'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tingkat Filter
                  if (_tingkatOptions.length > 2) ...[
                    const SizedBox(width: 8),
                    Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedTingkat,
                          isDense: true,
                          icon: const Icon(Icons.arrow_drop_down, size: 16),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedTingkat = val);
                          },
                          items: _tingkatOptions.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e == 'Semua' ? 'Semua Kelas' : e),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Main Body
          Expanded(child: body),
        ],
      ),
    );
  }


  // --- Sort & Filter --------------------------------------------------------
  List<RowStateModel> get _sortedRows {
    final filtered = _selectedTingkat == 'Semua'
        ? List<RowStateModel>.from(_rows)
        : _rows
              .where((r) => r.santri['tingkat']?.toString() == _selectedTingkat)
              .toList();

    final sorted = List<RowStateModel>.from(filtered);
    if (_sortMode == _SortMode.halaman) {
      sorted.sort((a, b) {
        // Latihan lebih tinggi dari reguler
        final aIsLat =
            (double.tryParse(a.santri['capai_hal']?.toString() ?? '0') ?? 0) >=
            (double.tryParse(a.santri['total_hal']?.toString() ?? '1') ?? 1);
        final bIsLat =
            (double.tryParse(b.santri['capai_hal']?.toString() ?? '0') ?? 0) >=
            (double.tryParse(b.santri['total_hal']?.toString() ?? '1') ?? 1);
        if (aIsLat != bIsLat) return aIsLat ? -1 : 1;
        return b.halAwal.compareTo(a.halAwal);
      });
    } else if (_sortMode == _SortMode.abjad) {
      sorted.sort((a, b) {
        final na = (a.santri['nama_santri'] ?? '').toString().toLowerCase();
        final nb = (b.santri['nama_santri'] ?? '').toString().toLowerCase();
        return na.compareTo(nb);
      });
    }
    return sorted;
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Urutkan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final mode in _SortMode.values)
              ListTile(
                dense: true,
                leading: Icon(
                  mode == _SortMode.urut
                      ? Icons.format_list_numbered_rounded
                      : mode == _SortMode.halaman
                      ? Icons.menu_book_rounded
                      : Icons.sort_by_alpha_rounded,
                  color: _sortMode == mode ? _kHeader : _kText2,
                  size: 20,
                ),
                title: Text(
                  mode == _SortMode.urut
                      ? 'Urutan Asli'
                      : mode == _SortMode.halaman
                      ? 'Halaman Tertinggi (Latihan dulu)'
                      : 'Abjad Aâ€“Z',
                  style: TextStyle(
                    fontSize: 13,
                    color: _sortMode == mode ? _kHeader : _kText1,
                    fontWeight: _sortMode == mode
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: _sortMode == mode
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: _kHeader,
                        size: 18,
                      )
                    : null,
                onTap: () {
                  setState(() => _sortMode = mode);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final rows = _sortedRows;
    // Kelompok bar
    Widget kelompokBar = const SizedBox.shrink();
    if (_kelompokList.length > 1) {
      kelompokBar = Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _kelompokList.map((k) {
              final id = int.tryParse(k['id_kelompok']?.toString() ?? '0') ?? 0;
              final isSel = _selectedKelompokId == id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    if (!isSel) {
                      setState(() {
                        _selectedKelompokId = id;
                      });
                      _loadSantri();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSel
                          ? _kHeader
                          : Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF374151)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel
                            ? _kHeader
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Text(
                      k['kelompok']?.toString() ?? '-',
                      style: TextStyle(
                        color: isSel
                            ? Colors.white
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
    // Global pengaturan (metode & peraga)
    Widget globalBar = const SizedBox.shrink();
    if (_showMetode || _showPeraga) {
      globalBar = StatefulBuilder(
        builder: (_, setGlobal) => Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: const Border(
              top: BorderSide(color: Color(0xFF10B981), width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.green.shade100),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 20,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pembelajaran (Berlaku Semua Santri)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_showMetode && _metodeList.isNotEmpty) ...[
                          Expanded(
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _globalMetodeId,
                                  isExpanded: true,
                                  isDense: true,
                                  hint: const Text(
                                    'Metode',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  onChanged: (v) =>
                                      setState(() => _globalMetodeId = v),
                                  items: [
                                    const DropdownMenuItem<int>(
                                      value: null,
                                      child: Text('- Tidak Ada -'),
                                    ),
                                    ..._metodeList.map(
                                      (m) => DropdownMenuItem<int>(
                                        value: int.tryParse(
                                          m['id_metode']?.toString() ?? '0',
                                        ),
                                        child: Text(
                                          m['nama_metode']?.toString() ?? '-',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (_showPeraga) ...[
                          Switch(
                            value: _globalGunakanPeraga,
                            activeThumbColor: _kHeader,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            onChanged: (v) =>
                                setState(() => _globalGunakanPeraga = v),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Peraga',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_showPeraga && _globalGunakanPeraga) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 36,
                              child: TextField(
                                controller: _globalHalamanPeragaCtrl,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  labelText: 'Hal Peraga',
                                  labelStyle: const TextStyle(fontSize: 12),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 0,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 36,
                              child: TextField(
                                controller: _globalKeteranganPeragaCtrl,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  labelText: 'Keterangan',
                                  labelStyle: const TextStyle(fontSize: 12),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 0,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        kelompokBar,
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadSantri,
            color: _kHeader,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
              itemCount: rows.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) return globalBar;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: EvaluasiSantriCard(
                    row: rows[i - 1],
                    index: i - 1,
                    isDecimalMode: _isDecimalMode,
                    onShowCatatan: _showCatatanSheet,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- Loading / Error ------------------------------------------------------
  Widget _buildLoader() =>
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: SkeletonListWidget(itemCount: 8, itemHeight: 120),
      );

  void _showCatatanSheet(RowStateModel row, StateSetter setRow) {
    List<String> selectedCatatan = row.catatanGuru.isNotEmpty
        ? row.catatanGuru.split(', ').where((e) => e.isNotEmpty).toList()
        : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
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
                  Text(
                    'Catatan Master',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih catatan standar untuk santri ini:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_catatanMaster.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Tidak ada template catatan guru untuk kelas ini.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _catatanMaster.map((c) {
                        final str = c['teks_catatan']?.toString() ?? '';
                        if (str.isEmpty) return const SizedBox.shrink();
                        final isSel = selectedCatatan.contains(str);
                        return FilterChip(
                          label: Text(str),
                          selected: isSel,
                          onSelected: (val) {
                            setModalState(() {
                              if (val) {
                                selectedCatatan.add(str);
                              } else {
                                selectedCatatan.remove(str);
                              }
                            });
                          },
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF374151)
                              : Colors.grey.shade100,
                          selectedColor: _kAccent.withValues(alpha: 0.15),
                          checkmarkColor: _kAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                            color: isSel ? _kAccent : _kText2,
                            fontWeight: isSel
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setRow(() {
                        row.catatanGuru = selectedCatatan.join(', ');
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kHeader,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Simpan Catatan',
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadSantri,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
            ),
          ],
        ),
      ),
    );
  }
}