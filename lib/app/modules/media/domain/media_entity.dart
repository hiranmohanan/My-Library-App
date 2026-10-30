import 'media_status.dart';
import 'media_type.dart';

/// A saved library entry. Storage and API representations stay in data models.
final class MediaEntity {
  MediaEntity({
    required this.id,
    required this.mediaType,
    required this.externalSource,
    required this.externalId,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.posterUrl,
    this.description,
    this.language,
    this.releaseDate,
    this.rating,
    this.notes,
  }) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
    if (externalSource != mediaType.externalSource) {
      throw ArgumentError('External source does not match media type.');
    }
    if (externalId.trim().isEmpty || externalId.length > 128) {
      throw ArgumentError.value(externalId, 'externalId');
    }
    if (title.trim().isEmpty || title.length > 500) {
      throw ArgumentError.value(title, 'title');
    }
    if (!status.isAllowedFor(mediaType)) {
      throw ArgumentError.value(status, 'status');
    }
    if (rating != null && (!rating!.isFinite || rating! < 0 || rating! > 10)) {
      throw ArgumentError.value(rating, 'rating');
    }
    if (notes != null && notes!.length > 10000) {
      throw ArgumentError.value(notes, 'notes');
    }
    if (updatedAt.isBefore(createdAt)) {
      throw ArgumentError('updatedAt must not precede createdAt.');
    }
  }

  final String id;
  final MediaType mediaType;
  final ExternalSource externalSource;
  final String externalId;
  final String title;
  final String? posterUrl;
  final String? description;
  final String? language;
  final String? releaseDate;
  final MediaStatus status;
  final double? rating;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  static const _unchanged = Object();

  MediaEntity copyWith({
    MediaStatus? status,
    Object? rating = _unchanged,
    Object? notes = _unchanged,
    DateTime? updatedAt,
  }) => MediaEntity(
    id: id,
    mediaType: mediaType,
    externalSource: externalSource,
    externalId: externalId,
    title: title,
    posterUrl: posterUrl,
    description: description,
    language: language,
    releaseDate: releaseDate,
    status: status ?? this.status,
    rating: identical(rating, _unchanged) ? this.rating : rating as double?,
    notes: identical(notes, _unchanged) ? this.notes : notes as String?,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
