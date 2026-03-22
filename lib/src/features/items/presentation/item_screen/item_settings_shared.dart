import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';

extension DietaryTypeLabel on DietaryType {
  String get label => switch (this) {
    DietaryType.notSpecified => 'Not specified',
    DietaryType.vegetarian => 'Vegetarian',
  };
}

extension PackagingOptionLabel on PackagingOption {
  String get label => switch (this) {
    PackagingOption.withBag => 'Food container and bag',
    PackagingOption.withBagOrOwnBag =>
      'Food container and bag, customer may bring their own bag',
    PackagingOption.noBag => 'Food container, no bag',
  };
}

class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ),
        gapW16,
        Expanded(child: child),
      ],
    );
  }
}
