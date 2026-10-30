import 'media_candidate.dart';
import 'media_entity.dart';
import 'media_repository.dart';
import 'media_status.dart';
import 'media_type.dart';

final class DuplicateMediaException implements Exception {
  const DuplicateMediaException();

  String get message => 'Already in your library.';
}

final class MediaNotFoundException implements Exception {
  const MediaNotFoundException();

  String get message => 'This library item was not found.';
}

final class GetLibrary {
  GetLibrary(this._repository);

  final MediaRepository _repository;

  Future<List<MediaEntity>> call(String userId) =>
      _repository.getLibrary(userId);
}

final class WatchLibrary {
  WatchLibrary(this._repository);

  final MediaRepository _repository;

  Stream<List<MediaEntity>> call(String userId) =>
      _repository.watchLibrary(userId);
}

final class SearchMovies {
  SearchMovies(this._repository);

  final MediaRepository _repository;

  Future<List<MediaCandidate>> call(String query) =>
      _repository.searchExternal(MediaType.movie, query.trim());
}

final class SearchSeries {
  SearchSeries(this._repository);

  final MediaRepository _repository;

  Future<List<MediaCandidate>> call(String query) =>
      _repository.searchExternal(MediaType.series, query.trim());
}

final class SearchBooks {
  SearchBooks(this._repository);

  final MediaRepository _repository;

  Future<List<MediaCandidate>> call(String query) =>
      _repository.searchExternal(MediaType.book, query.trim());
}

final class GetExternalDetails {
  GetExternalDetails(this._repository);

  final MediaRepository _repository;

  Future<MediaCandidate> call(MediaType type, String externalId) =>
      _repository.getExternalDetails(type, externalId);
}

final class AddMedia {
  AddMedia(this._repository);

  final MediaRepository _repository;

  Future<MediaEntity> call(
    String userId,
    MediaCandidate candidate,
    MediaStatus status, {
    double? rating,
    String? notes,
  }) async {
    if (!status.isAllowedFor(candidate.mediaType)) {
      throw ArgumentError.value(status, 'status');
    }
    final existing = await _repository.findByExternalIdentity(
      userId,
      candidate.externalSource,
      candidate.externalId,
    );
    if (existing != null) throw const DuplicateMediaException();
    return _repository.add(
      userId,
      candidate,
      status,
      rating: rating,
      notes: notes,
    );
  }
}

final class UpdateMedia {
  UpdateMedia(this._repository);

  final MediaRepository _repository;

  Future<MediaEntity> call(String userId, MediaEntity media) =>
      _repository.update(userId, media);
}

final class DeleteMedia {
  DeleteMedia(this._repository);

  final MediaRepository _repository;

  Future<void> call(String userId, String mediaId) =>
      _repository.delete(userId, mediaId);
}

final class GetMediaDetails {
  GetMediaDetails(this._repository);

  final MediaRepository _repository;

  Future<MediaEntity?> call(String userId, String mediaId) =>
      _repository.findById(userId, mediaId);
}

final class UpdateStatus {
  UpdateStatus(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final MediaRepository _repository;
  final DateTime Function() _clock;

  Future<MediaEntity> call(
    String userId,
    String mediaId,
    MediaStatus status,
  ) async {
    final media = await _repository.findById(userId, mediaId);
    if (media == null) throw const MediaNotFoundException();
    return _repository.update(
      userId,
      media.copyWith(status: status, updatedAt: _clock()),
    );
  }
}

final class UpdateRating {
  UpdateRating(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final MediaRepository _repository;
  final DateTime Function() _clock;

  Future<MediaEntity> call(
    String userId,
    String mediaId,
    double? rating,
  ) async {
    final media = await _repository.findById(userId, mediaId);
    if (media == null) throw const MediaNotFoundException();
    return _repository.update(
      userId,
      media.copyWith(rating: rating, updatedAt: _clock()),
    );
  }
}

final class UpdateNotes {
  UpdateNotes(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final MediaRepository _repository;
  final DateTime Function() _clock;

  Future<MediaEntity> call(String userId, String mediaId, String? notes) async {
    final media = await _repository.findById(userId, mediaId);
    if (media == null) throw const MediaNotFoundException();
    return _repository.update(
      userId,
      media.copyWith(notes: notes, updatedAt: _clock()),
    );
  }
}
