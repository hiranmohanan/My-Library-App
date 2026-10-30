import 'media_candidate.dart';

abstract interface class TrendingRepository {
  Future<List<MediaCandidate>> getTrending();
}
