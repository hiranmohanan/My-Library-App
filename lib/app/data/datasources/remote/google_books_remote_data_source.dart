import '../../api/api_client.dart';
import '../../api/api_exception.dart';

final class GoogleBooksRemoteDataSource {
  GoogleBooksRemoteDataSource(this._client, this._apiKey);

  final ApiClient _client;
  final String _apiKey;

  String get _key {
    if (_apiKey.isEmpty) {
      throw const ApiConfigurationException('Google Books is not configured.');
    }
    return _apiKey;
  }

  Future<List<Map<String, Object?>>> searchBooks(
    String query, {
    int startIndex = 0,
    int maxResults = 20,
  }) async {
    final searchTerm = query.trim();
    if (searchTerm.isEmpty) throw ArgumentError.value(query, 'query');
    if (startIndex < 0) throw RangeError.value(startIndex, 'startIndex');
    if (maxResults < 1 || maxResults > 40) {
      throw RangeError.range(maxResults, 1, 40);
    }
    final response = await _client.get(
      Uri.https('www.googleapis.com', '/books/v1/volumes', {
        'q': searchTerm,
        'startIndex': '$startIndex',
        'maxResults': '$maxResults',
        'printType': 'books',
        'key': _key,
      }),
    );
    final items = response.requireObject()['items'];
    if (items == null) return [];
    if (items is! List) throw const ApiResponseFormatException();
    try {
      return items
          .map((item) => Map<String, Object?>.from(item as Map))
          .toList();
    } on TypeError {
      throw const ApiResponseFormatException();
    }
  }

  Future<Map<String, Object?>> bookDetails(String id) async {
    if (id.isEmpty) throw ArgumentError.value(id, 'id');
    final response = await _client.get(
      Uri(
        scheme: 'https',
        host: 'www.googleapis.com',
        pathSegments: ['books', 'v1', 'volumes', id],
        queryParameters: {'key': _key},
      ),
    );
    return response.requireObject();
  }
}
