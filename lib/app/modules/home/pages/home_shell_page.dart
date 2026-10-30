import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bootstrap/app_bootstrap.dart';
import '../../../data/repositories/tmdb_trending_repository.dart';
import '../../../widgets/offline_banner.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../connectivity/bloc/connectivity_bloc.dart';
import '../../library/bloc/library_bloc.dart';
import '../../library/pages/library_page.dart';
import '../../media/domain/media_use_cases.dart';
import '../../navigation/bloc/navigation_bloc.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/pages/profile_page.dart';
import '../../search/bloc/search_bloc.dart';
import '../../search/pages/search_page.dart';
import '../bloc/home_bloc.dart';
import '../bloc/trending_bloc.dart';
import 'home_tab.dart';

class HomeShellPage extends StatelessWidget {
  const HomeShellPage({
    required this.dependencies,
    required this.userId,
    super.key,
  });

  final AppDependencies dependencies;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final repository = dependencies.mediaRepository!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc()),
        if (dependencies.tmdbRemoteDataSource != null)
          BlocProvider(
            create: (_) => TrendingBloc(
              TmdbTrendingRepository(dependencies.tmdbRemoteDataSource!),
            )..add(const TrendingRequested()),
          ),
        BlocProvider(
          create: (_) =>
              HomeBloc(WatchLibrary(repository))..add(HomeStarted(userId)),
        ),
        BlocProvider(
          create: (_) =>
              LibraryBloc(WatchLibrary(repository))
                ..add(LibraryStarted(userId)),
        ),
        BlocProvider(
          create: (_) => SearchBloc(
            SearchMovies(repository),
            SearchSeries(repository),
            SearchBooks(repository),
          ),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(
            dependencies.profileLocalDataSource!,
            dependencies.authUseCases!,
            GetLibrary(repository),
          )..add(ProfileRequested(userId)),
        ),
      ],
      child: _HomeShellView(dependencies: dependencies, userId: userId),
    );
  }
}

class _HomeShellView extends StatelessWidget {
  const _HomeShellView({required this.dependencies, required this.userId});
  final AppDependencies dependencies;
  final String userId;

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<NavigationBloc, NavigationState>(
    builder: (context, navigation) {
      final index = navigation.index;
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  if (dependencies.networkInfo != null)
                    BlocBuilder<ConnectivityBloc, ConnectivityState>(
                      builder: (context, connection) => connection.isOffline
                          ? const OfflineBanner()
                          : const SizedBox.shrink(),
                    ),
                  Expanded(
                    child: IndexedStack(
                      index: index,
                      children: [
                        HomeTab(dependencies: dependencies, userId: userId),
                        LibraryPage(dependencies: dependencies, userId: userId),
                        SearchPage(dependencies: dependencies, userId: userId),
                        ProfilePage(
                          userId: userId,
                          onSignOut: () => context.read<AuthBloc>().add(
                            const AuthSignOutRequested(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (selected) {
              if (selected == 3) {
                context.read<ProfileBloc>().add(ProfileRequested(userId));
              }
              context.read<NavigationBloc>().add(NavigationSelected(selected));
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.video_library_outlined),
                selectedIcon: Icon(Icons.video_library),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      );
    },
  );
}
