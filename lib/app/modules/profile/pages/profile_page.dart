import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/app_text.dart';
import '../../../widgets/content_state.dart';
import '../../../widgets/loading_skeleton_list.dart';
import '../../navigation/bloc/navigation_bloc.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.userId, required this.onSignOut, super.key});
  final String userId;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => BlocBuilder<ProfileBloc, ProfileState>(
    builder: (context, state) {
      if (state.loading) {
        return const LoadingSkeletonList(itemCount: 3);
      }
      final profile = state.profile;
      if (profile == null) {
        return ContentState(
          icon: Icons.person_off_outlined,
          title: 'Profile unavailable',
          message:
              state.errorMessage ?? 'Please try loading your profile again.',
          actionLabel: 'Retry',
          onAction: () =>
              context.read<ProfileBloc>().add(ProfileRequested(userId)),
        );
      }
      return ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  'Profile',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.of(context).pushNamed('/settings'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Center(
            child: Icon(
              Icons.account_circle_outlined,
              size: 80,
              semanticLabel: 'Profile avatar',
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: AppText(
              profile.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Center(child: AppText(profile.phoneNumber)),
          if (profile.email != null) Center(child: AppText(profile.email!)),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatTile(count: state.movies, label: 'Movies'),
              const SizedBox(height: 42, child: VerticalDivider()),
              _StatTile(count: state.series, label: 'Series'),
              const SizedBox(height: 42, child: VerticalDivider()),
              _StatTile(count: state.books, label: 'Books'),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.video_library_outlined),
            title: const AppText('My Library'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                context.read<NavigationBloc>().add(const NavigationSelected(1)),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const AppText('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/settings'),
          ),
          const Divider(),
          Form(
            child: Column(
              children: [
                TextFormField(
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  initialValue: profile.name,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 120,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Edit name',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (name) => context.read<ProfileBloc>().add(
                    ProfileNameSubmitted(name ?? ''),
                  ),
                  onFieldSubmitted: (name) => context.read<ProfileBloc>().add(
                    ProfileNameSubmitted(name),
                  ),
                ),
                Builder(
                  builder: (formContext) => FilledButton(
                    onPressed: state.saving
                        ? null
                        : () => Form.of(formContext).save(),
                    child: const AppText('Save name'),
                  ),
                ),
              ],
            ),
          ),
          if (state.saving) const LinearProgressIndicator(),
          if (state.errorMessage != null)
            AppText(
              state.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            label: const AppText('Sign out'),
          ),
        ],
      );
    },
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        AppText('$count', style: Theme.of(context).textTheme.headlineSmall),
        AppText(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}
