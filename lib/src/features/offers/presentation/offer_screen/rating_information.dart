import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/rating_icon.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/domain/rating.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class RatingInformation extends StatelessWidget {
  const RatingInformation({super.key, required this.rating});

  final Rating rating;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'What other people are saying'.toUpperCase(),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),

        gapH12,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RatingIcon(size: Sizes.p8),
            gapW16,
            Text(
              '${rating.average} / 5.0'.hardcoded,
              style: TextStyle(
                fontSize: Sizes.p24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        gapH16,
        // TODO: Добавить хайлайты
        Text('Добавить хайлайты'.hardcoded),
        Text('Delicious food'),
        Text('Quick collection'.hardcoded),
        Text('Friendly staff'.hardcoded),
        gapH16,
        Text('Based on 122 ratings over the past 2 months'.hardcoded),
      ],
    );
  }
}
