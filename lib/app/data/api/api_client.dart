import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'api_response.dart';

/// The only direct HTTP boundary used by external media data sources.
final class ApiClient {
  ApiClient(
    this._client, {
    this.timeout = const Duration(seconds: 10),
    this.maxGetAttempts = 3,
    Future<void> Function(Duration)? delay,
  }) : assert(maxGetAttempts > 0),
       _delay = delay ?? Future<void>.delayed;

  final http.Client _client;
  final Duration timeout;
  final int maxGetAttempts;
  final Future<void> Function(Duration) _delay;

  Future<ApiResponse> get(Uri uri, {Map<String, String> headers = const {}}) =>
      _request('GET', uri, headers: headers);

  Future<ApiResponse> post(
    Uri uri, {
    Map<String, String> headers = const {},
    Object? body,
  }) => _request('POST', uri, headers: headers, body: body);

  Future<ApiResponse> put(
    Uri uri, {
    Map<String, String> headers = const {},
    Object? body,
  }) => _request('PUT', uri, headers: headers, body: body);

  Future<ApiResponse> delete(
    Uri uri, {
    Map<String, String> headers = const {},
  }) => _request('DELETE', uri, headers: headers);

  Future<ApiResponse> _request(
    String method,
    Uri uri, {
    required Map<String, String> headers,
    Object? body,
  }) async {
    if (uri.scheme != 'https') {
      throw const ApiConfigurationException('Secure HTTPS is required.');
    }
    final attempts = method == 'GET' ? maxGetAttempts : 1;
    for (var attempt = 1; attempt <= attempts; attempt++) {
      try {
        final request = http.Request(method, uri)
          ..headers.addAll({'Accept': 'application/json', ...headers});
        if (body != null) {
          request.headers['Content-Type'] = 'application/json';
          request.body = jsonEncode(body);
        }
        final streamed = await _client.send(request).timeout(timeout);
        final response = await http.Response.fromStream(
          streamed,
        ).timeout(timeout);
        developer.log(
          'API $method ${uri.host}${uri.path}: ${response.statusCode}',
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          if (attempt < attempts && _retryableStatus(response.statusCode)) {
            await _delay(_backoff(attempt));
            continue;
          }
          throw ApiHttpException(
            _messageForStatus(response.statusCode),
            response.statusCode,
          );
        }

        Object? data;
        try {
          final bodyText = utf8.decode(response.bodyBytes);
          if (bodyText.trim().isNotEmpty) {
            data = jsonDecode(bodyText);
          }
        } on FormatException {
          throw const ApiResponseFormatException();
        }
        return ApiResponse(
          statusCode: response.statusCode,
          data: data,
          headers: response.headers,
        );
      } on TimeoutException {
        if (attempt < attempts) {
          await _delay(_backoff(attempt));
          continue;
        }
        throw const ApiTimeoutException();
      } on http.ClientException {
        if (attempt < attempts) {
          await _delay(_backoff(attempt));
          continue;
        }
        throw const ApiNetworkException();
      }
    }
    throw StateError('Request attempts exhausted.');
  }

  bool _retryableStatus(int status) => status == 429 || status >= 500;

  Duration _backoff(int attempt) => Duration(milliseconds: 250 * attempt);

  String _messageForStatus(int status) => switch (status) {
    401 || 403 => 'This service is not authorized.',
    404 => 'The requested item was not found.',
    429 => 'The service is busy. Please try again shortly.',
    >= 500 => 'The service is temporarily unavailable.',
    _ => 'The request failed. Please try again.',
  };

  void close() => _client.close();
}
