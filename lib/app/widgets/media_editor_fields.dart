import 'package:flutter/material.dart';

import '../core/constants/media_labels.dart';
import '../modules/media/domain/media_status.dart';
import '../modules/media/domain/media_type.dart';
import 'app_text.dart';

class MediaEditorFields extends StatelessWidget {
  const MediaEditorFields({
    required this.type,
    required this.status,
    required this.rating,
    required this.notes,
    required this.onStatusChanged,
    required this.onRatingChanged,
    required this.onNotesChanged,
    super.key,
  });

  final MediaType type;
  final MediaStatus status;
  final double? rating;
  final String? notes;
  final ValueChanged<MediaStatus> onStatusChanged;
  final ValueChanged<double?> onRatingChanged;
  final ValueChanged<String?> onNotesChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filledStars = ((rating ?? 0) / 2).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText('Status', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final choice in MediaStatus.values.where(
              (choice) => choice.isAllowedFor(type),
            ))
              ChoiceChip(
                label: AppText(choice.label),
                selected: choice == status,
                onSelected: (_) => onStatusChanged(choice),
              ),
          ],
        ),
        const SizedBox(height: 24),
        AppText('Rating', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var star = 1; star <= 5; star++)
              IconButton(
                tooltip: 'Rate $star of 5 stars',
                onPressed: () =>
                    onRatingChanged(filledStars == star ? null : star * 2.0),
                icon: Icon(
                  star <= filledStars ? Icons.star : Icons.star_border,
                  color: star <= filledStars
                      ? colors.tertiary
                      : colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        AppText('Notes', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: notes,
          maxLines: 3,
          maxLength: 10000,
          decoration: const InputDecoration(hintText: 'Add a note…'),
          onChanged: (value) => onNotesChanged(value.isEmpty ? null : value),
        ),
      ],
    );
  }
}
