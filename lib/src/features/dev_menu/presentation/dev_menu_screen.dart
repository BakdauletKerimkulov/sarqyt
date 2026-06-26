import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/routing/business_router.dart';

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

class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = BusinessRoute.values.where((r) => r != BusinessRoute.dev);

    return Scaffold(
      appBar: AppBar(title: const Text('Dev Menu')),
      body: ListView.separated(
        padding: const EdgeInsets.all(Sizes.p16),
        itemCount: routes.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final route = routes.elementAt(index);
          final path = _routePaths[route] ?? '/${route.name}';

          return ListTile(
            title: Text(route.name),
            subtitle: Text(path),
            onTap: () => context.go(path),
          );
        },
      ),
    );
  }
}
