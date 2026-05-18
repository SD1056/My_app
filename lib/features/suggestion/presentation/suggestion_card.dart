import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../record/domain/record.dart';

class SuggestionCard extends StatelessWidget {
  final Record suggestion;
  final VoidCallback onAccept;
  final VoidCallback onModify;
  final VoidCallback onSkip;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.onAccept,
    required this.onModify,
    required this.onSkip,
  });

  String get _emoji =>
      kCategories.firstWhere((c) => c.name == suggestion.category, orElse: () => kCategories.last).emoji;

  String get _displayValue {
    if (suggestion.category == '지출') {
      final amount = int.tryParse(suggestion.value) ?? 0;
      return '${NumberFormat('#,###').format(amount)}원';
    }
    return suggestion.value;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: colorScheme.secondary),
                const SizedBox(width: 6),
                Text(
                  'AI 제안',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: colorScheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(_emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(suggestion.category,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(_displayValue,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('수락'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onModify,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('수정'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onSkip,
                  icon: const Icon(Icons.close),
                  tooltip: '건너뜀',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
