import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/app_text.dart';
import '../bloc/auth_bloc.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({
    required this.phoneNumber,
    required this.otpCode,
    required this.resendSeconds,
    this.errorMessage,
    super.key,
  });

  final String phoneNumber;
  final String otpCode;
  final int resendSeconds;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Back to phone number',
        onPressed: () => context.read<AuthBloc>().add(const AuthBackToPhone()),
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: Form(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
        children: [
          AppText(
            'Enter Verification Code',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          AppText(
            "We've sent a 6-digit code to\n$phoneNumber",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            height: 56,
            child: Stack(
              children: [
                Row(
                  children: List.generate(
                    6,
                    (index) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index == 5 ? 0 : 8),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: errorMessage == null
                                ? null
                                : Border.all(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                          ),
                          child: AppText(
                            index < otpCode.length ? otpCode[index] : '',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.01,
                    alwaysIncludeSemantics: true,
                    child: TextFormField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Verification code',
                        counterText: '',
                      ),
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 6,
                      onChanged: (value) =>
                          context.read<AuthBloc>().add(AuthOtpChanged(value)),
                      onSaved: (value) => context.read<AuthBloc>().add(
                        AuthOtpSubmitted(value ?? ''),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            AppText(
              errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 28),
          Center(
            child: SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: resendSeconds / 60,
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onSurface,
                    backgroundColor: Theme.of(context).colorScheme.outline,
                  ),
                  AppText(
                    '${(resendSeconds ~/ 60).toString().padLeft(2, '0')}:${(resendSeconds % 60).toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Builder(
            builder: (formContext) => SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Form.of(formContext).save(),
                child: const AppText('Verify'),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: resendSeconds > 0
                  ? null
                  : () => context.read<AuthBloc>().add(const AuthOtpResent()),
              child: AppText(
                'Resend code',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
