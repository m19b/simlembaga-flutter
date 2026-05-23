import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/data/catatan_master_model.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/domain/repositories/catatan_master_repository.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/bloc/catatan_master_cubit.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/bloc/catatan_master_state.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/widgets/catatan_form_sheet.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';

// Standalone Catatan Master Screen — bisa filter per Kategori (Tahsin / Tahfidz)
class CatatanMasterScreen extends StatefulWidget {
  const CatatanMasterScreen({super.key});

  @override
  State<CatatanMasterScreen> createState() => _CatatanMasterScreenState();
}

class _CatatanMasterScreenState extends State<CatatanMasterScreen> {
  // Filter state (null = Semua Modul)
  int? _selectedKategori; // 1=Tahsin, 2=Tahfidz, null=Semua

  static const List<Map<String, dynamic>> _kategoriOptions = [
    {'id': null, 'label': 'Semua Modul', 'icon': Icons.layers_outlined},
    {'id': 1, 'label': 'Tahsin', 'icon': Icons.menu_book_outlined},
    {'id': 2, 'label': 'Tahfidz', 'icon': Icons.auto_stories_outlined},
  ];

  void _reload(CatatanMasterCubit cubit) {
    cubit.loadCatatan(idKategori: _selectedKategori);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CatatanMasterCubit>(
      create: (_) {
        final cubit = CatatanMasterCubit(
          repository: CatatanMasterRepository(
            networkInfo: LocalNetworkChecker(),
            localDataSource: LocalDataSource(),
          ),
        );
        cubit.loadCatatan(idKategori: _selectedKategori);
        return cubit;
      },
      child: Builder(
        builder: (ctx) {
          final cubit = ctx.read<CatatanMasterCubit>();
          return Scaffold(
            backgroundColor: Theme.of(ctx).extension<AppCustomStyles>()?.pageBg ?? const Color(0xFFF3F4F6),
            appBar: _buildAppBar(ctx, cubit),
            body: Column(
              children: [
                _buildFilterChips(cubit),
                Expanded(
                  child: BlocConsumer<CatatanMasterCubit, CatatanMasterState>(
                    listener: (ctx, state) {
                      if (state is CatatanMasterLoaded && state.message != null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(state.message!),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF0F4C2A),
                          ),
                        );
                      }
                    },
                    builder: (ctx, state) {
                      if (state is CatatanMasterLoading || state is CatatanMasterInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is CatatanMasterError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(state.message, style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _reload(cubit),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }
                      if (state is CatatanMasterLoaded) {
                        return _buildBody(ctx, state);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: BlocBuilder<CatatanMasterCubit, CatatanMasterState>(
              builder: (ctx, state) {
                if (state is! CatatanMasterLoaded) return const SizedBox.shrink();
                return FloatingActionButton.extended(
                  backgroundColor: const Color(0xFF0F4C2A),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text('Tambah Catatan',
                      style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600)),
                  onPressed: () => _showFormSheet(ctx, state.filterMeta, null),
                );
              },
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext ctx, CatatanMasterCubit cubit) {
    return AppBar(
      backgroundColor: const Color(0xFF0F4C2A),
      foregroundColor: Colors.white,
      title: Text(
        'Catatan Master',
        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          tooltip: 'Refresh',
          onPressed: () => _reload(cubit),
        ),
      ],
    );
  }

  Widget _buildFilterChips(CatatanMasterCubit cubit) {
    return Container(
      color: const Color(0xFF0F4C2A),
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 2),
      child: Row(
        children: _kategoriOptions.map((opt) {
          final bool isSelected = _selectedKategori == opt['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedKategori = opt['id'] as int?);
                _reload(cubit);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      opt['icon'] as IconData,
                      size: 14,
                      color: isSelected ? const Color(0xFF0F4C2A) : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      opt['label'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF0F4C2A) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(BuildContext ctx, CatatanMasterLoaded state) {
    if (state.catatan.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.list_alt_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Belum ada catatan',
              style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap tombol + untuk menambah catatan baru',
              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    // Group by namaKelas
    final Map<String, List<CatatanMaster>> grouped = {};
    for (final item in state.catatan) {
      final key = item.namaKelas.isNotEmpty ? item.namaKelas : 'Tanpa Kelas';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: grouped.length,
      itemBuilder: (ctx, groupIdx) {
        final kelasNama = grouped.keys.elementAt(groupIdx);
        final items = grouped[kelasNama]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F4C2A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    kelasNama,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(ctx).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F4C2A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${items.length}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F4C2A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...items.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final item = entry.value;
              return _buildCatatanCard(ctx, item, idx, state.filterMeta);
            }),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildCatatanCard(
    BuildContext ctx,
    CatatanMaster item,
    int nomor,
    Map<String, dynamic> filterMeta,
  ) {
    final cubit = ctx.read<CatatanMasterCubit>();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(ctx).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.aktif
              ? const Color(0xFF0F4C2A).withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: item.aktif
              ? const Color(0xFF0F4C2A).withValues(alpha: 0.12)
              : Colors.grey.shade200,
          child: Text(
            '$nomor',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: item.aktif ? const Color(0xFF0F4C2A) : Colors.grey,
            ),
          ),
        ),
        title: Text(
          item.teksCatatan,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: item.aktif
                ? Theme.of(ctx).colorScheme.onSurface
                : Colors.grey.shade400,
            decoration: item.aktif ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: item.aktif
            ? null
            : Text(
                'Nonaktif',
                style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey.shade400),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: Colors.blueGrey,
              onPressed: () => _showFormSheet(ctx, filterMeta, item),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red.shade300,
              onPressed: () => _confirmDelete(ctx, cubit, item),
              tooltip: 'Hapus',
            ),
          ],
        ),
      ),
    );
  }

  void _showFormSheet(BuildContext ctx, Map<String, dynamic> filterMeta, CatatanMaster? item) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<CatatanMasterCubit>(),
        child: CatatanFormSheet(item: item, filterMeta: filterMeta),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, CatatanMasterCubit cubit, CatatanMaster item) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text('Catatan ini akan dihapus:\n"${item.teksCatatan}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              cubit.deleteCatatan(item.idCatatan);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
