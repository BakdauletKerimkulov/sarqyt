import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class StoreInfo extends ConsumerWidget {
  const StoreInfo(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerFutureProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: AsyncValueWidget(
        value: offerAsync,
        data: (offer) {
          if (offer == null) {
            return Center(child: Text('Store not found'.hardcoded));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + name
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: customImageProvider(offer.storeLogo),
                      ),
                      gapH16,
                      Text(
                        offer.storeName,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                gapH24,
                const Divider(),
                gapH16,

                // Address
                if (offer.storeAddress != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 20, color: Colors.grey),
                      gapW8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Address'.hardcoded,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            gapH4,
                            Text(offer.storeAddress!),
                          ],
                        ),
                      ),
                    ],
                  ),
                  gapH16,
                ],

                // Pickup info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.schedule, size: 20, color: Colors.grey),
                    gapW8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup'.hardcoded,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          gapH4,
                          Text(offer.pickupLabel),
                        ],
                      ),
                    ),
                  ],
                ),
                gapH16,

                // Available
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        size: 20, color: Colors.grey),
                    gapW8,
                    Text(
                      'Available'.hardcoded,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    Text(offer.availableText),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
