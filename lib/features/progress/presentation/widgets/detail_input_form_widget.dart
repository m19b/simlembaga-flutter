import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/shared/widgets/custom_date_field.dart';

const Color _kHeader = Color(0xFF0F4C2A);
const Color _kAccent = Color(0xFF16A34A);
const Color _kBg = Color(0xFFF8FAFC);
const Color _kText1 = Color(0xFF1E293B);
const Color _kText2 = Color(0xFF64748B);

class DetailInputFormWidget extends StatefulWidget {
  final String nis;
  final double initialHalAwal;
  final bool isLatihan;
  final bool isAkselerasi;
  final int jmlTes;
  final bool isTerkunci;
  final String alasanKunci;
  final int jmlGagalBerturut;  // â† baru: tampilkan streak tidak lulus
  final List<Map<String, dynamic>> catatanMaster;
  final Map<String, dynamic> kelasSettings;
  final List<Map<String, dynamic>> metodeList;
  final int idKelas;
  final VoidCallback onSuccess;

  const DetailInputFormWidget({
    super.key,
    required this.nis,
    required this.initialHalAwal,
    required this.isLatihan,
    this.isAkselerasi = false,
    this.jmlTes = 0,
    this.isTerkunci = false,
    this.alasanKunci = '',
    this.jmlGagalBerturut = 0,
    required this.catatanMaster,
    required this.kelasSettings,
    required this.metodeList,
    required this.idKelas,
    required this.onSuccess,
  });

  @override
  State<DetailInputFormWidget> createState() => DetailInputFormWidgetState();
}

class DetailInputFormWidgetState extends State<DetailInputFormWidget> {
  final _formKey = GlobalKey<FormState>();

  // ðŸ”´ Controller untuk 3 kotak halaman
  final _halAwalCtrl = TextEditingController();
  final _halTotalCtrl = TextEditingController();
  final _halAkhirCtrl = TextEditingController();
  final _kehadiranCtrl = TextEditingController(text: '1'); // TM Stepper

  final _ketCtrl = TextEditingController();
  final _halamanPeragaCtrl = TextEditingController();
  final _keteranganPeragaCtrl = TextEditingController();

  bool _isLulus = true;
  bool _isDisimak = true;
  bool _showMetode = false;
  bool _showPeraga = false;
  bool _gunakanPeraga = false;
  int? _idMetode;

  DateTime _tgl = DateTime.now();
  bool _saving = false;
  String _msg = '';
  bool _isDecimalMode = false;

  @override
  void initState() {
    super.initState();
    // Mengisi default nilai Hal Awal sesuai progress santri
    _halAwalCtrl.text = widget.initialHalAwal == widget.initialHalAwal.toInt()
        ? widget.initialHalAwal.toInt().toString()
        : widget.initialHalAwal.toString();
    _halTotalCtrl.text = '1';
    _kehadiranCtrl.text = '1';

    // Setelan Kelas (Metode & Peraga)
    final ks = widget.kelasSettings;
    _showMetode = (int.tryParse(ks['is_metode_belajar']?.toString() ?? '0') ?? 0) == 1;
    _showPeraga = (int.tryParse(ks['is_peraga']?.toString() ?? '0') ?? 0) == 1;
    if (_showMetode) {
      final defMetode = int.tryParse(ks['default_id_metode']?.toString() ?? '0') ?? 0;
      if (defMetode > 0) _idMetode = defMetode;
    }

    _recalc(from: 'total');
  }

  @override
  void dispose() {
    _halAwalCtrl.dispose();
    _halTotalCtrl.dispose();
    _halAkhirCtrl.dispose();
    _kehadiranCtrl.dispose();
    _ketCtrl.dispose();
    _halamanPeragaCtrl.dispose();
    _keteranganPeragaCtrl.dispose();
    super.dispose();
  }

