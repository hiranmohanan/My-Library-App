import 'package:flutter_bloc/flutter_bloc.dart';

import '../../media/domain/media_candidate.dart';
import '../../media/domain/trending_repository.dart';

sealed class TrendingEvent {
  const TrendingEvent();
}

final class TrendingRequested extends TrendingEvent {
  const TrendingRequested();
}

final class TrendingState {
  const TrendingState({
    this.loading = false,
    this.items = const [],
    this.error,
  });

  final bool loading;
  final List<MediaCandidate> items;
  final String? error;
}

final class TrendingBloc extends Bloc<TrendingEvent, TrendingState> {
  TrendingBloc(this._repository) : super(const TrendingState()) {
    on<TrendingRequested>((event, emit) async {
      emit(TrendingState(loading: true, items: state.items));
      try {
        emit(TrendingState(items: await _repository.getTrending()));
      } catch (_) {
        emit(
          TrendingState(
            items: state.items,
            error: 'Could not load trending titles.',
          ),
        );
      }
    });
  }

  final TrendingRepository _repository;
}
