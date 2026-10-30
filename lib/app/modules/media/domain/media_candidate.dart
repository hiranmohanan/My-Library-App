import 'media_type.dart';

/// An external result that has not yet been added to a user's library.
final class MediaCandidate {
  MediaCandidate({
    required this.mediaType,
    required this.externalSource,
    required this.externalId,
    required this.title,
    this.posterUrl,
    this.description,
    this.language,
    this.releaseDate,
  }) {
    if (externalSource != mediaType.externalSource) {
      throw ArgumentError('External source does not match media type.');
    }
    if (externalId.trim().isEmpty || externalId.length > 128) {
      throw ArgumentError.value(externalId, 'externalId');
    }
    if (title.trim().isEmpty || title.length > 500) {
      throw ArgumentError.value(title, 'title');
    }
  }

  final MediaType mediaType;
  final ExternalSource externalSource;
  final String externalId;
  final String title;
  final String? posterUrl;
  final String? description;
  final String? language;
  final String? releaseDate;
}
