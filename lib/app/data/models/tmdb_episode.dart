/// Summary of a TMDB TV episode returned by the season-details endpoint.
final class TmdbEpisode {
  const TmdbEpisode({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.name,
    this.airDate,
    this.overview,
    this.runtime,
    this.stillPath,
    this.voteAverage,
    this.voteCount,
  });

  final int id;
  final int episodeNumber;
  final int seasonNumber;
  final String name;
  final String? airDate;
  final String? overview;
  final int? runtime;
  final String? stillPath;
  final double? voteAverage;
  final int? voteCount;

  String? get stillUrl => stillPath != null && stillPath!.startsWith('/')
      ? 'https://image.tmdb.org/t/p/w300$stillPath'
      : null;

  static TmdbEpisode? fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final episodeNumber = json['episode_number'];
    final seasonNumber = json['season_number'];
    final name = json['name'];
    if (id is! int ||
        episodeNumber is! int ||
        seasonNumber is! int ||
        name is! String) {
      return null;
    }
    return TmdbEpisode(
      id: id,
      episodeNumber: episodeNumber,
      seasonNumber: seasonNumber,
      name: name,
      airDate: json['air_date'] as String?,
      overview: json['overview'] as String?,
      runtime: (json['runtime'] as num?)?.toInt(),
      stillPath: json['still_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: (json['vote_count'] as num?)?.toInt(),
    );
  }
}
