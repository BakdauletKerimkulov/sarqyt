import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/rating_icon.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/review/application/store_reviews_provider.dart';
import 'package:sarqyt/src/features/review/presentation/widgets/review_card.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({
    super.key,
    required this.storeId,
    required this.avgRating,
    required this.reviewCount,
    this.onAllReviewsTap,
  });

  final StoreID storeId;
  final double avgRating;
  final int reviewCount;
  final VoidCallback? onAllReviewsTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Empty state — no reviews
    if (reviewCount == 0) {
      return _EmptyReviewsState();
    }

    final reviewsAsync = ref.watch(
      storeReviewsProvider(storeId: storeId, limit: 3),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RatingHeader(avgRating: avgRating, reviewCount: reviewCount),
        gapH12,
        reviewsAsync.when(
          data: (reviews) => Column(
            children: [
              for (final review in reviews) ...[
                ReviewCard(review: review),
                if (review != reviews.last) const Divider(height: Sizes.p24),
              ],
            ],
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(Sizes.p16),
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Text(
              e.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
        if (reviewCount > 3 && onAllReviewsTap != null) ...[
          gapH8,
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onAllReviewsTap,
              child: Text(
                context.loc.allReviews,
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyReviewsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p16),
      child: Center(
        child: Text(
          context.loc.noReviewsYet,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ),
    );
  }
}

class _RatingHeader extends StatelessWidget {
  const _RatingHeader({required this.avgRating, required this.reviewCount});

  final double avgRating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingIcon(rating: avgRating),
        gapW12,
        Text(
          context.loc.ratingDisplay(avgRating.toStringAsFixed(1)),
          style: const TextStyle(
            fontSize: Sizes.p20,
            fontWeight: FontWeight.w600,
          ),
        ),
        gapW8,
        Text(
          '($reviewCount)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}
