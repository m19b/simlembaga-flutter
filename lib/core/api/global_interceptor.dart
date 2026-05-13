import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manajemen_tahsin_app/app.dart';

import 'package:manajemen_tahsin_app/core/state/active_kelompok_cubit.dart';

class GlobalInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();
  
  // Custom header name untuk CI4 Token
  static const String _authHeaderKey = 'Authorization';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Ambil token dari secure storage
    final token = await _storage.read(key: 'jwt_token');

    options.headers['Accept'] = 'application/json';
    
    // Inject Multi-Tenancy Kelompok ID
    if (ActiveKelompokCubit.activeKelompokId > 0) {
      options.headers['X-Active-Kelompok'] = ActiveKelompokCubit.activeKelompokId.toString();
    }
    
    // Inject token ke Header jika ada
    if (token != null && token.isNotEmpty) {
      debugPrint("Token dikirim: $token");
      options.headers[_authHeaderKey] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Periksa apakah ini sedang memanggil jalur login
    final isLoginRequest = err.requestOptions.path.contains('/login');

    // Jika server mengembalikan 401 Unauthorized dan BUKAN sedang login, berarti sesi/token habis
    if (err.response?.statusCode == 401 && !isLoginRequest) {
      try {
        final dio = Dio(BaseOptions(baseUrl: err.requestOptions.baseUrl));
        // Try Silent Refresh
        final response = await dio.post('api/refresh');
        if (response.statusCode == 200 && response.data != null) {
           final newToken = response.data['data'] != null ? response.data['data']['token'] : response.data['token'];
           if (newToken != null) {
              await _storage.write(key: 'jwt_token', value: newToken);
              err.requestOptions.headers[_authHeaderKey] = 'Bearer $newToken';
              final retryResponse = await dio.fetch(err.requestOptions);
              return handler.resolve(retryResponse);
           } else {
              await _handleUnauthorized();
           }
        } else {
           await _handleUnauthorized();
        }
      } catch (_) {
         await _handleUnauthorized();
      }

      // Ubah pesan error menjadi lebih ramah agar tidak diproses lagi oleh penangkap standar
      final customError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: 'Sesi Anda telah habis, silakan login kembali.',
      );
      return handler.next(customError);
    }
    
    // Untuk error selain 401, ATAU error 401 yang terjadi saat login (karena password salah), lepaskan
    return handler.next(err);
  }

  /// Eksekusi pembersihan dan pemaksaan logout saat 401 terjadi
  Future<void> _handleUnauthorized() async {
    try {
      // 1. Hapus token dari secure storage
      await _storage.delete(key: 'jwt_token');

      // 2. Hapus state user dari shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('LOGGED_IN_USER');

      // 3. Maksa redirect ke LoginScreen via global navigatorKey
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Karena `navigatorKey` ada di MaterialApp, path minimal /login atau widget LoginScreen
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        
        // Tampilkan Snackbar pemberitahuan sesi habis
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sesi Anda telah habis, silakan login kembali.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error handling 401 Unauthorized: \$e');
    }
  }
}
