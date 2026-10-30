enum MediaType { movie, series, book }

enum ExternalSource { tmdb, googleBooks }

extension MediaTypeSource on MediaType {
  ExternalSource get externalSource => switch (this) {
    MediaType.movie || MediaType.series => ExternalSource.tmdb,
    MediaType.book => ExternalSource.googleBooks,
  };
}
