import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../widgets/app_text.dart';
import '../../../widgets/app_section_header.dart';
import '../../../widgets/content_state.dart';
import '../../../widgets/loading_skeleton_list.dart';
import '../../../widgets/media_grid_card.dart';
import '../../../core/constants/media_labels.dart';
import '../../media/domain/media_entity.dart';
import '../../media/domain/media_candidate.dart';
import '../../media/domain/media_type.dart';
import '../../media_details/pages/media_details_page.dart';
import '../../search/pages/candidate_details_page.dart';
import '../../library/bloc/library_bloc.dart';
import '../../navigation/bloc/navigation_bloc.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/trending_bloc.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({required this.dependencies, required this.userId, super.key});
  final AppDependencies dependencies;
  final String userId;

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
    builder: (context, state) {
      if (state.loading) {
        return const LoadingSkeletonList();
      }
      if (state.errorMessage != null) {
        return ContentState(
          icon: Icons.cloud_off_outlined,
          title: 'Library unavailable',
          message: state.errorMessage!,
          actionLabel: 'Retry',
          onAction: () => context.read<HomeBloc>().add(HomeStarted(userId)),
        );
      }
      final name = context.watch<ProfileBloc>().state.profile?.name;
      return ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Hello ${name == null || name.isEmpty ? 'there' : name} 👋',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    AppText(
                      'Your library awaits',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Open profile',
                onPressed: () => context.read<NavigationBloc>().add(
                  const NavigationSelected(3),
                ),
                icon: const Icon(Icons.person_outline),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () =>
                context.read<NavigationBloc>().add(const NavigationSelected(2)),
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search movies, series, books…',
              ),
              child: AppText(
                'Search movies, series, books…',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MediaType.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final type = MediaType.values[index];
                final icon = switch (type) {
                  MediaType.movie => Icons.movie_outlined,
                  MediaType.series => Icons.tv_outlined,
                  MediaType.book => Icons.menu_book_outlined,
                };
                return ActionChip(
                  avatar: Icon(icon, size: 16),
                  label: AppText(type.label),
                  onPressed: () {
                    context.read<LibraryBloc>().add(
                      LibraryFilterChanged(type: type),
                    );
                    context.read<NavigationBloc>().add(
                      const NavigationSelected(1),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          if (dependencies.tmdbRemoteDataSource != null) ...[
            AppSectionHeader(
              title: 'Trending Now',
              actionLabel: 'See All',
              onAction: () => context.read<NavigationBloc>().add(
                const NavigationSelected(2),
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<TrendingBloc, TrendingState>(
              builder: (context, trending) {
                if (trending.loading && trending.items.isEmpty) {
                  return const SizedBox(
                    height: 184,
                    child: LoadingSkeletonList(itemCount: 2),
                  );
                }
                if (trending.error != null && trending.items.isEmpty) {
                  return ContentState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Trending unavailable',
                    message: trending.error!,
                    actionLabel: 'Retry',
                    onAction: () => context.read<TrendingBloc>().add(
                      const TrendingRequested(),
                    ),
                  );
                }
                return _TrendingRow(
                  items: trending.items,
                  onOpen: (candidate) => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CandidateDetailsPage(
                        dependencies: dependencies,
                        userId: userId,
                        candidate: candidate,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
          ],
          AppSectionHeader(
            title: 'Recently Added',
            actionLabel: 'See All',
            onAction: () =>
                context.read<NavigationBloc>().add(const NavigationSelected(1)),
          ),
          const SizedBox(height: 12),
          state.recentlyAdded.isEmpty
              ? ContentState(
                  icon: Icons.auto_stories_outlined,
                  title: 'Your Library',
                  message: 'Start adding movies, series and books.',
                  actionLabel: 'Explore Content',
                  onAction: () => context.read<NavigationBloc>().add(
                    const NavigationSelected(2),
                  ),
                )
              : _PosterRow(
                  items: state.recentlyAdded,
                  onOpen: (item) => _openDetails(context, item),
                ),
          const SizedBox(height: 28),
          const AppSectionHeader(title: 'Continue Watching/Reading'),
          const SizedBox(height: 12),
          state.continueWatching.isEmpty
              ? AppText(
                  'Nothing in progress yet.',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : _PosterRow(
                  items: state.continueWatching,
                  onOpen: (item) => _openDetails(context, item),
                ),
        ],
      );
    },
  );

  void _openDetails(BuildContext context, MediaEntity item) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MediaDetailsPage(
            dependencies: dependencies,
            userId: userId,
            mediaId: item.id,
          ),
        ),
      );
}

class _TrendingRow extends StatelessWidget {
  const _TrendingRow({required this.items, required this.onOpen});

  final List<MediaCandidate> items;
  final ValueChanged<MediaCandidate> onOpen;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 184,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return SizedBox(
          width: 104,
          child: MediaGridCard.candidate(
            candidate: item,
            onTap: () => onOpen(item),
          ),
        );
      },
    ),
  );
}

class _PosterRow extends StatelessWidget {
  const _PosterRow({required this.items, required this.onOpen});

  final List<MediaEntity> items;
  final ValueChanged<MediaEntity> onOpen;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 184,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return SizedBox(
          width: 104,
          child: MediaGridCard(media: item, onTap: () => onOpen(item)),
        );
      },
    ),
  );
}
