import 'package:flutter/material.dart';

class MediaPoster extends StatelessWidget {
  const MediaPoster({
    required this.title,
    this.url,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String title;
  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.auto_stories_outlined,
          color: colors.onSurfaceVariant,
          semanticLabel: 'No cover for $title',
        ),
      ),
    );
    final imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) return placeholder;
    return Image.network(
      imageUrl,
      fit: fit,
      semanticLabel: 'Cover for $title',
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : ColoredBox(
              color: colors.surfaceContainerHighest,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: colors.onSurfaceVariant,
            semanticLabel: 'Cover unavailable for $title',
          ),
        ),
      ),
    );
  }
}
