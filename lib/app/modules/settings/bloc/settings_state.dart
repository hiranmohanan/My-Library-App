part of 'settings_bloc.dart';

final class SettingsState {
  const SettingsState({
    required this.mode,
    this.saving = false,
    this.errorMessage,
  });

  final ThemeMode mode;
  final bool saving;
  final String? errorMessage;
}
