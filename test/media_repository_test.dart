import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_library_app/app/data/datasources/media_local_data_source.dart';
import 'package:my_library_app/app/data/datasources/remote/firebase_media_data_source.dart';
import 'package:my_library_app/app/data/models/media_record.dart';
import 'package:my_library_app/app/data/repositories/media_repository_impl.dart';
import 'package:my_library_app/app/data/services/local_storage_service.dart';
import 'package:my_library_app/app/data/services/network_info_service.dart';
import 'package:my_library_app/app/modules/media/domain/media_candidate.dart';
import 'package:my_library_app/app/modules/media/domain/media_entity.dart';
import 'package:my_library_app/app/modules/media/domain/media_offline_exception.dart';
import 'package:my_library_app/app/modules/media/domain/media_status.dart';
import 'package:my_library_app/app/modules/media/domain/media_type.dart';
import 'package:my_library_app/app/modules/media/domain/media_use_cases.dart';

final class MemoryStorage implements LocalStorageService {
  final collections = <String, Map<String, Map<String, Object?>>>{};

  Map<String, Map<String, Object?>> _entries(String name) =>
      collections.putIfAbsent(name, () => {});

  @override
  Future<Map<String, Object?>?> read(String collection, String key) async =>
      _entries(collection)[key];

  @override
  Future<Map<String, Map<String, Object?>>> readAll(String collection) async =>
      Map.of(_entries(collection));

  @override
  Future<void> save(
    String collection,
    String key,
    Map<String, Object?> value,
  ) async => _entries(collection)[key] = value;

  @override
  Future<void> update(
    String collection,
    String key,
    Map<String, Object?> changes,
  ) async =>
      _entries(collection)[key] = {...?_entries(collection)[key], ...changes};

  @override
  Future<void> delete(String collection, String key) async =>
      _entries(collection).remove(key);

  @override
  Future<void> clear(String collection) async => _entries(collection).clear();

  @override
  Future<void> replaceAll(
    String collection,
    Map<String, Map<String, Object?>> records,
  ) async => collections[collection] = Map.of(records);
}

final class FakeRemote implements RemoteMediaDataSource {
  final records = <String, Map<String, Object?>>{};
  final events =
      StreamController<Map<String, Map<String, Object?>>>.broadcast();
  bool failSave = false;
  bool failRead = false;
  bool failDelete = false;

  @override
  Future<Map<String, Map<String, Object?>>> readAll() async {
    if (failRead) throw StateError('remote read failed');
    return Map.of(records);
  }

  @override
  Stream<Map<String, Map<String, Object?>>> watchAll() => events.stream;

  @override
  Future<Map<String, Object?>?> read(String id) async {
    if (failRead) throw StateError('remote read failed');
    return records[id];
  }

  @override
  Future<void> save(String id, Map<String, Object?> value) async {
    if (failSave) throw StateError('remote write failed');
    records[id] = value;
  }

  @override
  Future<void> delete(String id) async {
    if (failDelete) throw StateError('remote delete failed');
    records.remove(id);
  }
}

final class FakeNetwork implements NetworkInfo {
  FakeNetwork(this._online);

  final events = StreamController<bool>.broadcast();
  bool _online;
  bool get online => _online;
  set online(bool value) {
    _online = value;
    events.add(value);
  }

  @override
  Future<bool> get hasConnection async => _online;

  @override
  Stream<bool> get changes => events.stream;
}

