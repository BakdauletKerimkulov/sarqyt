import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/presentation/account_screen/account_screen.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_form_type.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_screen.dart';
import 'package:sarqyt/src/features/checkout/presentation/checkout_screen.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_list/discover_screen.dart';
import 'package:sarqyt/src/features/onboarding/data/client_onboarding_repository.dart';
import 'package:sarqyt/src/features/onboarding/presentation/client/welcome_screen.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_screen/offer_screen.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_screen/store_info.dart';
import 'package:sarqyt/src/features/orders/presentation/client/order_detail_screen.dart';
import 'package:sarqyt/src/features/auth/presentation/edit_profile/edit_profile_screen.dart';
import 'package:sarqyt/src/features/auth/presentation/settings/app_settings_screen.dart';
import 'package:sarqyt/src/features/orders/presentation/client/orders_screen.dart';
import 'package:sarqyt/src/features/review/presentation/review_screen.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/app_router_refresh_stream.dart';
import 'package:sarqyt/src/routing/not_found_screen.dart';

part 'client_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _discoverNavigatorKey = GlobalKey<NavigatorState>();
final _ordersNavigatorKey = GlobalKey<NavigatorState>();
final _profileNavigatorKey = GlobalKey<NavigatorState>();

enum ClientRoute {
  welcome,
  home,
  signIn,
  offer,
  store,
  checkout,
  orders,
  orderDetail,
  review,
  profile,
  editProfile,
  appSettings,
}

class ClientShellScaffold extends StatelessWidget {
  const ClientShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withAlpha(30),
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppColors.primary),
            label: 'Discover'.hardcoded,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag, color: AppColors.primary),
            label: 'Orders'.hardcoded,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profile'.hardcoded,
          ),
        ],
      ),
    );
  }
}

@riverpod
GoRouter clientRouter(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final path = state.uri.path;

      // Show welcome screen for first-time users (sync via .requireValue)
      final onboardingRepo =
          ref.read(clientOnboardingRepositoryProvider).requireValue;
      if (!onboardingRepo.isOnboardingComplete()) {
        if (path != '/welcome') return '/welcome';
        return null;
      }

      final user = authRepository.currentUser;
      if (user != null && path == '/signIn') {
        return '/';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    routes: [
      // Full-screen routes outside shell
      GoRoute(
        path: '/welcome',
        name: ClientRoute.welcome.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: '/signIn',
        name: ClientRoute.signIn.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: EmailPasswordSignInScreen(
            formType: EmailPasswordSignInFormType.signIn,
          ),
        ),
      ),
      GoRoute(
        path: '/checkout/:id',
        name: ClientRoute.checkout.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final param = state.pathParameters['id']!;
          return MaterialPage(child: CheckoutScreen(offerId: param));
        },
      ),

      // Shell with bottom nav
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ClientShellScaffold(navigationShell: navigationShell),
        branches: [
          // Tab 0: Discover
          StatefulShellBranch(
            navigatorKey: _discoverNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                name: ClientRoute.home.name,
                builder: (context, state) => const DiscoverScreen(),
                routes: [
                  GoRoute(
                    path: 'offer/:id',
                    name: ClientRoute.offer.name,
                    builder: (context, state) {
                      final offerId = state.pathParameters['id']!;
                      return OfferScreen(offerId: offerId);
                    },
                    routes: [
                      GoRoute(
                        path: 'store/:offerId',
                        name: ClientRoute.store.name,
                        builder: (context, state) {
                          final offerId = state.pathParameters['id']!;
                          return StoreInfo(offerId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Tab 1: Orders
          StatefulShellBranch(
            navigatorKey: _ordersNavigatorKey,
            routes: [
              GoRoute(
                path: '/orders',
                name: ClientRoute.orders.name,
                builder: (context, state) => const OrdersScreen(),
                routes: [
                  GoRoute(
                    path: ':orderId',
                    name: ClientRoute.orderDetail.name,
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId']!;
                      return OrderDetailScreen(orderId: orderId);
                    },
                    routes: [
                      GoRoute(
                        path: 'review',
                        name: ClientRoute.review.name,
                        builder: (context, state) {
                          final orderId = state.pathParameters['orderId']!;
                          final storeId = state.uri.queryParameters['storeId'] ?? '';
                          final storeName = state.uri.queryParameters['storeName'] ?? '';
                          return ReviewScreen(
                            orderId: orderId,
                            storeId: storeId,
                            storeName: storeName,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Tab 2: Profile
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: ClientRoute.profile.name,
                builder: (context, state) => const AccountScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: ClientRoute.editProfile.name,
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    name: ClientRoute.appSettings.name,
                    builder: (context, state) => const AppSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
