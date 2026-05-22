import re

with open(r'd:\PROJEK\projekrun\simflutter\manajemen_tahsin_app\lib\features\progress\presentation\progress_input_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# First replace setTanggal method
set_tanggal_func = """
  void setTanggal(DateTime date) {
    if (date != _tanggal) {
      setState(() {
        _tanggal = date;
        _selectedSesi = null;
      });
      _loadSantri();
    }
  }

  Widget _buildBody() {"""

content = content.replace("  Widget _buildBody() {", set_tanggal_func)

# Now replace the body of _buildBody
build_body_start = content.find("  Widget _buildBody() {")
build_body_end = content.find("  // --- Loading / Error ------------------------------------------------------")

if build_body_start != -1 and build_body_end != -1:
    new_build_body = """  Widget _buildBody() {
    final rows = _sortedRows;
    
    // Global pengaturan (metode & peraga) dan Filter
    Widget globalBar = StatefulBuilder(
      builder: (_, setGlobal) => Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Filter Options Row ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Sort button
                  IconButton(
                    tooltip: 'Urutkan',
                    onPressed: _showSortMenu,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.sort_rounded,
                          color: _kHeader,
                          size: 24,
                        ),
                        if (_sortMode != _SortMode.urut)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Decimal Toggle
                  GestureDetector(
                    onTap: () => setState(
                      () => _isDecimalMode = !_isDecimalMode,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
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
                  const SizedBox(width: 10),
                  // Status Absen Filter (Semua Santri)
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStatusAbsen,
                        isDense: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          size: 18,
                        ),
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
                    const SizedBox(width: 10),
                    Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                          ),
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
                              child: Text(
                                e == 'Semua' ? 'Semua Kelas' : e,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                  // Kelompok Chips
                  if (_kelompokList.length > 1) ...[
                    const SizedBox(width: 10),
                    ..._kelompokList.map((k) {
                      final id = int.tryParse(k['id_kelompok']?.toString() ?? '0') ?? 0;
                      final isSel = _selectedKelompokId == id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            if (!isSel) {
                              setState(() => _selectedKelompokId = id);
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
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),

            // --- Jadwal Sesi (Bila Ada) ---
            if (_jadwalInfo != null) ...[
              const SizedBox(height: 12),
              Container(
                height: 32,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: _jadwalList.length > 1
                    ? DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _jadwalInfo!['sesi'],
                          isDense: true,
                          isExpanded: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedSesi = newValue);
                              _loadSantri();
                            }
                          },
                          items: _jadwalList.map((jdwl) {
                            return DropdownMenuItem<int>(
                              value: jdwl['sesi'],
                              child: Text(
                                '${_hariLabel[jdwl['hari']] ?? ''} - ${_sesiLabel[jdwl['sesi']] ?? ''}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : Text(
                        '${_hariLabel[_jadwalInfo!['hari']] ?? ''} - ${_sesiLabel[_jadwalInfo!['sesi']] ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ],

            // --- Mode Belajar & Peraga (Bila Aktif) ---
            if (_showMetode || _showPeraga) ...[
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_showMetode && _metodeList.isNotEmpty) ...[
                    Expanded(
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
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
                              color: Theme.of(context).colorScheme.onSurface,
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
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
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
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (v) => setState(() => _globalGunakanPeraga = v),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 40,
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
                        height: 40,
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
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _loadSantri(),
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
"""
    
    final_content = content[:build_body_start] + new_build_body + "\n" + content[build_body_end:]
    
    with open(r'd:\PROJEK\projekrun\simflutter\manajemen_tahsin_app\lib\features\progress\presentation\progress_input_screen.dart', 'w', encoding='utf-8') as f:
        f.write(final_content)
    print("SUCCESS")
else:
    print("FAILED TO FIND")
