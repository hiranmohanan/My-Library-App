import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../data/repositories/tmdb_trending_repository.dart';
import '../../../widgets/app_text.dart';
import '../../../widgets/content_state.dart';
import '../../../widgets/media_grid_card.dart';
import '../../media/domain/media_candidate.dart';
import '../../search/pages/candidate_details_page.dart';
import '../bloc/trending_bloc.dart';

/// Full-screen paginated grid of all trending titles.
class TrendingAllPage extends StatelessWidget {
  const TrendingAllPage({
    required this.dependencies,
    required this.userId,
    super.key,
  });

  final AppDependencies dependencies;
  final String userId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        TrendingBloc(TmdbTrendingRepository(dependencies.tmdbRemoteDataSource!))
          ..add(const TrendingRequested()),
    child: _TrendingAllView(dependencies: dependencies, userId: userId),
  );
}

class _TrendingAllView extends StatefulWidget {
  const _TrendingAllView({required this.dependencies, required this.userId});

  final AppDependencies dependencies;
  final String userId;

  @override
  State<_TrendingAllView> createState() => _TrendingAllViewState();
}

class _TrendingAllViewState extends State<_TrendingAllView> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final nearBottom =
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 300;
    if (nearBottom) {
      context.read<TrendingBloc>().add(const TrendingNextPageRequested());
    }
  }

  void _openCandidate(BuildContext context, MediaCandidate candidate) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CandidateDetailsPage(
            dependencies: widget.dependencies,
            userId: widget.userId,
            candidate: candidate,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TrendingBloc, TrendingState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const AppText('Trending Now'),
              actions: [
                if (state.loadingMore)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      );

  Widget _buildBody(BuildContext context, TrendingState state) {
    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return ContentState(
        icon: Icons.cloud_off_outlined,
        title: 'Trending unavailable',
        message: state.error!,
        actionLabel: 'Retry',
        onAction: () =>
            context.read<TrendingBloc>().add(const TrendingRequested()),
      );
    }

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.55,
            ),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return MediaGridCard.candidate(
                candidate: item,
                onTap: () => _openCandidate(context, item),
              );
            },
          ),
        ),
        // Footer: load-more indicator / end message / error
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: _buildFooter(context, state),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, TrendingState state) {
    if (state.loadingMore) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Column(
        children: [
          AppText(
            state.error!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          TextButton(
            onPressed: () => context.read<TrendingBloc>().add(
              const TrendingNextPageRequested(),
            ),
            child: const AppText('Retry'),
          ),
        ],
      );
    }
    if (!state.hasMore) {
      return Center(
        child: AppText(
          'You\'ve reached the end',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
