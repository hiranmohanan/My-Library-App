import 'package:flutter_bloc/flutter_bloc.dart';

import '../../media/domain/media_candidate.dart';
import '../../media/domain/media_use_cases.dart';

final class CandidateDetailsState {
  const CandidateDetailsState(
    this.candidate, {
    this.loading = false,
    this.error,
  });

  final MediaCandidate candidate;
  final bool loading;
  final String? error;
}

final class CandidateDetailsCubit extends Cubit<CandidateDetailsState> {
  CandidateDetailsCubit(this._get, MediaCandidate candidate)
    : super(CandidateDetailsState(candidate));

  final GetExternalDetails _get;

  Future<void> load() async {
    emit(CandidateDetailsState(state.candidate, loading: true));
    try {
      final item = await _get(
        state.candidate.mediaType,
        state.candidate.externalId,
      );
      if (!isClosed) emit(CandidateDetailsState(item));
    } catch (_) {
      if (!isClosed) {
        emit(
          CandidateDetailsState(
            state.candidate,
            error: 'Showing the available result details.',
          ),
        );
      }
    }
  }
}
