import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

final class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(0)) {
    on<NavigationSelected>((event, emit) {
      if (event.index >= 0 && event.index < 4) {
        emit(NavigationState(event.index));
      }
    });
  }
}
