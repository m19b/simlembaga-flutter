import 'package:flutter/material.dart';

class SantriSelectionSheet extends StatefulWidget {
  final List<Map<String, dynamic>> santriList;

  const SantriSelectionSheet({super.key, required this.santriList});

  @override
  State<SantriSelectionSheet> createState() => _SantriSelectionSheetState();
}

class _SantriSelectionSheetState extends State<SantriSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = widget.santriList;
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterList);
    _searchController.dispose();
    super.dispose();
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = widget.santriList.where((s) {
        final nama = (s['nama_santri']?.toString() ?? '').toLowerCase();
        final nis = (s['nis']?.toString() ?? '').toLowerCase();
        return nama.contains(query) || nis.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBg = isDark ? theme.colorScheme.surface : Colors.white;
    final inputFill = isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white;
    final inputBorder = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300;
    final textMain = isDark ? theme.colorScheme.onSurface : const Color(0xFF111827);
    final textSub = isDark ? theme.colorScheme.onSurfaceVariant : Colors.grey.shade600;
    const accentGreen = Color(0xFF16A34A);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          
          // Header & Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Santri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textSub),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  autofocus: false,
                  style: TextStyle(fontSize: 14, color: textMain),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: inputFill,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: inputBorder),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: accentGreen, width: 1.5),
                    ),
                    hintText: 'Cari nama atau NIS santri...',
                    hintStyle: TextStyle(color: textSub, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: accentGreen),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _filterList();
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // List
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: Text(
                      'Santri tidak ditemukan',
                      style: TextStyle(color: textSub),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: _filteredList.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: inputBorder),
                    itemBuilder: (context, index) {
                      final santri = _filteredList[index];
                      final nama = santri['nama_santri']?.toString() ?? '-';
                      final nis = santri['nis']?.toString() ?? '-';
                      final tingkat = santri['tingkat']?.toString() ?? santri['kelas']?.toString() ?? '-';
                      
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: accentGreen.withValues(alpha: 0.12),
                          child: Text(
                            nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: accentGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          nama,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textMain,
                          ),
                        ),
                        subtitle: Text(
                          '$nis • $tingkat',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSub,
                          ),
                        ),
                        onTap: () => Navigator.pop(context, santri),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
