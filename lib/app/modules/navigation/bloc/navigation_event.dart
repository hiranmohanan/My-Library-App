part of 'navigation_bloc.dart';

sealed class NavigationEvent {
  const NavigationEvent();
}

final class NavigationSelected extends NavigationEvent {
  const NavigationSelected(this.index);

  final int index;
}
