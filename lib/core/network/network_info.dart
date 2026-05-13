import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:manajemen_tahsin_app/core/api/api_service.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<InternetConnectionStatus> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    try {
      // For local server, just checking the server is faster than pinging Google
      await ApiService.checkConnection();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<InternetConnectionStatus> get onStatusChange => connectionChecker.onStatusChange;
}
