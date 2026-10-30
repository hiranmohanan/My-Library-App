import 'package:flutter_test/flutter_test.dart';
import 'package:my_library_app/app/modules/media/domain/media_candidate.dart';
import 'package:my_library_app/app/modules/media/domain/media_entity.dart';
import 'package:my_library_app/app/modules/media/domain/media_repository.dart';
import 'package:my_library_app/app/modules/media/domain/media_status.dart';
import 'package:my_library_app/app/modules/media/domain/media_type.dart';
import 'package:my_library_app/app/modules/media/domain/media_use_cases.dart';
import 'package:my_library_app/app/modules/profile/domain/profile_entity.dart';

final class FakeMediaRepository implements MediaRepository {
  final entries = <String, MediaEntity>{};
  MediaType? lastSearchType;

  @override
  Future<List<MediaEntity>> getLibrary(String userId) async =>
      entries.values.toList();

  @override
  Stream<List<MediaEntity>> watchLibrary(String userId) =>
      Stream.value(entries.values.toList());

  @override
  Future<MediaEntity?> findById(String userId, String mediaId) async =>
      entries[mediaId];

  @override
  Future<MediaEntity?> findByExternalIdentity(
    String userId,
    ExternalSource source,
    String externalId,
  ) async {
    for (final media in entries.values) {
      if (media.externalSource == source && media.externalId == externalId) {
        return media;
      }
    }
    return null;
  }

  @override
  Future<List<MediaCandidate>> searchExternal(
    MediaType type,
    String query,
  ) async {
    lastSearchType = type;
    return [
      MediaCandidate(
        mediaType: type,
        externalSource: type.externalSource,
        externalId: 'external-1',
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
    title: 'Title',
  );

  @override
  Future<MediaEntity> add(
    String userId,
    MediaCandidate candidate,
    MediaStatus status, {
    double? rating,
    String? notes,
  }) async {
    final createdAt = DateTime.utc(2026);
    final media = MediaEntity(
      id: 'entry-1',
      mediaType: candidate.mediaType,
      externalSource: candidate.externalSource,
      externalId: candidate.externalId,
      title: candidate.title,
      status: status,
      rating: rating,
      notes: notes,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    entries[media.id] = media;
    return media;
  }

  @override
  Future<MediaEntity> update(String userId, MediaEntity media) async {
    entries[media.id] = media;
    return media;
  }

  @override
  Future<void> delete(String userId, String mediaId) async {
    entries.remove(mediaId);
  }
}

void main() {
  test('media and profile reject invalid domain values', () {
    expect(
      () => MediaCandidate(
        mediaType: MediaType.book,
        externalSource: ExternalSource.tmdb,
        externalId: 'x',
        title: 'Book',
      ),
      throwsArgumentError,
    );
    expect(MediaStatus.reading.isAllowedFor(MediaType.movie), isFalse);
    expect(MediaStatus.dropped.isAllowedFor(MediaType.book), isTrue);

    final createdAt = DateTime.utc(2026);
    expect(
      () => MediaEntity(
        id: '1',
        mediaType: MediaType.movie,
        externalSource: ExternalSource.tmdb,
        externalId: '10',
        title: 'Film',
        status: MediaStatus.watched,
        rating: 11,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      throwsArgumentError,
    );
    expect(
      () => ProfileEntity(
        id: 'user',
        name: '',
        phoneNumber: '+919876543210',
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      throwsArgumentError,
    );
  });

  test('use cases dispatch search and reject duplicate entries', () async {
    final repository = FakeMediaRepository();
    final candidate = (await SearchMovies(repository)('  Arrival  ')).single;
    expect(repository.lastSearchType, MediaType.movie);
    expect(candidate.title, 'Arrival');

    final add = AddMedia(repository);
    final saved = await add('user-1', candidate, MediaStatus.wantToWatch);
    expect(saved.externalId, candidate.externalId);
    await expectLater(
      add('user-1', candidate, MediaStatus.wantToWatch),
      throwsA(isA<DuplicateMediaException>()),
    );
    await expectLater(
      add('user-1', candidate, MediaStatus.reading),
      throwsArgumentError,
    );
  });

  test('use cases update status, clear rating and notes, and delete', () async {
    final repository = FakeMediaRepository();
    final candidate = MediaCandidate(
      mediaType: MediaType.book,
      externalSource: ExternalSource.googleBooks,
      externalId: 'book-1',
      title: 'Book',
    );
    await AddMedia(repository)('user-1', candidate, MediaStatus.wantToRead);
    final updatedAt = DateTime.utc(2026, 1, 2);

    final reading = await UpdateStatus(repository, clock: () => updatedAt)(
      'user-1',
      'entry-1',
      MediaStatus.reading,
    );
    expect(reading.status, MediaStatus.reading);
    expect(reading.updatedAt, updatedAt);

    await UpdateRating(repository, clock: () => updatedAt)(
      'user-1',
      'entry-1',
      8,
    );
    await UpdateNotes(repository, clock: () => updatedAt)(
      'user-1',
      'entry-1',
      'Finished chapter one',
    );
    final cleared = await UpdateRating(repository, clock: () => updatedAt)(
      'user-1',
      'entry-1',
      null,
    );
    expect(cleared.rating, isNull);

    final noNotes = await UpdateNotes(repository, clock: () => updatedAt)(
      'user-1',
      'entry-1',
      null,
    );
    expect(noNotes.notes, isNull);
    expect((await GetLibrary(repository)('user-1')).length, 1);
    await DeleteMedia(repository)('user-1', 'entry-1');
    expect(await GetMediaDetails(repository)('user-1', 'entry-1'), isNull);
  });
}
