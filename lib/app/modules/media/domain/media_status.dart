import 'media_type.dart';

enum MediaStatus {
  wantToWatch,
  watching,
  watched,
  wantToRead,
  reading,
  completed,
  dropped;

  bool isAllowedFor(MediaType type) => switch (type) {
    MediaType.movie || MediaType.series =>
      this == wantToWatch ||
          this == watching ||
          this == watched ||
          this == dropped,
    MediaType.book =>
      this == wantToRead ||
          this == reading ||
          this == completed ||
          this == dropped,
  };
}
