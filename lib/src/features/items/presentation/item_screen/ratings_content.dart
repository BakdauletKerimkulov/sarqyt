import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/review/data/review_repository.dart';
import 'package:sarqyt/src/features/review/domain/review.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// Aggregate rating + individual reviews for this item.
///
/// The Review model only carries two rating dimensions (storeRating,
/// offerRating) — the category bars reflect that, rather than the four
/// aspirational categories the old placeholder mocked up with no backing
/// data.
class RatingsContent extends ConsumerWidget {
  const RatingsContent({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(itemReviewsStreamProvider(itemId));
    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.surfaceContainerHighest;

    return AsyncValueWidget(
      value: reviewsAsync,
      data: (reviews) {
        final avgStore = _average(reviews.map((r) => r.storeRating));
        final avgOffer = _average(reviews.map((r) => r.offerRating));
        final overall = reviews.isEmpty
            ? null
            : reviews.map((r) => r.averageRating).reduce((a, b) => a + b) /
                  reviews.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer ratings'.hardcoded,
              style: theme.textTheme.headlineSmall,
            ),
            gapH8,
            Text(
              'We ask customers for their feedback after they collect their Surprise Bag. Here\'s what they think.'
                  .hardcoded,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            gapH24,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Sizes.p24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(Sizes.p16),
              ),
              child: Column(
                children: [
                  Text(
                    'Overall experience'.hardcoded,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  gapH8,
                  Text(
                    overall != null ? overall.toStringAsFixed(1) : '0',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  gapH8,
                  Text(
                    reviews.isEmpty
                        ? 'Not enough reviews to show a rating'.hardcoded
                        : '${reviews.length} review${reviews.length == 1 ? '' : 's'}'
                              .hardcoded,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  gapH24,
                  _RatingCategory(
                    label: 'Store experience'.hardcoded,
                    value: avgStore != null ? avgStore / 5 : null,
                    displayValue: avgStore,
                    lineColor: lineColor,
                  ),
                  gapH16,
                  _RatingCategory(
                    label: 'Offer quality'.hardcoded,
                    value: avgOffer != null ? avgOffer / 5 : null,
                    displayValue: avgOffer,
                    lineColor: lineColor,
                  ),
                ],
              ),
            ),
            if (reviews.isNotEmpty) ...[
              gapH24,
              Text('Reviews'.hardcoded, style: theme.textTheme.titleMedium),
              gapH8,
              for (final review in reviews) _ReviewTile(review: review),
            ],
          ],
        );
      },
    );
  }

  double? _average(Iterable<int> values) {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }
}

class _RatingCategory extends StatelessWidget {
  const _RatingCategory({
    required this.label,
    required this.value,
    required this.displayValue,
    required this.lineColor,
  });

  final String label;

  /// Normalized 0..1 for the progress bar.
  final double? value;

  /// Raw 1..5 average shown as text.
  final double? displayValue;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        gapH8,
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: value ?? 0,
                backgroundColor: lineColor,
                color: theme.colorScheme.primary,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            gapW12,
            SizedBox(
              width: 28,
              child: Text(
                displayValue != null ? displayValue!.toStringAsFixed(1) : '––',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
              gapW8,
              Text(
                DateFormat('d MMM yyyy').format(review.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            gapH4,
            Text(review.comment!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
