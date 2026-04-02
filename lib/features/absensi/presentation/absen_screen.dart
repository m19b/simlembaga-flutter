import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bottom.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:manajemen_tahsin_app/core/constants/api_config.dart';
import 'package:manajemen_tahsin_app/features/absensi/presentation/bottom.dart';

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
      final res = await ApiService.scanAbsen(cleanCode, 'masuk');
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

      _tts.speak(
        isAlreadyAbsent ? '$namaPanggilan sudah absen' : '$namaPanggilan hadir',
      );
    } catch (e) {
      _handleScanError(e, isFromCamera);
    } finally {
      if (mounted) {
        _rfidController.clear();
        _manualController.clear();
      }
    }
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
    if (_tabController.index == 2) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: _buildCustomAppBar(),
        body: const AbsenMassalTab(),
        bottomNavigationBar: _buildCustomBottomNav(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      // 🔴 KUNCI ANTI GETAR UTAMA: Jangan pernah menyusutkan UI karena keyboard!
      // Karena posisi input text kita ada di atas (aman dari tertutup keyboard),
      // Mematikan resize ini akan membuat UI 100% kaku/stabil saat keyboard muncul.
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
    return AppBar(
      backgroundColor: const Color(0xFF0F4C2A),
      elevation: 0,
      title: Text(
        'Scanner Absensi',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.13),
            borderRadius: BorderRadius.circular(11),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        if (_tabController.index == 0) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13),
                borderRadius: BorderRadius.circular(11),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.refresh, size: 20, color: Colors.white),
                tooltip: "Reset Kamera",
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
            padding: const EdgeInsets.only(
              right: 18.0,
              top: 10.0,
              bottom: 10.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13),
                borderRadius: BorderRadius.circular(11),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.flash_on, size: 20, color: Colors.white),
                tooltip: "Senter",
                onPressed: () => _cameraController.toggleTorch(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCameraViewport() {
    return SizedBox(
      height: 240,
      width: double.infinity,
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
                                color: const Color(0xFF22C55E).withOpacity(0.5),
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _rfidController,
            focusNode: _rfidFocusNode,
            keyboardType: TextInputType.none,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              hintText: 'Tap RFID Scanner...',
              hintStyle: GoogleFonts.dmSans(fontSize: 13),
              prefixIcon: const Icon(
                Icons.contactless,
                color: Color(0xFF0F4C2A),
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (val) => _processScan(val),
          ),
          const SizedBox(height: 12),
          Autocomplete<Map<String, dynamic>>(
            optionsBuilder: (TextEditingValue textEditingValue) async {
              if (textEditingValue.text.length < 2) {
                return const Iterable<Map<String, dynamic>>.empty();
              }
              try {
                final results = await ApiService.cariSantri(
                  textEditingValue.text,
                );
                return results.cast<Map<String, dynamic>>();
              } catch (e) {
                return const Iterable<Map<String, dynamic>>.empty();
              }
            },
            displayStringForOption: (option) => option['nis'].toString(),
            onSelected: (option) {
              _processScan(option['nis'].toString());
            },
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      hintText: 'Cari Nama Santri / Input ID Manual...',
                      hintStyle: GoogleFonts.dmSans(fontSize: 13),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF0F4C2A),
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xFF16A34A),
                          size: 18,
                        ),
                        onPressed: () {
                          _processScan(textEditingController.text);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
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
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(
                            option['nama_santri'] ?? '',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'NIS: ${option['nis']}',
                            style: GoogleFonts.dmMono(
                              fontSize: 12,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

    final Color bgColor = isWarning
        ? Colors.orange.shade50
        : const Color(0xFF0F4C2A);
    final IconData statusIcon = isWarning ? Icons.info_outline : Icons.check;

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
                    color: isWarning
                        ? Colors.orange.shade200
                        : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: isWarning ? Colors.orange.shade900 : Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWarning
                            ? 'Peringatan: Sudah Absen!'
                            : 'Absen Masuk Berhasil!',
                        style: GoogleFonts.plusJakartaSans(
                          color: isWarning
                              ? Colors.orange.shade900
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user['pesan'],
                        style: GoogleFonts.dmSans(
                          color: isWarning
                              ? Colors.orange.shade800
                              : Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  user['jam'],
                  style: GoogleFonts.dmMono(
                    color: isWarning ? Colors.orange.shade900 : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade200,
                ),
                clipBehavior: Clip.hardEdge,
                child: user['foto_url'] == null
                    ? const Icon(Icons.person, color: Colors.grey, size: 30)
                    : Image.network(
                        user['foto_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.person, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['nama_lengkap'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Panggilan: ${user['nama_panggilan']}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user['identitas'],
                  style: GoogleFonts.dmMono(
                    color: const Color(0xFF166534),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade200, thickness: 1.5),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                  const SizedBox(height: 4),
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
              Column(
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
                  const SizedBox(height: 4),
                  Text(
                    user['jam'],
                    style: GoogleFonts.dmMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
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
                  const SizedBox(height: 4),
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
                                      (0.7 * _successBlinkController.value),
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
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.blue, size: 18),
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
                        fontSize: 13,
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
                    fontSize: 11,
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
        bottom: MediaQuery.of(context).padding.bottom + 6,
        top: 10,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.qr_code_scanner, 'Scan QR'),
          _buildNavItem(1, Icons.credit_card, 'RFID & NIS'),
          _buildNavItem(2, Icons.group_add, 'Massal Santri'),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF16A34A) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF166534) : Colors.grey,
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
