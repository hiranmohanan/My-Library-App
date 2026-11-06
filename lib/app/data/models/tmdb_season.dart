/// Summary of a TMDB TV season returned by the `/3/tv/{id}` endpoint.
final class TmdbSeason {
  const TmdbSeason({
    required this.id,
    required this.seasonNumber,
    required this.name,
    required this.episodeCount,
    this.airDate,
    this.overview,
    this.posterPath,
    this.voteAverage,
  });

  final int id;
  final int seasonNumber;
  final String name;
  final int episodeCount;
  final String? airDate;
  final String? overview;
  final String? posterPath;
  final double? voteAverage;

  String? get posterUrl => posterPath != null && posterPath!.startsWith('/')
      ? 'https://image.tmdb.org/t/p/w300$posterPath'
      : null;

  static TmdbSeason? fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final seasonNumber = json['season_number'];
    final name = json['name'];
    final episodeCount = json['episode_count'];
    if (id is! int || seasonNumber is! int || name is! String) return null;
    return TmdbSeason(
      id: id,
      seasonNumber: seasonNumber,
      name: name,
      episodeCount: episodeCount is int ? episodeCount : 0,
      airDate: json['air_date'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
    );
  }
}
