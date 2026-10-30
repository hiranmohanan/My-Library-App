part of 'connectivity_bloc.dart';

sealed class ConnectivityEvent {
  const ConnectivityEvent();
}

final class ConnectivityStarted extends ConnectivityEvent {
  const ConnectivityStarted();
}

final class _ConnectivityChanged extends ConnectivityEvent {
  const _ConnectivityChanged(this.online);
  final bool online;
}
