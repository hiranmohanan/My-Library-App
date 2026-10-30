part of 'profile_bloc.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

final class ProfileRequested extends ProfileEvent {
  const ProfileRequested(this.userId);
  final String userId;
}

final class ProfileNameSubmitted extends ProfileEvent {
  const ProfileNameSubmitted(this.name);
  final String name;
}
