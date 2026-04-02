import 'package:dio/dio.dart';
import 'package:manajemen_tahsin_app/core/constants/api_config.dart';
import 'global_interceptor.dart';

class DioClient {
  static Dio? _dio;

  static Future<Dio> get dio async {
    if (_dio != null) return _dio!;

    final baseUrl = await ApiConfig.getBaseUrl();
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ));

    // Pasang Interceptor
    _dio!.interceptors.add(GlobalInterceptor());

    return _dio!;
  }
  
  // Method untuk reset instance dio saat IP Address Server diubah di pengaturan LoginScreen
  static void reset() {
    _dio = null;
  }
}
