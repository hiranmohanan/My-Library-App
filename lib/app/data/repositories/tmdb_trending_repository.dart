import '../../modules/media/domain/media_type.dart';
import '../../modules/media/domain/trending_repository.dart';
import '../datasources/remote/tmdb_remote_data_source.dart';
import '../models/media_record.dart';

final class TmdbTrendingRepository implements TrendingRepository {
  TmdbTrendingRepository(this._source);

  final TmdbRemoteDataSource _source;

  @override
  Future<TrendingPage> getTrending({int page = 1}) async {
    final responses = await Future.wait([
      _source.trending('movie', page: page),
      _source.trending('tv', page: page),
    ]);
    final movies = responses[0]
        .where((record) => record['adult'] != true)
        .map((record) => MediaRecord.fromTmdb(MediaType.movie, record))
        .toList();
    final series = responses[1]
        .where((record) => record['adult'] != true)
        .map((record) => MediaRecord.fromTmdb(MediaType.series, record))
        .toList();

    // Interleave movies and series for the first page (home preview).
    // For page > 1 in the "See All" view, just append all items.
    final items = page == 1
        ? [
            for (var i = 0; i < 10; i++) ...[
              if (i < movies.length) movies[i],
              if (i < series.length) series[i],
            ],
          ]
        : [...movies, ...series];

    // TMDB trending endpoint returns 500 pages max; we merge two feeds so cap
    // at a reasonable number.
    const totalPages = 20;

    return TrendingPage(items: items, page: page, totalPages: totalPages);
  }
}
