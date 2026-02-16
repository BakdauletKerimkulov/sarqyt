// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';

class IconTitleSubtitle extends StatelessWidget {
  const IconTitleSubtitle({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.size,
  });

  final Widget leading;
  final double? size;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        gapW16,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: Sizes.p16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(subtitle, style: TextStyle(fontSize: Sizes.p12)),
          ],
        ),
      ],
    );
  }
}
