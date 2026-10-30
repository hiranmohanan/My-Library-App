part of 'home_bloc.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class HomeStarted extends HomeEvent {
  const HomeStarted(this.userId);
  final String userId;
}

final class _HomeLibraryChanged extends HomeEvent {
  const _HomeLibraryChanged(this.request, this.items);
  final int request;
  final List<MediaEntity> items;
}

final class _HomeFailed extends HomeEvent {
  const _HomeFailed(this.request, this.message);
  final int request;
  final String message;
}
