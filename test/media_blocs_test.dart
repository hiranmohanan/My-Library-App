import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_library_app/app/data/datasources/profile_local_data_source.dart';
import 'package:my_library_app/app/data/services/local_storage_service.dart';
import 'package:my_library_app/app/modules/add_media/bloc/add_media_bloc.dart';
import 'package:my_library_app/app/modules/authentication/domain/auth_repository.dart';
import 'package:my_library_app/app/modules/authentication/domain/auth_use_cases.dart';
import 'package:my_library_app/app/modules/home/bloc/home_bloc.dart';
import 'package:my_library_app/app/modules/library/bloc/library_bloc.dart';
import 'package:my_library_app/app/modules/media/domain/media_candidate.dart';
import 'package:my_library_app/app/modules/media/domain/media_entity.dart';
import 'package:my_library_app/app/modules/media/domain/media_repository.dart';
import 'package:my_library_app/app/modules/media/domain/media_status.dart';
import 'package:my_library_app/app/modules/media/domain/media_type.dart';
import 'package:my_library_app/app/modules/media/domain/media_use_cases.dart';
import 'package:my_library_app/app/modules/media_details/bloc/media_details_bloc.dart';
import 'package:my_library_app/app/modules/profile/bloc/profile_bloc.dart';
import 'package:my_library_app/app/modules/search/bloc/search_bloc.dart';
import 'package:my_library_app/app/modules/settings/bloc/settings_bloc.dart';
import 'package:my_library_app/app/theme_controller.dart';

final class _Repository implements MediaRepository {
  final records = <String, MediaEntity>{};
  final changes = StreamController<List<MediaEntity>>.broadcast();
  bool failSearch = false;
  bool failBooks = false;
  int updateCalls = 0;

  @override
  Future<List<MediaEntity>> getLibrary(String userId) async =>
      records.values.toList();

  @override
  Stream<List<MediaEntity>> watchLibrary(String userId) => changes.stream;

  @override
  Future<MediaEntity?> findById(String userId, String mediaId) async =>
      records[mediaId];

