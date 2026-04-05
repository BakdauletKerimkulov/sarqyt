// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';

class OutlinedSectionWidget extends StatelessWidget {
  const OutlinedSectionWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(color: lineColor, width: 1),
        borderRadius: BorderRadius.circular(Sizes.p16),
      ),
      child: Padding(padding: const EdgeInsets.all(Sizes.p16), child: child),
    );
  }
}

class OutlinedSectionWidgetWithHeader extends StatelessWidget {
  const OutlinedSectionWidgetWithHeader({
    super.key,
    required this.header,
    required this.child,
    this.trailing,
  });

  final String header;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(width: 1, color: lineColor),
        borderRadius: BorderRadius.circular(Sizes.p16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    header,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Divider(thickness: 1, color: lineColor, height: 0),
          Padding(padding: const EdgeInsets.all(Sizes.p16), child: child),
        ],
      ),
    );
  }
}

class OutlinedSectionSliverWidgetWithHeader extends StatelessWidget {
  const OutlinedSectionSliverWidgetWithHeader({
    super.key,
    required this.header,
    required this.sliver,
    this.trailing,
  });

  final String header;
  final Widget sliver;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return DecoratedSliver(
      decoration: BoxDecoration(
        border: BoxBorder.all(width: 1, color: lineColor),
        borderRadius: BorderRadius.circular(Sizes.p16),
      ),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Sizes.p16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          header,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ),
                Divider(thickness: 1, color: lineColor, height: 0),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Sizes.p16),
            sliver: sliver,
          ),
        ],
      ),
    );
  }
}
