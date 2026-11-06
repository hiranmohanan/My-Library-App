import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/media_labels.dart';
import '../data/models/tmdb_episode.dart';
import '../data/models/tmdb_season.dart';
import '../modules/media/domain/media_type.dart';
import '../modules/search/bloc/season_episodes_cubit.dart';
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
    this.backdropUrl,
    this.originalTitle,
    this.language,
    this.rating,
    this.voteCount,
    this.popularity,
    this.genres,
    this.mediaStatus,
    this.runtime,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.tagline,
    this.homepage,
    this.originCountry,
    this.seasons,
    this.actionEnabled = true,
    this.footer,
    super.key,
  });

  final String title;
  final MediaType type;
  final String? posterUrl;
  final String? backdropUrl;
  final String? description;
  final String? releaseDate;
  final String? originalTitle;
  final String? language;
  final double? rating;
  final int? voteCount;
  final double? popularity;
  final List<String>? genres;
  final String? mediaStatus;
  final int? runtime;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final String? tagline;
  final String? homepage;
  final List<String>? originCountry;
  final List<TmdbSeason>? seasons;
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
            // ── Hero / Backdrop ────────────────────────────────────────────
            SizedBox(
              height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MediaPoster(
                    title: title,
                    url: backdropUrl ?? posterUrl,
                    fit: BoxFit.cover,
                  ),
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

            // ── Content ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + year + type
                  AppText(title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  AppText(
                    year == null ? type.label : '$year · ${type.label}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  // Original title (if different)
                  if (originalTitle != null && originalTitle != title) ...[
                    const SizedBox(height: 2),
                    AppText(
                      'Original: $originalTitle',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  // Tagline
                  if (tagline != null && tagline!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    AppText(
                      '"$tagline"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  // Rating row
                  if (rating != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 18,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 5),
                        AppText(
                          '${rating!.toStringAsFixed(1)} / 10',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (voteCount != null) ...[
                          const SizedBox(width: 6),
                          AppText(
                            '(${_formatCount(voteCount!)} votes)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  // Meta chips (genre, runtime, seasons, etc.)
                  const SizedBox(height: 14),
                  _MetaChips(
                    genres: genres,
                    runtime: runtime,
                    numberOfSeasons: numberOfSeasons,
                    numberOfEpisodes: numberOfEpisodes,
                    language: language,
                    originCountry: originCountry,
                    mediaStatus: mediaStatus,
                    popularity: popularity,
                  ),

                  // Synopsis
                  const SizedBox(height: 20),
                  AppText('Synopsis', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
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

                  // Seasons & Episodes (series only)
                  if (seasons != null && seasons!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SeasonsSection(seasons: seasons!),
                  ],

                  // Details table
                  const SizedBox(height: 20),
                  _DetailsTable(
                    releaseDate: releaseDate,
                    language: language,
                    originCountry: originCountry,
                    homepage: homepage,
                    mediaStatus: mediaStatus,
                  ),

                  // Action button
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

  static String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }
}

// ── Meta chips (genres, runtime, …) ──────────────────────────────────────────

class _MetaChips extends StatelessWidget {
  const _MetaChips({
    this.genres,
    this.runtime,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.language,
    this.originCountry,
    this.mediaStatus,
    this.popularity,
  });

  final List<String>? genres;
  final int? runtime;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final String? language;
  final List<String>? originCountry;
  final String? mediaStatus;
  final double? popularity;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (genres != null && genres!.isNotEmpty) {
      for (final genre in genres!) {
        chips.add(_Chip(label: genre));
      }
    }

    if (runtime != null && runtime! > 0) {
      final h = runtime! ~/ 60;
      final m = runtime! % 60;
      chips.add(
        _Chip(icon: Icons.schedule, label: h > 0 ? '${h}h ${m}m' : '${m}m'),
      );
    }

    if (numberOfSeasons != null) {
      chips.add(
        _Chip(
          icon: Icons.live_tv_outlined,
          label: '$numberOfSeasons season${numberOfSeasons! != 1 ? 's' : ''}',
        ),
      );
    }

    if (numberOfEpisodes != null) {
      chips.add(
        _Chip(icon: Icons.format_list_numbered, label: '$numberOfEpisodes ep.'),
      );
    }

    if (language != null) {
      chips.add(_Chip(icon: Icons.language, label: language!.toUpperCase()));
    }

    if (mediaStatus != null) {
      chips.add(_Chip(icon: Icons.info_outline, label: mediaStatus!));
    }

    if (popularity != null) {
      chips.add(
        _Chip(
          icon: Icons.local_fire_department_outlined,
          label: 'Pop. ${popularity!.toStringAsFixed(0)}',
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: theme.colorScheme.onSecondaryContainer),
            const SizedBox(width: 4),
          ],
          AppText(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Details table ─────────────────────────────────────────────────────────────

class _DetailsTable extends StatelessWidget {
  const _DetailsTable({
    this.releaseDate,
    this.language,
    this.originCountry,
    this.homepage,
    this.mediaStatus,
  });

  final String? releaseDate;
  final String? language;
  final List<String>? originCountry;
  final String? homepage;
  final String? mediaStatus;

  @override
  Widget build(BuildContext context) {
    final rows = <_TableRow>[];

    if (releaseDate != null && releaseDate!.isNotEmpty) {
      rows.add(_TableRow(label: 'Release date', value: releaseDate!));
    }
    if (language != null) {
      rows.add(_TableRow(label: 'Language', value: language!.toUpperCase()));
    }
    if (originCountry != null && originCountry!.isNotEmpty) {
      rows.add(_TableRow(label: 'Country', value: originCountry!.join(', ')));
    }
    if (mediaStatus != null) {
      rows.add(_TableRow(label: 'Status', value: mediaStatus!));
    }
    if (homepage != null) {
      rows.add(_TableRow(label: 'Homepage', value: homepage!, isUrl: true));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Details', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1)
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.label,
    required this.value,
    this.isUrl = false,
  });

  final String label;
  final String value;
  final bool isUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: AppText(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: AppText(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isUrl ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Seasons & Episodes section ────────────────────────────────────────────────

class _SeasonsSection extends StatelessWidget {
  const _SeasonsSection({required this.seasons});
  final List<TmdbSeason> seasons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    SeasonEpisodesCubit? cubit;
    try {
      cubit = context.read<SeasonEpisodesCubit>();
    } catch (_) {
      // Cubit not provided — episodes won't be expandable.
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Seasons', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final season in seasons)
          _SeasonTile(season: season, canLoadEpisodes: cubit != null),
      ],
    );
  }
}

class _SeasonTile extends StatelessWidget {
  const _SeasonTile({required this.season, required this.canLoadEpisodes});
  final TmdbSeason season;
  final bool canLoadEpisodes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!canLoadEpisodes) {
      return _SeasonHeader(season: season);
    }
    return BlocBuilder<SeasonEpisodesCubit, SeasonEpisodesState>(
      builder: (context, state) {
        final episodes = state.episodes[season.seasonNumber];
        final isLoading = state.loadingSeason == season.seasonNumber;
        final hasError = state.errorSeason == season.seasonNumber;
        final isExpanded = state.expandedSeasons.contains(season.seasonNumber);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                if (!isLoading) {
                  context.read<SeasonEpisodesCubit>().toggleSeason(
                    season.seasonNumber,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    if (season.posterUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 48,
                            height: 72,
                            child: MediaPoster(
                              title: season.name,
                              url: season.posterUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            season.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppText(
                            '${season.episodeCount} episode${season.episodeCount != 1 ? 's' : ''}'
                            '${season.airDate != null && season.airDate!.length >= 4 ? ' · ${season.airDate!.substring(0, 4)}' : ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 60, bottom: 4),
                child: AppText(
                  'Could not load episodes.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            if (isExpanded && episodes != null && episodes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Column(
                  children: [
                    for (final ep in episodes) _EpisodeTile(episode: ep),
                  ],
                ),
              ),
            if (isExpanded && episodes != null && episodes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 60, bottom: 8),
                child: AppText(
                  'No episode details available.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ],
        );
      },
    );
  }
}

class _SeasonHeader extends StatelessWidget {
  const _SeasonHeader({required this.season});
  final TmdbSeason season;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (season.posterUrl != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 48,
                  height: 72,
                  child: MediaPoster(
                    title: season.name,
                    url: season.posterUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  season.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppText(
                  '${season.episodeCount} episode${season.episodeCount != 1 ? 's' : ''}'
                  '${season.airDate != null && season.airDate!.length >= 4 ? ' · ${season.airDate!.substring(0, 4)}' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({required this.episode});
  final TmdbEpisode episode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (episode.stillUrl != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 80,
                  height: 45,
                  child: MediaPoster(
                    title: episode.name,
                    url: episode.stillUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'E${episode.episodeNumber} · ${episode.name}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                ),
                if (episode.runtime != null || episode.airDate != null)
                  AppText(
                    [
                      if (episode.runtime != null) '${episode.runtime} min',
                      if (episode.airDate != null) episode.airDate,
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                if (episode.overview != null &&
                    episode.overview!.trim().isNotEmpty)
                  AppText(
                    episode.overview!,
                    maxLines: 2,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          if (episode.voteAverage != null && episode.voteAverage! > 0)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 12, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 2),
                  AppText(
                    episode.voteAverage!.toStringAsFixed(1),
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Synopsis expand cubit ─────────────────────────────────────────────────────

final class _SynopsisCubit extends Cubit<bool> {
  _SynopsisCubit() : super(false);

  void toggle() => emit(!state);
}
