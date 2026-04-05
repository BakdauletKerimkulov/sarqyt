import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_business/sigin_in_business_screen.dart';
import 'package:sarqyt/src/features/business_console/presentation/dashboard_screen.dart';
import 'package:sarqyt/src/features/business_console/presentation/financials_screen.dart';
import 'package:sarqyt/src/features/business_console/presentation/help_centre_screen.dart';
import 'package:sarqyt/src/features/business_console/presentation/performance_screen.dart';
import 'package:sarqyt/src/features/business_console/presentation/settings_screen.dart';
import 'package:sarqyt/src/features/business_console/presentation/store_list_screen.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_screen.dart';
import 'package:sarqyt/src/features/items/presentation/item_tab.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/create_account_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/email_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/review_details_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/verify_email_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/item/create_item_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/item/price_and_stock_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/item/schedule_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/item/title_and_description_screen.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_redirect_state.dart';
import 'package:sarqyt/src/routing/forbidden_page.dart';
import 'package:sarqyt/src/routing/store_startup.dart';

part 'business_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _dashboardNavigatorKey = GlobalKey<NavigatorState>();
final _performanceNavigatorKey = GlobalKey<NavigatorState>();
final _financialsNavigatorKey = GlobalKey<NavigatorState>();
final _settingsNavigatorKey = GlobalKey<NavigatorState>();
final _helpNavigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
StoreShip currentStoreShip(Ref ref) => throw UnimplementedError(
  'Error: current store ship accessed outside of Store Shell'.hardcoded,
);

enum BusinessRoute {
  login,
  onboarding,
  inbound,
  createAccount,
  reviewDetails,
  email,
  verifyEmail,
  createItem,
  titleAndDescription,
  priceAndStock,
  schedule,
  stores,
  dashboard,
  item,
  forbidden,
  performance,
  financials,
  settings,
  helpCentre,
}

/// Pure, sync, testable global redirect for the business app.
///
/// Layers (evaluated top-to-bottom, first match wins):
///  1. Unauthenticated → allow /login & /onboarding/inbound, else → /login
///  2. Email not verified → /onboarding/inbound/verify-email
///  3. Still loading role/storeShips → stay put (don't redirect)
///  4. Role == guest (claims not set yet) → /onboarding/inbound/verify-email
///  5. Admin → redirect login/onboarding/forbidden to /stores, else stay
///  6. Non-partner → /forbidden
///  7. Partner + pending onboarding → /onboarding/create-item
///  8. Partner done → redirect login/onboarding/forbidden to /stores, else stay
String? businessRedirect({
  required BusinessRedirectState redirectState,
  required String path,
}) {
  final user = redirectState.user;
  final role = redirectState.role;
  final storeShips = redirectState.storeShips;

  final onLogin = path.startsWith('/login');
  final onOnboarding = path.startsWith('/onboarding');
  final onInbound = path.startsWith('/onboarding/inbound');
  final onForbidden = path.startsWith('/forbidden');

  // Layer 1: Unauthenticated — no need to wait for role/storeShips
  if (user == null) {
    if (onLogin || onInbound) return null;
    return '/login';
  }

  // Layer 2: Email not verified — no need to wait
  if (!user.emailVerified) {
    const verifyPath = '/onboarding/inbound/verify-email';
    if (path == verifyPath) return null;
    return verifyPath;
  }

  // Layer 3: Still loading role or storeShips — wait
  if (redirectState.isLoading) return null;

  // Layer 4: Role == guest (claims not yet set)
  if (role == UserRole.guest) {
    const verifyPath = '/onboarding/inbound/verify-email';
    if (path == verifyPath) return null;
    return verifyPath;
  }

  // Layer 5: Admin
  if (role == UserRole.admin) {
    if (onLogin || onOnboarding || onForbidden) return '/stores';
    return null;
  }

  // Layer 6: Non-partner
  if (role != UserRole.partner) {
    if (onForbidden) return null;
    return '/forbidden';
  }

  // Layer 7: Partner with pending onboarding
  final pending = storeShips.pendingOnboarding;
  if (pending != null) {
    const target = '/onboarding/create-item';
    if (path.startsWith(target)) return null;
    return target;
  }

  // Layer 7: Partner done
  if (onLogin || onOnboarding || onForbidden) return '/stores';
  return null;
}

/// Debounced notifier — prevents rapid-fire redirect cascades.
class _RouterRefreshNotifier extends ChangeNotifier {
  Timer? _timer;

  void refresh() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 100), notifyListeners);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

