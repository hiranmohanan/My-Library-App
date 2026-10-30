import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/app_text.dart';
import '../bloc/auth_bloc.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({this.errorMessage, super.key});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Form(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.camera_alt_outlined, size: 28),
            ),
          ),
          const SizedBox(height: 24),
          AppText(
            'Complete Your Profile',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText(
            'This helps personalize your experience',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              labelText: 'Display Name',
              hintText: 'Alex',
            ),
            textCapitalization: TextCapitalization.words,
            maxLength: 120,
            textInputAction: TextInputAction.next,
            onSaved: (value) =>
                context.read<AuthBloc>().add(AuthProfileSubmitted(value ?? '')),
          ),
          const SizedBox(height: 12),
          TextFormField(
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              labelText: 'Email (Optional)',
              hintText: 'you@example.com',
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            maxLength: 254,
            onChanged: (value) =>
                context.read<AuthBloc>().add(AuthProfileEmailChanged(value)),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            AppText(
              errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          Builder(
            builder: (formContext) => SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Form.of(formContext).save(),
                child: const AppText('Continue'),
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthProfileRetried()),
            child: const AppText('Retry loading profile'),
          ),
          TextButton(
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthSignOutRequested()),
            child: const AppText('Sign out'),
          ),
        ],
      ),
    ),
  );
}
