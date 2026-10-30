part of 'media_details_bloc.dart';

enum MediaDetailsStage {
  initial,
  loading,
  ready,
  saving,
  deleting,
  deleted,
  notFound,
  failure,
}

final class MediaDetailsState {
  const MediaDetailsState({
    this.stage = MediaDetailsStage.initial,
    this.item,
    this.errorMessage,
    this.editing = false,
    this.draftStatus,
    this.draftRating,
    this.draftNotes,
  });

  final MediaDetailsStage stage;
  final MediaEntity? item;
  final String? errorMessage;
  final bool editing;
  final MediaStatus? draftStatus;
  final double? draftRating;
  final String? draftNotes;

  MediaDetailsState copyWith({
    bool? editing,
    MediaStatus? draftStatus,
    Object? draftRating = _unchanged,
    Object? draftNotes = _unchanged,
  }) => MediaDetailsState(
    stage: stage,
    item: item,
    errorMessage: errorMessage,
    editing: editing ?? this.editing,
    draftStatus: draftStatus ?? this.draftStatus,
    draftRating: identical(draftRating, _unchanged)
        ? this.draftRating
        : draftRating as double?,
    draftNotes: identical(draftNotes, _unchanged)
        ? this.draftNotes
        : draftNotes as String?,
  );

  static const _unchanged = Object();
}
