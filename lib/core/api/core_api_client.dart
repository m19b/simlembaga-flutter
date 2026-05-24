import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dio_client.dart';

/// Centralized Core API Client for performing basic HTTP requests.
/// Menggunakan DioClient dan menangani parsing error global.
class CoreApiClient {
  /// Melakukan request GET
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final client = await DioClient.dio;
      final fullUrl = '${client.options.baseUrl}api/$endpoint';
      debugPrint("rrrrrrrrrrrrrrrrrrrrrrr API_GET: $fullUrl");
      if (queryParameters != null) debugPrint("rrrrrrrrrrrrrrrrrrrrrrr PARAMS: $queryParameters");

      final response = await client.get(
        'api/$endpoint',
        queryParameters: queryParameters,
      );
      return parseResponseData(response);
    } on DioException catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  /// Melakukan request POST
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final client = await DioClient.dio;
      final fullUrl = '${client.options.baseUrl}api/$endpoint';
      debugPrint("rrrrrrrrrrrrrrrrrrrrrrr API_POST: $fullUrl");
      debugPrint("rrrrrrrrrrrrrrrrrrrrrrr BODY: $body");
      if (queryParameters != null) debugPrint("rrrrrrrrrrrrrrrrrrrrrrr QUERY: $queryParameters");

      final response = await client.post(
        'api/$endpoint',
        data: body,
        queryParameters: queryParameters,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          contentType: Headers.jsonContentType,
        ),
      );
      debugPrint("Repository: CI4 Response Status: ${response.statusCode}");
      return parseResponseData(response);
    } on DioException catch (e) {
      handleDioError(e);
      rethrow;
    }
  }

  /// Melakukan parsing standar untuk response CI4 backend.
  static Map<String, dynamic> parseResponseData(Response response) {
    final data = response.data;
    Map<String, dynamic> parsedData;

    if (data is Map<String, dynamic>) {
      parsedData = data;
    } else if (data is Map) {
      parsedData = {};
      data.forEach((key, value) {
        parsedData[key.toString()] = value;
      });
    } else {
      debugPrint("RAW RESPONSE DATA (Not a Map): $data");
      throw Exception('Format respons tidak valid: Bukan JSON Object. Raw Data: $data');
    }

    print('xxxxxxxxxxxxxxxxxxxxxxx RAW RESPONSE: $parsedData');

    final isSuccess = parsedData['status'] == 200 || parsedData['status'] == true;
    if (!isSuccess || parsedData['error'] == true) {
      throw Exception(parsedData['message'] ?? 'Gagal memproses permintaan.');
    }
    return parsedData;
  }

  /// Global Error Handler untuk DioException
  static void handleDioError(DioException e) {
    print('xxxxxxxxxxxxxxxxxxxxxxx DIO ERROR DETAIL xxxxxxxxxxxxxxxxxxxxxxx');
    print('Request URL: ${e.requestOptions.uri}');
    print('Response Data: ${e.response?.data}');
    print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');

    String humanReadableMsg = "Terjadi kesalahan jaringan.";
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      humanReadableMsg =
          "Koneksi ke server timeout. Gagal terhubung, pastikan server aktif atau IP benar.";
    } else if (e.type == DioExceptionType.connectionError) {
      humanReadableMsg =
          "Koneksi ditolak oleh server. Pastikan HP dan PC (server) terhubung di jaringan WiFi yang sama, dan IP server benar.";
    } else if (e.response != null) {
      bool messageExtracted = false;
      try {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message') && data['message'] != null) {
          humanReadableMsg = data['message'];
          messageExtracted = true;
        } else if (data is Map && data.containsKey('error') && data['error'] != null) {
          humanReadableMsg = data['error'].toString();
          messageExtracted = true;
        }
      } catch (_) {}

      if (!messageExtracted && e.response?.data != null) {
        humanReadableMsg = 'Gagal memuat data dari server. Raw Server Response:\n${e.response?.data.toString()}';
      } else if (!messageExtracted) {
        if (e.response?.statusCode == 400) {
          humanReadableMsg = "Permintaan tidak valid (400 Bad Request). Periksa isian Anda.";
        } else if (e.response?.statusCode == 401) {
          humanReadableMsg = "Sesi telah berakhir atau akses ditolak (401). Silakan login kembali.";
        } else if (e.response?.statusCode == 403) {
          humanReadableMsg = "Anda tidak memiliki izin (403 Forbidden).";
        } else if (e.response?.statusCode == 404) {
          humanReadableMsg = "Endpoint (Alamat API) tidak ditemukan di server (404).";
        } else if (e.response?.statusCode == 500) {
          humanReadableMsg = "Terjadi kesalahan sistem internal di aplikasi server (500).";
        } else {
          humanReadableMsg = "Server mengembalikan status: ${e.response?.statusCode}";
        }
      }
    } else {
      humanReadableMsg = "Tidak bisa menghubungi server sama sekali. Periksa kembali IP Server dan pastikan HP terkoneksi WiFi.";
    }

    debugPrint("=== DETAIL DIO ERROR ===");
    debugPrint("TIPE: ${e.type.name}");
    debugPrint("PESAN: ${e.message}");
    if (e.response != null) {
      debugPrint("STATUS: ${e.response?.statusCode}");
      debugPrint("BALASAN: ${e.response?.data}");
    }

    throw Exception(humanReadableMsg);
  }
}
