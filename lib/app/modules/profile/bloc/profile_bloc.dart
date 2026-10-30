import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/profile_local_data_source.dart';
import '../../authentication/domain/auth_use_cases.dart';
import '../../media/domain/media_type.dart';
import '../../media/domain/media_use_cases.dart';
import '../domain/profile_entity.dart';

part 'profile_event.dart';
part 'profile_state.dart';

final class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._local, this._auth, this._library)
    : super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
    on<ProfileNameSubmitted>(_onNameSubmitted);
  }

  final ProfileLocalDataSource _local;
  final AuthUseCases _auth;
  final GetLibrary _library;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileState(loading: true));
    try {
      if (_auth.currentUser?.id != event.userId) {
        throw StateError('Authentication required.');
      }
      final record = await _local.read(event.userId);
      if (record == null) throw StateError('Profile unavailable.');
      final profile = ProfileEntity(
        id: event.userId,
        name: record['name'] as String,
        phoneNumber: record['phoneNumber'] as String,
        email: record['email'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          record['createdAt'] as int,
        ),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          record['updatedAt'] as int,
        ),
      );
      final media = await _library(event.userId);
      emit(
        ProfileState(
          profile: profile,
          movies: media
              .where((item) => item.mediaType == MediaType.movie)
              .length,
          series: media
              .where((item) => item.mediaType == MediaType.series)
              .length,
          books: media.where((item) => item.mediaType == MediaType.book).length,
        ),
      );
    } catch (_) {
      emit(const ProfileState(errorMessage: 'Could not load your profile.'));
    }
  }

  Future<void> _onNameSubmitted(
    ProfileNameSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.saving) return;
    final name = event.name.trim();
    if (name.isEmpty || name.length > 120) {
      emit(
        state.copyWith(errorMessage: 'Enter a name of 1 to 120 characters.'),
      );
      return;
    }
    final profile = state.profile;
    if (profile == null) {
      emit(
        state.copyWith(errorMessage: 'Load your profile before editing it.'),
      );
      return;
    }
    emit(state.copyWith(saving: true, clearError: true));
    try {
      await _auth.saveProfile(name);
      final record = await _local.read(profile.id);
      if (record == null) throw StateError('Profile unavailable.');
      emit(
        state.copyWith(
          saving: false,
          profile: ProfileEntity(
            id: profile.id,
            name: name,
            phoneNumber: profile.phoneNumber,
            email: profile.email,
            createdAt: profile.createdAt,
            updatedAt: DateTime.fromMillisecondsSinceEpoch(
              record['updatedAt'] as int,
            ),
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage: 'Could not save your profile.',
        ),
      );
    }
  }
}
