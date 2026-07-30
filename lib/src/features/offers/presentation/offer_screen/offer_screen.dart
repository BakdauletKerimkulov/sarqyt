// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/decorated_box_with_shadow.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/offers/data/favorites_repository.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_screen/offer_app_bar.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_ui_helpers.dart';
import 'package:sarqyt/src/features/review/presentation/widgets/reviews_section.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/client_router.dart';

class OfferScreen extends ConsumerWidget {
  const OfferScreen({required this.offerId, super.key});

  final OfferID offerId;

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    String storeId,
    String storeName,
    bool isFav,
  ) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;
    final repo = ref.read(favoritesRepositoryProvider);
    try {
      if (isFav) {
        await repo.removeFavorite(user.uid, storeId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.loc.removedFromFavorites(storeName)),
            ),
          );
        }
      } else {
        await repo.addFavorite(user.uid, storeId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.loc.addedToFavorites(storeName))),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.loc.failedToUpdateFavorites)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(offerStreamProvider(offerId), (prev, next) {
      if (prev?.value != null && next.value == null && !next.isLoading) {
        context.goNamed(ClientRoute.home.name);
      }
    });
    final offerValue = ref.watch(offerStreamProvider(offerId));
    final favIds = ref.watch(favoriteStoreIdsProvider).value ?? const {};

    return Scaffold(
      appBar: offerValue.value == null
          ? AppBar(leading: BackButton(onPressed: () => context.pop()))
          : null,
      body: AsyncValueWidget(
        value: offerValue,
        data: (offer) {
          if (offer == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text(context.loc.offerNotFound)],
              ),
            );
          }
          final isFav = favIds.contains(offer.storeId);
          return CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            slivers: [
              OfferSliverAppBar(
                offer,
                isFavorite: isFav,
                onFavoriteToggle: () => _toggleFavorite(
                  context,
                  ref,
                  offer.storeId,
                  offer.storeName,
                  isFav,
                ),
              ),
              OfferSliverContent(offer: offer),
            ],
          );
        },
      ),
      bottomNavigationBar: DecoratedBoxWithShadow(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: offerValue.value != null && !offerValue.value!.isAvailable
                ? PrimaryButton(onPressed: null, text: context.loc.soldOut)
                : PrimaryButton(
                    onPressed: () => context.goNamed(
                      ClientRoute.checkout.name,
                      pathParameters: {'id': offerId},
                    ),
                    text: context.loc.reserve,
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
                        _CollectRow(
                          'Collect: ${offer.pickupLabelLocalized(context)}',
                        ),
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
                  pathParameters: {'id': offer.id, 'offerId': offer.id},
                ),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on),
                title: Text(
                  offer.storeAddress ?? context.loc.addressNotSpecified,
                  style: const TextStyle(color: AppColors.primary),
                ),
                subtitle: Text(context.loc.moreInfoAboutStore),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                ),
              ),
              const Divider(),
              gapH8,
              Text(
                context.loc.offerStatus(offer.status.localizedLabel(context)),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              gapH8,
              Text(context.loc.availableItemsCount(offer.quantity)),
              gapH16,
              const Divider(),
              gapH12,
              Text(context.loc.offerDetailsSnapshot),
              gapH16,
              const Divider(),
              gapH12,
              ReviewsSection(
                storeId: offer.storeId,
                avgRating: offer.storeAvgRating,
                reviewCount: offer.storeReviewCount,
                onAllReviewsTap: () => context.pushNamed(
                  ClientRoute.storeReviews.name,
                  pathParameters: {'storeId': offer.storeId},
                  queryParameters: {'storeName': offer.storeName},
                ),
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
