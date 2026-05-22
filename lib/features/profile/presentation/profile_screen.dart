import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:manajemen_tahsin_app/core/widgets/app_header_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers
  final _namaTampilCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfCtrl = TextEditingController();
  final _noIjazahCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Visibility toggles
  bool _obscurePass = true;
  bool _obscurePassConf = true;

  // State
  bool _isLoadingData = true;
  bool _isSaving = false;
  String? _errorMsg;
  bool _isOfflineWarning = false;

  // Data dari API
  Map<String, dynamic> _profile = {};
  Map<String, dynamic>? _guru;
  bool _isGuru = false;
  String _jenisKelamin = 'Laki-laki';

  // Foto
  File? _pickedImageFile;
  String _fotoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _namaTampilCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfCtrl.dispose();
    _noIjazahCtrl.dispose();
    _noHpCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  // â”€â”€ Load Data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingData = true;
      _errorMsg = null;
    });
    try {
      final resp = await ApiService.getProfile();
      final data = resp['data'] as Map<String, dynamic>? ?? {};
      setState(() {
        _profile = data;
        _isGuru = data['is_guru'] == true;
        _guru = data['guru'] as Map<String, dynamic>?;
        _fotoUrl = data['foto_url']?.toString() ?? '';

        _namaTampilCtrl.text = data['nama_tampil']?.toString() ?? '';
        _emailCtrl.text = data['email']?.toString() ?? '';

        if (_guru != null) {
          _noIjazahCtrl.text = _guru!['no_ijazah']?.toString() ?? '';
          _noHpCtrl.text = _guru!['no_hp']?.toString() ?? '';
          _alamatCtrl.text = _guru!['alamat']?.toString() ?? '';
          _jenisKelamin = _guru!['jenis_kelamin']?.toString() == 'Perempuan'
              ? 'Perempuan'
              : 'Laki-laki';
        }
        _isOfflineWarning = resp['is_offline_fallback'] == true;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
        _isLoadingData = false;
      });
    }
  }

  // â”€â”€ Pilih Foto â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _showPickImageOptions() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ganti Foto Profil',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _photoOption(
                      ctx: ctx,
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      color: Theme.of(context).colorScheme.primary,
                      source: ImageSource.camera,
                    ),
                    _photoOption(
                      ctx: ctx,
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      color: Theme.of(context).colorScheme.tertiary,
                      source: ImageSource.gallery,
                    ),
                    if (_pickedImageFile != null)
                      GestureDetector(
                        onTap: () {
                          setState(() => _pickedImageFile = null);
                          Navigator.pop(ctx);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.error.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: Theme.of(context).colorScheme.error,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hapus',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _photoOption({
    required BuildContext ctx,
    required IconData icon,
    required String label,
    required Color color,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () async {
        if (mounted) {
          Navigator.pop(ctx);
          // Add a small delay to let the bottom sheet close completely before opening camera/gallery
          // This often fixes the 'hang' or 'unresponsive' issue on some Android devices (MIUI/Xiaomi)
          await Future.delayed(const Duration(milliseconds: 300));

          final picker = ImagePicker();
          final picked = await picker.pickImage(
            source: source,
            imageQuality: 80,
            maxWidth: 800,
          );
          if (picked != null && mounted) {
            setState(() => _pickedImageFile = File(picked.path));
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Simpan Profil â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    try {
      final fields = <String, String>{
        'nama_tampil': _namaTampilCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        if (_passwordCtrl.text.isNotEmpty) ...{
          'password': _passwordCtrl.text,
          'password_confirm': _passwordConfCtrl.text,
        },
        if (_isGuru) ...{
          'jenis_kelamin': _jenisKelamin,
          'no_ijazah': _noIjazahCtrl.text.trim(),
          'no_hp': _noHpCtrl.text.trim(),
          'alamat': _alamatCtrl.text.trim(),
        },
      };

      await ApiService.updateProfile(
        fields: fields,
        fotoFile: _pickedImageFile,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui âœ“'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Reload data agar UI sinkron
      await _loadProfile();
      _passwordCtrl.clear();
      _passwordConfCtrl.clear();
      setState(() => _pickedImageFile = null);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Gagal Menyimpan'),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // BUILD
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    final namaGuru = _profile['nama_tampil']?.toString() ?? '-';
    final jabatan = (_guru?['nama_jabatan']?.toString().isNotEmpty ?? false)
        ? _guru!['nama_jabatan'].toString()
        : (_isGuru ? 'Guru/Staff' : 'Pengelola Sistem');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const AppHeaderBar(
        title: 'Pengaturan Profil',
        subtitle: 'Perbarui data dan akun',
      ),
      body: Column(
        children: [
          if (_isOfflineWarning)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.wifi_off_rounded, color: Colors.orange.shade800, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Anda sedang offline. Menampilkan data lokal terakhir.',
                      style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : _errorMsg != null
                ? _buildError()
                : SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildAvatarCard(namaGuru, jabatan),
                            const SizedBox(height: 16),
                            _buildAkunCard(),
                            const SizedBox(height: 16),
                            if (_isGuru) _buildDetailCard(),
                            if (_isGuru) const SizedBox(height: 16),
                            _buildReadOnlyCard(),
                            const SizedBox(height: 24),
                            _buildSaveButton(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Bagian 1: Avatar & Info Pribadi ──────────────────────────────────────────
  Widget _buildAvatarCard(String namaGuru, String jabatan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: _showPickImageOptions,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage: _pickedImageFile != null
                        ? FileImage(_pickedImageFile!) as ImageProvider
                        : (_fotoUrl.isNotEmpty ? CachedNetworkImageProvider(_fotoUrl) : null),
                    child: (_pickedImageFile == null && _fotoUrl.isEmpty)
                        ? Icon(
                            Icons.person,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showPickImageOptions,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).cardColor,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Nama
          Text(
            namaGuru,
            style: GoogleFonts.plusJakartaSans(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          // Jabatan badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              jabatan,
              style: GoogleFonts.plusJakartaSans(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_pickedImageFile != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Foto baru dipilih',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // â”€â”€ Bagian 2: Informasi Akun â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildAkunCard() {
    return _SectionCard(
      title: 'Informasi Akun',
      icon: Icons.manage_accounts_outlined,
      children: [
        _LabeledField(
          label: 'Nama Lengkap Tampilan',
          child: TextFormField(
            controller: _namaTampilCtrl,
            decoration: _inputDeco('Nama lengkap', Icons.badge_outlined),
            validator: (v) => (v == null || v.trim().length < 3)
                ? 'Minimal 3 karakter'
                : null,
          ),
        ),
        _LabeledField(
          label: 'Email Login',
          child: TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDeco('alamat@email.com', Icons.email_outlined),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email wajib diisi';
              if (!v.contains('@')) return 'Format email tidak valid';
              return null;
            },
          ),
        ),
        _LabeledField(
          label: 'Ganti Password',
          child: TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePass,
            decoration: _inputDeco('Min. 8 karakter', Icons.lock_outline)
                .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
            validator: (v) {
              if (v != null && v.isNotEmpty && v.length < 8) {
                return 'Min. 8 karakter';
              }
              return null;
            },
          ),
        ),
        _LabeledField(
          label: 'Konfirmasi Password',
          child: TextFormField(
            controller: _passwordConfCtrl,
            obscureText: _obscurePassConf,
            decoration: _inputDeco('Ulangi password', Icons.lock_outline)
                .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassConf
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassConf = !_obscurePassConf),
                  ),
                ),
            validator: (v) {
              if (_passwordCtrl.text.isNotEmpty && v != _passwordCtrl.text) {
                return 'Password tidak cocok';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // â”€â”€ Bagian 3: Detail Pribadi (Guru saja) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildDetailCard() {
    return _SectionCard(
      title: 'Detail Pribadi & Alamat',
      icon: Icons.person_outline,
      children: [
        _LabeledField(
          label: 'Nomor Ijazah',
          child: TextFormField(
            controller: _noIjazahCtrl,
            keyboardType: TextInputType.text, // Explicitly allow text/symbols
            decoration: _inputDeco('No. Ijazah', Icons.school_outlined),
            validator: (v) {
              if (_isGuru && (v == null || v.isEmpty)) return 'Wajib diisi';
              return null;
            },
          ),
        ),
        _LabeledField(
          label: 'Jenis Kelamin',
          child: DropdownButtonFormField<String>(
            value: _jenisKelamin,
            isExpanded: true, // Menghindari overflow teks
            decoration: _inputDeco('', Icons.wc_outlined).copyWith(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 14,
              ),
            ),
            items: ['Laki-laki', 'Perempuan']
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _jenisKelamin = v!),
          ),
        ),
        _LabeledField(
          label: 'Nomor HP / WhatsApp',
          child: TextFormField(
            controller: _noHpCtrl,
            keyboardType: TextInputType.phone,
            decoration: _inputDeco('08xxxxxxxxxx', Icons.phone_outlined),
          ),
        ),
        _LabeledField(
          label: 'Alamat Domisili',
          child: TextFormField(
            controller: _alamatCtrl,
            maxLines: 3,
            decoration: _inputDeco(
              'Tulis alamat tinggal...',
              Icons.location_on_outlined,
            ),
          ),
        ),
      ],
    );
  }

  // â”€â”€ Bagian 4: Info Kepegawaian (Read-Only) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildReadOnlyCard() {
    final username = _profile['username']?.toString() ?? '-';
    final nig = _guru?['nig']?.toString();
    final rfid = _guru?['rfid_code']?.toString();

    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'Informasi Kepegawaian',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'TERKUNCI',
                    style: TextStyle(
                      fontSize: 9,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _ReadOnlyRow(
            icon: Icons.account_circle_outlined,
            label: 'Username',
            value: username,
          ),
          if (nig != null)
            _ReadOnlyRow(icon: Icons.badge_outlined, label: 'NIG', value: nig),
          if (rfid != null)
            _ReadOnlyRow(
              icon: Icons.nfc_rounded,
              label: 'RFID Code',
              value: rfid.isNotEmpty ? rfid : 'Belum Terdaftar',
              valueColor: rfid.isNotEmpty ? cs.primary : cs.tertiary,
            ),
        ],
      ),
    );
  }

  // â”€â”€ Bagian 5: Tombol Simpan â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildSaveButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _simpan,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: _isSaving
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Simpan Perubahan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMsg!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(
      icon,
      size: 20,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 1.5,
      ),
    ),
  );
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Reusable Sub-widgets
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ReadOnlyRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Text(
            '$label : ',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color:
                    valueColor ??
                    Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
