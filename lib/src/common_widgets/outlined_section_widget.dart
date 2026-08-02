// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/constants/breakpoints.dart';

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
          _SectionHeader(header: header, trailing: trailing),
          Divider(thickness: 1, color: lineColor, height: 0),
          Padding(padding: const EdgeInsets.all(Sizes.p16), child: child),
        ],
      ),
    );
  }
}

/// Title row of a section, with an optional [trailing] actions widget.
///
/// On a compact window the trailing widget moves onto its own line: side by
/// side there is not enough room for both, which collapses the title to zero
/// width and overflows the row.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.header, required this.trailing});

  final String header;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final title = Text(header, style: Theme.of(context).textTheme.titleLarge);
    final windowSize = WindowSize.fromWidth(MediaQuery.sizeOf(context).width);
    final stacked = windowSize == WindowSize.compact && trailing != null;

    return Padding(
      padding: const EdgeInsets.all(Sizes.p16),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [title, gapH8, trailing!],
            )
          : Row(
              children: [
                Expanded(child: title),
                if (trailing != null) trailing!,
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
                _SectionHeader(header: header, trailing: trailing),
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
