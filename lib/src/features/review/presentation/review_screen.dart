import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/review/presentation/review_controller.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({
    super.key,
    required this.orderId,
    required this.storeId,
    required this.storeName,
  });

  final OrderID orderId;
  final StoreID storeId;
  final String storeName;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _storeRating = 0;
  int _foodRating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewControllerProvider);

    ref.listen(reviewControllerProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });

    return Scaffold(
      appBar: AppBar(title: Text('Leave a review'.hardcoded)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Sizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.storeName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            gapH32,

            // Store rating
            Text(
              'How was the store?'.hardcoded,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            gapH12,
            _StarRow(
              rating: _storeRating,
              onChanged: (v) => setState(() => _storeRating = v),
            ),
            gapH24,

            // Food rating
            Text(
              'How was the food?'.hardcoded,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            gapH12,
            _StarRow(
              rating: _foodRating,
              onChanged: (v) => setState(() => _foodRating = v),
            ),
            gapH24,

            // Comment
            Text(
              'Any comments? (optional)'.hardcoded,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            gapH12,
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us about your experience'.hardcoded,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(Sizes.p12),
                ),
              ),
            ),
            gapH32,

            PrimaryButton(
              text: 'Submit review'.hardcoded,
              isLoading: state.isLoading,
              onPressed: state.isLoading || _storeRating == 0 || _foodRating == 0
                  ? null
                  : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final success = await ref
        .read(reviewControllerProvider.notifier)
        .submitReview(
          orderId: widget.orderId,
          storeId: widget.storeId,
          storeRating: _storeRating,
          foodRating: _foodRating,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        );
    if (success && mounted) {
      context.pop();
    }
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, required this.onChanged});

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          iconSize: 40,
          onPressed: () => onChanged(starIndex),
          icon: Icon(
            starIndex <= rating ? Icons.star : Icons.star_border,
            color: starIndex <= rating ? Colors.amber : Colors.grey,
          ),
        );
      }),
    );
  }
}
