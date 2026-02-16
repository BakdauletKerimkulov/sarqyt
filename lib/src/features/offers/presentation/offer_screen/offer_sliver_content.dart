import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/rating_icon.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/features/offers/domain/rating.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_screen/ingredients_allergens.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_screen/rating_information.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class OfferSliverContent extends StatelessWidget {
  const OfferSliverContent({super.key, required this.offer});

  final Offer offer;

  Product get product => offer.product;
  Store get store => offer.store;

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
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TitleRow(offer.displayName),
                      gapH4,

                      if (product.rating != null) _RatingRow(product.rating!),
                      gapH4,
                      _CollectRow('Collect: 12:30 - 14:00'.hardcoded),
                    ],
                  ),

                  Spacer(),

                  Text(
                    product.priceWithCurrency,
                    style: TextStyle(
                      fontSize: Sizes.p20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              gapH12,

              Divider(),

              // * Адрес и информация о магазине
              ListTile(
                onTap: () => showNotImplementedAlertDialog(context: context),
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.location_on),
                title: Text(
                  store.addressInfo,
                  style: TextStyle(color: AppColors.primary),
                ),
                subtitle: Text('More information about store'.hardcoded),
                trailing: Icon(Icons.chevron_right, color: AppColors.primary),
              ),

              Divider(),

              if (product.description != null)
                _ProductDescription(
                  description: product.description!,
                  category: product.category,
                ),

              IngredientsAllergens(),

              Divider(),
              gapH12,
              if (product.rating != null)
                RatingInformation(rating: product.rating!),
              gapH16,

              if (product.packagingOption != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    gapH12,
                    Text(
                      'What you need to know'.hardcoded,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    gapH12,
                    Text(product.packagingOption!),
                    gapH16,
                    Divider(),
                  ],
                ),

              const SizedBox(height: 40.0),
            ],
          ),
        ]),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow(this.displayName);

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.shopping_bag_outlined),
        gapW12,
        Text(
          displayName,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: Sizes.p16),
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow(this.rating);

  final Rating rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingIcon(),
        gapW12,
        Text('${rating.average} (${rating.ratingCount})'),
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
      children: [Icon(Icons.watch_later_outlined), gapW12, Text(collectWindow)],
    );
  }
}

class _ProductDescription extends StatelessWidget {
  const _ProductDescription({required this.description, this.category});

  final String description;
  final String? category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you get',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        gapH12,
        Text(description),
        gapH12,
        if (category != null)
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Sizes.p12,
                  vertical: Sizes.p4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(50),
                  borderRadius: BorderRadius.circular(Sizes.p16),
                ),
                child: Text(category!),
              ),
              gapH12,
            ],
          ),
        Divider(),
      ],
    );
  }
}
