import 'package:flutter/material.dart';

import 'modules/settings/pages/settings_page.dart';
import 'widgets/app_text.dart';
import 'theme_controller.dart';

abstract final class AppRouter {
  static const settings = '/settings';

  static Route<void> onGenerateRoute(
    RouteSettings route,
    ThemeController themeController,
  ) {
    switch (route.name) {
      case settings:
        return MaterialPageRoute<void>(
          settings: route,
          builder: (_) => SettingsPage(themeController: themeController),
        );
      default:
        return MaterialPageRoute<void>(
          settings: route,
          builder: (_) =>
              const Scaffold(body: Center(child: AppText('Page unavailable'))),
        );
    }
  }
}
