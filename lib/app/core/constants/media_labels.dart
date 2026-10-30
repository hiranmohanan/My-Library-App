import '../../modules/media/domain/media_status.dart';
import '../../modules/media/domain/media_type.dart';

extension MediaTypeLabel on MediaType {
  String get label => switch (this) {
    MediaType.movie => 'Movie',
    MediaType.series => 'Series',
    MediaType.book => 'Book',
  };
}

extension MediaStatusLabel on MediaStatus {
  String get label => switch (this) {
    MediaStatus.wantToWatch => 'Want to watch',
    MediaStatus.watching => 'Watching',
    MediaStatus.watched => 'Watched',
    MediaStatus.wantToRead => 'Want to read',
    MediaStatus.reading => 'Reading',
    MediaStatus.completed => 'Completed',
    MediaStatus.dropped => 'Dropped',
  };
}
