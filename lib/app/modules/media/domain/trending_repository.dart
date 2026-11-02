import 'media_candidate.dart';

/// Result of a trending page fetch.
final class TrendingPage {
  const TrendingPage({
    required this.items,
    required this.page,
    required this.totalPages,
  });

  final List<MediaCandidate> items;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;
}

abstract interface class TrendingRepository {
  Future<TrendingPage> getTrending({int page = 1});
}
