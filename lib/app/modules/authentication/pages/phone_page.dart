import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/app_text.dart';
import '../bloc/auth_bloc.dart';

class PhonePage extends StatelessWidget {
  const PhonePage({required this.countryCode, this.errorMessage, super.key});

  final String? errorMessage;
  final String countryCode;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Back to welcome',
        onPressed: () =>
            context.read<AuthBloc>().add(const AuthBackToWelcome()),
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: Form(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          AppText('Sign In', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          AppText(
            "We'll send a verification code to your phone number",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              PopupMenuButton<String>(
                tooltip: 'Country code',
                initialValue: countryCode,
                onSelected: (code) =>
                    context.read<AuthBloc>().add(AuthCountrySelected(code)),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: '+1', child: AppText('+1  US/Canada')),
                  PopupMenuItem(value: '+44', child: AppText('+44  UK')),
                  PopupMenuItem(value: '+91', child: AppText('+91  India')),
                  PopupMenuItem(value: '+61', child: AppText('+61  Australia')),
                ],
                child: Container(
                  width: 84,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(countryCode),
                      const Icon(Icons.keyboard_arrow_down, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: '987 654 3210',
                  ),
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  textInputAction: TextInputAction.done,
                  onSaved: (value) => context.read<AuthBloc>().add(
                    AuthPhoneSubmitted(value ?? ''),
                  ),
                  onFieldSubmitted: (value) =>
                      context.read<AuthBloc>().add(AuthPhoneSubmitted(value)),
                ),
              ),
            ],
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            AppText(
              errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          Builder(
            builder: (formContext) => SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Form.of(formContext).save(),
                child: const AppText('Send Code'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
