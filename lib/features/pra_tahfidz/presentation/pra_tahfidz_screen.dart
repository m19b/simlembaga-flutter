import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_header_background.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/domain/repositories/pra_tahfidz_repository.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/bloc/pra_tahfidz_cubit.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/tabs/pra_tahfidz_progress_tab.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/tabs/pra_tahfidz_input_massal_tab.dart';
import 'package:manajemen_tahsin_app/features/pra_tahfidz/presentation/tabs/pra_tahfidz_riwayat_tab.dart';

/// Entry point untuk modul Pra-Tahfidz. Menginisialisasi BLoC/Cubit.
class PraTahfidzScreen extends StatelessWidget {
  const PraTahfidzScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PraTahfidzCubit(
        repository: PraTahfidzRepository(
          networkInfo: NetworkInfoImpl(LocalNetworkChecker()),
        ),
        activeKelompokCubit: context.read<ActiveKelompokCubit>(),
      ),
      child: const _PraTahfidzView(),
    );
  }
}

class _PraTahfidzView extends StatefulWidget {
  const _PraTahfidzView();

  @override
  State<_PraTahfidzView> createState() => _PraTahfidzViewState();
}

class _PraTahfidzViewState extends State<_PraTahfidzView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  bool _isSearchOpen = false;
  final TextEditingController _searchCtrl = TextEditingController();

  // ValueNotifier untuk filter kelas dropdown di AppBar
  final ValueNotifier<List<Map<String, dynamic>>> _kelasListNotifier =
      ValueNotifier([]);
  final ValueNotifier<int?> _selectedKelasNotifier = ValueNotifier(null);

  static const List<({IconData icon, String label})> _tabs = [
    (icon: Icons.menu_book_rounded, label: 'Progress'),
    (icon: Icons.edit_document, label: 'Input Massal'),
    (icon: Icons.history_edu, label: 'Riwayat'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_isSearchOpen && _tabController.index != 0) {
      setState(() => _isSearchOpen = false);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    _searchCtrl.dispose();
    _kelasListNotifier.dispose();
    _selectedKelasNotifier.dispose();
    super.dispose();
  }

  String get _appBarTitle {
    return switch (_tabController.index) {
      0 => 'Pra-Tahfidz',
      1 => 'Input Massal',
      2 => 'Riwayat',
      _ => 'Pra-Tahfidz',
    };
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() => _selectedDate = picked);
      if (!mounted) return;
      context.read<PraTahfidzCubit>().fetchSantriList(
            tanggal: DateFormat('yyyy-MM-dd').format(_selectedDate),
            forceRefresh: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final styles = Theme.of(context).extension<AppCustomStyles>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Stack(
          children: [
            const Positioned.fill(child: GlobalHeaderBackground()),
            AppBar(
              toolbarHeight: 48,
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: colorScheme.onPrimary,
              iconTheme: IconThemeData(color: colorScheme.onPrimary),
              actionsIconTheme: IconThemeData(color: colorScheme.onPrimary),
              centerTitle: false,
              title: _isSearchOpen && _tabController.index == 0
                  ? _buildSearchField(colorScheme)
                  : Text(
                      _appBarTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
              actions: [
                // Tab 0: Filter tanggal + kelas + search
                if (_tabController.index == 0) ...[
                  // Dropdown kelas filter
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: _kelasListNotifier,
                    builder: (context, kelasList, _) {
                      if (kelasList.length <= 1) return const SizedBox.shrink();
                      return ValueListenableBuilder<int?>(
                        valueListenable: _selectedKelasNotifier,
                        builder: (context, selectedId, _) {
                          return _buildKelasDropdown(
                            context, kelasList, selectedId,
                            isDark: isDark, styles: styles,
                            colorScheme: colorScheme,
                          );
                        },
                      );
                    },
                  ),
                  // Date picker button
                  IconButton(
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    tooltip: DateFormat('dd MMM yyyy').format(_selectedDate),
                    onPressed: _pickDate,
                  ),
                  // Search toggle
                  if (!_isSearchOpen)
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => setState(() => _isSearchOpen = true),
                    ),
                ],
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          PraTahfidzProgressTab(
            searchCtrl: _searchCtrl,
            kelasListNotifier: _kelasListNotifier,
            selectedKelasNotifier: _selectedKelasNotifier,
            selectedDate: _selectedDate,
          ),
          const PraTahfidzInputMassalTab(),
          const PraTahfidzRiwayatTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(colorScheme, isDark),
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme) {
    return TextField(
      controller: _searchCtrl,
      autofocus: true,
      style: TextStyle(color: colorScheme.onPrimary),
      decoration: InputDecoration(
        hintText: 'Cari santri...',
        hintStyle:
            TextStyle(color: colorScheme.onPrimary.withValues(alpha: 0.7)),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onPrimary),
          onPressed: () {
            _searchCtrl.clear();
            setState(() => _isSearchOpen = false);
          },
        ),
      ),
    );
  }

  Widget _buildKelasDropdown(
    BuildContext context,
    List<Map<String, dynamic>> kelasList,
    int? selectedId, {
    required bool isDark,
    required AppCustomStyles styles,
    required ColorScheme colorScheme,
  }) {
    return Container(
      height: 26,
      margin: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: styles.headerBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedId,
          isDense: true,
          dropdownColor:
              isDark ? Colors.black : colorScheme.primary,
          icon: Icon(
            Icons.arrow_drop_down,
            size: 16,
            color: colorScheme.onPrimary.withValues(alpha: 0.7),
          ),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          onChanged: (val) => _selectedKelasNotifier.value = val,
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Semua'),
            ),
            ...kelasList.map((k) {
              final id =
                  int.tryParse(k['id_kelas']?.toString() ?? '0') ?? 0;
              final tingkat = k['tingkat']?.toString() ?? '-';
              return DropdownMenuItem<int?>(
                value: id,
                child: Text(tingkat),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        top: 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (i) {
          return Expanded(
            child: _NavItem(
              index: i,
              icon: _tabs[i].icon,
              label: _tabs[i].label,
              isSelected: _tabController.index == i,
              colorScheme: colorScheme,
              isDark: isDark,
              onTap: () => setState(() => _tabController.index = i),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Bottom Nav Item ──────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final ColorScheme colorScheme;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.colorScheme,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
                  .withValues(alpha: isDark ? 0.15 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.white : colorScheme.primary)
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