@Riverpod(keepAlive: true)
GoRouter businessRouter(Ref ref) {
  final refresh = _RouterRefreshNotifier();

  // Single reactive source — triggers refresh when any input changes.
  ref.listen(businessRedirectStateProvider, (_, __) => refresh.refresh());
  ref.onDispose(() => refresh.dispose());

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.error?.message ?? 'Page not found'.hardcoded),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/login'),
                child: Text('Go to login'.hardcoded),
              ),
            ],
          ),
        ),
      );
    },
    redirect: (context, state) {
      // Fully synchronous — all data comes from the reactive provider.
      final redirectState = ref.read(businessRedirectStateProvider);
      return businessRedirect(
        redirectState: redirectState,
        path: state.uri.path,
      );
    },
    refreshListenable: refresh,
    routes: [
      GoRoute(
        path: '/forbidden',
        name: BusinessRoute.forbidden.name,
        builder: (context, state) => const ForbiddenPage(),
      ),

      GoRoute(
        path: '/login',
        name: BusinessRoute.login.name,
        builder: (context, state) => const SignInBusinessScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        name: BusinessRoute.onboarding.name,
        redirect: (context, state) {
          if (state.uri.path == '/onboarding') {
            return '/onboarding/inbound';
          }
          return null;
        },
        routes: [
          GoRoute(
            path: 'inbound',
            name: BusinessRoute.inbound.name,
            redirect: (_, state) {
              if (state.uri.path == '/onboarding/inbound') {
                return '/onboarding/inbound/create-account';
              }
              return null;
            },
            routes: [
              GoRoute(
                path: 'create-account',
                name: BusinessRoute.createAccount.name,
                builder: (context, state) => const CreateAccountScreen(),
              ),
              GoRoute(
                path: 'review-details',
                name: BusinessRoute.reviewDetails.name,
                builder: (context, state) => const ReviewDetailsScreen(),
              ),
              GoRoute(
                path: 'email',
                name: BusinessRoute.email.name,
                builder: (context, state) => const EmailScreen(),
              ),
              GoRoute(
                path: 'verify-email',
                name: BusinessRoute.verifyEmail.name,
                builder: (context, state) => const VerifyEmailScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'create-item',
            name: BusinessRoute.createItem.name,
            builder: (context, state) => const CreateItemScreen(),
            routes: [
              GoRoute(
                path: 'title-and-description',
                name: BusinessRoute.titleAndDescription.name,
                builder: (context, state) => const TitleAndDescriptionScreen(),
              ),
              GoRoute(
                path: 'price-and-stock',
                name: BusinessRoute.priceAndStock.name,
                builder: (context, state) => const PriceAndStockScreen(),
              ),
              GoRoute(
                path: 'schedule',
                name: BusinessRoute.schedule.name,
                builder: (context, state) => const ScheduleScreen(),
              ),
            ],
          ),
        ],
      ),

      // Store selection screen (if > 1)
      GoRoute(
        path: '/stores',
        name: BusinessRoute.stores.name,
        redirect: (context, state) {
          if (state.uri.path != '/stores') return null;
          final redirectData = ref.read(businessRedirectStateProvider);
          final completed = redirectData.storeShips
              .where((s) => s.onboardingStatus == OnboardingStatus.completed)
              .toList();
          if (completed.length == 1) {
            return '/stores/${completed.first.storeId}/dashboard';
          }
          return null;
        },
        builder: (context, state) => const StoreListScreen(),
        routes: [
          GoRoute(
            path: ':storeId',
            redirect: (context, state) {
              final storeId = state.pathParameters['storeId']!;
              if (state.uri.path == '/stores/$storeId') {
                return '/stores/$storeId/dashboard';
              }
              return null;
            },
            routes: [
              StatefulShellRoute.indexedStack(
                pageBuilder: (context, state, navigationShell) {
                  final storeId = state.pathParameters['storeId']!;
                  return NoTransitionPage(
                    child: StoreStartupWidget(
                      storeId: storeId,
                      navigationShell: navigationShell,
                    ),
                  );
                },
                branches: [
                  StatefulShellBranch(
                    navigatorKey: _dashboardNavigatorKey,
                    routes: [
                      GoRoute(
                        path: 'dashboard',
                        name: BusinessRoute.dashboard.name,
                        builder: (context, state) => const DashboardScreen(),
                      ),
                      GoRoute(
                        path: 'item/:itemId',
                        name: BusinessRoute.item.name,
                        builder: (context, state) {
                          final itemId = state.pathParameters['itemId']!;
                          final storeId = state.pathParameters['storeId']!;
                          final tab = ItemTabX.fromParam(
                            state.uri.queryParameters['tab'],
                          );
                          return ItemScreen(
                            itemId: itemId,
                            storeId: storeId,
                            initialTab: tab,
                          );
                        },
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    navigatorKey: _performanceNavigatorKey,
                    routes: [
                      GoRoute(
                        path: 'performance',
                        name: BusinessRoute.performance.name,
                        builder: (context, state) => const PerformanceScreen(),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    navigatorKey: _financialsNavigatorKey,
                    routes: [
                      GoRoute(
                        path: 'financials',
                        name: BusinessRoute.financials.name,
                        builder: (context, state) => const FinancialsScreen(),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    navigatorKey: _settingsNavigatorKey,
                    routes: [
                      GoRoute(
                        path: 'settings',
                        name: BusinessRoute.settings.name,
                        builder: (context, state) => const SettingsScreen(),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    navigatorKey: _helpNavigatorKey,
                    routes: [
                      GoRoute(
                        path: 'help',
                        name: BusinessRoute.helpCentre.name,
                        builder: (context, state) =>
                            const HelpCentreScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
