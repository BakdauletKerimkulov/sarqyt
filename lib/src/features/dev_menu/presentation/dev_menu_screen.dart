import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/routing/business_redirect_state.dart';
import 'package:sarqyt/src/routing/business_router.dart';

// ── Route metadata ──

/// Maps each [BusinessRoute] to its GoRouter path pattern.
const _routePaths = <BusinessRoute, String>{
  BusinessRoute.login: '/login',
  BusinessRoute.loading: '/loading',
  BusinessRoute.onboarding: '/onboarding',
  BusinessRoute.inbound: '/onboarding/inbound',
  BusinessRoute.createAccount: '/onboarding/inbound/create-account',
  BusinessRoute.reviewDetails: '/onboarding/inbound/review-details',
  BusinessRoute.email: '/onboarding/inbound/email',
  BusinessRoute.verifyEmail: '/onboarding/inbound/verify-email',
  BusinessRoute.welcome: '/onboarding/welcome',
  BusinessRoute.stores: '/stores',
  BusinessRoute.addStore: '/stores/add',
  BusinessRoute.dashboard: '/stores/:storeId/dashboard',
  BusinessRoute.newItem: '/stores/:storeId/new-item',
  BusinessRoute.item: '/stores/:storeId/item/:itemId',
  BusinessRoute.team: '/stores/:storeId/team',
  BusinessRoute.performance: '/stores/:storeId/performance',
  BusinessRoute.financials: '/stores/:storeId/financials',
  BusinessRoute.settings: '/stores/:storeId/settings',
  BusinessRoute.helpCentre: '/stores/:storeId/help',
  BusinessRoute.forbidden: '/forbidden',
  BusinessRoute.dev: '/dev',
};

enum _RouteCategory { onboarding, store, settings, other }

_RouteCategory _categorize(BusinessRoute route) => switch (route) {
      BusinessRoute.createAccount ||
      BusinessRoute.reviewDetails ||
      BusinessRoute.email ||
      BusinessRoute.verifyEmail ||
      BusinessRoute.welcome ||
      BusinessRoute.onboarding ||
      BusinessRoute.inbound =>
        _RouteCategory.onboarding,
      BusinessRoute.dashboard ||
      BusinessRoute.newItem ||
      BusinessRoute.item ||
      BusinessRoute.team ||
      BusinessRoute.performance ||
      BusinessRoute.financials ||
      BusinessRoute.stores ||
      BusinessRoute.addStore ||
      BusinessRoute.helpCentre =>
        _RouteCategory.store,
      BusinessRoute.settings => _RouteCategory.settings,
      _ => _RouteCategory.other,
    };

String _categoryLabel(_RouteCategory cat) => switch (cat) {
      _RouteCategory.onboarding => 'Onboarding',
      _RouteCategory.store => 'Store / Dashboard',
      _RouteCategory.settings => 'Settings',
      _RouteCategory.other => 'Other',
    };

/// Extracts param names like `:storeId` from a path pattern.
List<String> _extractParams(String path) {
  final matches = RegExp(r':(\w+)').allMatches(path);
  return matches.map((m) => m.group(1)!).toList();
}

/// True for routes that are blocked by admin redirect (onboarding paths).
bool _needsDevMenuBypass(String path) => path.startsWith('/onboarding');
// ── Screen ──

class DevMenuScreen extends ConsumerStatefulWidget {
  const DevMenuScreen({super.key});

  @override
  ConsumerState<DevMenuScreen> createState() => _DevMenuScreenState();
}

class _DevMenuScreenState extends ConsumerState<DevMenuScreen> {
  /// Stores the current text value for each path parameter.
  /// Key format: `routeName:paramName`.
  final _paramValues = <String, String>{};

  String _searchQuery = '';
  String? _defaultStoreId;

  @override
  void initState() {
    super.initState();
    // Pre-fill storeId from the first completed storeShip, if any.
    final redirectState = ref.read(businessRedirectStateProvider);
    final completed =
        redirectState.storeShips.where((s) => s.welcomeCompleted);
    if (completed.isNotEmpty) {
      _defaultStoreId = completed.first.storeId;
    }
  }

