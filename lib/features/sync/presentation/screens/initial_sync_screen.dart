import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:manajemen_tahsin_app/features/sync/presentation/bloc/initial_sync_cubit.dart';
import 'package:manajemen_tahsin_app/features/sync/presentation/bloc/initial_sync_state.dart';

class InitialSyncScreen extends StatefulWidget {
  const InitialSyncScreen({super.key});

  @override
  State<InitialSyncScreen> createState() => _InitialSyncScreenState();
}

class _InitialSyncScreenState extends State<InitialSyncScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InitialSyncCubit>().runInitialSync();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<InitialSyncCubit, InitialSyncState>(
        listener: (context, state) {
          if (state is InitialSyncSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              }
            });
          }
        },
        builder: (context, state) {
          double progress = 0.0;
          String message = "Menyiapkan sesi...";
          bool isError = false;

          if (state is InitialSyncInProgress) {
            progress = state.progress;
            message = state.message;
          } else if (state is InitialSyncFailure) {
            isError = true;
            _animationController.stop();
            message = "Gagal menyinkronkan data:\n${state.error.replaceFirst('Exception: ', '')}";
          } else if (state is InitialSyncSuccess) {
            progress = 1.0;
            message = state.message;
            _animationController.stop();
          } else {
            if (!_animationController.isAnimating && !isError) {
              _animationController.repeat();
            }
          }

          return SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: RotationTransition(
                        turns: _animationController,
                        child: Icon(
                          Icons.sync_rounded,
                          size: 80,
                          color: isDark ? Colors.green[400] : Colors.green[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      'Menyinkronkan Data',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      'Mohon tunggu, kami sedang menyiapkan lingkungan offline Anda.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 48),

                    if (!isError) ...[
                      // Animated Progress Bar
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, _) => Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 10,
                                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? Colors.greenAccent : Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    message,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${(value * 100).toInt()}%',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Error State
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.red[900]?.withValues(alpha: 0.3) : Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.red[700]! : Colors.red[200]!,
                          ),
                        ),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.red[200] : Colors.red[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<InitialSyncCubit>().runInitialSync();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
