import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:manajemen_tahsin_app/core/data/local_data_source.dart';
import 'package:manajemen_tahsin_app/core/network/network_info.dart';
import 'package:manajemen_tahsin_app/features/absensi/domain/repositories/absensi_repository.dart';
import 'package:manajemen_tahsin_app/features/auth/presentation/login_screen.dart';

import 'package:manajemen_tahsin_app/core/theme/app_theme.dart';
import 'package:manajemen_tahsin_app/core/theme/theme_cubit.dart';
import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:manajemen_tahsin_app/core/widgets/global_network_indicator.dart';

// Global navigator key untuk melakukan redirect tanpa Context (misal saat 401 Unauthorized)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AbsensiRepository>(
          create: (_) => AbsensiRepository(
            networkInfo: NetworkInfoImpl(InternetConnectionChecker.createInstance()),
            localDataSource: LocalDataSourceImpl(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => ActiveKelompokCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Manajemen Tahsin',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('id', 'ID'),
              Locale('en', 'US'),
            ],
            // ── Batasi skala teks agar tampil lebih rapat / ramping seperti Grab ──
            builder: (context, child) {
              return GlobalNetworkIndicator(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.of(context).textScaler.scale(1.0).clamp(0.0, 0.9),
                    ),
                  ),
                  child: child!,
                ),
              );
            },
            home: const LoginScreen(),
          );
        },
        ),
      ),
    );
  }
}

