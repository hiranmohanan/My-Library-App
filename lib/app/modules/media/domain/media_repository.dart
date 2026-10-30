import 'media_candidate.dart';
import 'media_entity.dart';
import 'media_status.dart';
import 'media_type.dart';

/// Domain contract. The data-layer implementation decides local/remote policy.
abstract interface class MediaRepository {
  Future<List<MediaEntity>> getLibrary(String userId);

  Stream<List<MediaEntity>> watchLibrary(String userId);

  Future<MediaEntity?> findById(String userId, String mediaId);

  Future<MediaEntity?> findByExternalIdentity(
    String userId,
    ExternalSource source,
    String externalId,
  );

  Future<List<MediaCandidate>> searchExternal(MediaType type, String query);

  Future<MediaCandidate> getExternalDetails(MediaType type, String externalId);

  Future<MediaEntity> add(
    String userId,
    MediaCandidate candidate,
    MediaStatus status, {
    double? rating,
    String? notes,
  });

  Future<MediaEntity> update(String userId, MediaEntity media);

  Future<void> delete(String userId, String mediaId);
}
