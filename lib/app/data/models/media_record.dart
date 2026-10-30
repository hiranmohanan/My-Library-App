import '../../modules/media/domain/media_candidate.dart';
import '../../modules/media/domain/media_entity.dart';
import '../../modules/media/domain/media_status.dart';
import '../../modules/media/domain/media_type.dart';

abstract final class MediaRecord {
  static Map<String, Object?> encode(MediaEntity media) => {
    'mediaType': media.mediaType.name,
    'externalSource': media.externalSource.name,
    'externalId': media.externalId,
    'title': media.title,
    if (media.posterUrl != null) 'posterUrl': media.posterUrl,
    if (media.description != null) 'description': media.description,
    if (media.language != null) 'language': media.language,
    if (media.releaseDate != null) 'releaseDate': media.releaseDate,
    'status': media.status.name,
    if (media.rating != null) 'rating': media.rating,
    if (media.notes != null) 'notes': media.notes,
    'createdAt': media.createdAt.millisecondsSinceEpoch,
    'updatedAt': media.updatedAt.millisecondsSinceEpoch,
  };

  static MediaEntity decode(String id, Map<String, Object?> value) {
    final type = MediaType.values.byName(value['mediaType'] as String);
    return MediaEntity(
      id: id,
      mediaType: type,
      externalSource: ExternalSource.values.byName(
        value['externalSource'] as String,
      ),
      externalId: value['externalId'] as String,
      title: value['title'] as String,
      posterUrl: value['posterUrl'] as String?,
      description: value['description'] as String?,
      language: value['language'] as String?,
      releaseDate: value['releaseDate'] as String?,
      status: MediaStatus.values.byName(value['status'] as String),
      rating: (value['rating'] as num?)?.toDouble(),
      notes: value['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(value['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(value['updatedAt'] as int),
    );
  }

  static MediaCandidate fromTmdb(MediaType type, Map<String, Object?> value) {
    final id = value['id'];
    final title = value[type == MediaType.movie ? 'title' : 'name'];
    if (id is! int || title is! String || title.trim().isEmpty) {
      throw const FormatException('Invalid TMDB media result.');
    }
    final posterPath = value['poster_path'];
    return MediaCandidate(
      mediaType: type,
      externalSource: ExternalSource.tmdb,
      externalId: '$id',
      title: title,
      posterUrl: posterPath is String && posterPath.startsWith('/')
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : null,
      description: value['overview'] as String?,
      language: value['original_language'] as String?,
      releaseDate:
          value[type == MediaType.movie ? 'release_date' : 'first_air_date']
              as String?,
    );
  }

  static MediaCandidate fromGoogleBooks(Map<String, Object?> value) {
    final id = value['id'];
    final info = value['volumeInfo'];
    if (id is! String || info is! Map || info['title'] is! String) {
      throw const FormatException('Invalid Google Books result.');
    }
    final images = info['imageLinks'];
    final thumbnail = images is Map ? images['thumbnail'] : null;
    return MediaCandidate(
      mediaType: MediaType.book,
      externalSource: ExternalSource.googleBooks,
      externalId: id,
      title: info['title'] as String,
      posterUrl: thumbnail is String
          ? thumbnail.replaceFirst('http://', 'https://')
          : null,
      description: info['description'] as String?,
      language: info['language'] as String?,
      releaseDate: info['publishedDate'] as String?,
    );
  }
}
