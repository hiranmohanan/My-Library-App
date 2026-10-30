import 'package:flutter/material.dart';

import 'app_text.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: AppText(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      if (actionLabel != null && onAction != null)
        TextButton(
          onPressed: onAction,
          child: AppText(
            actionLabel!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
    ],
  );
}
