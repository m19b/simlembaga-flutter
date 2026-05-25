import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manajemen_tahsin_app/features/auth/data/user_model.dart';
import 'package:manajemen_tahsin_app/features/pengaturan/presentation/bloc/header_settings_cubit.dart';
import 'package:manajemen_tahsin_app/core/state/sync_center_cubit.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_header_background.dart';
import 'sync_popup_dialog.dart';

class DashboardHeader extends StatelessWidget {
  final String name;
  final String role;
  final String kelompok;
  final String kelas;
  final List<Map<String, dynamic>> availableKategori;
  final List<Map<String, dynamic>> availableKelas;
  final Map<String, dynamic>? selectedKelas;
  final String randomGreeting;
  final UserModel? currentUser;
  final String? baseUrl;
  final VoidCallback onLogout;

  const DashboardHeader({
    super.key,
    required this.name,
    required this.role,
    required this.kelompok,
    required this.kelas,
    required this.availableKategori,
    required this.availableKelas,
    this.selectedKelas,
    required this.randomGreeting,
    required this.currentUser,
    this.baseUrl,
    required this.onLogout,
  });

  String? _fixUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (baseUrl == null) return path;

    String base = baseUrl!;
    if (base.endsWith('/') && path.startsWith('/')) {
      return base + path.substring(1);
    } else if (!base.endsWith('/') && !path.startsWith('/')) {
      return '$base/$path';
    }
    return base + path;
  }

  Widget _buildAbsImage(
    String? rawUrl,
    IconData fallbackIcon, {
    double size = 40,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final iconColor = isDark
            ? Theme.of(context).colorScheme.primary
            : Colors.white;
        final bgColor = isDark
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.15);

        return SizedBox(
          width: size,
          height: size,
          child: ClipOval(
            child: Builder(
              builder: (context) {
                String? url = _fixUrl(rawUrl);

                // [PATCH 1]: Fix bug jika nama file dari database mengandung spasi
                if (url != null) {
                  url = url.replaceAll(' ', '%20');
                }

                // [PATCH 2]: Pasang Log Tracker di konsol
                print('--- DEBUG GAMBAR ---');
                print('Raw Path : $rawUrl');
                print('Base URL : $baseUrl');
                print('Final URL: $url');
                print('--------------------');

                if (url != null && url.isNotEmpty) {
                  return CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: bgColor,
                      child: Icon(fallbackIcon, color: iconColor, size: 24),
                    ),
                    errorWidget: (context, url, error) {
                      // Tampilkan alasan error di terminal IDE Anda
                      print('❌ GAMBAR GAGAL DIMUAT: $url');
                      print('Alasan Error: $error');

                      return Container(
                        color: bgColor,
                        child: Icon(fallbackIcon, color: iconColor, size: 24),
                      );
                    },
                  );
                }
                return Container(
                  color: bgColor,
                  child: Icon(fallbackIcon, color: iconColor, size: 24),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildContextChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKelompokSelector(BuildContext context, String fallbackNama) {
    return BlocBuilder<ActiveKelompokCubit, ActiveKelompokState>(
      builder: (context, state) {
        if (state.allowedKelompok.isEmpty) {
          return _buildContextChip(Icons.business_outlined, fallbackNama);
        }

        int? validActiveId = state.activeId > 0 ? state.activeId : null;
        final hasActiveId = state.allowedKelompok.any((k) {
          final id = k['id_kelompok'] ?? k['id'];
          final intId = id is String ? int.tryParse(id) : (id as int?);
          return intId == validActiveId;
        });
        if (!hasActiveId) validActiveId = null;

        return Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: validActiveId,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 16,
              ),
              dropdownColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]
                  : const Color(0xFF0F4C2A),
              isDense: true,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              onChanged: (val) {
                if (val != null) {
                  context.read<ActiveKelompokCubit>().changeKelompok(val);
                }
              },
              items: state.allowedKelompok.map((k) {
                final id = k['id_kelompok'] ?? k['id'];
                final intId = id is String ? int.tryParse(id) : (id as int?);
                final nama = k['kelompok'] ?? k['nama_kelompok'] ?? 'Unknown';
                return DropdownMenuItem<int>(
                  value: intId ?? 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.business_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(nama),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    final activeId = cubit.activeKategori;

    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: activeId,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
            size: 16,
          ),
          dropdownColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : const Color(0xFF0F4C2A),
          isDense: true,
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (val) => cubit.setKategori(val),
          items: availableKategori.map((kat) {
            return DropdownMenuItem<int?>(
              value: kat['id'],
              child: Text(kat['nama']),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKelasSelector(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    final isEmpty = availableKelas.isEmpty;

    final String? currentId = selectedKelas?['id_kelas']?.toString();
    final bool isValid =
        currentId == null ||
        availableKelas.any((k) => k['id_kelas']?.toString() == currentId);
    final String? safeId = isValid ? currentId : null;

    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isEmpty
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: safeId,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isEmpty ? Colors.white38 : Colors.white,
            size: 16,
          ),
          dropdownColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : const Color(0xFF0F4C2A),
          isDense: true,
          onChanged: isEmpty
              ? null
              : (val) {
                  if (val == null) {
                    cubit.setKelas(null);
                  } else {
                    final found = availableKelas
                        .where((k) => k['id_kelas']?.toString() == val)
                        .toList();
                    cubit.setKelas(found.isNotEmpty ? found.first : null);
                  }
                },
          style: GoogleFonts.dmSans(
            color: isEmpty ? Colors.white38 : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isEmpty ? 'Pilih Kategori' : 'Semua Kelas',
                    style: GoogleFonts.dmSans(
                      color: isEmpty ? Colors.white38 : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ...availableKelas.map((kelasData) {
              return DropdownMenuItem<String?>(
                value: kelasData['id_kelas']?.toString(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.class_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      kelasData['tingkat']?.toString() ?? '-',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncBtn(BuildContext context) {
    return BlocBuilder<SyncCenterCubit, SyncCenterState>(
      builder: (context, state) {
        final hasQueue = state.totalAntrean > 0;
        final icon = hasQueue ? Icons.cloud_upload : Icons.cloud_done;
        final color = hasQueue ? Colors.orange : Colors.white;

        Widget btn = IconButton(
          icon: Icon(icon, color: color),
          onPressed: () => showSyncPopupDialog(context),
        );

        if (hasQueue) {
          btn = Stack(
            alignment: Alignment.center,
            children: [
              btn,
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${state.totalAntrean}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }

        return btn;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final isCollapsed = constraints.scrollOffset > 50;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SliverAppBar(
          expandedHeight: 240,
          floating: false,
          pinned: true,
          elevation: isCollapsed ? 4 : 0,
          backgroundColor: isDark ? Colors.black : const Color(0xFF0F4C2A),
          surfaceTintColor: Colors.transparent,
          title: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isCollapsed ? 1.0 : 0.0,
            child: Row(
              children: [
                _buildAbsImage(currentUser?.fotoUser, Icons.person, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSyncBtn(context),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Logout',
                    onPressed: onLogout,
                  ),
                ],
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.zero,
            title: isCollapsed
                ? const SizedBox()
                : Container(
                    height: 0,
                    width: double.infinity,
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [const SizedBox(width: 48)],
                    ),
                  ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                const Positioned.fill(child: GlobalHeaderBackground()),
                Positioned(
                  left: 16,
                  bottom: 16,
                  right: 16,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isCollapsed ? 0.0 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BlocBuilder<
                          HeaderSettingsCubit,
                          List<HeaderImageConfig>
                        >(
                          builder: (context, headerConfigList) {
                            final List<Widget> imageWidgets = [];

                            for (final config in headerConfigList) {
                              if (!config.isVisible) continue;

                              Widget? imgWidget;
                              if (config.id == 'profil') {
                                imgWidget = _buildAbsImage(
                                  currentUser?.fotoUser,
                                  Icons.person,
                                  size: 48,
                                );
                              } else if (config.id == 'metode') {
                                imgWidget = _buildAbsImage(
                                  currentUser?.logoMetode,
                                  Icons.menu_book_outlined,
                                  size: 48,
                                );
                              } else if (config.id == 'lembaga') {
                                imgWidget = _buildAbsImage(
                                  currentUser?.logoLembaga,
                                  Icons.account_balance_outlined,
                                  size: 48,
                                );
                              }

                              if (imgWidget != null) {
                                imageWidgets.add(imgWidget);
                                imageWidgets.add(const SizedBox(width: 6));
                              }
                            }

                            if (imageWidgets.isNotEmpty) {
                              imageWidgets.removeLast();
                            }

                            return Row(children: imageWidgets);
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          randomGreeting,
                          style: GoogleFonts.dmSans(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildKelompokSelector(context, kelompok),
                              const SizedBox(width: 8),
                              _buildCategorySelector(context),
                              const SizedBox(width: 8),
                              _buildKelasSelector(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
