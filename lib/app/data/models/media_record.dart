import '../../modules/media/domain/media_candidate.dart';
import '../../modules/media/domain/media_entity.dart';
import '../../modules/media/domain/media_status.dart';
import '../../modules/media/domain/media_type.dart';
import 'tmdb_season.dart';

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
    final backdropPath = value['backdrop_path'];

    // Genres: present as a list of maps in detail responses.
    final rawGenres = value['genres'];
    final genres = rawGenres is List
        ? rawGenres
              .whereType<Map>()
              .map((g) => g['name'])
              .whereType<String>()
              .toList()
        : null;

    // origin_country may be a List<String>.
    final rawCountry = value['origin_country'];
    final originCountry = rawCountry is List
        ? rawCountry.whereType<String>().toList()
        : null;

    // Seasons: present as a list of maps in TV detail responses.
    final rawSeasons = value['seasons'];
    final seasons = rawSeasons is List
        ? rawSeasons
              .whereType<Map>()
              .map((s) => TmdbSeason.fromJson(Map<String, Object?>.from(s)))
              .whereType<TmdbSeason>()
              .toList()
        : null;

    return MediaCandidate(
      mediaType: type,
      externalSource: ExternalSource.tmdb,
      externalId: '$id',
      title: title,
      posterUrl: posterPath is String && posterPath.startsWith('/')
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : null,
      backdropUrl: backdropPath is String && backdropPath.startsWith('/')
          ? 'https://image.tmdb.org/t/p/w780$backdropPath'
          : null,
      description: value['overview'] as String?,
      language: value['original_language'] as String?,
      originalTitle:
          value[type == MediaType.movie ? 'original_title' : 'original_name']
              as String?,
      releaseDate:
          value[type == MediaType.movie ? 'release_date' : 'first_air_date']
              as String?,
      voteAverage: (value['vote_average'] as num?)?.toDouble(),
      voteCount: (value['vote_count'] as num?)?.toInt(),
      popularity: (value['popularity'] as num?)?.toDouble(),
      genres: genres,
      status: value['status'] as String?,
      runtime: (value['runtime'] as num?)?.toInt(),
      numberOfSeasons: (value['number_of_seasons'] as num?)?.toInt(),
      numberOfEpisodes: (value['number_of_episodes'] as num?)?.toInt(),
      tagline: value['tagline'] as String?,
      homepage:
          value['homepage'] is String &&
              (value['homepage'] as String).isNotEmpty
          ? value['homepage'] as String
          : null,
      originCountry: originCountry,
      seasons: type == MediaType.series && seasons != null && seasons.isNotEmpty
          ? seasons
          : null,
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
