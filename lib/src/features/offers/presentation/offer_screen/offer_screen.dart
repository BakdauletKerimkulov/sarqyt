// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/decorated_box_with_shadow.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_screen/offer_app_bar.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_screen/offer_sliver_content.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/client_router.dart';

class OfferScreen extends ConsumerWidget {
  const OfferScreen({required this.productId, super.key});

  final ProductID productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerFutureProvider(productId));

    return Scaffold(
      body: AsyncValueWidget(
        value: offerAsync,
        data: (offer) {
          return offer != null
              ? Stack(
                  children: [
                    CustomScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      slivers: [
                        OfferSliverAppBar(offer),
                        OfferSliverContent(offer: offer),
                      ],
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    children: [
                      Text('Offer not found'.hardcoded),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text('Go back'.hardcoded),
                      ),
                    ],
                  ),
                );
        },
      ),
      bottomNavigationBar: DecoratedBoxWithShadow(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              onPressed: () => context.goNamed(
                ClientRoute.checkout.name,
                pathParameters: {'id': productId},
              ),
              text: 'Reserve'.hardcoded,
            ),
          ),
        ),
      ),
    );
  }
}
