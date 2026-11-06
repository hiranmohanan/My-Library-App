import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../widgets/app_text.dart';
import '../../../widgets/content_state.dart';
import '../../../widgets/loading_skeleton_list.dart';
import '../../../widgets/media_candidate_tile.dart';
import '../../../widgets/media_grid_card.dart';
import '../../add_media/pages/add_media_page.dart';
import '../../connectivity/bloc/connectivity_bloc.dart';
import '../../home/bloc/trending_bloc.dart';
import '../../media/domain/media_type.dart';
import '../bloc/search_bloc.dart';
import 'candidate_details_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({
    required this.dependencies,
    required this.userId,
    super.key,
  });
  final AppDependencies dependencies;
  final String userId;

  @override
  Widget build(BuildContext context) => BlocBuilder<SearchBloc, SearchState>(
    builder: (context, state) {
      final offline =
          dependencies.networkInfo != null &&
          context.watch<ConnectivityBloc>().state.isOffline;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                'Search',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              key: ValueKey(state.clearVersion),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                hintText: 'Search movies, series, books…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () => context.read<SearchBloc>().add(
                          const SearchCleared(),
                        ),
                      ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) =>
                  context.read<SearchBloc>().add(SearchQueryChanged(value)),
              onSubmitted: (_) {
                if (!offline) {
                  context.read<SearchBloc>().add(const SearchSubmitted());
                }
              },
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 16),
                for (final (label, type) in [
                  ('All', null),
                  ('Movies', MediaType.movie),
                  ('Series', MediaType.series),
                  ('Books', MediaType.book),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: AppText(label),
                      selected: state.type == type,
                      onSelected: (_) => context.read<SearchBloc>().add(
                        SearchTypeChanged(type),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey(offline ? 'offline' : state.status),
                child: offline
                    ? const ContentState(
                        icon: Icons.wifi_off,
                        title: 'Search is offline',
                        message:
                            'External search is unavailable while offline.',
                      )
                    : switch (state.status) {
                        SearchStatus.loading => const LoadingSkeletonList(),
                        SearchStatus.failure => ContentState(
                          icon: Icons.search_off,
                          title: 'Search failed',
                          message: state.errorMessage ?? 'Please try again.',
                          actionLabel: 'Retry',
                          onAction: () => context.read<SearchBloc>().add(
                            const SearchSubmitted(),
                          ),
                        ),
                        SearchStatus.success when state.results.isEmpty =>
                          const ContentState(
                            icon: Icons.search_off,
                            title: 'No results',
                            message:
                                'Try another title or a different media type.',
                          ),
                        SearchStatus.success => ListView.builder(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount:
                              state.results.length +
                              (state.partialFailure ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (state.partialFailure && index == 0) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: AppText(
                                  'Some sources are unavailable. Showing available results.',
                                ),
                              );
                            }
                            final candidate =
                                state.results[index -
                                    (state.partialFailure ? 1 : 0)];
                            return MediaCandidateTile(
                              candidate: candidate,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => CandidateDetailsPage(
                                    dependencies: dependencies,
                                    userId: userId,
                                    candidate: candidate,
                                  ),
                                ),
                              ),
                              onAdd: () => showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                useSafeArea: true,
                                builder: (_) => SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.82,
                                  child: AddMediaPage(
                                    dependencies: dependencies,
                                    userId: userId,
                                    candidate: candidate,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        _ =>
                          dependencies.tmdbRemoteDataSource != null
                              ? _TrendingGrid(
                                  dependencies: dependencies,
                                  userId: userId,
                                  type: state.type,
                                )
                              : const ContentState(
                                  icon: Icons.search,
                                  title: 'Find your next favorite',
                                  message: 'Search movies, series, or books.',
                                ),
                      },
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _TrendingGrid extends StatelessWidget {
  const _TrendingGrid({
    required this.dependencies,
    required this.userId,
    this.type,
  });

  final AppDependencies dependencies;
  final String userId;
  final MediaType? type;

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<TrendingBloc, TrendingState>(
    builder: (context, trending) {
      if (type == MediaType.book) {
        return const ContentState(
          icon: Icons.menu_book_outlined,
          title: 'Trending books unavailable',
          message:
              'Books do not have a trending feed. Search by title, author, or ISBN.',
        );
      }
      if (trending.loading && trending.items.isEmpty) {
        return const LoadingSkeletonList(itemCount: 4);
      }
      if (trending.error != null && trending.items.isEmpty) {
        return ContentState(
          icon: Icons.cloud_off_outlined,
          title: 'Trending unavailable',
          message: trending.error!,
          actionLabel: 'Retry',
          onAction: () =>
              context.read<TrendingBloc>().add(const TrendingRequested()),
        );
      }
      final items = type == null
          ? trending.items
          : trending.items.where((i) => i.mediaType == type).toList();

      if (items.isEmpty) {
        return const ContentState(
          icon: Icons.search,
          title: 'Find your next favorite',
          message: 'Search movies, series, or books.',
        );
      }

      final title = switch (type) {
        MediaType.movie => 'Trending Movies',
        MediaType.series => 'Trending Series',
        MediaType.book => 'Trending Books',
        null => 'Trending Now',
      };

      return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 120 &&
              trending.hasMore &&
              !trending.loadingMore) {
            context.read<TrendingBloc>().add(const TrendingNextPageRequested());
          }
          return false;
        },
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverToBoxAdapter(
                child: AppText(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 140,
                  childAspectRatio: 0.55,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return MediaGridCard.candidate(
                    candidate: item,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CandidateDetailsPage(
                          dependencies: dependencies,
                          userId: userId,
                          candidate: item,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (trending.loadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
