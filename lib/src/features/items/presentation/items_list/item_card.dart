// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class ItemCard extends StatefulWidget {
  const ItemCard({
    super.key,
    required this.item,
    this.currentOffer,
    this.onPressed,
    this.onStartSelling,
    this.onStopSelling,
  });

  final Item item;
  final Offer? currentOffer;
  final VoidCallback? onPressed;
  final VoidCallback? onStartSelling;
  final VoidCallback? onStopSelling;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  Item get item => widget.item;
  Offer? get offer => widget.currentOffer;

  bool _isHovered = false;

  bool get _isSellingNow {
    if (offer == null) return false;
    final now = DateTime.now();
    return offer!.pickupStartTime.isBefore(now) &&
        offer!.pickupEndTime.isAfter(now);
  }

  bool get _isScheduled => item.isActive && offer != null && !_isSellingNow;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: widget.onPressed,
        onHover: (value) => setState(() => _isHovered = value),
        hoverColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p4),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(Sizes.p12),
                    child: CustomImage(
                      imageUrl: item.imageUrl,
                      aspectRatio: 1.5,
                    ),
                  ),
                  if (_isSellingNow)
                    Positioned(
                      top: Sizes.p8,
                      left: Sizes.p8,
                      child: _Badge(
                        text: 'Selling now'.hardcoded,
                        color: Colors.green,
                      ),
                    )
                  else if (_isScheduled)
                    Positioned(
                      top: Sizes.p8,
                      left: Sizes.p8,
                      child: _Badge(
                        text: 'Scheduled'.hardcoded,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
              gapH8,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.p8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item.name,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: _isHovered
                                    ? TextDecoration.underline
                                    : null,
                                color:
                                    _isHovered ? AppColors.primary : null,
                              ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Selling now info
                    if (_isSellingNow && offer != null) ...[
                      gapH4,
                      Text(
                        '${offer!.quantity} available'.hardcoded,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        offer!.pickupLabel,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '${item.schedule.maxDayQuantity} per day'.hardcoded,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],

                    gapH12,

                    // Actions
                    if (item.isActive)
                      TextButton(
                        onPressed: widget.onStopSelling,
                        child: Text('Not ready yet?'.hardcoded),
                      )
                    else
                      PrimaryWebButton(
                        text: 'Start selling'.hardcoded,
                        onPressed: widget.onStartSelling,
                      ),
                  ],
                ),
              ),
              gapH8,
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.p8,
        vertical: Sizes.p4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(200),
        borderRadius: BorderRadius.circular(Sizes.p8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
