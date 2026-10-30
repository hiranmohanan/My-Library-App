final class MediaOfflineException implements Exception {
  const MediaOfflineException();

  String get message =>
      "You're offline. Connect to the internet to perform this action.";
}