  String _resolvedPath(BusinessRoute route) {
    final pattern = _routePaths[route] ?? '/${route.name}';
    final params = _extractParams(pattern);
    var resolved = pattern;
    for (final param in params) {
      final key = '${route.name}:$param';
      final value =
          _paramValues[key] ?? (param == 'storeId' ? _defaultStoreId : null);
      resolved = resolved.replaceFirst(':$param', value ?? ':$param');
    }
    if (_needsDevMenuBypass(resolved)) {
      final separator = resolved.contains('?') ? '&' : '?';
      resolved = '$resolved${separator}devMenu=true';
    }
    return resolved;
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.toLowerCase();
    final routes = BusinessRoute.values.where((r) {
      if (r == BusinessRoute.dev) return false;
      if (query.isEmpty) return true;
      final path = _routePaths[r] ?? '/${r.name}';
      return r.name.toLowerCase().contains(query) ||
          path.toLowerCase().contains(query);
    }).toList();

    // Group by category, preserving enum order within each group.
    final grouped = <_RouteCategory, List<BusinessRoute>>{};
    for (final route in routes) {
      final cat = _categorize(route);
      (grouped[cat] ??= []).add(route);
    }

    // Ordered categories.
    const categoryOrder = _RouteCategory.values;

    return Scaffold(
      appBar: AppBar(title: const Text('Dev Menu')),
      body: ListView(
        padding: const EdgeInsets.all(Sizes.p16),
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Filter routes...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          for (final cat in categoryOrder)
            if (grouped[cat] case final routes?)
              _CategorySection(
                label: _categoryLabel(cat),
                routes: routes,
                paramValues: _paramValues,
                defaultStoreId: _defaultStoreId,
                onParamChanged: (key, value) =>
                    setState(() => _paramValues[key] = value),
                onRouteTap: (route) => context.go(_resolvedPath(route)),
                resolvedPathFor: _resolvedPath,
              ),
        ],
      ),
    );
  }
}

// ── Extracted widgets ──

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.label,
    required this.routes,
    required this.paramValues,
    required this.defaultStoreId,
    required this.onParamChanged,
    required this.onRouteTap,
    required this.resolvedPathFor,
  });

  final String label;
  final List<BusinessRoute> routes;
  final Map<String, String> paramValues;
  final String? defaultStoreId;
  final void Function(String key, String value) onParamChanged;
  final ValueChanged<BusinessRoute> onRouteTap;
  final String Function(BusinessRoute) resolvedPathFor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: Sizes.p16, bottom: Sizes.p8),
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        for (final route in routes)
          _RouteItem(
            route: route,
            paramValues: paramValues,
            defaultStoreId: defaultStoreId,
            onParamChanged: onParamChanged,
            onTap: () => onRouteTap(route),
            resolvedPath: resolvedPathFor(route),
          ),
      ],
    );
  }
}

class _RouteItem extends StatelessWidget {
  const _RouteItem({
    required this.route,
    required this.paramValues,
    required this.defaultStoreId,
    required this.onParamChanged,
    required this.onTap,
    required this.resolvedPath,
  });

  final BusinessRoute route;
  final Map<String, String> paramValues;
  final String? defaultStoreId;
  final void Function(String key, String value) onParamChanged;
  final VoidCallback onTap;
  final String resolvedPath;

  @override
  Widget build(BuildContext context) {
    final path = _routePaths[route] ?? '/${route.name}';
    final params = _extractParams(path);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(route.name),
          subtitle: Text(path),
          onTap: onTap,
          dense: true,
          trailing: IconButton(
            icon: const Icon(Icons.copy, size: Sizes.p16),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: resolvedPath));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Copied: $resolvedPath'),
                duration: const Duration(seconds: 1),
              ));
            },
          ),
        ),
        if (params.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.p16)
                .copyWith(bottom: Sizes.p8),
            child: Wrap(
              spacing: Sizes.p8,
              runSpacing: Sizes.p4,
              children: [
                for (final param in params)
                  SizedBox(
                    width: 180,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: param,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: paramValues['${route.name}:$param'] ??
                            (param == 'storeId' ? defaultStoreId : null),
                      ),
                      onChanged: (v) =>
                          onParamChanged('${route.name}:$param', v),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
