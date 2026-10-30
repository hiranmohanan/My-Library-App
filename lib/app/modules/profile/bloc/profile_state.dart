part of 'profile_bloc.dart';

final class ProfileState {
  const ProfileState({
    this.loading = false,
    this.saving = false,
    this.profile,
    this.movies = 0,
    this.series = 0,
    this.books = 0,
    this.errorMessage,
  });

  final bool loading;
  final bool saving;
  final ProfileEntity? profile;
  final int movies;
  final int series;
  final int books;
  final String? errorMessage;

  ProfileState copyWith({
    bool? loading,
    bool? saving,
    ProfileEntity? profile,
    String? errorMessage,
    bool clearError = false,
  }) => ProfileState(
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    profile: profile ?? this.profile,
    movies: movies,
    series: series,
    books: books,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
