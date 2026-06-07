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
            RatingIcon(rating: rating.average, size: Sizes.p8),
            gapW16,
            Text(
              context.loc.ratingDisplay(rating.average.toString()),
              style: TextStyle(
                fontSize: Sizes.p24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        gapH16,
        // TODO: Добавить хайлайты
        Text(context.loc.addHighlights),
        Text('Delicious food'),
        Text(context.loc.quickCollection),
        Text(context.loc.friendlyStaff),
        gapH16,
        Text(context.loc.basedOnRatings),
      ],
    );
  }
}
