// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class ItemCard extends StatefulWidget {
  const ItemCard({
    super.key,
    required this.item,
    this.onPressed,
    this.onStartSelling,
    this.isSelling = false,
    this.onStopSelling,
  });

  final Item item;
  final VoidCallback? onPressed;
  final VoidCallback? onStartSelling;
  final bool isSelling;
  final VoidCallback? onStopSelling;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  Item get item => widget.item;

  static const itemCardKey = Key('item-card');

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        key: itemCardKey,
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
                  if (widget.isSelling)
                    Positioned(
                      top: Sizes.p8,
                      left: Sizes.p8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.p8,
                          vertical: Sizes.p4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(Sizes.p8),
                        ),
                        child: Text(
                          'Scheduled'.hardcoded,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: _isHovered
                            ? TextDecoration.underline
                            : null,
                        color: _isHovered ? AppColors.primary : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Text(
                      '${item.schedule.maxDayQuantity} ${item.name}s per day',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    gapH16,
                    if (widget.isSelling)
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
              gapH16,
            ],
          ),
        ),
      ),
    );
  }
}
