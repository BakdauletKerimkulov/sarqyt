import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';

class RatingIcon extends StatelessWidget {
  const RatingIcon({super.key, this.size = Sizes.p4});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(Sizes.p8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size, vertical: size),
        child: Icon(Icons.star, color: Colors.white, size: size + 12),
      ),
    );
  }
}
