import 'package:flutter/material.dart';

import '../modules/media/domain/media_entity.dart';
import '../modules/media/domain/media_candidate.dart';
import '../modules/media/domain/media_type.dart';
import '../core/constants/media_labels.dart';
import 'app_text.dart';
import 'media_poster.dart';

class MediaGridCard extends StatelessWidget {
  MediaGridCard({required MediaEntity media, required this.onTap, super.key})
    : title = media.title,
      type = media.mediaType,
      posterUrl = media.posterUrl;

  MediaGridCard.candidate({
    required MediaCandidate candidate,
    required this.onTap,
    super.key,
  }) : title = candidate.title,
       type = candidate.mediaType,
       posterUrl = candidate.posterUrl;

  final String title;
  final MediaType type;
  final String? posterUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: onTap,
    child: Semantics(
      button: true,
      excludeSemantics: true,
      label: '$title, ${type.label}. Open details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: MediaPoster(title: title, url: posterUrl),
            ),
          ),
          const SizedBox(height: 6),
          AppText(
            title,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          AppText(
            type.label,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}
