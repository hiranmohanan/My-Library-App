import 'package:flutter/material.dart';

import 'app_text.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.errorContainer,
    child: SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.wifi_off, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: AppText(
                "You're offline. Showing cached data.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
