
import 'package:manajemen_tahsin_app/core/network/local_network_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<LocalNetworkStatus> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  final LocalNetworkChecker localNetworkChecker;

  NetworkInfoImpl(this.localNetworkChecker);

  @override
  Future<bool> get isConnected async {
    return await localNetworkChecker.checkConnection();
  }

  @override
  Stream<LocalNetworkStatus> get onStatusChange => localNetworkChecker.onStatusChange;
}
