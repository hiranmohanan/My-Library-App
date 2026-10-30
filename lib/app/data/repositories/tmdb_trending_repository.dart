import '../../modules/media/domain/media_candidate.dart';
import '../../modules/media/domain/media_type.dart';
import '../../modules/media/domain/trending_repository.dart';
import '../datasources/remote/tmdb_remote_data_source.dart';
import '../models/media_record.dart';

final class TmdbTrendingRepository implements TrendingRepository {
  TmdbTrendingRepository(this._source);

  final TmdbRemoteDataSource _source;

  @override
  Future<List<MediaCandidate>> getTrending() async {
    final responses = await Future.wait([
      _source.trending('movie'),
      _source.trending('tv'),
    ]);
    final movies = responses[0]
        .where((record) => record['adult'] != true)
        .map((record) => MediaRecord.fromTmdb(MediaType.movie, record))
        .take(10)
        .toList();
    final series = responses[1]
        .where((record) => record['adult'] != true)
        .map((record) => MediaRecord.fromTmdb(MediaType.series, record))
        .take(10)
        .toList();
    return [
      for (var index = 0; index < 10; index++) ...[
        if (index < movies.length) movies[index],
        if (index < series.length) series[index],
      ],
    ];
  }
}
