import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';

class ItemListAligned extends StatelessWidget {
  const ItemListAligned({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;

  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(Sizes.p8),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      separatorBuilder: (context, index) => gapH12,
    );
  }
}
