/// Supply keys with --dart-define at build time. Do not commit real values.
abstract final class ApiConfiguration {
  static const tmdbReadAccessToken = String.fromEnvironment(
    'TMDB_READ_ACCESS_TOKEN',
  );
  static const googleBooksApiKey = String.fromEnvironment(
    'GOOGLE_BOOKS_API_KEY',
  );
}
