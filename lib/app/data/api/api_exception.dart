sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ApiNetworkException extends ApiException {
  const ApiNetworkException()
    : super('Check your internet connection and try again.');
}

final class ApiTimeoutException extends ApiException {
  const ApiTimeoutException()
    : super('The request took too long. Please try again.');
}

final class ApiHttpException extends ApiException {
  const ApiHttpException(super.message, this.statusCode);

  final int statusCode;
}

final class ApiResponseFormatException extends ApiException {
  const ApiResponseFormatException()
    : super('The service returned an unexpected response.');
}

final class ApiConfigurationException extends ApiException {
  const ApiConfigurationException(super.message);
}
