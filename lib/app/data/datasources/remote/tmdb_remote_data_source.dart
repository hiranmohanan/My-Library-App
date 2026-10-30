import '../../api/api_client.dart';
import '../../api/api_exception.dart';

final class TmdbRemoteDataSource {
  TmdbRemoteDataSource(this._client, this._readAccessToken);

  final ApiClient _client;
  final String _readAccessToken;

  Map<String, String> get _headers {
    if (_readAccessToken.isEmpty) {
      throw const ApiConfigurationException('TMDB is not configured.');
    }
    return {'Authorization': 'Bearer $_readAccessToken'};
  }

  Future<List<Map<String, Object?>>> searchMovies(
    String query, {
    int page = 1,
  }) => _search('movie', query, page);

  Future<List<Map<String, Object?>>> searchSeries(
    String query, {
    int page = 1,
  }) => _search('tv', query, page);

  Future<List<Map<String, Object?>>> trending(String type) async {
    if (type != 'movie' && type != 'tv') {
      throw ArgumentError.value(type, 'type');
    }
    final response = await _client.get(
      Uri.https('api.themoviedb.org', '/3/trending/$type/day'),
      headers: _headers,
    );
    final results = response.requireObject()['results'];
    if (results is! List) throw const ApiResponseFormatException();
    try {
      return results
          .map((item) => Map<String, Object?>.from(item as Map))
          .toList();
    } on TypeError {
      throw const ApiResponseFormatException();
    }
  }

  Future<List<Map<String, Object?>>> _search(
    String type,
    String query,
    int page,
  ) async {
    final searchTerm = query.trim();
    if (searchTerm.isEmpty) throw ArgumentError.value(query, 'query');
    if (page < 1 || page > 500) throw RangeError.range(page, 1, 500);
    final response = await _client.get(
      Uri.https('api.themoviedb.org', '/3/search/$type', {
        'query': searchTerm,
        'page': '$page',
        'include_adult': 'false',
      }),
      headers: _headers,
    );
    final results = response.requireObject()['results'];
    if (results is! List) throw const ApiResponseFormatException();
    try {
      return results
          .map((item) => Map<String, Object?>.from(item as Map))
          .toList();
    } on TypeError {
      throw const ApiResponseFormatException();
    }
  }

  Future<Map<String, Object?>> movieDetails(int id) => _details('movie', id);

  Future<Map<String, Object?>> seriesDetails(int id) => _details('tv', id);

  Future<Map<String, Object?>> _details(String type, int id) async {
    if (id <= 0) throw RangeError.value(id, 'id');
    final response = await _client.get(
      Uri.https('api.themoviedb.org', '/3/$type/$id'),
      headers: _headers,
    );
    return response.requireObject();
  }
}
