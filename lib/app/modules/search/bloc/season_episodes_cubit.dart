import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/remote/tmdb_remote_data_source.dart';
import '../../../data/models/tmdb_episode.dart';

final class SeasonEpisodesState {
  const SeasonEpisodesState({
    this.episodes = const {},
    this.expandedSeasons = const {},
    this.loadingSeason,
    this.errorSeason,
  });

  /// Map of season number → list of episodes (loaded on demand).
  final Map<int, List<TmdbEpisode>> episodes;

  /// Seasons that are currently expanded in the UI.
  final Set<int> expandedSeasons;

  /// The season currently being loaded (null if idle).
  final int? loadingSeason;

  /// The season that failed to load (null if no error).
  final int? errorSeason;
}

final class SeasonEpisodesCubit extends Cubit<SeasonEpisodesState> {
  SeasonEpisodesCubit(this._tmdb, this._seriesId)
    : super(const SeasonEpisodesState());

  final TmdbRemoteDataSource _tmdb;
  final int _seriesId;

  Future<void> toggleSeason(int seasonNumber) async {
    if (state.expandedSeasons.contains(seasonNumber)) {
      emit(
        SeasonEpisodesState(
          episodes: state.episodes,
          expandedSeasons: state.expandedSeasons.difference({seasonNumber}),
          loadingSeason: state.loadingSeason,
          errorSeason: state.errorSeason,
        ),
      );
      return;
    }

    final newExpanded = {...state.expandedSeasons, seasonNumber};

    // If episodes are already cached, expand immediately without API call.
    if (state.episodes.containsKey(seasonNumber)) {
      emit(
        SeasonEpisodesState(
          episodes: state.episodes,
          expandedSeasons: newExpanded,
          loadingSeason: state.loadingSeason,
        ),
      );
      return;
    }

    emit(
      SeasonEpisodesState(
        episodes: state.episodes,
        expandedSeasons: newExpanded,
        loadingSeason: seasonNumber,
      ),
    );
    try {
      final json = await _tmdb.seasonDetails(_seriesId, seasonNumber);
      final rawEpisodes = json['episodes'];
      final episodes = <TmdbEpisode>[];
      if (rawEpisodes is List) {
        for (final raw in rawEpisodes) {
          if (raw is Map) {
            final ep = TmdbEpisode.fromJson(Map<String, Object?>.from(raw));
            if (ep != null) episodes.add(ep);
          }
        }
      }
      if (!isClosed) {
        emit(
          SeasonEpisodesState(
            episodes: {...state.episodes, seasonNumber: episodes},
            expandedSeasons: newExpanded,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          SeasonEpisodesState(
            episodes: state.episodes,
            expandedSeasons: state.expandedSeasons,
            errorSeason: seasonNumber,
          ),
        );
      }
    }
  }
}
