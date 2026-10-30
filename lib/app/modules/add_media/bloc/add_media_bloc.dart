import 'package:flutter_bloc/flutter_bloc.dart';

import '../../media/domain/media_candidate.dart';
import '../../media/domain/media_entity.dart';
import '../../media/domain/media_offline_exception.dart';
import '../../media/domain/media_status.dart';
import '../../media/domain/media_type.dart';
import '../../media/domain/media_use_cases.dart';

part 'add_media_event.dart';
part 'add_media_state.dart';

final class AddMediaBloc extends Bloc<AddMediaEvent, AddMediaState> {
  AddMediaBloc(this._details, this._add) : super(const AddMediaState()) {
    on<AddMediaStarted>((event, emit) => emit(AddMediaState(type: event.type)));
    on<AddMediaCandidateSelected>(
      (event, emit) => emit(
        AddMediaState(
          type: event.candidate.mediaType,
          candidate: event.candidate,
          status: _defaultStatus(event.candidate.mediaType),
        ),
      ),
    );
    on<AddMediaStatusChanged>((event, emit) {
      if (event.status.isAllowedFor(state.type)) {
        emit(state.copyWith(status: event.status, clearError: true));
      }
    });
    on<AddMediaRatingChanged>((event, emit) {
      if (event.rating == null || (event.rating! >= 0 && event.rating! <= 10)) {
        emit(state.copyWith(rating: event.rating, clearError: true));
      }
    });
    on<AddMediaNotesChanged>((event, emit) {
      if (event.notes == null || event.notes!.length <= 10000) {
        emit(state.copyWith(notes: event.notes, clearError: true));
      }
    });
    on<AddMediaDetailsRequested>(_onDetailsRequested);
    on<AddMediaSaveRequested>(_onSaveRequested);
  }

  final GetExternalDetails _details;
  final AddMedia _add;

  static MediaStatus _defaultStatus(MediaType type) =>
      type == MediaType.book ? MediaStatus.wantToRead : MediaStatus.wantToWatch;

  Future<void> _onDetailsRequested(
    AddMediaDetailsRequested event,
    Emitter<AddMediaState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final candidate = await _details(event.type, event.externalId);
      emit(
        AddMediaState(
          type: event.type,
          candidate: candidate,
          status: _defaultStatus(event.type),
        ),
      );
    } on MediaOfflineException catch (error) {
      emit(state.copyWith(loading: false, errorMessage: error.message));
    } catch (_) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: 'Could not load media details.',
        ),
      );
    }
  }

  Future<void> _onSaveRequested(
    AddMediaSaveRequested event,
    Emitter<AddMediaState> emit,
  ) async {
    final candidate = state.candidate;
    if (candidate == null || state.saving) return;
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final saved = await _add(
        event.userId,
        candidate,
        state.status,
        rating: state.rating,
        notes: state.notes?.trim().isEmpty == true ? null : state.notes?.trim(),
      );
      emit(state.copyWith(saving: false, saved: saved));
    } on DuplicateMediaException catch (error) {
      emit(state.copyWith(saving: false, errorMessage: error.message));
    } on MediaOfflineException catch (error) {
      emit(state.copyWith(saving: false, errorMessage: error.message));
    } catch (_) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: 'Could not add this item. Please try again.',
        ),
      );
    }
  }
}
