import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../media/domain/media_candidate.dart';
import '../../media/domain/media_type.dart';
import '../../media/domain/media_use_cases.dart';

part 'search_event.dart';
part 'search_state.dart';

final class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._movies, this._series, this._books)
    : super(const SearchState()) {
    on<SearchTypeChanged>((event, emit) {
      _debounce?.cancel();
      _request++;
      emit(
        SearchState(
          type: event.type,
          query: state.query,
          clearVersion: state.clearVersion,
        ),
      );
      if (state.query.trim().isNotEmpty) add(const SearchSubmitted());
    });
    on<SearchQueryChanged>((event, emit) {
      _request++;
      _debounce?.cancel();
      emit(
        state.copyWith(
          query: event.query,
          results: const [],
          status: SearchStatus.idle,
          clearError: true,
        ),
      );
      if (event.query.trim().isNotEmpty) {
        _debounce = Timer(
          const Duration(milliseconds: 400),
          () => add(const SearchSubmitted()),
        );
      }
    });
    on<SearchCleared>((event, emit) {
      _debounce?.cancel();
      _request++;
      emit(SearchState(type: state.type, clearVersion: state.clearVersion + 1));
    });
    on<SearchSubmitted>(_onSubmitted);
  }

  final SearchMovies _movies;
  final SearchSeries _series;
  final SearchBooks _books;
  int _request = 0;
  Timer? _debounce;

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  Future<void> _onSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    _debounce?.cancel();
    final query = state.query.trim();
    if (query.isEmpty) {
      emit(
        state.copyWith(
          results: const [],
          status: SearchStatus.idle,
          clearError: true,
        ),
      );
      return;
    }
    final request = ++_request;
    final type = state.type;
    emit(state.copyWith(status: SearchStatus.loading, clearError: true));
    try {
      if (type == null) {
        final responses = await Future.wait([
          _movies(
            query,
          ).then<Object>((value) => value).catchError((Object error) => error),
          _series(
            query,
          ).then<Object>((value) => value).catchError((Object error) => error),
          _books(
            query,
          ).then<Object>((value) => value).catchError((Object error) => error),
        ]);
        final results = responses
            .whereType<List<MediaCandidate>>()
            .expand((items) => items)
            .toList();
        if (results.isEmpty &&
            responses.every((item) => item is! List<MediaCandidate>)) {
          throw responses.first;
        }
        if (request == _request) {
          emit(
            state.copyWith(
              results: results,
              status: SearchStatus.success,
              partialFailure: responses.any(
                (item) => item is! List<MediaCandidate>,
              ),
            ),
          );
        }
        return;
      }
      final results = switch (type) {
        MediaType.movie => await _movies(query),
        MediaType.series => await _series(query),
        MediaType.book => await _books(query),
      };
      if (request == _request) {
        emit(
          state.copyWith(
            results: results,
            status: SearchStatus.success,
            partialFailure: false,
          ),
        );
      }
    } catch (error) {
      if (request == _request) {
        emit(
          state.copyWith(
            status: SearchStatus.failure,
            errorMessage: _message(error),
          ),
        );
      }
    }
  }

  String _message(Object error) {
    try {
      final value = (error as dynamic).message;
      if (value is String) return value;
    } catch (_) {}
    return 'Search failed. Please try again.';
  }
}
