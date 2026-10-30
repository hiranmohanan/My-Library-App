import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/network_info_service.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

final class ConnectivityBloc
    extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc(this._network) : super(const ConnectivityState()) {
    on<ConnectivityStarted>(_onStarted);
    on<_ConnectivityChanged>(
      (event, emit) => emit(
        ConnectivityState(
          status: event.online
              ? ConnectivityStatus.online
              : ConnectivityStatus.offline,
        ),
      ),
    );
  }

  final NetworkInfo _network;
  StreamSubscription<bool>? _subscription;
  int _changeCount = 0;

  Future<void> _onStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    if (_subscription != null) return;
    _subscription = _network.changes.listen((online) {
      _changeCount++;
      add(_ConnectivityChanged(online));
    });
    try {
      final online = await _network.hasConnection;
      if (_changeCount == 0) add(_ConnectivityChanged(online));
    } catch (_) {
      if (_changeCount == 0) add(const _ConnectivityChanged(false));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
