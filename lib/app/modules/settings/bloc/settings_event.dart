part of 'settings_bloc.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

final class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

final class SettingsThemeSelected extends SettingsEvent {
  const SettingsThemeSelected(this.mode);
  final ThemeMode mode;
}

final class _SettingsThemeObserved extends SettingsEvent {
  const _SettingsThemeObserved(this.mode);
  final ThemeMode mode;
}
