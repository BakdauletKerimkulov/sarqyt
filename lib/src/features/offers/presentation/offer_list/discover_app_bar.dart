import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/application/discover_filter.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

const _kSearchDebounce = Duration(milliseconds: 300);

class DiscoverAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const DiscoverAppBar({
    super.key,
    this.bottom,
    this.onFilterPressed,
    this.hasActiveFilters = false,
  });

  final PreferredSizeWidget? bottom;
  final VoidCallback? onFilterPressed;
  final bool hasActiveFilters;

  @override
  ConsumerState<DiscoverAppBar> createState() => _DiscoverAppBarState();

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }
}

class _DiscoverAppBarState extends ConsumerState<DiscoverAppBar> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  var _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {}); // refresh clear-button visibility
    _debounce?.cancel();
    _debounce = Timer(_kSearchDebounce, () {
      ref.read(discoverFilterControllerProvider.notifier).setSearchQuery(value);
    });
  }

  void _openSearch() => setState(() => _searching = true);

  void _closeSearch() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(discoverFilterControllerProvider.notifier).setSearchQuery('');
    setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
      leading: _searching
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _closeSearch,
            )
          : null,
      title: _searching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: context.loc.searchOffersHint,
                border: InputBorder.none,
              ),
              onChanged: _onQueryChanged,
            )
          : Text(context.loc.discover),
      centerTitle: !_searching,
      actions: [
        if (_searching && _searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _onQueryChanged('');
            },
          )
        else if (!_searching)
          IconButton(icon: const Icon(Icons.search), onPressed: _openSearch),
        if (widget.onFilterPressed != null)
          IconButton(
            icon: Icon(
              widget.hasActiveFilters
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
            onPressed: widget.onFilterPressed,
          ),
      ],
      bottom: widget.bottom,
    );
  }
}

enum ListMapToggle { list, map }

class ListMapToggleWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const ListMapToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(Sizes.p12);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Sizes.p16,
        horizontal: Sizes.p32,
      ),
      child: Material(
        color: Colors.grey.shade300,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: Sizes.p40,
          child: TabBar(
            splashBorderRadius: radius,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              borderRadius: radius,
              color: AppColors.primary,
            ),
            tabs: ListMapToggle.values.map((c) => Tab(text: c.name)).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(Sizes.p40 + Sizes.p16 * 2);
}
