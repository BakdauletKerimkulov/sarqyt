// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/decorated_box_with_shadow.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_screen/offer_app_bar.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/client_router.dart';

class OfferScreen extends ConsumerWidget {
  const OfferScreen({required this.offerId, super.key});

  final OfferID offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerFutureProvider(offerId));

    return Scaffold(
      appBar: offerAsync.value == null
          ? AppBar(leading: BackButton(onPressed: () => context.pop()))
          : null,
      body: AsyncValueWidget(
        value: offerAsync,
        data: (offer) {
          return offer != null
              ? CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    OfferSliverAppBar(offer),
                    OfferSliverContent(offer: offer),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Offer not found'.hardcoded)],
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
                pathParameters: {'id': offerId},
              ),
              text: 'Reserve'.hardcoded,
            ),
          ),
        ),
      ),
    );
  }
}

class OfferSliverContent extends StatelessWidget {
  const OfferSliverContent({super.key, required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.p16,
        vertical: Sizes.p8,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TitleRow(offer.name),
                        gapH8,
                        _CollectRow('Collect: ${offer.pickupLabel}'),
                      ],
                    ),
                  ),
                  Text(
                    '${offer.price.round()} ${offer.currencySymbol}',
                    style: const TextStyle(
                      fontSize: Sizes.p20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              gapH12,
              const Divider(),
              ListTile(
                onTap: () => context.goNamed(
                  ClientRoute.store.name,
                  pathParameters: {
                    'id': offer.id,
                    'offerId': offer.id,
                  },
                ),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on),
                title: Text(
                  offer.storeAddress ?? 'Address is not specified'.hardcoded,
                  style: const TextStyle(color: AppColors.primary),
                ),
                subtitle: Text('More information about store'.hardcoded),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                ),
              ),
              const Divider(),
              gapH8,
              Text(
                'Status: ${offer.status.label()}'.hardcoded,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              gapH8,
              Text('Available items: ${offer.quantity}'.hardcoded),
              gapH16,
              const Divider(),
              gapH12,
              Text(
                'Offer details are loaded from store and product snapshot at creation time.'
                    .hardcoded,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ]),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.shopping_bag_outlined),
        gapW12,
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: Sizes.p16,
          ),
        ),
      ],
    );
  }
}

class _CollectRow extends StatelessWidget {
  const _CollectRow(this.collectWindow);

  final String collectWindow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.watch_later_outlined),
        gapW12,
        Text(collectWindow),
      ],
    );
  }
}
