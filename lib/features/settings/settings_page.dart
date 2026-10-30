import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/theme_controller.dart';
import '../../app/widgets/app_text.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({required this.themeController, super.key});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeController, ThemeMode>(
      bloc: themeController,
      builder: (context, mode) => Scaffold(
        appBar: AppBar(title: const AppText('Settings')),
        body: ListView(
          children: [
            const ListTile(title: AppText('Appearance')),
            RadioGroup<ThemeMode>(
              groupValue: mode,
              onChanged: (value) async {
                if (value == null) return;
                try {
                  await themeController.setMode(value);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: AppText(
                          'Could not save your theme preference.',
                        ),
                      ),
                    );
                  }
                }
              },
              child: Column(
                children: [
                  for (final (mode, label) in [
                    (ThemeMode.system, 'System'),
                    (ThemeMode.light, 'Light'),
                    (ThemeMode.dark, 'Dark'),
                  ])
                    RadioListTile<ThemeMode>(
                      title: AppText(label),
                      value: mode,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
