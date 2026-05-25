import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/core/state/indicator_settings_cubit.dart';
import 'package:manajemen_tahsin_app/core/widgets/settings_dialog.dart';
import 'package:manajemen_tahsin_app/app.dart';

class GlobalNetworkIndicator extends StatefulWidget {
  final Widget child;
  const GlobalNetworkIndicator({super.key, required this.child});

  @override
  State<GlobalNetworkIndicator> createState() => _GlobalNetworkIndicatorState();
}

class _GlobalNetworkIndicatorState extends State<GlobalNetworkIndicator> {
  late final NetworkInfo _networkInfo;

  double _pillX = 20;
  double _pillY = 120;
  bool _isPillDragged = false;
  bool _hasInitializedPos = false;

  bool _isVisible = false;
  Timer? _visibilityTimer;

  @override
  void initState() {
    super.initState();
    _networkInfo = NetworkInfoImpl(LocalNetworkChecker());
  }

  void _handleTouch() {
    _visibilityTimer?.cancel();
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }
    _visibilityTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _visibilityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IndicatorSettingsCubit, IndicatorSettings>(
      builder: (context, settings) {
        // Sinkronisasi posisi awal hanya sekali saat pengaturan berhasil diload
        if (!_hasInitializedPos && (settings.initialX != null || settings.initialY != null)) {
          _pillX = settings.initialX ?? 20;
          _pillY = settings.initialY ?? 120;
          _hasInitializedPos = true;
        }

        // Use custom settings if available, default to transparent / theme colors if not
        
        // Background color logic: if customized, use it. Else use theme's card color.
        final Color baseCardColor = settings.backgroundColor == Colors.transparent 
            ? Theme.of(context).cardColor 
            : settings.backgroundColor;

        // Apply opacity logic
        final Color cardColor = (_isPillDragged || _isVisible)
            ? baseCardColor.withValues(alpha: settings.opacity)
            : baseCardColor.withValues(alpha: 0.0);

        return StreamBuilder<LocalNetworkStatus>(
          stream: LocalNetworkChecker().onStatusChange,
          initialData: LocalNetworkChecker().currentStatus,
          builder: (context, statusSnapshot) {
            final _isOnline = statusSnapshot.data == LocalNetworkStatus.online;
            final Color indicatorColor = _isOnline ? settings.onlineColor : settings.offlineColor;
            final String indicatorText = _isOnline ? settings.onlineText : settings.offlineText;

            return Stack(
              children: [
                widget.child,
                Positioned(
                  left: _pillX,
                  top: _pillY,
                  child: GestureDetector(
                    onTap: _handleTouch,
                    onDoubleTap: () async {
                      _handleTouch();
                      await _networkInfo.checkNetworkNow();
                    },
                onLongPress: () {
                  final navContext = navigatorKey.currentContext;
                  if (navContext != null) {
                    SettingsDialog.show(navContext);
                  }
                },
                onPanStart: (_) {
                  _visibilityTimer?.cancel();
                  setState(() {
                    _isPillDragged = true;
                    _isVisible = true;
                    if (settings.initialX != null) _pillX = settings.initialX!;
                    if (settings.initialY != null) _pillY = settings.initialY!;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _pillX += details.delta.dx;
                    _pillY += details.delta.dy;
                  });
                },
                onPanEnd: (_) {
                  setState(() => _isPillDragged = false);
                  // Simpan ke memory lokal hanya saat drag selesai (onPanEnd)
                  context.read<IndicatorSettingsCubit>().savePosition(_pillX, _pillY);
                  _handleTouch();
                },
                child: SafeArea(
                  child: Material(
                    color: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: indicatorColor,
                          width: settings.borderWidth,
                        ),
                        boxShadow: (_isPillDragged || _isVisible)
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: indicatorColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            indicatorText,
                            style: TextStyle(
                              fontSize: 12,
                              color: indicatorColor,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
          },
        );
      },
    );
  }
}
