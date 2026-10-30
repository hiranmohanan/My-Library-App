import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_library_app/app/app.dart';
import 'package:my_library_app/app/theme_controller.dart';
import 'package:my_library_app/core/bootstrap/app_bootstrap.dart';

void main() {
  testWidgets('navigation and theme setting work', (tester) async {
    final controller = ThemeController();
    await tester.pumpWidget(
      MediaLibraryApp(
        dependencies: AppDependencies(themeController: controller),
      ),
    );

    expect(find.text('Your Library'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Manage your library account.'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(controller.mode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.text('Appearance'))).brightness,
      Brightness.dark,
    );
  });
}
