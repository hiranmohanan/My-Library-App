part of 'library_bloc.dart';

enum LibrarySort { recentlyAdded, title, rating }

enum LibraryDisplay { list, grid }

final class LibraryState {
  const LibraryState({
    this.loading = false,
    this.items = const [],
    this.type,
    this.status,
    this.minimumRating,
    this.query = '',
    this.sort = LibrarySort.recentlyAdded,
    this.display = LibraryDisplay.grid,
    this.errorMessage,
  });

  final bool loading;
  final List<MediaEntity> items;
  final MediaType? type;
  final MediaStatus? status;
  final double? minimumRating;
  final String query;
  final LibrarySort sort;
  final LibraryDisplay display;
  final String? errorMessage;

  List<MediaEntity> get visibleItems {
    final term = query.toLowerCase();
    final result = items
        .where(
          (item) =>
              (type == null || item.mediaType == type) &&
              (status == null || item.status == status) &&
              (minimumRating == null ||
                  (item.rating != null && item.rating! >= minimumRating!)) &&
              (term.isEmpty || item.title.toLowerCase().contains(term)),
        )
        .toList();
    switch (sort) {
      case LibrarySort.recentlyAdded:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case LibrarySort.title:
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case LibrarySort.rating:
        result.sort((a, b) => (b.rating ?? -1).compareTo(a.rating ?? -1));
    }
    return result;
  }

  LibraryState copyWith({
    List<MediaEntity>? items,
    Object? type = _unchanged,
    Object? status = _unchanged,
    Object? minimumRating = _unchanged,
    String? query,
    LibrarySort? sort,
    LibraryDisplay? display,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
  }) => LibraryState(
    items: items ?? this.items,
    type: identical(type, _unchanged) ? this.type : type as MediaType?,
    status: identical(status, _unchanged)
        ? this.status
        : status as MediaStatus?,
    minimumRating: identical(minimumRating, _unchanged)
        ? this.minimumRating
        : minimumRating as double?,
    query: query ?? this.query,
    sort: sort ?? this.sort,
    display: display ?? this.display,
    loading: loading ?? this.loading,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  static const _unchanged = Object();
}
