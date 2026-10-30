import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme_controller.dart';
import '../../../widgets/app_text.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({required this.themeController, super.key});
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SettingsBloc(themeController)..add(const SettingsStarted()),
    child: BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const AppText('Settings')),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  'Appearance',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final mode in [
                    ThemeMode.light,
                    ThemeMode.dark,
                    ThemeMode.system,
                  ])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _ThemePreviewCard(
                          mode: mode,
                          selected: state.mode == mode,
                          onTap: state.saving
                              ? null
                              : () => context.read<SettingsBloc>().add(
                                  SettingsThemeSelected(mode),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (state.errorMessage != null)
              ListTile(
                title: AppText(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = mode == ThemeMode.dark;
    final previewBackground = dark ? const Color(0xFF1C1C1E) : Colors.white;
    final previewBlock = dark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE4E4E7);
    final label = switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 0.72,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: mode == ThemeMode.system
                    ? colors.surfaceContainerHighest
                    : previewBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? colors.secondary : colors.outline,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 28, height: 5, color: previewBlock),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Row(
                          children: [
                            for (var index = 0; index < 2; index++) ...[
                              Expanded(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: previewBlock,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              if (index == 0) const SizedBox(width: 4),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(width: 42, height: 5, color: previewBlock),
                    ],
                  ),
                  if (mode == ThemeMode.system)
                    Positioned.fill(
                      left: 45,
                      child: ColoredBox(color: const Color(0x991C1C1E)),
                    ),
                  if (selected)
                    const Positioned(
                      left: 2,
                      bottom: 2,
                      child: Icon(Icons.check_circle, size: 20),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          AppText(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
