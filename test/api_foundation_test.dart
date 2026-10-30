import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_library_app/app/data/api/api_client.dart';
import 'package:my_library_app/app/data/api/api_exception.dart';
import 'package:my_library_app/app/data/datasources/remote/google_books_remote_data_source.dart';
import 'package:my_library_app/app/data/datasources/remote/tmdb_remote_data_source.dart';
import 'package:my_library_app/app/data/repositories/tmdb_trending_repository.dart';
import 'package:my_library_app/app/modules/media/domain/media_type.dart';

void main() {
  final uri = Uri.https('example.com', '/data');

  test('GET retries a temporary failure and parses JSON', () async {
    var calls = 0;
    final client = ApiClient(
      MockClient((_) async {
        calls++;
        return calls == 1
            ? http.Response('unavailable', 503)
            : http.Response('{"items":[1]}', 200);
      }),
      delay: (_) async {},
    );
    addTearDown(client.close);

    expect((await client.get(uri)).requireObject()['items'], [1]);
    expect(calls, 2);
  });

  test('POST does not retry, even on server failure', () async {
    var calls = 0;
    final client = ApiClient(
      MockClient((_) async {
        calls++;
        return http.Response('unavailable', 503);
      }),
      delay: (_) async {},
    );
    addTearDown(client.close);

    await expectLater(
      client.post(uri, body: {'title': 'Example'}),
      throwsA(
        isA<ApiHttpException>().having((e) => e.statusCode, 'status', 503),
      ),
    );
    expect(calls, 1);
  });

  test('timeout and invalid JSON become app exceptions', () async {
    final slow = ApiClient(
      MockClient((_) => Completer<http.Response>().future),
      timeout: const Duration(milliseconds: 5),
      maxGetAttempts: 2,
      delay: (_) async {},
    );
    addTearDown(slow.close);
    await expectLater(slow.get(uri), throwsA(isA<ApiTimeoutException>()));

    final malformed = ApiClient(
      MockClient((_) async => http.Response('{broken', 200)),
    );
    addTearDown(malformed.close);
    await expectLater(
      malformed.get(uri),
      throwsA(isA<ApiResponseFormatException>()),
    );
  });

  test('TMDB and Google Books parse their search results', () async {
    final client = ApiClient(
      MockClient((request) async {
        if (request.url.host == 'api.themoviedb.org') {
          expect(request.headers['Authorization'], 'Bearer tmdb-test-token');
          expect(request.url.path, '/3/search/movie');
          expect(request.url.queryParameters['query'], 'Arrival');
          return http.Response('{"results":[{"id":1,"title":"Arrival"}]}', 200);
        }
        expect(request.url.host, 'www.googleapis.com');
        expect(request.url.queryParameters['key'], 'books-test-key');
        return http.Response('{"items":[{"id":"book-1"}]}', 200);
      }),
    );
    addTearDown(client.close);
    final tmdb = TmdbRemoteDataSource(client, 'tmdb-test-token');
    final books = GoogleBooksRemoteDataSource(client, 'books-test-key');

    expect((await tmdb.searchMovies('Arrival')).single['title'], 'Arrival');
    expect((await books.searchBooks('Dune')).single['id'], 'book-1');
  });

  test('provider without configuration fails before sending', () async {
    var calls = 0;
    final client = ApiClient(
      MockClient((_) async {
        calls++;
        return http.Response('{}', 200);
      }),
    );
    addTearDown(client.close);

    await expectLater(
      TmdbRemoteDataSource(client, '').searchMovies('Arrival'),
      throwsA(isA<ApiConfigurationException>()),
    );
    expect(calls, 0);
  });

  test('trending mixes TMDB movies and series', () async {
    final client = ApiClient(
      MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer test-token');
        if (request.url.path == '/3/trending/movie/day') {
          return http.Response('{"results":[{"id":1,"title":"Film"}]}', 200);
        }
        expect(request.url.path, '/3/trending/tv/day');
        return http.Response('{"results":[{"id":2,"name":"Series"}]}', 200);
      }),
    );
    addTearDown(client.close);
    final trending = TmdbTrendingRepository(
      TmdbRemoteDataSource(client, 'test-token'),
    );
    final items = await trending.getTrending();
    expect(items.map((item) => item.mediaType), [
      MediaType.movie,
      MediaType.series,
    ]);
    expect(items.map((item) => item.title), ['Film', 'Series']);
  });
}
