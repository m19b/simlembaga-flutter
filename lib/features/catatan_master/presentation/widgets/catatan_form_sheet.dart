import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/data/catatan_master_model.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/bloc/catatan_master_cubit.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/presentation/bloc/catatan_master_state.dart';

class CatatanFormSheet extends StatefulWidget {
  final CatatanMaster? item;
  final Map<String, dynamic> filterMeta;

  const CatatanFormSheet({
    super.key,
    this.item,
    required this.filterMeta,
  });

  @override
  State<CatatanFormSheet> createState() => _CatatanFormSheetState();
}

class _CatatanFormSheetState extends State<CatatanFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _teksCtrl;
  late TextEditingController _urutanCtrl;
  
  int? _selectedKelasId;
  int? _selectedKelompokId;
  bool _aktif = true;

  List<Map<String, dynamic>> _kelasList = [];

  @override
  void initState() {
    super.initState();
    _teksCtrl = TextEditingController(text: widget.item?.teksCatatan ?? '');
    _urutanCtrl = TextEditingController(text: (widget.item?.urutan ?? 0).toString());
    _selectedKelasId = widget.item?.idKelas;
    _selectedKelompokId = widget.item?.idKelompok;
    _aktif = widget.item?.aktif ?? true;

    // Parse filterMeta kelas
    final rawKelas = widget.filterMeta['kelas_list'];
    if (rawKelas is List) {
      _kelasList = rawKelas.map((e) {
        if (e is Map) {
          return e.map((k, v) => MapEntry(k.toString(), v));
        }
        return <String, dynamic>{};
      }).where((e) => e.isNotEmpty).toList();
    }
  }

  @override
  void dispose() {
    _teksCtrl.dispose();
    _urutanCtrl.dispose();
    super.dispose();
  }

  void _onKelasChanged(int? val) {
    if (val == null) return;
    setState(() {
      _selectedKelasId = val;
      // Cari id_kelompok dari list kelas (Sesuai spec backend)
      Map<String, dynamic>? kelasData;
      for (var k in _kelasList) {
        if (int.tryParse(k['id_kelas'].toString()) == val) {
          kelasData = k;
          break;
        }
      }
      if (kelasData != null) {
        _selectedKelompokId = int.tryParse(kelasData['id_kelompok'].toString());
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKelasId == null || _selectedKelompokId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih Kelas Terlebih Dahulu')));
      return;
    }

    final data = {
      if (widget.item != null) 'id_catatan': widget.item!.idCatatan,
      'id_kelas': _selectedKelasId,
      'id_kelompok': _selectedKelompokId,
      'teks_catatan': _teksCtrl.text.trim(),
      'urutan': int.tryParse(_urutanCtrl.text) ?? 0,
      'aktif': _aktif ? 1 : 0,
    };

    if (widget.item == null) {
      context.read<CatatanMasterCubit>().addCatatan(data);
    } else {
      context.read<CatatanMasterCubit>().updateCatatan(data);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor, // bg utama gelap
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 1.5)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              Text(
                isEdit ? 'Edit Catatan Master' : 'Tambah Catatan Baru',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 24),
              
              // Dropdown Kelas (Dropdown 2)
              _buildLabel('Target Kelas'),
              _buildDropdownKelas(_kelasList),
              const SizedBox(height: 16),
              
              _buildLabel('Teks Catatan'),
              TextFormField(
                controller: _teksCtrl,
                maxLines: 3,
                decoration: _inputDecoration(context, 'Contoh: Bunyi huruf sudah fasih'),
                style: const TextStyle(fontSize: 14),
                validator: (v) => v == null || v.isEmpty ? 'Teks tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('No Urut'),
                        TextFormField(
                          controller: _urutanCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(context, '0'),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Status'),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_aktif ? 'Aktif' : 'Nonaktif', style: const TextStyle(fontSize: 14)),
                          value: _aktif,
                          onChanged: (v) => setState(() => _aktif = v),
                          activeThumbColor: const Color(0xFF16A34A),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<CatatanMasterCubit, CatatanMasterState>(
                  builder: (context, state) {
                    final isLoading = state is CatatanMasterActionProgress;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEdit ? 'Simpan Perubahan' : 'Tambah Catatan', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
      filled: true,
      fillColor: Theme.of(context).cardColor, // inputan diberi warna seperti bg lama
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }



  Widget _buildDropdownKelas(List<Map<String, dynamic>> items) {
    final bool valueExists = items.any((item) => int.tryParse(item['id_kelas']?.toString() ?? '') == _selectedKelasId);
    final int? effectiveValue = valueExists ? _selectedKelasId : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // bg dropdown
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: effectiveValue,
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          hint: const Text('Pilih Kelas', style: TextStyle(fontSize: 14)),
          items: items.map((item) {
            return DropdownMenuItem<int>(
              value: int.tryParse(item['id_kelas']?.toString() ?? '0'),
              child: Text(item['tingkat']?.toString() ?? '-', style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: _onKelasChanged,
        ),
      ),
    );
  }
}