  // ðŸ”´ Logika Reactive saat 3 kotak diedit
  void _recalc({required String from}) {
    double awal = double.tryParse(_halAwalCtrl.text) ?? 0;
    double total = double.tryParse(_halTotalCtrl.text) ?? 0;
    double akhir = double.tryParse(_halAkhirCtrl.text) ?? 0;

    String fmt(double v) =>
        v == v.toInt() ? v.toInt().toString() : v.toString();

    if (from == 'awal' || from == 'total') {
      double newAkhir = awal + total;
      _halAkhirCtrl.text = newAkhir > 0 ? fmt(newAkhir) : '';
    } else if (from == 'akhir') {
      double newTotal = akhir - awal;
      if (newTotal < 0) newTotal = 0;
      _halTotalCtrl.text = newTotal > 0 ? fmt(newTotal) : '';
    }
  }


  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // ðŸ”´ VALIDASI SISA HALAMAN DIAGNOSTIK DIHAPUS
    double inputTotal = double.tryParse(_halTotalCtrl.text.trim()) ?? 0;
    if (inputTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Total halaman minimal 1!',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
      _msg = '';
    });
    try {
      final tglStr = DateFormat('yyyy-MM-dd').format(_tgl);

      final payload = <String, dynamic>{
        'nis': widget.nis,
        'id_kelas': widget.idKelas,
        'tgl_simak': tglStr,
        'hal_awal': double.tryParse(_halAwalCtrl.text.trim()) ?? 0,
        'hal_total': double.tryParse(_halTotalCtrl.text.trim()) ?? 0,
        'jml_kehadiran': int.tryParse(_kehadiranCtrl.text.trim()) ?? 1,
        'status_halaman': _isLulus ? 'Lulus' : 'Mengulang',
        'catatan_guru': _ketCtrl.text.trim(),
        'disimak': _isDisimak ? '1' : '0',
      };

      if (_showMetode && _idMetode != null) {
        payload['id_metode'] = _idMetode;
      }
      if (_showPeraga) {
        payload['menggunakan_peraga'] = _gunakanPeraga ? 1 : 0;
        if (_gunakanPeraga) {
          payload['halaman_peraga'] = _halamanPeragaCtrl.text.trim();
          payload['keterangan_peraga'] = _keteranganPeragaCtrl.text.trim();
        }
      }

      await ApiService.inputCepatProgress(payload);

      setState(() {
        _saving = false;
      });

      _halTotalCtrl.text = '1';
      _halAkhirCtrl.clear();
      _ketCtrl.clear();
      _halamanPeragaCtrl.clear();
      _keteranganPeragaCtrl.clear();
      _kehadiranCtrl.text = '1';

      // ðŸ”´ Notifikasi Hijau yang cantik
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Data berhasil disimpan!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: _kAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      widget.onSuccess();
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          errorMsg = data['message'].toString();
        }
      }
      setState(() {
        _saving = false;
        _msg = errorMsg;
      });
    }
  }

  Widget _buildBox({
    required String label,
    required TextEditingController ctrl,
    bool isPrimary = false,
    Color? textColor,
    Function(String)? onChanged,
    VoidCallback? onAdd,
    VoidCallback? onMinus,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isPrimary ? Colors.red.shade600 : _kText2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor ?? _kText1,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isPrimary ? Colors.white : _kBg,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isPrimary ? _kAccent : Colors.grey.shade400,
              ),
            ),
            prefixIcon: onMinus != null
                ? IconButton(
                    icon: Icon(
                      Icons.remove,
                      size: 16,
                      color: Colors.red.shade600,
                    ),
                    onPressed: onMinus,
                    splashRadius: 16,
                  )
                : null,
            suffixIcon: onAdd != null
                ? IconButton(
                    icon: Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    onPressed: onAdd,
                    splashRadius: 16,
                  )
                : null,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Input Simakan Cepat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _kText1,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isDecimalMode = !_isDecimalMode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isDecimalMode
                          ? Colors.orange.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isDecimalMode
                            ? Colors.orange.shade300
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
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
                        const SizedBox(width: 6),
                        Text(
                          _isDecimalMode ? 'Desimal (0.5)' : 'Bulat (1.0)',
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
              ],
            ),
            const SizedBox(height: 20),

            _label('Tanggal Simak'),
            CustomDateField(
              selectedDate: _tgl,
              onDateSelected: (date) {
                if (date != null && date != _tgl) {
                  setState(() => _tgl = date);
                }
              },
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Tatap Muka (TM)'),
                      SizedBox(
                        width: 140, // Membatasi lebar stepper kehadiran
                        child: _buildBox(
                          label: '',
                          ctrl: _kehadiranCtrl,
                          isPrimary: false,
                          textColor: Colors.teal.shade700,
                          onAdd: () {
                            int val = int.tryParse(_kehadiranCtrl.text) ?? 1;
                            _kehadiranCtrl.text = (val + 1).toString();
                          },
                          onMinus: () {
                            int val = int.tryParse(_kehadiranCtrl.text) ?? 1;
                            if (val > 1) {
                              _kehadiranCtrl.text = (val - 1).toString();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isAkselerasi
                        ? Colors.red.shade50
                        : (widget.isLatihan
                              ? Colors.teal.shade50
                              : Colors.deepPurple.shade50),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          (widget.isAkselerasi
                                  ? Colors.red
                                  : (widget.isLatihan
                                        ? Colors.teal
                                        : Colors.deepPurple))
                              .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    widget.isAkselerasi
                        ? 'Mode: AKSELERASI ${widget.jmlTes > 0 ? widget.jmlTes : 1}'
                        : (widget.isLatihan
                              ? 'Mode: LATIHAN'
                              : 'Mode: REGULER'),
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isAkselerasi
                          ? Colors.red
                          : (widget.isLatihan
                                ? Colors.teal
                                : Colors.deepPurple),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (widget.isTerkunci)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded, size: 24, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Santri Siap Test!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber.shade900)),
                          const SizedBox(height: 4),
                          Text('${widget.alasanKunci} Form dihentikan. Wajib tes.', style: TextStyle(fontSize: 12, color: Colors.amber.shade800)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.amber.shade600, borderRadius: BorderRadius.circular(20)),
                      child: const Text('SIAP TEST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
              )
            else ...[
              // ðŸ”´ 3 KOTAK HALAMAN (Awal, Total, Akhir)
              Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildBox(
                    label: 'Awal',
                    ctrl: _halAwalCtrl,
                    onChanged: (v) => _recalc(from: 'awal'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildBox(
                    label: 'Total (Baru)',
                    ctrl: _halTotalCtrl,
                    isPrimary: true,
                    onChanged: (v) => _recalc(from: 'total'),
                    onAdd: () {
                      double val = double.tryParse(_halTotalCtrl.text) ?? 0;
                      double step = _isDecimalMode ? 0.5 : 1.0;
                      double res = val + step;
                      _halTotalCtrl.text = res == res.toInt()
                          ? res.toInt().toString()
                          : res.toString();
                      _recalc(from: 'total');
                    },
                    onMinus: () {
                      double val = double.tryParse(_halTotalCtrl.text) ?? 0;
                      double step = _isDecimalMode ? 0.5 : 1.0;
                      if (val > step) {
                        double res = val - step;
                        _halTotalCtrl.text = res == res.toInt()
                            ? res.toInt().toString()
                            : res.toString();
                        _recalc(from: 'total');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildBox(
                    label: 'Akhir',
                    ctrl: _halAkhirCtrl,
                    textColor: Colors.indigo.shade600,
                    onChanged: (v) => _recalc(from: 'akhir'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _label('Status Simakan'),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLulus = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isLulus ? _kAccent : Colors.white,
                        border: Border.all(
                          color: _isLulus ? _kAccent : Colors.grey.shade300,
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Lulus',
                        style: TextStyle(
                          color: _isLulus ? Colors.white : _kText2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isLulus = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isLulus ? Colors.red.shade500 : Colors.white,
                        border: Border.all(
                          color: !_isLulus
                              ? Colors.red.shade500
                              : Colors.grey.shade300,
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Mengulang',
                        style: TextStyle(
                          color: !_isLulus ? Colors.white : _kText2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _label('Disimak di Rumah?'),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDisimak = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isDisimak ? Colors.blue.shade600 : Colors.white,
                        border: Border.all(
                          color: _isDisimak
                              ? Colors.blue.shade600
                              : Colors.grey.shade300,
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Ya, Disimak',
                        style: TextStyle(
                          color: _isDisimak ? Colors.white : _kText2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDisimak = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isDisimak
                            ? Colors.orange.shade600
                            : Colors.white,
                        border: Border.all(
                          color: !_isDisimak
                              ? Colors.orange.shade600
                              : Colors.grey.shade300,
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Tidak',
                        style: TextStyle(
                          color: !_isDisimak ? Colors.white : _kText2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const SizedBox(height: 14),

            if (_showMetode || _showPeraga) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings_suggest, size: 18, color: _kHeader),
                        const SizedBox(width: 8),
                        Text('Pengaturan Pembelajaran', style: TextStyle(fontWeight: FontWeight.bold, color: _kHeader, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_showMetode && widget.metodeList.isNotEmpty) ...[
                      Text('Metode Belajar', style: TextStyle(fontSize: 12, color: _kText2, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: _idMetode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade200)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade200)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: [
                          const DropdownMenuItem<int>(value: null, child: Text('- Tidak Ada Metode -')),
                          ...widget.metodeList.map((m) => DropdownMenuItem<int>(
                            value: int.tryParse(m['id_metode']?.toString() ?? '0'),
                            child: Text(m['nama_metode']?.toString() ?? '-', style: const TextStyle(fontSize: 14)),
                          )),
                        ],
                        onChanged: (v) => setState(() => _idMetode = v),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_showPeraga) ...[
                      Row(
                        children: [
                          Switch(
                            value: _gunakanPeraga,
                            activeThumbColor: _kHeader,
                            onChanged: (v) => setState(() => _gunakanPeraga = v),
                          ),
                          const SizedBox(width: 8),
                          Text('Gunakan Peraga', style: TextStyle(fontWeight: FontWeight.bold, color: _kText1)),
                        ],
                      ),
                      if (_gunakanPeraga) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _halamanPeragaCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Halaman',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade200)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade200)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _keteranganPeragaCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Keterangan',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade200)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade200)),
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
              const SizedBox(height: 24),
            ],

            _label('Catatan Cepat'),
            if (widget.catatanMaster.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Tidak ada template catatan standar.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kText2,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.catatanMaster.map((c) {
                    final str = c['teks_catatan']?.toString() ?? '';
                    if (str.isEmpty) return const SizedBox.shrink();
                    final isSel = _ketCtrl.text.contains(str);
                    return FilterChip(
                      label: Text(str),
                      selected: isSel,
                      onSelected: (val) {
                        setState(() {
                          List<String> current = _ketCtrl.text.trim().isNotEmpty
                              ? _ketCtrl.text
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList()
                              : [];
                          if (val) {
                            if (!current.contains(str)) current.add(str);
                          } else {
                            current.remove(str);
                          }
                          _ketCtrl.text = current.join(', ');
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: _kAccent.withValues(alpha: 0.15),
                      checkmarkColor: _kAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide.none,
                      labelStyle: TextStyle(
                        color: isSel ? _kAccent : _kText2,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ),

            _label('Keterangan (opsional)'),
            TextFormField(
              controller: _ketCtrl,
              maxLines: 3,
              style: TextStyle(fontSize: 14),
              decoration: _inputDeco('Catatan tambahanâ€¦'),
            ),
            const SizedBox(height: 24),

            if (_msg.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_rounded,
                      color: Colors.red.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _msg,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Simpan Simakan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: _kText1,
      ),
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kAccent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}