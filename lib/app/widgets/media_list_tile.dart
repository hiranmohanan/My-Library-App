import 'package:flutter/material.dart';

import '../modules/media/domain/media_entity.dart';
import '../core/constants/media_labels.dart';
import 'app_text.dart';
import 'media_poster.dart';

class MediaListTile extends StatelessWidget {
  const MediaListTile({required this.media, required this.onTap, super.key});

  final MediaEntity media;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: SizedBox(
      width: 48,
      height: 72,
      child: MediaPoster(title: media.title, url: media.posterUrl),
    ),
    title: AppText(media.title, maxLines: 2),
    subtitle: AppText('${media.mediaType.label} · ${media.status.label}'),
    trailing: media.rating == null ? null : AppText('${media.rating}/10'),
  );
}
