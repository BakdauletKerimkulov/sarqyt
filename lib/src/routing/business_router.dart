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
import 'package:sarqyt/src/features/business_console/presentation/stores/add_store_screen.dart';
import 'package:sarqyt/src/features/business_console/presentation/team/team_list_screen.dart';
import 'package:sarqyt/src/features/items/presentation/item_create/create_item_screen.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_screen.dart';
import 'package:sarqyt/src/features/items/presentation/item_tab.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/create_account_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/email_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/review_details_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/verify_email_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/welcome/welcome_screen.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_loading_screen.dart';
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
  loading,
  onboarding,
  inbound,
  createAccount,
  reviewDetails,
  email,
  verifyEmail,
  welcome,
  stores,
  dashboard,
  item,
  forbidden,
  performance,
  financials,
  settings,
  helpCentre,
  newItem,
  team,
  addStore,
}

/// Pure, sync, testable global redirect for the business app.
///
/// Layers (evaluated top-to-bottom, first match wins):
///  1. Unauthenticated → allow /login & /onboarding/inbound, else → /login
///  2. Email not verified → /onboarding/inbound/verify-email
///  3. Role == guest (claims not yet set) → /onboarding/inbound/verify-email
///  4. Non-partner / non-admin → /forbidden
///  5. Admin → redirect onboarding/login/forbidden to /stores, else stay
///  6. Partner + storeShips not yet loaded → stay put (avoid bouncing)
///  7. Partner with a storeShip whose welcome is not done → /onboarding/welcome
///  8. Partner done → redirect onboarding/login/forbidden to /stores, else stay
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
  final onWelcome = path.startsWith('/onboarding/welcome');
  final onForbidden = path.startsWith('/forbidden');
  final onLoading = path.startsWith('/loading');

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

  // Layer 3: Role still loading / claims not set yet → guest
  if (role == UserRole.guest) {
    const verifyPath = '/onboarding/inbound/verify-email';
    if (path == verifyPath) return null;
    return verifyPath;
  }

  // Layer 4: Non-partner / non-admin
  if (role != UserRole.partner && role != UserRole.admin) {
    if (onForbidden) return null;
    return '/forbidden';
  }

  // Layer 5: Admin — bypass welcome flow entirely
  if (role == UserRole.admin) {
    if (onLogin || onOnboarding || onForbidden) return '/stores';
    return null;
  }

  // Layer 6: Partner — wait for storeShips before deciding welcome vs stores.
  // Redirect /login → /loading so user sees a loading screen, not a frozen form.
  if (!redirectState.storeShipsLoaded) {
    if (onLogin) return '/loading';
    return null;
  }

  // Layer 7: Partner with at least one storeShip pending welcome → /welcome
  if (storeShips.pendingWelcome != null) {
    if (onWelcome) return null;
    return '/onboarding/welcome';
  }

  // Layer 8: Partner done
  if (onLogin || onOnboarding || onForbidden || onLoading) return '/stores';
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
              Text(state.error?.message ?? context.loc.pageNotFound),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/login'),
                child: Text(context.loc.goToLogin),
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
        path: '/loading',
        name: BusinessRoute.loading.name,
        builder: (context, state) => const BusinessLoadingScreen(),
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
            path: 'welcome',
            name: BusinessRoute.welcome.name,
            builder: (context, state) => const WelcomeScreen(),
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
          final completed =
              redirectData.storeShips.where((s) => s.welcomeCompleted).toList();
          if (completed.length == 1) {
            return '/stores/${completed.first.storeId}/dashboard';
          }
          return null;
        },
        builder: (context, state) => const StoreListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: BusinessRoute.addStore.name,
            builder: (context, state) => const AddStoreScreen(),
          ),
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
                        path: 'new-item',
                        name: BusinessRoute.newItem.name,
                        builder: (context, state) {
                          final storeId = state.pathParameters['storeId']!;
                          return CreateItemFormScreen(storeId: storeId);
                        },
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
                      GoRoute(
                        path: 'team',
                        name: BusinessRoute.team.name,
                        builder: (context, state) {
                          final storeId = state.pathParameters['storeId']!;
                          return TeamListScreen(storeId: storeId);
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