void main() {
  final candidate = MediaCandidate(
    mediaType: MediaType.movie,
    externalSource: ExternalSource.tmdb,
    externalId: '42',
    title: 'Example',
  );

  late MemoryStorage storage;
  late MediaLocalDataSource local;
  late FakeRemote remote;
  late FakeNetwork network;
  late MediaRepositoryImpl repository;
  var userId = 'user-a';

  setUp(() {
    storage = MemoryStorage();
    local = MediaLocalDataSource(storage);
    remote = FakeRemote();
    network = FakeNetwork(true);
    userId = 'user-a';
    repository = MediaRepositoryImpl(
      local: local,
      remote: remote,
      network: network,
      currentUserId: () => userId,
      clock: () => DateTime.utc(2026, 10, 29),
    );
  });

  tearDown(() async {
    await remote.events.close();
    await network.events.close();
  });

  test(
    'remote write precedes cache update, and offline reads use cache',
    () async {
      remote.failSave = true;
      await expectLater(
        repository.add('user-a', candidate, MediaStatus.wantToWatch),
        throwsStateError,
      );
      expect(await local.readAll('user-a'), isEmpty);

      remote.failSave = false;
      final item = await repository.add(
        'user-a',
        candidate,
        MediaStatus.wantToWatch,
      );
      expect(remote.records[item.id], MediaRecord.encode(item));
      expect(await local.read('user-a', item.id), MediaRecord.encode(item));
      await expectLater(
        repository.add('user-a', candidate, MediaStatus.wantToWatch),
        throwsA(isA<DuplicateMediaException>()),
      );

      network.online = false;
      expect((await repository.getLibrary('user-a')).single.id, item.id);
      await expectLater(
        repository.delete('user-a', item.id),
        throwsA(isA<MediaOfflineException>()),
      );
      expect(remote.records, contains(item.id));
    },
  );

  test('refresh replaces stale cache and rejects another user', () async {
    final item = await repository.add(
      'user-a',
      candidate,
      MediaStatus.wantToWatch,
    );
    await local.clear('user-a');
    expect((await repository.getLibrary('user-a')).single.id, item.id);

    userId = 'user-b';
    await expectLater(
      repository.getLibrary('user-a'),
      throwsA(isA<MediaAuthenticationException>()),
    );
    expect(await local.readAll('user-b'), isEmpty);
  });

  test('update and delete keep remote and cache in step', () async {
    final item = await repository.add(
      'user-a',
      candidate,
      MediaStatus.wantToWatch,
    );
    final updated = item.copyWith(
      status: MediaStatus.watched,
      rating: 8.0,
      updatedAt: DateTime.utc(2026, 10, 30),
    );
    await repository.update('user-a', updated);
    expect(remote.records[item.id]?['status'], 'watched');
    expect((await local.read('user-a', item.id))?['rating'], 8.0);

    await repository.delete('user-a', item.id);
    expect(remote.records, isEmpty);
    expect(await local.readAll('user-a'), isEmpty);
  });

  test(
    'remote failures preserve cached entries and prevent local deletion',
    () async {
      final item = await repository.add(
        'user-a',
        candidate,
        MediaStatus.wantToWatch,
      );
      remote.failRead = true;
      expect((await repository.getLibrary('user-a')).single.id, item.id);
      remote.failRead = false;
      remote.failDelete = true;
      await expectLater(repository.delete('user-a', item.id), throwsStateError);
      expect(await local.read('user-a', item.id), isNotNull);
      expect(remote.records, contains(item.id));
    },
  );

  test('remote duplicate is rejected when local cache is empty', () async {
    final item = await repository.add(
      'user-a',
      candidate,
      MediaStatus.wantToWatch,
    );
    await local.clear('user-a');
    await expectLater(
      repository.add('user-a', candidate, MediaStatus.wantToWatch),
      throwsA(isA<DuplicateMediaException>()),
    );
    expect(remote.records.length, 1);
    expect(remote.records, contains(item.id));
  });

  test('large cached library remains available offline and sorted', () async {
    final now = DateTime.utc(2026, 10, 29);
    for (var index = 0; index < 1000; index++) {
      final item = MediaEntity(
        id: 'cached-$index',
        mediaType: MediaType.movie,
        externalSource: ExternalSource.tmdb,
        externalId: '$index',
        title: 'Movie $index',
        status: MediaStatus.wantToWatch,
        createdAt: now,
        updatedAt: now.add(Duration(minutes: index)),
      );
      await local.save('user-a', item.id, MediaRecord.encode(item));
    }
    network.online = false;
    final library = await repository.getLibrary('user-a');
    expect(library.length, 1000);
    expect(library.first.id, 'cached-999');
    expect(library.last.id, 'cached-0');
  });

  test('offline library stream refreshes cache after reconnect', () async {
    network.online = false;
    final now = DateTime.utc(2026, 10, 29);
    final item = MediaEntity(
      id: 'remote-1',
      mediaType: MediaType.movie,
      externalSource: ExternalSource.tmdb,
      externalId: '42',
      title: 'Remote movie',
      status: MediaStatus.wantToWatch,
      createdAt: now,
      updatedAt: now,
    );
    remote.records[item.id] = MediaRecord.encode(item);
    final iterator = StreamIterator(repository.watchLibrary('user-a'));
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current, isEmpty);

    network.online = true;
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current.single.title, 'Remote movie');
    expect(await local.read('user-a', item.id), MediaRecord.encode(item));

    network.online = false;
    await pumpEventQueue();
    remote.records.clear();
    remote.events.add({});
    expect(await local.read('user-a', item.id), isNotNull);
    network.online = true;
    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current, isEmpty);
    expect(await local.readAll('user-a'), isEmpty);
    await iterator.cancel();
  });

  test('provider records map to candidates and stored records round trip', () {
    final tmdb = MediaRecord.fromTmdb(MediaType.movie, {
      'id': 42,
      'title': 'Example',
      'poster_path': '/poster.jpg',
    });
    expect(tmdb.posterUrl, 'https://image.tmdb.org/t/p/w500/poster.jpg');
    final book = MediaRecord.fromGoogleBooks({
      'id': 'book-1',
      'volumeInfo': {
        'title': 'Book',
        'imageLinks': {'thumbnail': 'http://books.example/cover.jpg'},
      },
    });
    expect(book.posterUrl, 'https://books.example/cover.jpg');
  });
}
