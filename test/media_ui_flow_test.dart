import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_library_app/app/app.dart';
import 'package:my_library_app/app/data/datasources/profile_local_data_source.dart';
import 'package:my_library_app/app/modules/authentication/domain/auth_repository.dart';
import 'package:my_library_app/app/modules/authentication/domain/auth_use_cases.dart';
import 'package:my_library_app/app/modules/media/domain/media_entity.dart';
import 'package:my_library_app/app/modules/media/domain/media_status.dart';
import 'package:my_library_app/app/modules/media/domain/media_type.dart';
import 'package:my_library_app/app/theme_controller.dart';
import 'package:my_library_app/app/widgets/media_grid_card.dart';
import 'package:my_library_app/app/widgets/media_details_content.dart';
import 'package:my_library_app/app/widgets/app_text.dart';
import 'package:my_library_app/core/bootstrap/app_bootstrap.dart';

import 'media_domain_test.dart' show FakeMediaRepository;
import 'media_repository_test.dart' show MemoryStorage, FakeNetwork;

final class _SignedInAuth implements AuthRepository {
  @override
  AuthUser? get currentUser => (id: 'user', phoneNumber: '+911234567890');

  @override
  Stream<AuthUser?> authStateChanges() => Stream.value(currentUser);

  @override
  Future<bool> hasProfile() async => true;

  @override
  Future<void> saveProfile(String name, {String? email}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<bool> sendOtp(String phoneNumber, {bool resend = false}) async => true;

  @override
  Future<void> verifyOtp(String code) async {}
}

void main() {
  testWidgets('compact dark main tabs render', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime.utc(2026, 10, 29).millisecondsSinceEpoch;
    final profileLocal = ProfileLocalDataSource(MemoryStorage());
    await profileLocal.save('user', {
      'name': 'Alex',
      'phoneNumber': '+911234567890',
      'createdAt': now,
      'updatedAt': now,
    });
    await tester.pumpWidget(
      MediaLibraryApp(
        dependencies: AppDependencies(
          themeController: ThemeController(initialMode: ThemeMode.dark),
          authUseCases: AuthUseCases(_SignedInAuth()),
          mediaRepository: FakeMediaRepository(),
          profileLocalDataSource: profileLocal,
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final tab in ['Library', 'Search', 'Profile']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('details synopsis expands and collapses', (tester) async {
    final description =
        'A long synopsis about a journey across distant worlds. ' * 4;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaDetailsContent(
            title: 'Dune',
            type: MediaType.movie,
            posterUrl: null,
            description: description,
            releaseDate: '2021-01-01',
            actionLabel: 'Add to Library',
            onAction: () {},
            onBack: () {},
          ),
        ),
      ),
    );
    final synopsis = find.byWidgetPredicate(
      (widget) => widget is AppText && widget.data == description,
    );
    expect(tester.widget<AppText>(synopsis).maxLines, 3);
    await tester.tap(find.text('Read more'));
    await tester.pumpAndSettle();
    expect(tester.widget<AppText>(synopsis).maxLines, isNull);
  });

  testWidgets(
    'authenticated shell opens library, search, add flow, profile, and settings',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = FakeMediaRepository();
      final now = DateTime.utc(2026, 10, 29).millisecondsSinceEpoch;
      repository.entries['existing'] = MediaEntity(
        id: 'existing',
        mediaType: MediaType.movie,
        externalSource: ExternalSource.tmdb,
        externalId: 'existing',
        title: 'Saved Movie',
        status: MediaStatus.watching,
        notes: 'Saved note',
        createdAt: DateTime.fromMillisecondsSinceEpoch(now),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(now),
      );
      final profileLocal = ProfileLocalDataSource(MemoryStorage());
      await profileLocal.save('user', {
        'name': 'Alex',
        'phoneNumber': '+911234567890',
        'createdAt': now,
        'updatedAt': now,
      });
      final theme = ThemeController();
      final network = FakeNetwork(true);
      await tester.pumpWidget(
        MediaLibraryApp(
          dependencies: AppDependencies(
            themeController: theme,
            authUseCases: AuthUseCases(_SignedInAuth()),
            mediaRepository: repository,
            profileLocalDataSource: profileLocal,
            networkInfo: network,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your library awaits'), findsOneWidget);
      expect(find.text('Saved Movie'), findsWidgets);
      await tester.tap(find.text('Library').last);
      await tester.pumpAndSettle();
      expect(find.text('Search your library'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
      await tester.tap(find.widgetWithText(MediaGridCard, 'Saved Movie'));
      await tester.pumpAndSettle();
      network.online = false;
      await tester.pumpAndSettle();
      expect(
        find.text("You're offline. Connect to the internet to edit or delete."),
        findsOneWidget,
      );
      network.online = true;
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit in Library'));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField).last, findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).last)
            .initialValue,
        'Saved note',
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search').last);
      await tester.pumpAndSettle();
      network.online = false;
      await tester.pumpAndSettle();
      expect(find.text("You're offline. Showing cached data."), findsOneWidget);
      expect(
        find.text('External search is unavailable while offline.'),
        findsOneWidget,
      );
      network.online = true;
      await tester.pumpAndSettle();
      expect(find.text("You're offline. Showing cached data."), findsNothing);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Movies'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'New Movie');
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Add New Movie to library'));
      await tester.pumpAndSettle();
      expect(find.text('Add to Library'), findsWidgets);
      network.online = false;
      await tester.pumpAndSettle();
      expect(
        find.text("You're offline. Connect to the internet to add media."),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
            .onPressed,
        isNull,
      );
      network.online = true;
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(repository.entries.length, 2);

      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      expect(find.text('Alex'), findsWidgets);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(theme.mode, ThemeMode.dark);
      await tester.pumpWidget(const SizedBox());
      await network.events.close();
      await theme.close();
    },
  );
}
