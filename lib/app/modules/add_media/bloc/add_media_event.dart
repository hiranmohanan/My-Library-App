part of 'add_media_bloc.dart';

sealed class AddMediaEvent {
  const AddMediaEvent();
}

final class AddMediaStarted extends AddMediaEvent {
  const AddMediaStarted(this.type);
  final MediaType type;
}

final class AddMediaCandidateSelected extends AddMediaEvent {
  const AddMediaCandidateSelected(this.candidate);
  final MediaCandidate candidate;
}

final class AddMediaDetailsRequested extends AddMediaEvent {
  const AddMediaDetailsRequested(this.type, this.externalId);
  final MediaType type;
  final String externalId;
}

final class AddMediaStatusChanged extends AddMediaEvent {
  const AddMediaStatusChanged(this.status);
  final MediaStatus status;
}

final class AddMediaRatingChanged extends AddMediaEvent {
  const AddMediaRatingChanged(this.rating);
  final double? rating;
}

final class AddMediaNotesChanged extends AddMediaEvent {
  const AddMediaNotesChanged(this.notes);
  final String? notes;
}

final class AddMediaSaveRequested extends AddMediaEvent {
  const AddMediaSaveRequested(this.userId);
  final String userId;
}
