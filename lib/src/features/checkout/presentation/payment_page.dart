// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/checkout/application/checkout_service.dart';
import 'package:sarqyt/src/features/checkout/presentation/item_quantity_selector.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class PaymentPage extends ConsumerWidget {
  const PaymentPage({super.key, required this.productID});

  final ItemID productID;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerFutureProvider(productID));
    return AsyncValueWidget(
      value: offerAsync,
      data: (offer) {
        final quantity = ref.watch(offerItemsQuantityProvider);
        final total = offer != null ? offer.price * quantity : null;
        return offer != null
            ? Padding(
                padding: const EdgeInsets.all(Sizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    gapH16,
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: customImageProvider(
                              offer.storeLogo,
                            ),
                            radius: 32,
                          ),
                          gapH16,
                          Text(
                            offer.storeName,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          gapH16,
                          Text('время забора'.hardcoded),
                        ],
                      ),
                    ),

                    gapH12,
                    Divider(),
                    gapH12,
                    Text('Payment method'.toUpperCase().hardcoded),
                    // TODO: подключить платежную систему
                    gapH64,
                    TotalWidget(total: total!, currency: offer.currencySymbol),
                    gapH12,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.p16,
                      ),
                      child: Text(
                        'By recerving this meal you agree to Sarqyt\'s terms & conditions'
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
                          onChanged: (value) => ref
                              .read(offerItemsQuantityProvider.notifier)
                              .setQuantity(value),
                        ),

                        gapW16,
                        Expanded(
                          child: PrimaryButton(
                            text: 'Pay'.hardcoded,
                            onPressed: () =>
                                showNotImplementedAlertDialog(context: context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Text('Offer not found');
      },
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
      padding: EdgeInsets.symmetric(horizontal: Sizes.p16, vertical: Sizes.p8),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(40),
        borderRadius: BorderRadius.circular(Sizes.p12),
      ),
      child: Row(
        children: [
          Text('Total'.hardcoded, style: textTheme),
          Spacer(),
          Text('$currency$total', style: textTheme),
        ],
      ),
    );
  }
}
