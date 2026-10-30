import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../widgets/app_text.dart';
import '../../../widgets/media_details_content.dart';
import '../../add_media/pages/add_media_page.dart';
import '../../media/domain/media_candidate.dart';
import '../../media/domain/media_use_cases.dart';
import '../bloc/candidate_details_bloc.dart';

class CandidateDetailsPage extends StatelessWidget {
  const CandidateDetailsPage({
    required this.dependencies,
    required this.userId,
    required this.candidate,
    super.key,
  });

  final AppDependencies dependencies;
  final String userId;
  final MediaCandidate candidate;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => CandidateDetailsCubit(
      GetExternalDetails(dependencies.mediaRepository!),
      candidate,
    )..load(),
    child: BlocBuilder<CandidateDetailsCubit, CandidateDetailsState>(
      builder: (context, state) => Scaffold(
        body: MediaDetailsContent(
          title: state.candidate.title,
          type: state.candidate.mediaType,
          posterUrl: state.candidate.posterUrl,
          description: state.candidate.description,
          releaseDate: state.candidate.releaseDate,
          actionLabel: 'Add to Library',
          onBack: () => Navigator.of(context).pop(),
          onAction: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.82,
              child: AddMediaPage(
                dependencies: dependencies,
                userId: userId,
                candidate: state.candidate,
              ),
            ),
          ),
          footer: state.loading
              ? const LinearProgressIndicator()
              : state.error == null
              ? null
              : AppText(state.error!),
        ),
      ),
    ),
  );
}
