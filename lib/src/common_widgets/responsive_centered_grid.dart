import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/constants/breakpoints.dart';

class ResponsiveCenteredGrid extends StatelessWidget {
  const ResponsiveCenteredGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return SizedBox(
        height: 400.0,
        child: const Center(child: Text('No products')),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Breakpoint.desktop),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Ширина карточки не будет превышать 300 пикселей.
            // Flutter сам решит, поставить 2, 3 или 4 в ряд.
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: Sizes.p16,
                crossAxisSpacing: Sizes.p16,
                childAspectRatio: 0.75,
              ),
            );
          },
        ),
      ),
    );
  }
}
