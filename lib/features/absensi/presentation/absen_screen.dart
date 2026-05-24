import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_tahsin_app/core/api/services/absensi_api_service.dart';
import 'package:manajemen_tahsin_app/core/api/services/santri_catatan_api_service.dart';
import 'package:manajemen_tahsin_app/core/constants/api_config.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/bottom.dart';
import 'package:manajemen_tahsin_app/core/widgets/app_header_bar.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/data/isar_db.dart';
import 'package:manajemen_tahsin_app/core/data/models/santri_binaan_cache.dart';
import 'package:manajemen_tahsin_app/core/data/models/santri_universal_cache.dart';
import 'package:manajemen_tahsin_app/core/data/models/guru_universal_cache.dart';
import 'package:isar/isar.dart';

enum ScanState { waiting, success }

class AbsenScreen extends StatefulWidget {
  final int initialIndex;
  const AbsenScreen({super.key, this.initialIndex = 0});

  @override
  State<AbsenScreen> createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ==========================================
  // 1. CONTROLLERS & STATE
  // ==========================================
  late final TabController _tabController;
  late final MobileScannerController _cameraController;
  late final FlutterTts _tts;

  final TextEditingController _rfidController = TextEditingController();
  final FocusNode _rfidFocusNode = FocusNode();
  final TextEditingController _manualController = TextEditingController();
  final FocusNode _manualFocusNode = FocusNode();
  
  final GlobalKey<AbsenMassalTabState> _massalTabKey = GlobalKey<AbsenMassalTabState>();

  ScanState _scanState = ScanState.waiting;
  Map<String, dynamic>? _lastScannedUser;
  String _baseUrl = '';

  bool _isProcessing = false;
  String _lastProcessedCode = '';
  DateTime? _lastScanTime;
  Timer? _resetTimer;

  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  late AnimationController _pulseController;
  late AnimationController _successBlinkController;