  @override
  Future<MediaEntity?> findByExternalIdentity(
    String userId,
    ExternalSource source,
    String externalId,
  ) async {
    for (final item in records.values) {
      if (item.externalSource == source && item.externalId == externalId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<MediaCandidate>> searchExternal(
    MediaType type,
    String query,
  ) async {
    if (failSearch || (failBooks && type == MediaType.book)) {
      throw StateError('Search unavailable');
    }
    return [
      MediaCandidate(
        mediaType: type,
        externalSource: type.externalSource,
        externalId: '42',
        title: query,
      ),
    ];
  }

  @override
  Future<MediaCandidate> getExternalDetails(
    MediaType type,
    String externalId,
  ) async => MediaCandidate(
    mediaType: type,
    externalSource: type.externalSource,
    externalId: externalId,
    title: 'Example',
  );

  @override
  Future<MediaEntity> add(
    String userId,
    MediaCandidate candidate,
    MediaStatus status, {
    double? rating,
    String? notes,
  }) async {
    final now = DateTime.utc(2026, 10, 29);
    final item = MediaEntity(
      id: 'item-1',
      mediaType: candidate.mediaType,
      externalSource: candidate.externalSource,
      externalId: candidate.externalId,
      title: candidate.title,
      status: status,
      rating: rating,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    records[item.id] = item;
    return item;
  }

  @override
  Future<MediaEntity> update(String userId, MediaEntity media) async {
    updateCalls++;
    records[media.id] = media;
    return media;
  }

  @override
  Future<void> delete(String userId, String mediaId) async =>
      records.remove(mediaId);
}

final class _Storage implements LocalStorageService {
  final values = <String, Map<String, Map<String, Object?>>>{};
  Map<String, Map<String, Object?>> _collection(String name) =>
      values.putIfAbsent(name, () => {});

  @override
  Future<Map<String, Object?>?> read(String collection, String key) async =>
      _collection(collection)[key];
  @override
  Future<Map<String, Map<String, Object?>>> readAll(String collection) async =>
      Map.of(_collection(collection));
  @override
  Future<void> save(
    String collection,
    String key,
    Map<String, Object?> value,
  ) async => _collection(collection)[key] = value;
  @override
  Future<void> update(
    String collection,
    String key,
    Map<String, Object?> changes,
  ) async => _collection(collection)[key] = {
    ...?_collection(collection)[key],
    ...changes,
  };
  @override
  Future<void> delete(String collection, String key) async =>
      _collection(collection).remove(key);
  @override
  Future<void> clear(String collection) async =>
      _collection(collection).clear();
  @override
  Future<void> replaceAll(
    String collection,
    Map<String, Map<String, Object?>> records,
  ) async => values[collection] = records;
}

final class _Auth implements AuthRepository {
  _Auth(this.local);
  final ProfileLocalDataSource local;
  @override
  AuthUser? get currentUser => (id: 'user', phoneNumber: '+911234567890');
  @override
  Stream<AuthUser?> authStateChanges() => Stream.value(currentUser);
  @override
  Future<bool> hasProfile() async => true;
  @override
  Future<bool> sendOtp(String phoneNumber, {bool resend = false}) async => true;
  @override
  Future<void> verifyOtp(String code) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> saveProfile(String name, {String? email}) async =>
      local.update('user', {
        'name': name,
        'updatedAt': DateTime.utc(2026, 10, 30).millisecondsSinceEpoch,
      });
}

Future<T> _next<T>(Stream<T> stream, bool Function(T) predicate) =>
    stream.firstWhere(predicate);

void main() {
  late _Repository repository;
  setUp(() => repository = _Repository());
  tearDown(() => repository.changes.close());

  test('home and library react to media and library filters', () async {
    final item = await repository.add(
      'user',
      MediaCandidate(
        mediaType: MediaType.movie,
        externalSource: ExternalSource.tmdb,
        externalId: '42',
        title: 'Example',
      ),
      MediaStatus.watching,
    );
    final home = HomeBloc(WatchLibrary(repository));
    final library = LibraryBloc(WatchLibrary(repository));
    final homeLoading = _next(home.stream, (state) => state.loading);
    final libraryLoading = _next(library.stream, (state) => state.loading);
    home.add(const HomeStarted('user'));
    library.add(const LibraryStarted('user'));
    await Future.wait([homeLoading, libraryLoading]);
    await pumpEventQueue();
    final homeItems = _next(home.stream, (state) => state.items.isNotEmpty);
    final libraryItems = _next(
      library.stream,
      (state) => state.items.isNotEmpty,
    );
    repository.changes.add([item]);
    expect((await homeItems).continueWatching.single.id, item.id);
    expect((await libraryItems).visibleItems.single.id, item.id);
    library.add(const LibraryFilterChanged(type: MediaType.book));
    expect(
      (await _next(
        library.stream,
        (state) => state.type == MediaType.book,
      )).visibleItems,
      isEmpty,
    );
    await home.close();
    await library.close();
  });

  test(
    'search, add, details, and deletion follow event to state flow',
    () async {
      final search = SearchBloc(
        SearchMovies(repository),
        SearchSeries(repository),
        SearchBooks(repository),
      );
      search.add(const SearchTypeChanged(MediaType.movie));
      search.add(const SearchQueryChanged('Example'));
      await _next(search.stream, (state) => state.query == 'Example');
      search.add(const SearchSubmitted());
      final result = (await _next(
        search.stream,
        (state) => state.status == SearchStatus.success,
      )).results.single;

      final add = AddMediaBloc(
        GetExternalDetails(repository),
        AddMedia(repository),
      );
      add.add(AddMediaCandidateSelected(result));
      await _next(add.stream, (state) => state.candidate != null);
      add.add(const AddMediaSaveRequested('user'));
      final saved = (await _next(
        add.stream,
        (state) => state.saved != null,
      )).saved!;

      final details = MediaDetailsBloc(
        GetMediaDetails(repository),
        UpdateStatus(repository),
        UpdateRating(repository),
        UpdateNotes(repository),
        DeleteMedia(repository),
        update: UpdateMedia(repository),
      );
      details.add(MediaDetailsRequested('user', saved.id));
      await _next(
        details.stream,
        (state) => state.stage == MediaDetailsStage.ready,
      );
      details.add(MediaStatusChanged('user', saved.id, MediaStatus.watched));
      expect(
        (await _next(
          details.stream,
          (state) => state.item?.status == MediaStatus.watched,
        )).item?.status,
        MediaStatus.watched,
      );
      details.add(
        const MediaChangesSaved(
          'user',
          'item-1',
          MediaStatus.watching,
          8,
          'Enjoyed it',
        ),
      );
      final edited = await _next(
        details.stream,
        (state) => state.item?.notes == 'Enjoyed it',
      );
      expect(edited.item?.rating, 8);
      expect(edited.item?.status, MediaStatus.watching);
      expect(repository.updateCalls, 2);
      details.add(MediaDeleteRequested('user', saved.id));
      await _next(
        details.stream,
        (state) => state.stage == MediaDetailsStage.deleted,
      );
      expect(repository.records, isEmpty);
      await search.close();
      await add.close();
      await details.close();
    },
  );

  test('All search retains available providers when Books fails', () async {
    repository.failBooks = true;
    final search = SearchBloc(
      SearchMovies(repository),
      SearchSeries(repository),
      SearchBooks(repository),
    );
    search.add(const SearchQueryChanged('Dune'));
    await _next(search.stream, (state) => state.query == 'Dune');
    search.add(const SearchSubmitted());
    final result = await _next(
      search.stream,
      (state) => state.status == SearchStatus.success,
    );
    expect(result.results.map((item) => item.mediaType), [
      MediaType.movie,
      MediaType.series,
    ]);
    expect(result.partialFailure, isTrue);
    await search.close();
  });

  test('profile loads local data and settings persist theme', () async {
    final local = ProfileLocalDataSource(_Storage());
    final now = DateTime.utc(2026, 10, 29).millisecondsSinceEpoch;
    await local.save('user', {
      'name': 'Alex',
      'phoneNumber': '+911234567890',
      'createdAt': now,
      'updatedAt': now,
    });
    final profile = ProfileBloc(
      local,
      AuthUseCases(_Auth(local)),
      GetLibrary(repository),
    );
    profile.add(const ProfileRequested('user'));
    expect(
      (await _next(
        profile.stream,
        (state) => state.profile != null,
      )).profile?.name,
      'Alex',
    );
    profile.add(const ProfileNameSubmitted('Alexis'));
    expect(
      (await _next(
        profile.stream,
        (state) => state.profile?.name == 'Alexis',
      )).saving,
      false,
    );

    ThemeMode? persisted;
    final theme = ThemeController(
      persistMode: (mode) async => persisted = mode,
    );
    final settings = SettingsBloc(theme)..add(const SettingsStarted());
    settings.add(const SettingsThemeSelected(ThemeMode.dark));
    expect(
      (await _next(
        settings.stream,
        (state) => state.mode == ThemeMode.dark && !state.saving,
      )).mode,
      ThemeMode.dark,
    );
    expect(persisted, ThemeMode.dark);
    await profile.close();
    await settings.close();
    await theme.close();
  });
}
