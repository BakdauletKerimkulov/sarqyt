// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/checkout/application/checkout_service.dart';
import 'package:sarqyt/src/features/checkout/presentation/item_quantity_selector.dart';
import 'package:sarqyt/src/features/checkout/presentation/payment_button_controller.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/client_router.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class PaymentPage extends ConsumerWidget {
  const PaymentPage({super.key, required this.offerId});

  final OfferID offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerFutureProvider(offerId));
    final buttonState = ref.watch(paymentButtonControllerProvider);

    ref.listen(paymentButtonControllerProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });

    return AsyncValueWidget(
      value: offerAsync,
      data: (offer) {
        if (offer == null) return Text('Offer not found');

        final quantity = ref.watch(offerItemsQuantityProvider);
        final total = offer.price * quantity;
        final isLoading = buttonState.isLoading;

        return Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gapH16,
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: customImageProvider(offer.storeLogo),
                      radius: 32,
                    ),
                    gapH16,
                    Text(
                      offer.storeName,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    gapH8,
                    Text(offer.pickupLabel),
                  ],
                ),
              ),
              gapH12,
              const Divider(),
              gapH12,
              Text(
                'Payment method'.toUpperCase().hardcoded,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: Colors.grey),
              ),
              gapH8,
              const _PaymentMethodCard(),
              const Spacer(),
              TotalWidget(total: total, currency: offer.currencySymbol),
              gapH12,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
                child: Text(
                  'By reserving this meal you agree to Sarqyt\'s terms & conditions'
                      .hardcoded,
                  textAlign: TextAlign.center,
                ),
              ),
              gapH24,
              Row(
                children: [
                  ItemQuantitySelector(
                    quantity: quantity,
                    maxQuantity: offer.quantity,
                    onChanged: isLoading
                        ? null
                        : (value) => ref
                              .read(offerItemsQuantityProvider.notifier)
                              .setQuantity(value),
                  ),
                  gapW16,
                  Expanded(
                    child: PrimaryButton(
                      isLoading: isLoading,
                      text: 'Pay'.hardcoded,
                      onPressed: isLoading
                          ? null
                          : () => _onPay(context, ref, offer, quantity),
                    ),
                  ),
                ],
              ),
              gapH48,
            ],
          ),
        );
      },
    );
  }

  Future<void> _onPay(
    BuildContext context,
    WidgetRef ref,
    Offer offer,
    int quantity,
  ) async {
    final (result, orderId) = await ref
        .read(paymentButtonControllerProvider.notifier)
        .submitPayment(
          offerId: offer.id,
          quantity: quantity,
          storeName: offer.storeName,
        );
    if (!context.mounted) return;

    switch (result) {
      case PaymentResult.success:
        if (orderId != null) {
          context.goNamed(
            ClientRoute.orderDetail.name,
            pathParameters: {'orderId': orderId},
          );
        } else {
          context.goNamed(ClientRoute.orders.name);
        }
      case PaymentResult.cancelled:
        break; // Stay on page
      case PaymentResult.error:
        break; // Error dialog shown by listener
    }
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.p12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(Sizes.p12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(Sizes.p4),
            ),
            child: const Icon(Icons.credit_card, size: 20, color: Colors.grey),
          ),
          gapW12,
          Expanded(
            child: Text(
              'Card payment'.hardcoded,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            'Selected at checkout'.hardcoded,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class TotalWidget extends StatelessWidget {
  const TotalWidget({super.key, required this.total, required this.currency});

  final double total;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.titleMedium;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.p16,
        vertical: Sizes.p8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(40),
        borderRadius: BorderRadius.circular(Sizes.p12),
      ),
      child: Row(
        children: [
          Text('Total'.hardcoded, style: textTheme),
          const Spacer(),
          Text('$currency${total.round()}', style: textTheme),
        ],
      ),
    );
  }
}
