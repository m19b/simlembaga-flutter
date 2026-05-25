import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/utils/dialog_utils.dart';
import 'package:manajemen_tahsin_app/core/widgets/empty_kelompok_widget.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/data/models/pra_tahfidz_santri_model.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/bloc/pra_tahfidz_cubit.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/widgets/pra_tahfidz_filter_sheet.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/widgets/pra_tahfidz_massal_card.dart';
import 'package:manajemen_tahsin_app/features/tahfidz/presentation/widgets/tahfidz_header_widget.dart';

class PraTahfidzInputMassalTab extends StatefulWidget {
  const PraTahfidzInputMassalTab({super.key});

  @override
  State<PraTahfidzInputMassalTab> createState() => PraTahfidzInputMassalTabState();
}

class PraTahfidzInputMassalTabState extends State<PraTahfidzInputMassalTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _kelasList = [];
  int? _selectedKelasId;

  final Map<String, Map<String, dynamic>> _rowData = {};

  DateTime _tanggal = DateTime.now();
  bool isSaving = false;

  double _kelipatan = 1.0;
  String _sortMode = 'asli';
  final TextEditingController _kelipatanCtrl = TextEditingController(text: '1');

  List<Map<String, dynamic>> _jadwalListAll = [];
  List<Map<String, dynamic>> _jadwalList = [];
  int? _selectedSesi;

  String _selectedStatusAbsen = 'semua';
  String _tglUpdateCache = 'Belum Sinkron';
  bool _isInitialFetchDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeId = context.read<ActiveKelompokCubit>().state.activeId;
      if (activeId > 0) _refreshData();
    });
  }

  @override
  void dispose() {
    _kelipatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    try {
      final idKelompok = context.read<ActiveKelompokCubit>().state.activeId;
      if (idKelompok <= 0) return;
      List<int> kelasIds = [];
      if (_selectedKelasId != null && _selectedKelasId != -1) {
        kelasIds = [_selectedKelasId!];
      }
      await context.read<PraTahfidzCubit>().fetchSantriList(
        idKelompok: idKelompok,
        kelasIds: kelasIds.isEmpty ? null : kelasIds,
        sesi: _selectedSesi,
        tanggal: _tanggal.toIso8601String().split('T')[0],
        forceRefresh: true,
      );
    } catch (e) {
      debugPrint("Error refresh: $e");
    }
  }

  void _pickTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _tanggal) {
      setState(() => _tanggal = picked);
      _refreshData();
    }
  }

  Future<void> simpanMassal() async {
    FocusScope.of(context).unfocus(); 
    if (_rowData.isEmpty) return;

    setState(() => isSaving = true);

    try {
      final List<Map<String, dynamic>> arr = [];
      for (final r in _rowData.values) {
        arr.add({
          'nis': r['nis'],
          'id_kelas': r['id_kelas'],
          'sesi': r['sesi'],
          'hal_awal': r['hal_awal'],
          'hal_akhir': r['hal_akhir'],
          'hal_total': r['total_hal'],
          'status_bacaan': r['status_bacaan'],
        });
      }

      if (arr.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada santri untuk diinput.')),
          );
        }
        if (mounted) setState(() => isSaving = false);
        return;
      }

      final payload = {
        'id_kelompok': context.read<ActiveKelompokCubit>().state.activeId,
        'tanggal': _tanggal.toIso8601String().split('T')[0],
        'sesi': int.tryParse(_selectedSesi?.toString() ?? '1') ?? 1,
        'rows': arr,
      };

      await context.read<PraTahfidzCubit>().submitInputMassal(payload);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final activeId = context.watch<ActiveKelompokCubit>().state.activeId;
    if (activeId <= 0) {
      return const EmptyKelompokWidget();
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<ActiveKelompokCubit, ActiveKelompokState>(
          listener: (context, state) {
            if (state.activeId > 0) {
              _refreshData();
            }
          },
        ),
        BlocListener<PraTahfidzCubit, PraTahfidzState>(
          listener: (context, state) {
            if (state is PraTahfidzLoaded) {
              final actualData = state.data['data'] ?? state.data;
              final fm = actualData['filter_meta'] is Map ? actualData['filter_meta'] as Map : {};

              final rawJadwalList = fm['jadwal_list'] ?? actualData['jadwal_list'];
              if (rawJadwalList is List) {
                _jadwalListAll = rawJadwalList.map((e) => Map<String, dynamic>.from(e)).toList();
              }

              // Load Kelas
              final rawKelasList = fm['kelas_list'];
              if (rawKelasList is List) {
                _kelasList = rawKelasList.map((e) {
                  return {
                    'id_kelas': e['id_kelas']?.toString() ?? '',
                    'tingkat': e['tingkat']?.toString() ?? '-',
                  };
                }).toList();
                
                if (_kelasList.isEmpty) {
                  _kelasList.add({'id_kelas': '-1', 'tingkat': 'Belum ada kelas Pra-Tahfidz'});
                }
              }

              // Set default kelas
              if (_selectedKelasId == null && _kelasList.isNotEmpty) {
                _selectedKelasId = int.tryParse(_kelasList.first['id_kelas']?.toString() ?? '');
                if (_selectedKelasId != -1 && !_isInitialFetchDone) {
                  _isInitialFetchDone = true;
                  _refreshData(); // Re-fetch for specific class
                }
              }

              // Tanggal update
              final maxTglUpdate = fm['tanggal_update'];
              if (maxTglUpdate != null) {
                try {
                  final dt = DateTime.parse(maxTglUpdate.toString());
                  _tglUpdateCache = DateFormat('d MMM yyyy', 'id_ID').format(dt);
                } catch (_) {
                  _tglUpdateCache = maxTglUpdate.toString();
                }
              } else {
                _tglUpdateCache = 'Belum Sinkron';
              }

              _jadwalList = List.from(_jadwalListAll);
              if (_jadwalList.isNotEmpty && !_jadwalList.any((j) => j['sesi'] == _selectedSesi)) {
                _selectedSesi = _jadwalList.first['sesi'];
              } else if (_jadwalList.isEmpty) {
                _selectedSesi = null;
              }
              setState(() {});
            } else if (state is PraTahfidzSubmitting) {
              setState(() => isSaving = true);
            } else if (state is PraTahfidzSubmitError) {
              setState(() => isSaving = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is PraTahfidzConfirmationRequired) {
              setState(() => isSaving = false);
              DialogUtils.showDoubleInputConfirmation(
                context: context,
                message: state.message,
                onConfirm: () => context.read<PraTahfidzCubit>().submitInputMassal(state.payload, forceSave: true),
              );
            } else if (state is PraTahfidzSubmitSuccess) {
              setState(() {
                isSaving = false;
                _rowData.clear(); // Bersihkan map internal
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              _refreshData();
            }
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          Widget globalBar = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TahfidzHeaderWidget(
                isDark: isDark,
                primaryColor: primaryColor,
                tglUpdateCache: _tglUpdateCache,
                tanggal: _tanggal,
                selectedKelasId: _selectedKelasId,
                kelasList: _kelasList,
                selectedSesi: _selectedSesi,
                jadwalList: _jadwalList,
                selectedStatusAbsen: _selectedStatusAbsen,
                kelipatanCtrl: _kelipatanCtrl,
                onUrutkanTap: () => PraTahfidzFilterSheet.show(
                  context, 
                  _sortMode, 
                  (val) => setState(() => _sortMode = val),
                ),
                onTanggalTap: _pickTanggal,
                onKelasChanged: (val) {
                  if (val != null && val != _selectedKelasId) {
                    setState(() => _selectedKelasId = val);
                    _refreshData();
                  }
                },
                onSesiChanged: (val) {
                  if (val != null && val != _selectedSesi) {
                    setState(() => _selectedSesi = val);
                    _refreshData();
                  }
                },
                onStatusAbsenChanged: (val) {
                  final strVal = val ? 'hanya_hadir' : 'semua';
                  if (strVal != _selectedStatusAbsen) {
                    setState(() => _selectedStatusAbsen = strVal);
                    _refreshData();
                  }
                },
                onKelipatanChanged: (val) {
                  final k = double.tryParse(val);
                  if (k != null && k >= 1.0) {
                    setState(() => _kelipatan = k);
                  }
                },
              ),
            ],
          );

          return Stack(
            children: [
              if (_kelasList.isEmpty)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: globalBar,
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Memuat data kelas / belum ada kelas',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: globalBar,
                    ),
                    Expanded(
                      child: BlocBuilder<PraTahfidzCubit, PraTahfidzState>(
                        buildWhen: (previous, current) {
                          return current is PraTahfidzLoading ||
                                 current is PraTahfidzLoaded ||
                                 current is PraTahfidzError;
                        },
                        builder: (context, state) {
                          if (state is PraTahfidzLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (state is PraTahfidzLoaded) {
                            final actualData = state.data['data'] ?? state.data;
                            final rawList = actualData['santri_list'] as List<dynamic>? ?? [];
                            final models = rawList.map((e) => PraTahfidzSantriModel.fromJson(e as Map<String, dynamic>)).toList();
                            final filteredModels = models.where((s) => s.idKelas == _selectedKelasId).toList();
                            
                            if (filteredModels.isEmpty) {
                              return const Center(child: Text("Tidak ada santri di kelas ini.", style: TextStyle(fontWeight: FontWeight.w500)));
                            }

                            List<PraTahfidzSantriModel> sortedModels = List.from(filteredModels);
                            if (_sortMode != 'asli') {
                              sortedModels.sort((a, b) {
                                if (_sortMode == 'halaman_desc' || _sortMode == 'halaman_asc') {
                                  final awA = a.pointerHalaman ?? 0.0;
                                  final awB = b.pointerHalaman ?? 0.0;
                                  return _sortMode == 'halaman_desc' ? awB.compareTo(awA) : awA.compareTo(awB);
                                } else if (_sortMode == 'za') {
                                  return (b.namaSantri ?? '').compareTo(a.namaSantri ?? '');
                                }
                                return (a.namaSantri ?? '').compareTo(b.namaSantri ?? '');
                              });
                            }
                            
                            return ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                              itemCount: sortedModels.length,
                              itemBuilder: (context, index) {
                                final santriModel = sortedModels[index];
                                final santriMap = santriModel.toJson();
                                final nis = santriModel.nis ?? '';
                                
                                var row = _rowData[nis];
                                if (row == null) {
                                  final hal = santriModel.pointerHalaman ?? 0.0;
                                  row = {
                                    'nis': nis,
                                    'id_kelas': _selectedKelasId,
                                    'hal_awal': hal,
                                    'hal_akhir': hal,
                                    'total_hal': 0.0,
                                    'status_bacaan': 'Sesuai Target',
                                    'sesi': _selectedSesi ?? 1,
                                  };
                                  _rowData[nis] = row;
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: PraTahfidzMassalCard(
                                    santri: santriMap,
                                    rowData: row,
                                    kelipatan: _kelipatan,
                                  ),
                                );
                              },
                            );
                          }
                          return const Center(child: Text("Silahkan pilih kelas untuk memuat data.", style: TextStyle(fontWeight: FontWeight.w500)));
                        },
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
