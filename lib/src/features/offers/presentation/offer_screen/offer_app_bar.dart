import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/common_widgets/info_badge.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';

class OfferSliverAppBar extends ConsumerWidget {
  const OfferSliverAppBar(this.offer, {super.key});

  final Offer offer;

  static const _expandedHeight = 250.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: _expandedHeight,
      stretch: true,
      flexibleSpace: LayoutBuilder(
        builder: (context, c) {
          final settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;

          final deltaExtent = settings.maxExtent - settings.minExtent;
          final t =
              ((settings.currentExtent - settings.minExtent) / deltaExtent)
                  .clamp(0.0, 1.0);
          final opacity = 1.0 - t;

          return FlexibleSpaceBar(
            stretchModes: [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            centerTitle: true,
            title: Opacity(
              opacity: opacity,
              child: Text(
                offer.storeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                CustomImage(imageUrl: offer.productImage),

                Positioned(
                  left: Sizes.p16,
                  bottom: Sizes.p24,
                  child: Opacity(
                    opacity: 1 - opacity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoBadge(text: offer.availableText),
                        gapH8,
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: customImageProvider(
                                offer.storeLogo,
                              ),
                              radius: Sizes.p32,
                            ),
                            gapW8,
                            Text(
                              offer.storeName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Sizes.p20,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
