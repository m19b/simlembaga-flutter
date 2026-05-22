import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_header_background.dart';
import 'package:manajemen_tahsin_app/core/state/indicator_settings_cubit.dart';

class PengaturanIndikatorScreen extends StatefulWidget {
  const PengaturanIndikatorScreen({super.key});

  @override
  State<PengaturanIndikatorScreen> createState() => _PengaturanIndikatorScreenState();
}

class _PengaturanIndikatorScreenState extends State<PengaturanIndikatorScreen> {
  final _onlineTextCtrl = TextEditingController();
  final _offlineTextCtrl = TextEditingController();

  // Preset Colors
  final List<Color> _presetColors = [
    Colors.green, Colors.red, Colors.blue, Colors.orange, 
    Colors.purple, Colors.teal, Colors.grey, Colors.black, Colors.transparent,
  ];

  @override
  void initState() {
    super.initState();
    final settings = context.read<IndicatorSettingsCubit>().state;
    _onlineTextCtrl.text = settings.onlineText;
    _offlineTextCtrl.text = settings.offlineText;
  }

  @override
  void dispose() {
    _onlineTextCtrl.dispose();
    _offlineTextCtrl.dispose();
    super.dispose();
  }

  void _updateSettings(IndicatorSettings newSettings) {
    context.read<IndicatorSettingsCubit>().updateSettings(newSettings);
  }

  Widget _buildColorPicker(String title, Color currentColor, ValueChanged<Color> onColorChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetColors.map((color) {
            final isSelected = currentColor.value == color.value;
            final isTransparent = color == Colors.transparent;
            return GestureDetector(
              onTap: () => onColorChanged(color),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isTransparent ? Colors.grey.shade300 : color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade400,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isTransparent 
                  ? const Icon(Icons.format_color_reset, size: 16, color: Colors.black54)
                  : (isSelected ? const Icon(Icons.check, size: 18, color: Colors.white) : null),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Stack(
          children: [
            const Positioned.fill(child: GlobalHeaderBackground()),
            AppBar(
              toolbarHeight: 48,
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: true,
              title: Text(
                'Indikator Jaringan',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<IndicatorSettingsCubit, IndicatorSettings>(
        builder: (context, settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildColorPicker("Warna Saat Online", settings.onlineColor, (c) => _updateSettings(settings.copyWith(onlineColor: c))),
                      _buildColorPicker("Warna Saat Offline", settings.offlineColor, (c) => _updateSettings(settings.copyWith(offlineColor: c))),
                      _buildColorPicker("Warna Latar Belakang (Background)", settings.backgroundColor, (c) => _updateSettings(settings.copyWith(backgroundColor: c))),

                      const Divider(),
                      
                      const Text("Transparansi (Opacity)", style: TextStyle(fontWeight: FontWeight.w600)),
                      Slider(
                        value: settings.opacity,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        label: "${(settings.opacity * 100).toInt()}%",
                        onChanged: (val) => _updateSettings(settings.copyWith(opacity: val)),
                      ),

                      const Text("Ketebalan Garis (Border Width)", style: TextStyle(fontWeight: FontWeight.w600)),
                      Slider(
                        value: settings.borderWidth,
                        min: 0.0,
                        max: 5.0,
                        divisions: 10,
                        label: settings.borderWidth.toStringAsFixed(1),
                        onChanged: (val) => _updateSettings(settings.copyWith(borderWidth: val)),
                      ),

                      const Divider(),
                      const SizedBox(height: 8),
                      
                      const Text("Teks Indikator", style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _onlineTextCtrl,
                              decoration: const InputDecoration(labelText: "Teks Online", border: OutlineInputBorder(), isDense: true),
                              onChanged: (val) => _updateSettings(settings.copyWith(onlineText: val)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _offlineTextCtrl,
                              decoration: const InputDecoration(labelText: "Teks Offline", border: OutlineInputBorder(), isDense: true),
                              onChanged: (val) => _updateSettings(settings.copyWith(offlineText: val)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset ke Pengaturan Default'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    context.read<IndicatorSettingsCubit>().resetToDefault();
                    final defaultSettings = IndicatorSettings();
                    _onlineTextCtrl.text = defaultSettings.onlineText;
                    _offlineTextCtrl.text = defaultSettings.offlineText;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dikembalikan ke pengaturan awal')));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
