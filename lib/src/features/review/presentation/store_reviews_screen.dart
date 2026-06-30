import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/review/application/store_reviews_provider.dart';
import 'package:sarqyt/src/features/review/presentation/widgets/review_card.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class StoreReviewsScreen extends ConsumerWidget {
  const StoreReviewsScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  final StoreID storeId;
  final String storeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(
      storeReviewsProvider(storeId: storeId, limit: 50),
    );

    return Scaffold(
      appBar: AppBar(title: Text(storeName)),
      body: AsyncValueWidget(
        value: reviewsAsync,
        data: (reviews) {
          if (reviews.isEmpty) {
            return Center(
              child: Text(
                context.loc.noReviewsYet,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(Sizes.p16),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const Divider(height: Sizes.p24),
            itemBuilder: (_, index) => ReviewCard(review: reviews[index]),
          );
        },
      ),
    );
  }
}
