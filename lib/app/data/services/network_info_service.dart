import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports network transport availability. HTTP can still fail on an active
/// transport, so callers must also handle ApiNetworkException and timeouts.
abstract interface class NetworkInfo {
  Future<bool> get hasConnection;

  Stream<bool> get changes;
}

final class ConnectivityNetworkInfo implements NetworkInfo {
  ConnectivityNetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get hasConnection async =>
      _hasTransport(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get changes =>
      _connectivity.onConnectivityChanged.map(_hasTransport).distinct();

  bool _hasTransport(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
