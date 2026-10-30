part of 'search_bloc.dart';

enum SearchStatus { idle, loading, success, failure }

final class SearchState {
  const SearchState({
    this.type,
    this.query = '',
    this.results = const [],
    this.status = SearchStatus.idle,
    this.errorMessage,
    this.clearVersion = 0,
    this.partialFailure = false,
  });

  final MediaType? type;
  final String query;
  final List<MediaCandidate> results;
  final SearchStatus status;
  final String? errorMessage;
  final int clearVersion;
  final bool partialFailure;

  SearchState copyWith({
    MediaType? type,
    String? query,
    List<MediaCandidate>? results,
    SearchStatus? status,
    String? errorMessage,
    bool clearError = false,
    bool? partialFailure,
    int? clearVersion,
  }) => SearchState(
    type: type ?? this.type,
    query: query ?? this.query,
    results: results ?? this.results,
    status: status ?? this.status,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    clearVersion: clearVersion ?? this.clearVersion,
    partialFailure: partialFailure ?? this.partialFailure,
  );
}
