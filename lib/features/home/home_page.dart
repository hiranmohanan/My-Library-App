import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_router.dart';
import '../../app/modules/navigation/bloc/navigation_bloc.dart';
import '../../core/widgets/feature_placeholder.dart';
import '../../app/widgets/app_text.dart';

class HomePage extends StatelessWidget {
  const HomePage({this.onSignOut, super.key});

  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => NavigationBloc(),
    child: _HomeView(onSignOut: onSignOut),
  );
}

class _HomeView extends StatelessWidget {
  const _HomeView({this.onSignOut});

  final VoidCallback? onSignOut;

  static const _titles = ['Home', 'Library', 'Search', 'Profile'];
  static const _pages = [
    FeaturePlaceholder(
      icon: Icons.auto_stories_outlined,
      title: 'Your Library',
      message: 'Your movies, series, and books will appear here.',
    ),
    FeaturePlaceholder(
      icon: Icons.video_library_outlined,
      title: 'Library',
      message: 'Saved media will appear here when the library is connected.',
    ),
    FeaturePlaceholder(
      icon: Icons.search,
      title: 'Search',
      message: 'Search across movies, series, and books will be added here.',
    ),
  ];

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) => _buildPage(context, state.index),
      );

  Widget _buildPage(BuildContext context, int index) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(_titles[index]),
        actions: [
          if (index == 3)
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRouter.settings),
            ),
        ],
      ),
      body: IndexedStack(
        index: index,
        children: [
          ..._pages,
          Column(
            children: [
              const Expanded(
                child: FeaturePlaceholder(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  message: 'Manage your library account.',
                ),
              ),
              if (onSignOut != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: onSignOut,
                    icon: const Icon(Icons.logout),
                    label: const AppText('Sign out'),
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (selected) =>
            context.read<NavigationBloc>().add(NavigationSelected(selected)),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            label: 'Library',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
