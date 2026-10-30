import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../widgets/app_text.dart';
import '../../../widgets/loading_skeleton_list.dart';
import '../../../widgets/media_editor_fields.dart';
import '../../../widgets/media_poster.dart';
import '../../../core/constants/media_labels.dart';
import '../../connectivity/bloc/connectivity_bloc.dart';
import '../../media/domain/media_candidate.dart';
import '../../media/domain/media_use_cases.dart';
import '../bloc/add_media_bloc.dart';

class AddMediaPage extends StatelessWidget {
  const AddMediaPage({
    required this.dependencies,
    required this.userId,
    required this.candidate,
    super.key,
  });
  final AppDependencies dependencies;
  final String userId;
  final MediaCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final repository = dependencies.mediaRepository!;
    return BlocProvider(
      create: (_) =>
          AddMediaBloc(GetExternalDetails(repository), AddMedia(repository))
            ..add(AddMediaCandidateSelected(candidate)),
      child: _AddMediaView(
        userId: userId,
        networkAware: dependencies.networkInfo != null,
      ),
    );
  }
}

class _AddMediaView extends StatelessWidget {
  const _AddMediaView({required this.userId, required this.networkAware});
  final String userId;
  final bool networkAware;

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<AddMediaBloc, AddMediaState>(
    listenWhen: (previous, current) =>
        previous.saved == null && current.saved != null,
    listener: (context, state) => Navigator.of(context).pop(),
    child: BlocBuilder<AddMediaBloc, AddMediaState>(
      builder: (context, state) {
        final offline =
            networkAware && context.watch<ConnectivityBloc>().state.isOffline;
        final candidate = state.candidate;
        return Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: candidate == null
                  ? const LoadingSkeletonList(itemCount: 3)
                  : ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 48,
                                height: 68,
                                child: MediaPoster(
                                  title: candidate.title,
                                  url: candidate.posterUrl,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    candidate.title,
                                    maxLines: 2,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  AppText(
                                    candidate.mediaType.label,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AppText(
                          'Add to Library',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        MediaEditorFields(
                          type: candidate.mediaType,
                          status: state.status,
                          rating: state.rating,
                          notes: state.notes,
                          onStatusChanged: (status) => context
                              .read<AddMediaBloc>()
                              .add(AddMediaStatusChanged(status)),
                          onRatingChanged: (rating) => context
                              .read<AddMediaBloc>()
                              .add(AddMediaRatingChanged(rating)),
                          onNotesChanged: (notes) => context
                              .read<AddMediaBloc>()
                              .add(AddMediaNotesChanged(notes)),
                        ),
                        if (state.errorMessage != null)
                          AppText(
                            state.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        if (offline)
                          const AppText(
                            "You're offline. Connect to the internet to add media.",
                          ),
                        const SizedBox(height: 20),
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
                                onPressed: state.saving || offline
                                    ? null
                                    : () => context.read<AddMediaBloc>().add(
                                        AddMediaSaveRequested(userId),
                                      ),
                                child: AppText(
                                  state.saving ? 'Saving…' : 'Save',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    ),
  );
}
