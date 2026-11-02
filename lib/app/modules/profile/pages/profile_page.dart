import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/app_text.dart';
import '../../../widgets/content_state.dart';
import '../../library/bloc/library_bloc.dart';
import '../../media/domain/media_type.dart';
import '../../navigation/bloc/navigation_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../domain/profile_entity.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.userId, required this.onSignOut, super.key});
  final String userId;
  final VoidCallback onSignOut;

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) => BlocConsumer<ProfileBloc, ProfileState>(
    listenWhen: (previous, current) =>
        previous.errorMessage != current.errorMessage &&
        current.errorMessage != null,
    listener: (context, state) {
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(state.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    },
    builder: (context, state) {
      if (state.loading) {
        return const _ProfileSkeleton();
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

      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final created = profile.createdAt;
      final memberSince =
          'Member since ${_monthNames[created.month - 1]} ${created.year}';
      final totalLibraryCount = state.movies + state.series + state.books;

      return ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // Top bar with header and settings shortcut
          Row(
            children: [
              Expanded(
                child: AppText(
                  'Profile',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.of(context).pushNamed('/settings'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Hero Profile Card
          Center(child: _ProfileAvatar(name: profile.name, size: 92)),
          const SizedBox(height: 16),
          Center(
            child: AppText(
              profile.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: AppText(
              memberSince,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Contact pills
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(icon: Icons.phone_outlined, label: profile.phoneNumber),
              if (profile.email != null && profile.email!.isNotEmpty)
                _InfoPill(icon: Icons.mail_outline, label: profile.email!),
            ],
          ),
          const SizedBox(height: 16),

          // Edit profile button
          Center(
            child: FilledButton.tonalIcon(
              onPressed: () => _openEditProfileSheet(context, profile),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const AppText('Edit Profile'),
            ),
          ),
          const SizedBox(height: 28),

          // Library Overview Header
          AppText(
            'Library Overview',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Media Stat Cards Grid
          Row(
            children: [
              _MediaStatCard(
                count: state.movies,
                label: 'Movies',
                icon: Icons.movie_outlined,
                onTap: () => _navigateToLibrary(context, MediaType.movie),
              ),
              const SizedBox(width: 12),
              _MediaStatCard(
                count: state.series,
                label: 'Series',
                icon: Icons.tv_outlined,
                onTap: () => _navigateToLibrary(context, MediaType.series),
              ),
              const SizedBox(width: 12),
              _MediaStatCard(
                count: state.books,
                label: 'Books',
                icon: Icons.menu_book_outlined,
                onTap: () => _navigateToLibrary(context, MediaType.book),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Preferences & Shortcuts Section
          AppText(
            'Preferences',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.video_library_outlined),
                  title: const AppText('My Library'),
                  subtitle: AppText('$totalLibraryCount items saved'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.read<NavigationBloc>().add(
                    const NavigationSelected(1),
                  ),
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 16,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const AppText('Appearance & Theme'),
                  subtitle: const AppText('Customize app styling'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pushNamed('/settings'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sign out button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout),
            label: const AppText('Sign out'),
          ),
        ],
      );
    },
  );

  void _navigateToLibrary(BuildContext context, MediaType type) {
    context.read<LibraryBloc>().add(LibraryFilterChanged(type: type));
    context.read<NavigationBloc>().add(const NavigationSelected(1));
  }

  Future<void> _openEditProfileSheet(
    BuildContext context,
    ProfileEntity profile,
  ) async {
    final bloc = context.read<ProfileBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _EditProfileSheet(profile: profile),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout),
        title: const AppText('Sign out of your account?'),
        content: const AppText(
          'You will need to sign in again to view and synchronize your library.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const AppText('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const AppText('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onSignOut();
    }
  }
}

// ── Profile Avatar Widget with Initials & Gradient ───────────────────────────

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name, this.size = 88});

  final String name;
  final double size;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: AppText(
        _initials,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Contact Info Pill ────────────────────────────────────────────────────────

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          AppText(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Media Stat Card ──────────────────────────────────────────────────────────

class _MediaStatCard extends StatelessWidget {
  const _MediaStatCard({
    required this.count,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final int count;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Expanded(
      child: Material(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24, color: colorScheme.primary),
                const SizedBox(height: 8),
                AppText(
                  '$count',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                AppText(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Edit Profile Modal Sheet ──────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profile});

  final ProfileEntity profile;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ProfileBloc>().add(ProfileNameSubmitted(_nameController.text));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ProfileBloc, ProfileState>(
    builder: (context, state) => Material(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      'Edit Profile',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 120,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _nameController.clear(),
                    ),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Please enter your name.';
                    if (trimmed.length > 120) {
                      return 'Name cannot exceed 120 characters.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Read-only account info
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Phone Number',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        AppText(
                          widget.profile.phoneNumber,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.profile.email != null &&
                  widget.profile.email!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mail_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Email Address',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          AppText(
                            widget.profile.email!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const AppText('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: state.saving ? null : () => _onSave(context),
                      child: state.saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const AppText('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ── Profile Skeleton Loading View ─────────────────────────────────────────────

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Row(
          children: [
            Container(
              width: 120,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 160,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 96,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 32),
        Container(
          height: 128,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }
}
