import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

const _text =
    'Your bag is a surprise. We wish we could tell you what exactly '
    'will be in your Surprise Bag, but it\'s always a surprise! '
    'The store will fill it with a selection of their unsold items. '
    'If you have questions about allergens or specific ingredients, '
    'please ask the store or write down.';

class IngredientsAllergens extends StatelessWidget {
  const IngredientsAllergens({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(Sizes.p16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Sizes.p16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Показать анимацию'),
                    gapH16,
                    Text(
                      'Your surprise bag is a surprise'.hardcoded,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    gapH16,
                    Text(_text, textAlign: TextAlign.center),
                    gapH16,
                    PrimaryButton(
                      text: 'Got it!'.hardcoded,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients & Allergens',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: AppColors.primary),
          ),
          Spacer(),
          Icon(CupertinoIcons.chevron_right),
        ],
      ),
    );
  }
}
