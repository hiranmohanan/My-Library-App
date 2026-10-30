import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../widgets/app_text.dart';
import '../../../widgets/content_state.dart';
import '../../../widgets/loading_skeleton_list.dart';
import '../../../widgets/media_details_content.dart';
import '../../../widgets/media_editor_fields.dart';
import '../../connectivity/bloc/connectivity_bloc.dart';
import '../../media/domain/media_entity.dart';
import '../../media/domain/media_use_cases.dart';
import '../bloc/media_details_bloc.dart';

class MediaDetailsPage extends StatelessWidget {
  const MediaDetailsPage({
    required this.dependencies,
    required this.userId,
    required this.mediaId,
    super.key,
  });

  final AppDependencies dependencies;
  final String userId;
  final String mediaId;

  @override
  Widget build(BuildContext context) {
    final repository = dependencies.mediaRepository!;
    return BlocProvider(
      create: (_) => MediaDetailsBloc(
        GetMediaDetails(repository),
        UpdateStatus(repository),
        UpdateRating(repository),
        UpdateNotes(repository),
        DeleteMedia(repository),
        update: UpdateMedia(repository),
      )..add(MediaDetailsRequested(userId, mediaId)),
      child: _MediaDetailsView(
        userId: userId,
        mediaId: mediaId,
        networkAware: dependencies.networkInfo != null,
      ),
    );
  }
}

class _MediaDetailsView extends StatelessWidget {
  const _MediaDetailsView({
    required this.userId,
    required this.mediaId,
    required this.networkAware,
  });

  final String userId;
  final String mediaId;
  final bool networkAware;

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<MediaDetailsBloc, MediaDetailsState>(
    listenWhen: (previous, current) =>
        current.stage == MediaDetailsStage.deleted,
    listener: (context, state) => Navigator.of(context).pop(),
    child: BlocBuilder<MediaDetailsBloc, MediaDetailsState>(
      builder: (context, state) {
        final offline =
            networkAware && context.watch<ConnectivityBloc>().state.isOffline;
        final item = state.item;
        return Scaffold(
          appBar: item == null ? AppBar(title: const AppText('Details')) : null,
          body: item == null
              ? SafeArea(
                  child: state.stage == MediaDetailsStage.loading
                      ? const LoadingSkeletonList(itemCount: 4)
                      : ContentState(
                          icon: Icons.search_off,
                          title: state.stage == MediaDetailsStage.notFound
                              ? 'Item not found'
                              : 'Could not load item',
                          message:
                              state.errorMessage ??
                              'This item is not available in your library.',
                          actionLabel: state.stage == MediaDetailsStage.notFound
                              ? null
                              : 'Retry',
                          onAction: state.stage == MediaDetailsStage.notFound
                              ? null
                              : () => context.read<MediaDetailsBloc>().add(
                                  MediaDetailsRequested(userId, mediaId),
                                ),
                        ),
                )
              : MediaDetailsContent(
                  title: item.title,
                  type: item.mediaType,
                  posterUrl: item.posterUrl,
                  description: item.description,
                  releaseDate: item.releaseDate,
                  rating: item.rating,
                  actionLabel: 'Edit in Library',
                  actionEnabled:
                      state.stage == MediaDetailsStage.ready && !offline,
                  onBack: () => Navigator.of(context).pop(),
                  onAction: () => _showEditSheet(context, item),
                  footer: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (offline)
                        const AppText(
                          "You're offline. Connect to the internet to edit or delete.",
                        ),
                      if (state.errorMessage != null)
                        AppText(
                          state.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed:
                            state.stage == MediaDetailsStage.ready && !offline
                            ? () => _confirmDelete(context)
                            : null,
                        icon: const Icon(Icons.delete_outline),
                        label: const AppText('Delete'),
                      ),
                    ],
                  ),
                ),
        );
      },
    ),
  );

  Future<void> _showEditSheet(BuildContext context, MediaEntity item) async {
    final bloc = context.read<MediaDetailsBloc>();
    bloc.add(const MediaEditStarted());
    await bloc.stream.firstWhere((state) => state.editing);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.82,
          child: _EditMediaSheet(userId: userId, mediaId: mediaId, item: item),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText('Delete this item?'),
        content: const AppText('This removes it from your library.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const AppText('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const AppText('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<MediaDetailsBloc>().add(
        MediaDeleteRequested(userId, mediaId),
      );
    }
  }
}

class _EditMediaSheet extends StatelessWidget {
  const _EditMediaSheet({
    required this.userId,
    required this.mediaId,
    required this.item,
  });

  final String userId;
  final String mediaId;
  final MediaEntity item;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MediaDetailsBloc, MediaDetailsState>(
        builder: (context, state) => Material(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  AppText(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  MediaEditorFields(
                    type: item.mediaType,
                    status: state.draftStatus ?? item.status,
                    rating: state.draftRating,
                    notes: state.draftNotes,
                    onStatusChanged: (value) => context
                        .read<MediaDetailsBloc>()
                        .add(MediaEditStatusChanged(value)),
                    onRatingChanged: (value) => context
                        .read<MediaDetailsBloc>()
                        .add(MediaEditRatingChanged(value)),
                    onNotesChanged: (value) => context
                        .read<MediaDetailsBloc>()
                        .add(MediaEditNotesChanged(value)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const AppText('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            context.read<MediaDetailsBloc>().add(
                              MediaChangesSaved(
                                userId,
                                mediaId,
                                state.draftStatus ?? item.status,
                                state.draftRating,
                                state.draftNotes,
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          child: const AppText('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
