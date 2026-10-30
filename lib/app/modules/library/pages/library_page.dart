import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../widgets/app_text.dart';
import '../../../widgets/content_state.dart';
import '../../../widgets/loading_skeleton_list.dart';
import '../../../widgets/loading_skeleton_grid.dart';
import '../../../widgets/media_grid_card.dart';
import '../../../widgets/media_list_tile.dart';
import '../../../core/constants/media_labels.dart';
import '../../media/domain/media_status.dart';
import '../../media/domain/media_type.dart';
import '../../media_details/pages/media_details_page.dart';
import '../../navigation/bloc/navigation_bloc.dart';
import '../bloc/library_bloc.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({
    required this.dependencies,
    required this.userId,
    super.key,
  });
  final AppDependencies dependencies;
  final String userId;

  @override
  Widget build(BuildContext context) => BlocBuilder<LibraryBloc, LibraryState>(
    builder: (context, state) {
      final items = state.visibleItems;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    'My Library',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: TextField(
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search your library',
              ),
              onChanged: (value) =>
                  context.read<LibraryBloc>().add(LibraryQueryChanged(value)),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 16),
                for (final (label, type) in <(String, MediaType?)>[
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
                      onSelected: (_) => context.read<LibraryBloc>().add(
                        LibraryFilterChanged(type: type),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 16),
                for (final status in <MediaStatus?>[
                  null,
                  ...MediaStatus.values.where(
                    (status) =>
                        state.type == null || status.isAllowedFor(state.type!),
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: AppText(status?.label ?? 'All'),
                      selected: state.status == status,
                      onSelected: (_) => context.read<LibraryBloc>().add(
                        LibraryFilterChanged(type: state.type, status: status),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: state.display == LibraryDisplay.list
                      ? 'Grid view'
                      : 'List view',
                  icon: Icon(
                    state.display == LibraryDisplay.list
                        ? Icons.grid_view
                        : Icons.view_list,
                  ),
                  onPressed: () => context.read<LibraryBloc>().add(
                    LibraryDisplayChanged(
                      state.display == LibraryDisplay.list
                          ? LibraryDisplay.grid
                          : LibraryDisplay.list,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<double?>(
                  value: state.minimumRating,
                  items: const [
                    DropdownMenuItem(value: null, child: AppText('Any rating')),
                    DropdownMenuItem(value: 5.0, child: AppText('5+ rating')),
                    DropdownMenuItem(value: 8.0, child: AppText('8+ rating')),
                  ],
                  onChanged: (rating) => context.read<LibraryBloc>().add(
                    LibraryRatingChanged(rating),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<LibrarySort>(
                  value: state.sort,
                  items: const [
                    DropdownMenuItem(
                      value: LibrarySort.recentlyAdded,
                      child: AppText('Recently added'),
                    ),
                    DropdownMenuItem(
                      value: LibrarySort.title,
                      child: AppText('A–Z'),
                    ),
                    DropdownMenuItem(
                      value: LibrarySort.rating,
                      child: AppText('Rating'),
                    ),
                  ],
                  onChanged: (sort) {
                    if (sort != null) {
                      context.read<LibraryBloc>().add(LibrarySortChanged(sort));
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: state.loading
                ? state.display == LibraryDisplay.grid
                      ? const LoadingSkeletonGrid()
                      : const LoadingSkeletonList()
                : state.errorMessage != null
                ? ContentState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Could not load library',
                    message: state.errorMessage!,
                    actionLabel: 'Retry',
                    onAction: () =>
                        context.read<LibraryBloc>().add(LibraryStarted(userId)),
                  )
                : items.isEmpty
                ? ContentState(
                    icon: state.items.isEmpty
                        ? Icons.video_library_outlined
                        : Icons.filter_alt_off_outlined,
                    title: state.items.isEmpty
                        ? 'Your library is empty'
                        : 'No matches',
                    message: state.items.isEmpty
                        ? 'Start adding your favorite movies, series and books.'
                        : 'Try a different search or filter.',
                    actionLabel: state.items.isEmpty ? 'Explore Content' : null,
                    onAction: state.items.isEmpty
                        ? () => context.read<NavigationBloc>().add(
                            const NavigationSelected(2),
                          )
                        : null,
                  )
                : state.display == LibraryDisplay.list
                ? ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return MediaListTile(
                        media: item,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => MediaDetailsPage(
                              dependencies: dependencies,
                              userId: userId,
                              mediaId: item.id,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : LayoutBuilder(
                    builder: (context, constraints) => GridView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (constraints.maxWidth / 112)
                            .floor()
                            .clamp(2, 5),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.58,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return MediaGridCard(
                          media: item,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => MediaDetailsPage(
                                dependencies: dependencies,
                                userId: userId,
                                mediaId: item.id,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      );
    },
  );
}
