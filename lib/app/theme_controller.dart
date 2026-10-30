import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class ThemeController extends Cubit<ThemeMode> {
  ThemeController({ThemeMode initialMode = ThemeMode.system, this.persistMode})
    : super(initialMode);

  final Future<void> Function(ThemeMode mode)? persistMode;

  ThemeMode get mode => state;

  Future<void> setMode(ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    await persistMode?.call(mode);
  }
}
