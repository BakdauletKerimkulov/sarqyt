import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/constants/breakpoints.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

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

class ResponsiveSliverAlignedGrid extends StatelessWidget {
  const ResponsiveSliverAlignedGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  /// Total number of items to display.
  final int itemCount;

  /// Function used to build a widget for a given index in the grid.
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(
            'No products found'.hardcoded,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );
    }
    // use a LayoutBuilder to determine the crossAxisCount
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        // width of the screen
        final width = constraints.crossAxisExtent;
        // max width allowed for the sliver
        final maxWidth = min(width, Breakpoint.desktop);
        // use 1 column for width < 500px
        // then add one more column for each 250px
        final crossAxisCount = max(1, maxWidth ~/ 250);
        // calculate a "responsive" padding that increases
        // when the width is greater than the desktop breakpoint
        // this is used to center the content horizontally on large screens
        final padding = width > Breakpoint.desktop + Sizes.p32
            ? (width - Breakpoint.desktop) / 2
            : Sizes.p16;
        return SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: Sizes.p16,
          ),
          sliver: SliverAlignedGrid.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: Sizes.p24,
            crossAxisSpacing: Sizes.p24,
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          ),
        );
      },
    );
  }
}
