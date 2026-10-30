import 'package:flutter_bloc/flutter_bloc.dart';

import '../../media/domain/media_entity.dart';
import '../../media/domain/media_offline_exception.dart';
import '../../media/domain/media_status.dart';
import '../../media/domain/media_use_cases.dart';

part 'media_details_event.dart';
part 'media_details_state.dart';

final class MediaDetailsBloc
    extends Bloc<MediaDetailsEvent, MediaDetailsState> {
  MediaDetailsBloc(
    this._get,
    this._status,
    this._rating,
    this._notes,
    this._delete, {
    UpdateMedia? update,
  }) : super(const MediaDetailsState()) {
    _update = update;
    on<MediaDetailsRequested>(_onRequested);
    on<MediaStatusChanged>(_onStatusChanged);
    on<MediaRatingChanged>(_onRatingChanged);
    on<MediaNotesChanged>(_onNotesChanged);
    on<MediaChangesSaved>(_onChangesSaved);
    on<MediaEditStarted>((event, emit) {
      final item = state.item;
      if (state.stage == MediaDetailsStage.ready && item != null) {
        emit(
          state.copyWith(
            editing: true,
            draftStatus: item.status,
            draftRating: item.rating,
            draftNotes: item.notes,
          ),
        );
      }
    });
    on<MediaEditStatusChanged>((event, emit) {
      if (state.editing && event.status.isAllowedFor(state.item!.mediaType)) {
        emit(state.copyWith(draftStatus: event.status));
      }
    });
    on<MediaEditRatingChanged>((event, emit) {
      if (state.editing) emit(state.copyWith(draftRating: event.rating));
    });
    on<MediaEditNotesChanged>((event, emit) {
      if (state.editing && (event.notes?.length ?? 0) <= 10000) {
        emit(state.copyWith(draftNotes: event.notes));
      }
    });
    on<MediaDeleteRequested>(_onDeleteRequested);
  }

  final GetMediaDetails _get;
  final UpdateStatus _status;
  final UpdateRating _rating;
  final UpdateNotes _notes;
  final DeleteMedia _delete;
  late final UpdateMedia? _update;

  Future<void> _onChangesSaved(
    MediaChangesSaved event,
    Emitter<MediaDetailsState> emit,
  ) async {
    final original = state.item;
    final update = _update;
    if (state.stage != MediaDetailsStage.ready ||
        original == null ||
        update == null) {
      return;
    }
    await _change(
      emit,
      () => update(
        event.userId,
        original.copyWith(
          status: event.status,
          rating: event.rating,
          notes: event.notes?.trim().isEmpty == true
              ? null
              : event.notes?.trim(),
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> _onRequested(
    MediaDetailsRequested event,
    Emitter<MediaDetailsState> emit,
  ) async {
    emit(const MediaDetailsState(stage: MediaDetailsStage.loading));
    try {
      final item = await _get(event.userId, event.mediaId);
      emit(
        item == null
            ? const MediaDetailsState(stage: MediaDetailsStage.notFound)
            : MediaDetailsState(stage: MediaDetailsStage.ready, item: item),
      );
    } catch (_) {
      emit(
        const MediaDetailsState(
          stage: MediaDetailsStage.failure,
          errorMessage: 'Could not load this item.',
        ),
      );
    }
  }

  Future<void> _onStatusChanged(
    MediaStatusChanged event,
    Emitter<MediaDetailsState> emit,
  ) => _change(emit, () => _status(event.userId, event.mediaId, event.status));

  Future<void> _onRatingChanged(
    MediaRatingChanged event,
    Emitter<MediaDetailsState> emit,
  ) => _change(emit, () => _rating(event.userId, event.mediaId, event.rating));

  Future<void> _onNotesChanged(
    MediaNotesChanged event,
    Emitter<MediaDetailsState> emit,
  ) => _change(emit, () => _notes(event.userId, event.mediaId, event.notes));

  Future<void> _change(
    Emitter<MediaDetailsState> emit,
    Future<MediaEntity> Function() action,
  ) async {
    if (state.stage != MediaDetailsStage.ready) return;
    final previous = state.item;
    emit(MediaDetailsState(stage: MediaDetailsStage.saving, item: previous));
    try {
      final updated = await action();
      emit(MediaDetailsState(stage: MediaDetailsStage.ready, item: updated));
    } on MediaOfflineException catch (error) {
      emit(
        MediaDetailsState(
          stage: MediaDetailsStage.ready,
          item: previous,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        MediaDetailsState(
          stage: MediaDetailsStage.ready,
          item: previous,
          errorMessage: 'Could not save changes.',
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    MediaDeleteRequested event,
    Emitter<MediaDetailsState> emit,
  ) async {
    if (state.stage != MediaDetailsStage.ready) return;
    final previous = state.item;
    emit(MediaDetailsState(stage: MediaDetailsStage.deleting, item: previous));
    try {
      await _delete(event.userId, event.mediaId);
      emit(const MediaDetailsState(stage: MediaDetailsStage.deleted));
    } on MediaOfflineException catch (error) {
      emit(
        MediaDetailsState(
          stage: MediaDetailsStage.ready,
          item: previous,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        MediaDetailsState(
          stage: MediaDetailsStage.ready,
          item: previous,
          errorMessage: 'Could not delete this item.',
        ),
      );
    }
  }
}
