import '../../../data/models/tmdb_season.dart';
import 'media_type.dart';

/// An external result that has not yet been added to a user's library.
final class MediaCandidate {
  MediaCandidate({
    required this.mediaType,
    required this.externalSource,
    required this.externalId,
    required this.title,
    this.posterUrl,
    this.backdropUrl,
    this.description,
    this.language,
    this.originalTitle,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    this.popularity,
    this.genres,
    this.status,
    this.runtime,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.tagline,
    this.homepage,
    this.originCountry,
    this.seasons,
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
  final String? backdropUrl;
  final String? description;
  final String? language;
  final String? originalTitle;
  final String? releaseDate;

  /// TMDB vote average (0–10).
  final double? voteAverage;

  /// TMDB vote count.
  final int? voteCount;

  /// TMDB popularity score.
  final double? popularity;

  /// Genre names (e.g. ['Action', 'Drama']).
  final List<String>? genres;

  /// Release / production status (e.g. 'Released', 'Ended').
  final String? status;

  /// Movie runtime in minutes.
  final int? runtime;

  /// Number of seasons (series only).
  final int? numberOfSeasons;

  /// Number of episodes (series only).
  final int? numberOfEpisodes;

  /// Tagline / short marketing text.
  final String? tagline;

  /// Official homepage URL.
  final String? homepage;

  /// Country codes of origin (e.g. ['US']).
  final List<String>? originCountry;

  /// Season summaries (series only, from TMDB detail response).
  final List<TmdbSeason>? seasons;
}
