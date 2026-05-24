import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/data/catatan_master_model.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/domain/repositories/catatan_master_repository.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/bloc/catatan_master_cubit.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/bloc/catatan_master_state.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/widgets/catatan_form_sheet.dart';
import 'package:manajemen_tahsin_app/core/widgets/app_header_bar.dart';

// Standalone Catatan Master Screen — bisa filter per Kategori (Tahsin / Tahfidz)
class CatatanMasterScreen extends StatefulWidget {
  const CatatanMasterScreen({super.key});

  @override
  State<CatatanMasterScreen> createState() => _CatatanMasterScreenState();
}

class _CatatanMasterScreenState extends State<CatatanMasterScreen> {
  void _reload(CatatanMasterCubit cubit) {
    cubit.loadCatatan();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CatatanMasterCubit>(
      create: (_) {
        final cubit = CatatanMasterCubit(
          repository: CatatanMasterRepository(
            networkInfo: NetworkInfoImpl(LocalNetworkChecker()),
            localDataSource: LocalDataSourceImpl(),
          ),
        );
        cubit.loadCatatan();
        return cubit;
      },
      child: Builder(
        builder: (ctx) {
          final cubit = ctx.read<CatatanMasterCubit>();
          return Scaffold(
            backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
            appBar: AppHeaderBar(
              title: 'Catatan Master',
              subtitle: 'Atur template catatan penilaian',
              height: 48,
              actions: [
                BlocBuilder<CatatanMasterCubit, CatatanMasterState>(
                  builder: (ctx, state) {
                    if (state is! CatatanMasterLoaded) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                      tooltip: 'Tambah Catatan',
                      onPressed: () => _showFormSheet(ctx, state.filterMeta, null),
                    );
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => _reload(cubit),
                      child: BlocConsumer<CatatanMasterCubit, CatatanMasterState>(
                        listener: (ctx, state) {
                          if (state is CatatanMasterLoaded) {
                            if (state.message != null) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(state.message!),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFF0F4C2A),
                                ),
                              );
                            }
                          }
                        },
                        builder: (ctx, state) {
                          if (state is CatatanMasterLoading || state is CatatanMasterInitial) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (state is CatatanMasterError) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: MediaQuery.of(ctx).size.height * 0.5,
                                child: Center(
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
                                ),
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext ctx, CatatanMasterLoaded state) {
    if (state.catatan.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.5,
            child: Center(
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
            ),
          ),
        ],
      );
    }

    // Group by Kategori dan Kelas
    final Map<String, List<CatatanMaster>> grouped = {};
    for (final item in state.catatan) {
      final kategoriStr = item.namaKategori.isNotEmpty ? item.namaKategori : 'Lainnya';
      final kelasStr = item.namaKelas.isNotEmpty ? item.namaKelas : 'Tanpa Kelas';
      final key = '$kategoriStr - $kelasStr';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
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
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0F4C2A);

    // Warna background card: terang di light mode, abu-abu gelap di dark mode
    final cardBg = isDark
        ? const Color(0xFF1E2A23) // hijau tua gelap agar kontras di dark mode
        : Colors.white;

    // Warna accent strip kiri
    final stripColor = item.aktif ? primaryColor : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.aktif
              ? primaryColor.withValues(alpha: isDark ? 0.3 : 0.15)
              : Colors.grey.withValues(alpha: isDark ? 0.25 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Strip warna kiri
              Container(width: 4, color: stripColor),
              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: item.aktif
                        ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.12)
                        : Colors.grey.shade600.withValues(alpha: 0.3),
                    child: Text(
                      '$nomor',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: item.aktif
                            ? (isDark ? Colors.greenAccent.shade200 : primaryColor)
                            : Colors.grey,
                      ),
                    ),
                  ),
                  title: Text(
                    item.teksCatatan,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: item.aktif
                          ? Theme.of(ctx).colorScheme.onSurface
                          : Colors.grey.shade500,
                      decoration: item.aktif ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        if (item.namaKategori.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(ctx).colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.namaKategori,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(ctx).colorScheme.secondary,
                              ),
                            ),
                          ),
                        if (item.namaKelas.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.namaKelas,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                        if (!item.aktif) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Nonaktif',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: isDark ? Colors.blueAccent.shade100 : Colors.blueGrey,
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
              ),
            ],
          ),
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
        child: CatatanFormSheet(
          item: item,
          filterMeta: filterMeta,
        ),
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
