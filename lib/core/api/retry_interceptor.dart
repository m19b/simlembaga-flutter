import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 1});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    int retries = err.requestOptions.extra['retries'] ?? 0;
    if (retries >= maxRetries) {
      return handler.next(err);
    }

    retries++;
    err.requestOptions.extra['retries'] = retries;

    // Delay linier: 1s, 2s, 3s
    final delay = Duration(seconds: retries);
    debugPrint('Network error. Retrying request $retries/$maxRetries in ${delay.inSeconds}s...');
    await Future.delayed(delay);

    try {
      // Gunakan DIO yang sama (sudah punya timeout & interceptor)
      // Remove own interceptor temporarily to avoid infinite recursion
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      // Let the next error pass through to retry logic again
      return onError(e, handler);
    } catch (e) {
      return handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.error is SocketException;
  }
}
