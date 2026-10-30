import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme_controller.dart';

part 'settings_event.dart';
part 'settings_state.dart';

final class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._theme) : super(SettingsState(mode: _theme.mode)) {
    on<SettingsStarted>((event, emit) {
      _subscription ??= _theme.stream.listen(
        (mode) => add(_SettingsThemeObserved(mode)),
      );
      emit(SettingsState(mode: _theme.mode));
    });
    on<_SettingsThemeObserved>(
      (event, emit) => emit(SettingsState(mode: event.mode)),
    );
    on<SettingsThemeSelected>(_onThemeSelected);
  }

  final ThemeController _theme;
  StreamSubscription<ThemeMode>? _subscription;

  Future<void> _onThemeSelected(
    SettingsThemeSelected event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsState(mode: state.mode, saving: true));
    try {
      await _theme.setMode(event.mode);
      emit(SettingsState(mode: event.mode));
    } catch (_) {
      emit(
        SettingsState(
          mode: _theme.mode,
          errorMessage: 'Could not save theme preference.',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
