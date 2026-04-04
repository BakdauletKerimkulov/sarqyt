import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';

class RatingIcon extends StatelessWidget {
  const RatingIcon({super.key, this.rating, this.size = Sizes.p4});

  final double? rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasRating = rating != null && rating! > 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size + 4, vertical: size),
      decoration: BoxDecoration(
        color: hasRating ? AppColors.primary : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(Sizes.p8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: size + 12),
          SizedBox(width: size),
          Text(
            hasRating ? rating!.toStringAsFixed(1) : 'New',
            style: TextStyle(
              color: Colors.white,
              fontSize: size + 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
