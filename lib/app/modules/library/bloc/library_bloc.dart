import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../media/domain/media_entity.dart';
import '../../media/domain/media_status.dart';
import '../../media/domain/media_type.dart';
import '../../media/domain/media_use_cases.dart';

part 'library_event.dart';
part 'library_state.dart';

final class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc(this._watchLibrary) : super(const LibraryState()) {
    on<LibraryStarted>(_onStarted);
    on<LibraryFilterChanged>(
      (event, emit) =>
          emit(state.copyWith(type: event.type, status: event.status)),
    );
    on<LibraryQueryChanged>(
      (event, emit) => emit(state.copyWith(query: event.query.trim())),
    );
    on<LibrarySortChanged>(
      (event, emit) => emit(state.copyWith(sort: event.sort)),
    );
    on<LibraryRatingChanged>(
      (event, emit) => emit(state.copyWith(minimumRating: event.minimumRating)),
    );
    on<LibraryDisplayChanged>(
      (event, emit) => emit(state.copyWith(display: event.display)),
    );
    on<_LibraryItemsChanged>((event, emit) {
      if (event.request == _request) {
        emit(
          state.copyWith(items: event.items, loading: false, clearError: true),
        );
      }
    });
    on<_LibraryFailed>((event, emit) {
      if (event.request == _request) {
        emit(state.copyWith(loading: false, errorMessage: event.message));
      }
    });
  }

  final WatchLibrary _watchLibrary;
  StreamSubscription<List<MediaEntity>>? _subscription;
  int _request = 0;

  Future<void> _onStarted(
    LibraryStarted event,
    Emitter<LibraryState> emit,
  ) async {
    final request = ++_request;
    emit(state.copyWith(items: const [], loading: true, clearError: true));
    if (_subscription != null) {
      await _subscription!.cancel();
    }
    if (request != _request) return;
    _subscription = _watchLibrary(event.userId).listen(
      (items) => add(_LibraryItemsChanged(request, items)),
      onError: (Object error) =>
          add(_LibraryFailed(request, 'Could not load your library.')),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
