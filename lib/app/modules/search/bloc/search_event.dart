part of 'search_bloc.dart';

sealed class SearchEvent {
  const SearchEvent();
}

final class SearchTypeChanged extends SearchEvent {
  const SearchTypeChanged(this.type);
  final MediaType? type;
}

final class SearchCleared extends SearchEvent {
  const SearchCleared();
}

final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);
  final String query;
}

final class SearchSubmitted extends SearchEvent {
  const SearchSubmitted();
}
