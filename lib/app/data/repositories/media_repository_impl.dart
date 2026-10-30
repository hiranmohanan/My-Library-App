import 'dart:async';
import 'dart:convert';

import '../../modules/media/domain/media_candidate.dart';
import '../../modules/media/domain/media_entity.dart';
import '../../modules/media/domain/media_offline_exception.dart';
import '../../modules/media/domain/media_repository.dart';
import '../../modules/media/domain/media_status.dart';
import '../../modules/media/domain/media_type.dart';
import '../../modules/media/domain/media_use_cases.dart';
import '../api/api_exception.dart';
import '../datasources/media_local_data_source.dart';
import '../datasources/remote/firebase_media_data_source.dart';
import '../datasources/remote/google_books_remote_data_source.dart';
import '../datasources/remote/tmdb_remote_data_source.dart';
import '../models/media_record.dart';
import '../services/network_info_service.dart';

final class MediaAuthenticationException implements Exception {
  const MediaAuthenticationException();

  String get message => 'Sign in again to access your library.';
}

final class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl({
    required MediaLocalDataSource local,
    required RemoteMediaDataSource remote,
    required NetworkInfo network,
    required String? Function() currentUserId,
    TmdbRemoteDataSource? tmdb,
    GoogleBooksRemoteDataSource? googleBooks,
    DateTime Function()? clock,
  }) : _local = local,
       _remote = remote,
       _network = network,
       _currentUserId = currentUserId,
       _tmdb = tmdb,
       _googleBooks = googleBooks,
       _clock = clock ?? DateTime.now;

  final MediaLocalDataSource _local;
  final RemoteMediaDataSource _remote;
  final NetworkInfo _network;
  final String? Function() _currentUserId;
  final TmdbRemoteDataSource? _tmdb;
  final GoogleBooksRemoteDataSource? _googleBooks;
  final DateTime Function() _clock;

  void _requireUser(String userId) {
    if (userId.isEmpty || _currentUserId() != userId) {
      throw const MediaAuthenticationException();
    }
  }

  Future<void> _requireOnline() async {
    if (!await _network.hasConnection) throw const MediaOfflineException();
  }

  List<MediaEntity> _decode(Map<String, Map<String, Object?>> records) {
    final items = records.entries
        .map((entry) => MediaRecord.decode(entry.key, entry.value))
        .toList();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  Future<List<MediaEntity>> _refresh(String userId) async {
    _requireUser(userId);
    final records = await _remote.readAll();
    _requireUser(userId);
    final items = _decode(records);
    await _local.replaceAll(userId, records);
    return items;
  }

  @override
  Future<List<MediaEntity>> getLibrary(String userId) async {
    _requireUser(userId);
    final cached = _decode(await _local.readAll(userId));
    if (!await _network.hasConnection) return cached;
    if (cached.isNotEmpty) {
      unawaited(_refresh(userId).catchError((Object _) => <MediaEntity>[]));
      return cached;
    }
    try {
      return await _refresh(userId);
    } catch (_) {
      return cached;
    }
  }

  @override
  Stream<List<MediaEntity>> watchLibrary(String userId) {
    _requireUser(userId);
    late StreamController<List<MediaEntity>> controller;
    StreamSubscription<bool>? connectivitySubscription;
    StreamSubscription<Map<String, Map<String, Object?>>>? remoteSubscription;
    bool? connected;
    var generation = 0;

    Future<void> setConnection(bool online) async {
      if (connected == online || controller.isClosed) return;
      connected = online;
      final currentGeneration = ++generation;
      await remoteSubscription?.cancel();
      remoteSubscription = null;
      if (!online || controller.isClosed) return;

      try {
        final items = await _refresh(userId);
        if (currentGeneration != generation || controller.isClosed) return;
        controller.add(items);
        remoteSubscription = _remote.watchAll().listen(
          (records) async {
            if (currentGeneration != generation || controller.isClosed) return;
            try {
              _requireUser(userId);
              final refreshed = _decode(records);
              await _local.replaceAll(userId, records);
              if (currentGeneration == generation && !controller.isClosed) {
                controller.add(refreshed);
              }
            } catch (_) {
              // Keep the last valid cached library if a remote snapshot fails.
            }
          },
          onError: (Object _) {
            // Connectivity changes will retry; cached entries remain visible.
          },
        );
      } catch (_) {
        // A failed refresh must not hide the cached library.
      }
    }

    Future<void> initialize() async {
      try {
        _requireUser(userId);
        controller.add(_decode(await _local.readAll(userId)));
        connectivitySubscription = _network.changes.listen(
          (online) => unawaited(setConnection(online)),
        );
        final initial = await _network.hasConnection;
        if (connected == null) await setConnection(initial);
      } catch (error, stackTrace) {
        if (!controller.isClosed) controller.addError(error, stackTrace);
      }
    }

    controller = StreamController<List<MediaEntity>>(
      onListen: () => unawaited(initialize()),
      onCancel: () async {
        generation++;
        await connectivitySubscription?.cancel();
        await remoteSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<MediaEntity?> findById(String userId, String mediaId) async {
    _requireUser(userId);
    final cached = await _local.read(userId, mediaId);
    if (cached != null) return MediaRecord.decode(mediaId, cached);
    if (!await _network.hasConnection) return null;
    final remote = await _remote.read(mediaId);
    if (remote == null) return null;
    _requireUser(userId);
    final item = MediaRecord.decode(mediaId, remote);
    await _local.save(userId, mediaId, remote);
    return item;
  }

  @override
  Future<MediaEntity?> findByExternalIdentity(
    String userId,
    ExternalSource source,
    String externalId,
  ) async {
    _requireUser(userId);
    final id = _id(source, externalId);
    final cached = await _local.read(userId, id);
    if (cached != null) return MediaRecord.decode(id, cached);
    if (!await _network.hasConnection) return null;
    final remote = await _remote.read(id);
    if (remote == null) return null;
    _requireUser(userId);
    final item = MediaRecord.decode(id, remote);
    await _local.save(userId, id, remote);
    return item;
  }

  String _id(ExternalSource source, String externalId) =>
      '${source.name}_${base64Url.encode(utf8.encode(externalId)).replaceAll('=', '')}';

  @override
  Future<List<MediaCandidate>> searchExternal(
    MediaType type,
    String query,
  ) async {
    await _requireOnline();
    switch (type) {
      case MediaType.movie:
      case MediaType.series:
        final provider = _tmdb;
        if (provider == null) {
          throw const ApiConfigurationException('TMDB is not configured.');
        }
        final records = type == MediaType.movie
            ? await provider.searchMovies(query)
            : await provider.searchSeries(query);
        return records
            .map((record) => MediaRecord.fromTmdb(type, record))
            .toList();
      case MediaType.book:
        final provider = _googleBooks;
        if (provider == null) {
          throw const ApiConfigurationException(
            'Google Books is not configured.',
          );
        }
        return (await provider.searchBooks(
          query,
        )).map(MediaRecord.fromGoogleBooks).toList();
    }
  }

  @override
  Future<MediaCandidate> getExternalDetails(
    MediaType type,
    String externalId,
  ) async {
    await _requireOnline();
    switch (type) {
      case MediaType.movie:
      case MediaType.series:
        final provider = _tmdb;
        if (provider == null) {
          throw const ApiConfigurationException('TMDB is not configured.');
        }
        final id = int.tryParse(externalId);
        if (id == null || id <= 0) {
          throw ArgumentError.value(externalId, 'externalId');
        }
        final record = type == MediaType.movie
            ? await provider.movieDetails(id)
            : await provider.seriesDetails(id);
        return MediaRecord.fromTmdb(type, record);
      case MediaType.book:
        final provider = _googleBooks;
        if (provider == null) {
          throw const ApiConfigurationException(
            'Google Books is not configured.',
          );
        }
        return MediaRecord.fromGoogleBooks(
          await provider.bookDetails(externalId),
        );
    }
  }

  @override
  Future<MediaEntity> add(
    String userId,
    MediaCandidate candidate,
    MediaStatus status, {
    double? rating,
    String? notes,
  }) async {
    _requireUser(userId);
    await _requireOnline();
    if (!status.isAllowedFor(candidate.mediaType)) {
      throw ArgumentError.value(status, 'status');
    }
    final id = _id(candidate.externalSource, candidate.externalId);
    if (await _local.read(userId, id) != null ||
        await _remote.read(id) != null) {
      throw const DuplicateMediaException();
    }
    final now = _clock();
    final media = MediaEntity(
      id: id,
      mediaType: candidate.mediaType,
      externalSource: candidate.externalSource,
      externalId: candidate.externalId,
      title: candidate.title,
      posterUrl: candidate.posterUrl,
      description: candidate.description,
      language: candidate.language,
      releaseDate: candidate.releaseDate,
      status: status,
      rating: rating,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    final record = MediaRecord.encode(media);
    _requireUser(userId);
    await _remote.save(id, record);
    await _local.save(userId, id, record);
    return media;
  }

  @override
  Future<MediaEntity> update(String userId, MediaEntity media) async {
    _requireUser(userId);
    await _requireOnline();
    final existing = await _remote.read(media.id);
    if (existing == null) throw const MediaNotFoundException();
    final original = MediaRecord.decode(media.id, existing);
    if (original.externalSource != media.externalSource ||
        original.externalId != media.externalId ||
        original.mediaType != media.mediaType ||
        original.createdAt.millisecondsSinceEpoch !=
            media.createdAt.millisecondsSinceEpoch) {
      throw ArgumentError.value(
        media,
        'media',
        'Media identity cannot change.',
      );
    }
    final record = MediaRecord.encode(media);
    _requireUser(userId);
    await _remote.save(media.id, record);
    await _local.save(userId, media.id, record);
    return media;
  }

  @override
  Future<void> delete(String userId, String mediaId) async {
    _requireUser(userId);
    await _requireOnline();
    await _remote.delete(mediaId);
    await _local.delete(userId, mediaId);
  }
}
