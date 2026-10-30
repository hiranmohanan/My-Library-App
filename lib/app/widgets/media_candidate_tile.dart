import 'package:flutter/material.dart';

import '../modules/media/domain/media_candidate.dart';
import '../core/constants/media_labels.dart';
import 'app_text.dart';
import 'media_poster.dart';

class MediaCandidateTile extends StatelessWidget {
  const MediaCandidateTile({
    required this.candidate,
    required this.onTap,
    required this.onAdd,
    super.key,
  });
  final MediaCandidate candidate;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final date = candidate.releaseDate;
    final year = date == null || date.length < 4 ? null : date.substring(0, 4);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 48,
            height: 68,
            child: MediaPoster(
              title: candidate.title,
              url: candidate.posterUrl,
            ),
          ),
        ),
        title: AppText(
          candidate.title,
          maxLines: 2,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: AppText(
          year == null
              ? candidate.mediaType.label
              : '$year · ${candidate.mediaType.label}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton.filled(
          tooltip: 'Add ${candidate.title} to library',
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 20),
        ),
      ),
    );
  }
}
