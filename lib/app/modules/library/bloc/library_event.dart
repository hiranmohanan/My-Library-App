part of 'library_bloc.dart';

sealed class LibraryEvent {
  const LibraryEvent();
}

final class LibraryStarted extends LibraryEvent {
  const LibraryStarted(this.userId);
  final String userId;
}

final class LibraryFilterChanged extends LibraryEvent {
  const LibraryFilterChanged({this.type, this.status});
  final MediaType? type;
  final MediaStatus? status;
}

final class LibraryQueryChanged extends LibraryEvent {
  const LibraryQueryChanged(this.query);
  final String query;
}

final class LibrarySortChanged extends LibraryEvent {
  const LibrarySortChanged(this.sort);
  final LibrarySort sort;
}

final class LibraryRatingChanged extends LibraryEvent {
  const LibraryRatingChanged(this.minimumRating);
  final double? minimumRating;
}

final class LibraryDisplayChanged extends LibraryEvent {
  const LibraryDisplayChanged(this.display);
  final LibraryDisplay display;
}

final class _LibraryItemsChanged extends LibraryEvent {
  const _LibraryItemsChanged(this.request, this.items);
  final int request;
  final List<MediaEntity> items;
}

final class _LibraryFailed extends LibraryEvent {
  const _LibraryFailed(this.request, this.message);
  final int request;
  final String message;
}
