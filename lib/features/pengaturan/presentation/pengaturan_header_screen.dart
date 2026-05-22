import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_header_background.dart';
import 'package:manajemen_tahsin_app/features/pengaturan/presentation/bloc/header_settings_cubit.dart';

class PengaturanHeaderScreen extends StatelessWidget {
  const PengaturanHeaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Stack(
          children: [
            const Positioned.fill(
              child: GlobalHeaderBackground(),
            ),
            AppBar(
              toolbarHeight: 48,
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: true,
              title: Text(
                'Header Dashboard',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<HeaderSettingsCubit, List<HeaderImageConfig>>(
        builder: (context, configList) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tarik (drag) ikon garis tiga (â˜°) untuk mengubah urutan gambar di header Dashboard.',
                          style: TextStyle(
                            color: isDark ? Colors.blue.shade300 : Colors.blue.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.transparent,
                    ),
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        context.read<HeaderSettingsCubit>().reorder(oldIndex, newIndex);
                      },
                      children: [
                        for (int i = 0; i < configList.length; i++)
                          Card(
                            key: ValueKey(configList[i].id),
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDark ? Colors.white12 : Colors.grey.shade200,
                              ),
                            ),
                            color: Theme.of(context).colorScheme.surfaceContainer,
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIconForId(configList[i].id),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                configList[i].label,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                configList[i].isVisible ? 'Ditampilkan' : 'Disembunyikan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: configList[i].isVisible ? Colors.green : Colors.grey,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: configList[i].isVisible,
                                    activeColor: Colors.blue,
                                    onChanged: (val) {
                                      context.read<HeaderSettingsCubit>().updateVisibility(configList[i].id, val);
                                    },
                                  ),
                                  ReorderableDragStartListener(
                                    index: i,
                                    child: const Icon(Icons.drag_handle, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForId(String id) {
    switch (id) {
      case 'profil':
        return Icons.person;
      case 'metode':
        return Icons.menu_book_outlined;
      case 'lembaga':
        return Icons.account_balance_outlined;
      default:
        return Icons.image;
    }
  }
}
