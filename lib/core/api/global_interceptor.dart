import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manajemen_tahsin_app/app.dart';

class GlobalInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();
  
  // Custom header name untuk CI4 Token
  static const String _authHeaderKey = 'Authorization';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Ambil token dari secure storage
    final token = await _storage.read(key: 'jwt_token');

    options.headers['Accept'] = 'application/json';
    
    // Inject token ke Header jika ada
    if (token != null && token.isNotEmpty) {
      debugPrint("Token dikirim: $token");
      options.headers[_authHeaderKey] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Jika server mengembalikan 401 Unauthorized, sesi/token habis
    if (err.response?.statusCode == 401) {
      await _handleUnauthorized();

      // Secara opsional, ubah pesan error menjadi lebih ramah
      final customError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: 'Sesi Anda telah habis, silakan login kembali.',
      );
      return handler.next(customError);
    }
    
    // Untuk error selain 401
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