  // ==========================================
  // 2. LIFECYCLE METHODS
  // ==========================================
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initBasicServices();
    _initAnimations();
    _initControllers();
  }

  void _initBasicServices() async {
    _baseUrl = await ApiConfig.getBaseUrl();
    _tts = FlutterTts();
    await _tts.setLanguage("id-ID");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    _checkCameraPermission();
  }

  void _initControllers() {
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      autoStart: false,
    );

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex > 2 ? 0 : widget.initialIndex,
    );

    _tabController.addListener(_onTabChanged);
  }

  void _initAnimations() {
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _successBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_tabController.index != 0) return;

    if (state == AppLifecycleState.resumed) {
      _cameraController.start();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetTimer?.cancel();
    _cameraController.dispose();
    _tabController.dispose();
    _rfidController.dispose();
    _manualController.dispose();
    _rfidFocusNode.dispose();
    _manualFocusNode.dispose();
    _tts.stop();
    _scanLineController.dispose();
    _pulseController.dispose();
    _successBlinkController.dispose();
    super.dispose();
  }

  // ==========================================
  // 3. CORE LOGIC (Pemrosesan Data)
  // ==========================================
  void _onTabChanged() async {
    _resetScanState();

    if (_tabController.index == 0) {
      await _cameraController.start();
      _pulseController.repeat();
      _scanLineController.repeat(reverse: true);
      _unfocusAll();
    } else if (_tabController.index == 1) {
      await _cameraController.stop();
      _pulseController.stop();
      _scanLineController.stop();
      _rfidFocusNode.requestFocus();
    } else {
      await _cameraController.stop();
      _pulseController.stop();
      _scanLineController.stop();
      _unfocusAll();
    }

    if (mounted) setState(() {});
  }

  void _unfocusAll() {
    _rfidFocusNode.unfocus();
    _manualFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus(); // Paksa semua keyboard mati
  }

  void _resetScanState() {
    _resetTimer?.cancel();
    if (!mounted) return;

    setState(() {
      _scanState = ScanState.waiting;
      _lastScannedUser = null;
      _isProcessing = false;
    });
    _successBlinkController.stop();
  }

  Future<void> _processScan(String code, {bool isFromCamera = false}) async {
    final cleanCode = code.replaceAll(RegExp(r'\s+'), '');
    if (cleanCode.isEmpty) return;

    if (_isProcessing) return;

    if (isFromCamera && cleanCode == _lastProcessedCode) {
      if (_lastScanTime != null &&
          DateTime.now().difference(_lastScanTime!).inSeconds < 10) {
        return;
      }
    }

    setState(() => _isProcessing = true);
    _lastProcessedCode = cleanCode;
    _lastScanTime = DateTime.now();

    // 🔴 LOGIKA JEDA KEYBOARD (Ide Cerdas Abi)
    if (!isFromCamera) {
      _unfocusAll(); // Hilangkan keyboard seketika
      // Beri waktu 500ms agar keyboard benar-benar turun ke bawah layar
      // Sebelum UI memproses hasil absen, agar tidak tabrakan animasi.
      await Future.delayed(const Duration(milliseconds: 500));
    }

    await _executeApiCall(cleanCode, isFromCamera);
  }

  Future<void> _executeApiCall(String cleanCode, bool isFromCamera) async {
    final now = DateTime.now();
    final currentJamStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    try {
      final res = await AbsensiApiService.scanAbsen(cleanCode, 'masuk').timeout(const Duration(seconds: 3));
      final data = res['data'] as Map<String, dynamic>?;

      final namaLengkap = data?['nama_santri'] ?? 'Tidak Diketahui';
      final namaPanggilan = data?['nama_panggilan'] ?? namaLengkap;
      final jk = data?['jenis_kelamin']?.toString() ?? '-';
      final kelas = data?['kelas'] ?? '-';
      final fotoName = data?['foto'];
      final identitas = data?['nis']?.toString() ?? cleanCode;
      final userAbsen = data?['user_absen'] ?? '-';

      final tipe = data?['tipe'] ?? 'santri';
      final fotoUrl = (fotoName != null && fotoName.toString().isNotEmpty)
          ? '$_baseUrl/uploads/$tipe/$fotoName'
          : null;

      String pesanInfo = res['message'] ?? 'Berhasil absen';
      pesanInfo = pesanInfo.replaceAllMapped(
        RegExp(r'\b(\d{2}:\d{2})\b'),
        (match) => currentJamStr,
      );

      final bool isAlreadyAbsent =
          (data?['sudah_absen'] == true) ||
          pesanInfo.toLowerCase().contains('sudah');

      if (!mounted) return;

      setState(() {
        _lastScannedUser = {
          'nama_lengkap': namaLengkap,
          'nama_panggilan': namaPanggilan,
          'identitas': identitas,
          'jk': jk,
          'kelas': kelas,
          'foto_url': fotoUrl,
          'jam': currentJamStr,
          'pesan': pesanInfo,
          'user_absen': userAbsen,
          'sudah_absen': isAlreadyAbsent,
          'tipe': tipe,
        };
        _scanState = ScanState.success;
      });

      _successBlinkController.repeat(reverse: true);

      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isProcessing = false);
          // HAPUS auto-focus agar keyboard tidak tiba-tiba muncul lagi sendiri
          // if (_tabController.index == 1) _rfidFocusNode.requestFocus();
        }
      });

      if (tipe == 'guru') {
        _tts.speak(isAlreadyAbsent ? 'Ustaz $namaPanggilan sudah absen' : 'Ustaz $namaPanggilan hadir');
      } else {
        _tts.speak(isAlreadyAbsent ? '$namaPanggilan sudah absen' : '$namaPanggilan hadir');
      }
    } catch (e) {
      if (e is TimeoutException || 
          e.toString().toLowerCase().contains('socket') || 
          e.toString().toLowerCase().contains('network') || 
          e.toString().toLowerCase().contains('offline')) {
        await _handleOfflineScan(cleanCode, currentJamStr);
      } else {
        _handleScanError(e, isFromCamera);
      }
    } finally {
      if (mounted) {
        _rfidController.clear();
        _manualController.clear();
      }
    }
  }

  Future<void> _handleOfflineScan(String cleanCode, String jamStr) async {
    final isar = IsarDb.instance;
    
    // Fallback Chain 1: Santri Binaan
    final cachedBinaan = await isar.santriBinaanCaches.filter().nisEqualTo(cleanCode).findFirst();
    if (cachedBinaan != null) {
      await _prosesOfflineFound(cleanCode, cachedBinaan.nama, cachedBinaan.nis, cachedBinaan.tingkatKelas ?? '-', jamStr, 'santri');
      return;
    }

    // Fallback Chain 2: Santri Universal
    final cachedSantriUniv = await isar.santriUniversalCaches.filter().nisEqualTo(cleanCode).findFirst();
    if (cachedSantriUniv != null) {
      await _prosesOfflineFound(cleanCode, cachedSantriUniv.nama, cachedSantriUniv.nis, cachedSantriUniv.tingkatKelas ?? '-', jamStr, 'santri');
      return;
    }

    // Fallback Chain 3: Guru Universal
    final cachedGuruUniv = await isar.guruUniversalCaches.filter().nigEqualTo(cleanCode).findFirst();
    if (cachedGuruUniv != null) {
      await _prosesOfflineFound(cleanCode, cachedGuruUniv.nama, cachedGuruUniv.nig, 'Guru/Staf', jamStr, 'guru');
      return;
    }

    // Jika tidak ketemu satupun
    _lastProcessedCode = '';
    _tts.speak('Mode luring. QR tidak dikenali.');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mode Luring: QR tidak dikenali atau belum diunduh ke cache. Harap sambungkan ke internet.'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _prosesOfflineFound(String cleanCode, String nama, String identitas, String kelas, String jamStr, String tipe) async {
    final payload = {'kode': cleanCode, 'waktu': 'masuk', 'offline_timestamp': DateTime.now().toIso8601String()};
    await LocalDataSourceImpl().enqueueRequest('guru/absen-santri/scan', payload);

    if (!mounted) return;
    setState(() {
      _lastScannedUser = {
        'nama_lengkap': nama,
        'nama_panggilan': nama,
        'identitas': identitas,
        'jk': '-',
        'kelas': kelas,
        'foto_url': null,
        'jam': jamStr,
        'pesan': 'Disimpan Luring: Hadir',
        'user_absen': 'Luring',
        'sudah_absen': false,
        'tipe': tipe,
      };
      _scanState = ScanState.success;
    });

    _successBlinkController.repeat(reverse: true);
    
    if (tipe == 'guru') {
      _tts.speak('Ustaz $nama hadir luring');
    } else {
      _tts.speak('$nama hadir luring');
    }

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  void _handleScanError(dynamic error, bool isFromCamera) {
    _lastProcessedCode = '';
    final msg = error.toString().replaceFirst('Exception: ', '');

    if (msg.toLowerCase().contains('tidak ditemukan')) {
      _tts.speak('Data tidak ditemukan');
    } else if (msg.toLowerCase().contains('akses')) {
      _tts.speak('Akses ditolak.');
    } else if (msg.toLowerCase().contains('belum absen masuk')) {
      _tts.speak('Belum absen masuk.');
    } else if (msg.toLowerCase().contains('jadwal kelas')) {
      _tts.speak(msg); // Bacakan langsung pesan dari backend: "Nama tidak memiliki jadwal..."
    } else if (msg.toLowerCase().contains('luar jendela')) {
      _tts.speak('Di luar jam absen.');
    } else if (msg.length < 60) {
      _tts.speak(msg); // Bacakan pesan jika tidak terlalu panjang
    } else {
      _tts.speak('Terjadi kesalahan. Gagal absen.');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Future.delayed(const Duration(seconds: 1), _resetScanState);
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Izin kamera ditolak. Silakan izinkan di pengaturan layar Android Anda.',
          ),
        ),
      );
    } else {
      if (widget.initialIndex == 0 && mounted) {
        await _cameraController.start();
      }
    }
  }

  // ==========================================
  // 4. UI BUILDING METHODS
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    if (_tabController.index == 2) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: _buildCustomAppBar(),
        body: AbsenMassalTab(key: _massalTabKey),
        bottomNavigationBar: _buildCustomBottomNav(),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      // 🔴 KUNCI ANTI GETAR UTAMA: Jangan pernah menyusutkan UI karena keyboard!
      resizeToAvoidBottomInset: false,
      appBar: _buildCustomAppBar(),
      body: Column(
        children: [
          if (_tabController.index == 0) _buildCameraViewport(),
          if (_tabController.index == 1) _buildRfidNisForm(),
          Expanded(child: _buildBottomPanel()),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    final iconOverlay = Colors.white.withValues(alpha: 0.15);

    return AppHeaderBar(
      title: 'Scanner Absensi',
      actions: [
        if (_tabController.index == 0) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(color: iconOverlay, borderRadius: BorderRadius.circular(11)),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.refresh, size: 20, color: Colors.white),
                tooltip: 'Reset Kamera',
                onPressed: () async {
                  setState(() => _isProcessing = true);
                  await _cameraController.stop();
                  await Future.delayed(const Duration(milliseconds: 300));
                  await _cameraController.start();
                  setState(() => _isProcessing = false);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(color: iconOverlay, borderRadius: BorderRadius.circular(11)),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.flash_on, size: 20, color: Colors.white),
                tooltip: 'Senter',
                onPressed: () => _cameraController.toggleTorch(),
              ),
            ),
          ),
        ],
        if (_tabController.index == 2) ...[
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              icon: const Icon(Icons.save, size: 16),
              label: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () {
                 _massalTabKey.currentState?.simpan();
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCameraViewport() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              final String code = capture.barcodes.firstOrNull?.rawValue ?? "";
              if (code.isNotEmpty) _processScan(code, isFromCamera: true);
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: const BorderSide(color: Colors.black54, width: 30),
                bottom: const BorderSide(color: Colors.black54, width: 30),
                left: BorderSide(
                  color: Colors.black54,
                  width: (MediaQuery.of(context).size.width - 180) / 2,
                ),
                right: BorderSide(
                  color: Colors.black54,
                  width: (MediaQuery.of(context).size.width - 180) / 2,
                ),
              ),
            ),
          ),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _FramePainter()),
                  AnimatedBuilder(
                    animation: _scanLineAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _scanLineAnimation.value * 180,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Posisikan QR di dalam bingkai',
                style: GoogleFonts.dmSans(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRfidNisForm() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          controller: _rfidController,
          focusNode: _rfidFocusNode,
          keyboardType: TextInputType.none,
          decoration: InputDecoration(
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            hintText: 'Tap RFID Scanner...',
            hintStyle: GoogleFonts.dmSans(fontSize: 13),
            prefixIcon: Icon(Icons.contactless, color: cs.primary, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.zero,
          ),
          onSubmitted: (val) => _processScan(val),
        ),
        const SizedBox(height: 12),
        Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.length < 2) return const Iterable<Map<String, dynamic>>.empty();
            try {
              final results = await SantriCatatanApiService.cariSantri(textEditingValue.text);
              return results.cast<Map<String, dynamic>>();
            } catch (e) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
          },
          displayStringForOption: (option) => option['nis'].toString(),
          onSelected: (option) => _processScan(option['nis'].toString()),
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                hintText: 'Cari Nama Santri / Input ID Manual...',
                hintStyle: GoogleFonts.dmSans(fontSize: 13),
                prefixIcon: Icon(Icons.search, color: cs.primary, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: cs.secondary, size: 18),
                  onPressed: () => _processScan(textEditingController.text),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (val) => _processScan(val),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 32,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option['nama_santri'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text('NIS: ${option['nis']}', style: GoogleFonts.dmMono(fontSize: 12, color: cs.primary)),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  // ==========================================
  // PERBAIKAN 3: Transisi Menggunakan AnimatedCrossFade
  // (Jauh lebih stabil dan anti-getar untuk perubahan tinggi konten)
  // ==========================================
  Widget _buildBottomPanel() {
    return Container(
      width: double.infinity,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5))),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
          crossFadeState: _scanState == ScanState.waiting
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Container(
            width: double.infinity,
            alignment: Alignment.topCenter,
            child: _buildWaitingState(),
          ),
          secondChild: Container(
            width: double.infinity,
            alignment: Alignment.topCenter,
            child: _scanState == ScanState.success
                ? _buildSuccessState()
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 22),
        SizedBox(
          width: 80,
          height: 80,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (ctx, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _buildPulseCircle(_pulseController.value),
                  _buildPulseCircle((_pulseController.value + 0.35) % 1.0),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF16A34A),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Siap Memindai',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F4C2A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _tabController.index == 0
              ? 'Arahkan kode QR ke\nkamera di atas'
              : 'Arahkan kartu ke sensor RFID atau input ID',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildPulseCircle(double value) {
    return Transform.scale(
      scale: 0.7 + (0.8 * value),
      child: Opacity(
        opacity: 0.7 * (1.0 - value),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF22C55E), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    if (_lastScannedUser == null) return const SizedBox.shrink();

    final user = _lastScannedUser!;
    final bool isWarning = user['sudah_absen'] == true;

    final String tipe = user['tipe'] ?? 'santri';
    final bool isGuru = tipe == 'guru';

    final cs = Theme.of(context).colorScheme;
    final Color successBgColor = isGuru ? Colors.teal.shade50 : cs.primaryContainer;
    final Color bgColor = isWarning ? Colors.orange.shade50 : successBgColor;
    final IconData statusIcon = isWarning ? Icons.info_outline : Icons.check;
    final Color successIconColor = isGuru ? Colors.teal.shade700 : cs.onPrimaryContainer;
    final Color successIconBg = isGuru ? Colors.teal.shade200 : cs.onPrimaryContainer.withValues(alpha: 0.2);

    return Padding(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        bottom: 24.0,
        top: 4.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isWarning ? Colors.orange.shade200 : successIconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: isWarning ? Colors.orange.shade900 : successIconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWarning ? 'Peringatan: Sudah Absen!' : (isGuru ? 'Absen Guru Berhasil!' : 'Absen Masuk Berhasil!'),
                        style: GoogleFonts.plusJakartaSans(
                          color: isWarning ? Colors.orange.shade900 : successIconColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user['pesan'],
                        style: GoogleFonts.dmSans(
                          color: isWarning
                              ? Colors.orange.shade800
                              : cs.onPrimaryContainer.withValues(alpha: 0.75),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  user['jam'],
                  style: GoogleFonts.dmMono(
                    color: isWarning ? Colors.orange.shade900 : cs.onPrimaryContainer,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. FOTO BESAR DI KIRI
              Container(
                width: 150,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: user['foto_url'] == null
                    ? const Icon(Icons.person, color: Colors.grey, size: 50)
                    : Image.network(
                        user['foto_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
              ),
              const SizedBox(width: 16),

              // 2. IDENTITAS DI KANAN
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    Text(
                      user['nama_lengkap'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Panggilan: ${user['nama_panggilan']}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // NIS Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user['identitas'],
                        style: GoogleFonts.dmMono(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: Colors.grey.shade200,
                      thickness: 1,
                      height: 1,
                    ),
                    const SizedBox(height: 12),

                    // Info Grid (Kelas & Jam)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'KELAS',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user['kelas'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF16A34A),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'JAM ABSEN',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user['jam'],
                                style: GoogleFonts.dmMono(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STATUS',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            isWarning
                                ? const Icon(
                                    Icons.warning,
                                    color: Colors.orange,
                                    size: 12,
                                  )
                                : AnimatedBuilder(
                                    animation: _successBlinkController,
                                    builder: (ctx, child) {
                                      return Opacity(
                                        opacity:
                                            0.3 +
                                            (0.7 *
                                                _successBlinkController.value),
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF16A34A),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                            const SizedBox(width: 6),
                            Text(
                              isWarning ? 'Sudah Absen' : 'Hadir',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isWarning
                                    ? Colors.orange.shade800
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: cs.outline.withValues(alpha: 0.2), thickness: 1.5),
          const SizedBox(height: 12),

          // Dicatat Oleh (Bottom section)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.blue, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DICATAT OLEH',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      user['user_absen'],
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Operator',
                  style: GoogleFonts.dmSans(
                    color: Colors.orange.shade800,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        top: 2,
        left: 0,
        right: 0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark 
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
        children: [
          Expanded(child: _buildNavItem(0, Icons.qr_code_scanner, 'Scan QR')),
          Expanded(child: _buildNavItem(1, Icons.credit_card, 'RFID & NIS')),
          Expanded(child: _buildNavItem(2, Icons.group_add, 'Massal Santri')),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _tabController.index == index;
    return InkWell(
      onTap: () => setState(() => _tabController.index = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? (Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 4),
            if (isSelected || MediaQuery.of(context).size.width > 360)
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected 
                        ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).colorScheme.primary) 
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

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const double len = 20;

    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, 0)
        ..lineTo(len, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, len),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height)
        ..lineTo(len, size.height),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
