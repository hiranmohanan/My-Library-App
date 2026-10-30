part of 'add_media_bloc.dart';

final class AddMediaState {
  const AddMediaState({
    this.type = MediaType.movie,
    this.candidate,
    this.status = MediaStatus.wantToWatch,
    this.rating,
    this.notes,
    this.loading = false,
    this.saving = false,
    this.saved,
    this.errorMessage,
  });

  final MediaType type;
  final MediaCandidate? candidate;
  final MediaStatus status;
  final double? rating;
  final String? notes;
  final bool loading;
  final bool saving;
  final MediaEntity? saved;
  final String? errorMessage;

  AddMediaState copyWith({
    bool? loading,
    bool? saving,
    MediaStatus? status,
    Object? rating = _unchanged,
    Object? notes = _unchanged,
    MediaEntity? saved,
    String? errorMessage,
    bool clearError = false,
  }) => AddMediaState(
    type: type,
    candidate: candidate,
    status: status ?? this.status,
    rating: identical(rating, _unchanged) ? this.rating : rating as double?,
    notes: identical(notes, _unchanged) ? this.notes : notes as String?,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  static const _unchanged = Object();
}
