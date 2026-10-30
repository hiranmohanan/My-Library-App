part of 'media_details_bloc.dart';

sealed class MediaDetailsEvent {
  const MediaDetailsEvent();
}

final class MediaDetailsRequested extends MediaDetailsEvent {
  const MediaDetailsRequested(this.userId, this.mediaId);
  final String userId;
  final String mediaId;
}

final class MediaStatusChanged extends MediaDetailsEvent {
  const MediaStatusChanged(this.userId, this.mediaId, this.status);
  final String userId;
  final String mediaId;
  final MediaStatus status;
}

final class MediaRatingChanged extends MediaDetailsEvent {
  const MediaRatingChanged(this.userId, this.mediaId, this.rating);
  final String userId;
  final String mediaId;
  final double? rating;
}

final class MediaNotesChanged extends MediaDetailsEvent {
  const MediaNotesChanged(this.userId, this.mediaId, this.notes);
  final String userId;
  final String mediaId;
  final String? notes;
}

final class MediaChangesSaved extends MediaDetailsEvent {
  const MediaChangesSaved(
    this.userId,
    this.mediaId,
    this.status,
    this.rating,
    this.notes,
  );
  final String userId;
  final String mediaId;
  final MediaStatus status;
  final double? rating;
  final String? notes;
}

final class MediaEditStarted extends MediaDetailsEvent {
  const MediaEditStarted();
}

final class MediaEditStatusChanged extends MediaDetailsEvent {
  const MediaEditStatusChanged(this.status);
  final MediaStatus status;
}

final class MediaEditRatingChanged extends MediaDetailsEvent {
  const MediaEditRatingChanged(this.rating);
  final double? rating;
}

final class MediaEditNotesChanged extends MediaDetailsEvent {
  const MediaEditNotesChanged(this.notes);
  final String? notes;
}

final class MediaDeleteRequested extends MediaDetailsEvent {
  const MediaDeleteRequested(this.userId, this.mediaId);
  final String userId;
  final String mediaId;
}
