import 'package:flutter_bloc/flutter_bloc.dart';

import '../../media/domain/media_candidate.dart';
import '../../media/domain/trending_repository.dart';

sealed class TrendingEvent {
  const TrendingEvent();
}

/// Load (or reload) the first page.
final class TrendingRequested extends TrendingEvent {
  const TrendingRequested();
}

/// Append the next page.
final class TrendingNextPageRequested extends TrendingEvent {
  const TrendingNextPageRequested();
}

final class TrendingState {
  const TrendingState({
    this.loading = false,
    this.loadingMore = false,
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.error,
  });

  final bool loading;
  final bool loadingMore;
  final List<MediaCandidate> items;

  /// Last successfully loaded page number (0 = nothing loaded yet).
  final int page;

  final bool hasMore;
  final String? error;
}

final class TrendingBloc extends Bloc<TrendingEvent, TrendingState> {
  TrendingBloc(this._repository) : super(const TrendingState()) {
    on<TrendingRequested>(_onRequested);
    on<TrendingNextPageRequested>(_onNextPage);
  }

  final TrendingRepository _repository;

  Future<void> _onRequested(
    TrendingRequested event,
    Emitter<TrendingState> emit,
  ) async {
    emit(TrendingState(loading: true));
    try {
      final result = await _repository.getTrending(page: 1);
      emit(
        TrendingState(
          items: result.items,
          page: result.page,
          hasMore: result.hasMore,
        ),
      );
    } catch (_) {
      emit(const TrendingState(error: 'Could not load trending titles.'));
    }
  }

  Future<void> _onNextPage(
    TrendingNextPageRequested event,
    Emitter<TrendingState> emit,
  ) async {
    if (state.loadingMore || !state.hasMore) return;
    emit(
      TrendingState(
        loadingMore: true,
        items: state.items,
        page: state.page,
        hasMore: state.hasMore,
      ),
    );
    try {
      final result = await _repository.getTrending(page: state.page + 1);
      emit(
        TrendingState(
          items: [...state.items, ...result.items],
          page: result.page,
          hasMore: result.hasMore,
        ),
      );
    } catch (_) {
      emit(
        TrendingState(
          items: state.items,
          page: state.page,
          hasMore: state.hasMore,
          error: 'Could not load more trending titles.',
        ),
      );
    }
  }
}
