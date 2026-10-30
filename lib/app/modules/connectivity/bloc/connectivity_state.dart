part of 'connectivity_bloc.dart';

enum ConnectivityStatus { checking, online, offline }

final class ConnectivityState {
  const ConnectivityState({this.status = ConnectivityStatus.checking});
  final ConnectivityStatus status;
  bool get isOffline => status == ConnectivityStatus.offline;
}
