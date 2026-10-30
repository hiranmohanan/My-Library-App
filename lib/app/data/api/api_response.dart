import 'api_exception.dart';

final class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    required this.data,
    required this.headers,
  });

  final int statusCode;
  final Object? data;
  final Map<String, String> headers;

  Map<String, Object?> requireObject() {
    final value = data;
    if (value is! Map) throw const ApiResponseFormatException();
    try {
      return Map<String, Object?>.from(value);
    } on TypeError {
      throw const ApiResponseFormatException();
    }
  }
}
