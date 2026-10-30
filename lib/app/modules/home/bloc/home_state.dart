part of 'home_bloc.dart';

final class HomeState {
  const HomeState({
    this.loading = false,
    this.items = const [],
    this.errorMessage,
  });

  final bool loading;
  final List<MediaEntity> items;
  final String? errorMessage;

  int count(MediaType type) =>
      items.where((item) => item.mediaType == type).length;

  List<MediaEntity> get continueWatching => items
      .where(
        (item) =>
            item.status == MediaStatus.watching ||
            item.status == MediaStatus.reading,
      )
      .toList();

  List<MediaEntity> get recentlyAdded {
    final sorted = [...items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(10).toList();
  }
}
