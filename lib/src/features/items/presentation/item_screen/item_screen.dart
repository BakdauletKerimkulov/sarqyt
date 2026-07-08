// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/data/items_repository.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/overview_content.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/schedule_content.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/settings_content.dart';
import 'package:sarqyt/src/features/items/presentation/item_tab.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class ItemScreen extends ConsumerStatefulWidget {
  const ItemScreen({
    super.key,
    required this.itemId,
    required this.storeId,
    this.initialTab = ItemTab.overview,
  });

  final String itemId;
  final StoreID storeId;
  final ItemTab initialTab;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ItemScreenState();
}

class _ItemScreenState extends ConsumerState<ItemScreen>
    with SingleTickerProviderStateMixin {
  late final List<ItemTab> _filteredTabs;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _filteredTabs = ItemTab.values;
    final initialIndex = _filteredTabs.indexOf(widget.initialTab);
    _tabController = TabController(
      length: _filteredTabs.length,
      initialIndex: initialIndex.clamp(0, _filteredTabs.length - 1),
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant ItemScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      final newIndex = _filteredTabs.indexOf(widget.initialTab);
      _tabController.animateTo(
        newIndex.clamp(0, _filteredTabs.length - 1),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider =
        itemStreamProvider(id: widget.itemId, storeId: widget.storeId);

    // Pop when item is deleted (stream emits null after having data)
    ref.listen(itemProvider, (prev, next) {
      final hadItem = prev != null && prev.hasValue && prev.value != null;
      final itemGone = next.hasValue && next.value == null;
      if (hadItem && itemGone) {
        context.pop();
      }
    });

    final itemValue = ref.watch(itemProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Sizes.p32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: Sizes.p16),
              child: TextButton.icon(
                onPressed: () => context.pop(),
                label: Text('Back'),
                icon: Icon(Icons.arrow_back),
              ),
            ),
          ),
          gapH16,
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            dividerHeight: 1,
            tabs: _filteredTabs.map((tab) {
              return Tab(
                height: Sizes.p40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(tab.icon), gapW4, Text(tab.label(context.loc))],
                ),
              );
            }).toList(),
          ),
          gapH16,
          AsyncValueWidget(
            value: itemValue,
            data: (item) {
              if (item == null) return Text('No item found');
              return _buildTabContent(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(Item item) {
    return switch (_filteredTabs[_tabController.index]) {
      ItemTab.overview => OverviewContent(storeId: widget.storeId, item: item),
      ItemTab.calendar => CalendarContent(),
      ItemTab.schedule => ScheduleContent(item: item, storeId: widget.storeId),
      ItemTab.customerRatings => CustomerRatingsContent(),
      ItemTab.settings => SettingsContent(item: item, storeId: widget.storeId),
    };
  }
}

class OrdersAlignedGrid extends StatelessWidget {
  const OrdersAlignedGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Orders', style: TextStyle(color: Colors.grey)),
          Text('Coming soon', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class CalendarContent extends StatelessWidget {
  const CalendarContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Calendar', style: TextStyle(color: Colors.grey)),
          Text('Coming soon', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class CustomerRatingsContent extends StatelessWidget {
  const CustomerRatingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer ratings', style: theme.textTheme.headlineSmall),
        gapH8,
        Text(
          'We ask customers for their feedback after they collect their Surprise Bag. Here\'s what they think.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        gapH24,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Sizes.p24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(Sizes.p16),
          ),
          child: Column(
            children: [
              Text(
                'Overall experience',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              gapH8,
              Text(
                '0',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              gapH8,
              Text(
                'Not enough reviews to show a rating',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              gapH24,
              _RatingCategory(
                label: 'Collection experience',
                value: null,
                lineColor: lineColor,
              ),
              gapH16,
              _RatingCategory(
                label: 'Food quality',
                value: null,
                lineColor: lineColor,
              ),
              gapH16,
              _RatingCategory(
                label: 'Variety of contents',
                value: null,
                lineColor: lineColor,
              ),
              gapH16,
              _RatingCategory(
                label: 'Food quantity',
                value: null,
                lineColor: lineColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingCategory extends StatelessWidget {
  const _RatingCategory({
    required this.label,
    required this.value,
    required this.lineColor,
  });

  final String label;
  final double? value;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        gapH8,
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: value ?? 0,
                backgroundColor: lineColor,
                color: theme.colorScheme.primary,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            gapW12,
            SizedBox(
              width: 28,
              child: Text(
                value != null ? value!.toStringAsFixed(1) : '––',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
