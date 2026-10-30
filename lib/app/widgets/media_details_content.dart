import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/media_labels.dart';
import '../modules/media/domain/media_type.dart';
import 'app_text.dart';
import 'media_poster.dart';

class MediaDetailsContent extends StatelessWidget {
  const MediaDetailsContent({
    required this.title,
    required this.type,
    required this.posterUrl,
    required this.description,
    required this.releaseDate,
    required this.actionLabel,
    required this.onAction,
    required this.onBack,
    this.rating,
    this.actionEnabled = true,
    this.footer,
    super.key,
  });

  final String title;
  final MediaType type;
  final String? posterUrl;
  final String? description;
  final String? releaseDate;
  final double? rating;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback onBack;
  final bool actionEnabled;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heroHeight = math.min(MediaQuery.sizeOf(context).height * 0.4, 400.0);
    final date = releaseDate;
    final year = date == null || date.length < 4 ? null : date.substring(0, 4);
    return BlocProvider(
      create: (_) => _SynopsisCubit(),
      child: BlocBuilder<_SynopsisCubit, bool>(
        builder: (context, expanded) => ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MediaPoster(title: title, url: posterUrl, fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.scaffoldBackgroundColor.withValues(alpha: 0),
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 8,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.45),
                      child: IconButton(
                        tooltip: 'Back',
                        onPressed: onBack,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  AppText(
                    year == null ? type.label : '$year · ${type.label}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (rating != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 18,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 5),
                        AppText('${rating!.toStringAsFixed(1)}/10'),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  AppText(
                    description?.trim().isNotEmpty == true
                        ? description!
                        : 'No description available.',
                    style: theme.textTheme.bodyMedium,
                    maxLines: expanded ? null : 3,
                  ),
                  if ((description?.trim().length ?? 0) > 120)
                    TextButton(
                      onPressed: () => context.read<_SynopsisCubit>().toggle(),
                      child: AppText(expanded ? 'Show less' : 'Read more'),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: actionEnabled ? onAction : null,
                      child: AppText(actionLabel),
                    ),
                  ),
                  if (footer != null) ...[const SizedBox(height: 20), footer!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SynopsisCubit extends Cubit<bool> {
  _SynopsisCubit() : super(false);

  void toggle() => emit(!state);
}
