import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../media/domain/media_entity.dart';
import '../../media/domain/media_type.dart';
import '../../media/domain/media_status.dart';
import '../../media/domain/media_use_cases.dart';

part 'home_event.dart';
part 'home_state.dart';

final class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._watchLibrary) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<_HomeLibraryChanged>((event, emit) {
      if (event.request == _request) emit(HomeState(items: event.items));
    });
    on<_HomeFailed>((event, emit) {
      if (event.request == _request) {
        emit(HomeState(errorMessage: event.message));
      }
    });
  }

  final WatchLibrary _watchLibrary;
  StreamSubscription<List<MediaEntity>>? _subscription;
  int _request = 0;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    final request = ++_request;
    emit(const HomeState(loading: true));
    if (_subscription != null) {
      await _subscription!.cancel();
    }
    if (request != _request) return;
    _subscription = _watchLibrary(event.userId).listen(
      (items) => add(_HomeLibraryChanged(request, items)),
      onError: (Object error) =>
          add(_HomeFailed(request, 'Could not load your library.')),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
