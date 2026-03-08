import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/common_widgets/forbidden_page.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_business/sigin_in_business_screen.dart';
import 'package:sarqyt/src/features/business_console/presentation/dashboard_screen.dart';
import 'package:sarqyt/src/features/business_console/presentation/financials_screen.dart';
import 'package:sarqyt/src/features/business_console/presentation/performance_screen.dart';
import 'package:sarqyt/src/features/business_console/presentation/settings_screen.dart';
import 'package:sarqyt/src/features/business_console/presentation/store_list_screen.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/create_business/create_business_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/create_account_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/email_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/review_details_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/verify_email_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/item/create_item_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/item/price_and_stock_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/item/schedule_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/item/title_and_description_screen.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/store_startup.dart';

part 'business_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _dashboardNavigatorKey = GlobalKey<NavigatorState>();
final _performanceNavigatorKey = GlobalKey<NavigatorState>();
final _financialsNavigatorKey = GlobalKey<NavigatorState>();
final _settingsNavigatorKey = GlobalKey<NavigatorState>();

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
  createBusiness,
  stores,
  dashboard,
  item,
  forbidden,
  performance,
  financials,
  settings,
}

/// Pure, **sync**, testable global redirect for the business app.
///
/// Layers (evaluated top-to-bottom, first match wins):
///  1. Unauthenticated → allow /login & /onboarding/inbound, else → /login
///  2. Email not verified OR verified but role not yet set (guest) →
///     stay on /onboarding/inbound/verify-email (completeMerchant still running)
///  3. Admin → redirect login/onboarding/forbidden to /stores, else stay
///  3. Non-partner → /forbidden
///  4. Partner + pending onboarding → redirect by onboardingStatus
///  5. Partner done → redirect login/onboarding/forbidden to /stores, else stay
String? businessRedirect({
  required AppUser? user,
  required GoRouterState state,
  required UserRole role,
  required List<StoreShip> storeShips,
}) {
  final path = state.uri.path;
  final onLogin = path.startsWith('/login');
  final onOnboarding = path.startsWith('/onboarding');
  final onInbound = path.startsWith('/onboarding/inbound');
  final onForbidden = path.startsWith('/forbidden');

  // Layer 1: Unauthenticated
  if (user == null) {
    if (onLogin || onInbound) return null;
    return '/login';
  }

  // Layer 2: Email not verified, or verified but claims not yet set
  // (role == guest means completeMerchantOnboarding is still running).
  if (!user.emailVerified || role == UserRole.guest) {
    const verifyPath = '/onboarding/inbound/verify-email';
    if (path == verifyPath) return null;
    return verifyPath;
  }

  // Layer 3: Role-based routing
  if (role == UserRole.admin) {
    if (onLogin || onOnboarding || onForbidden) return '/stores';
    return null;
  }

  if (role != UserRole.partner) {
    if (onForbidden) return null;
    return '/forbidden';
  }

  // Layer 4: Partner with pending onboarding
  final pending = storeShips.pendingOnboarding;
  if (pending != null) {
    final target = switch (pending.onboardingStatus) {
      OnboardingStatus.storeCreated => '/onboarding/create-item',
      OnboardingStatus.itemCreated => '/onboarding/create-business',
      OnboardingStatus.completed => '/stores',
    };
    if (path.startsWith(target)) return null;
    return target;
  }

  // Layer 5: Partner done (no pending onboarding)
  if (onLogin || onOnboarding || onForbidden) return '/stores';
  return null;
}

/// Notifies GoRouter to re-run redirect when called.
class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

@Riverpod(keepAlive: true)
GoRouter businessRouter(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  final refresh = _RouterRefreshNotifier();

  // Re-run redirect on auth changes (sign-in/out + token refresh) and
  // store-ship updates.
  final authSub = authRepo.idTokenChanges().listen((_) => refresh.refresh());
  ref.listen(currentPartnerStoreShipsProvider, (_, __) => refresh.refresh());
  ref.onDispose(() {
    authSub.cancel();
    refresh.dispose();
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) {
      final message = state.error?.message ?? 'Неизвестная ошибка'.hardcoded;
      return ErrorWidget(message);
    },
    redirect: (context, state) async {
      final user = authRepo.currentUser;

      // Layer 1-2: short-circuit when not authenticated or email not verified.
      if (user == null || !user.emailVerified) {
        return businessRedirect(
          user: user,
          state: state,
          role: UserRole.guest,
          storeShips: const [],
        );
      }

      // Await role directly — no reactive cycle since this is not a provider.
      final role = await user.getRole();

      // Layers 3-5: role is known, resolve storeShips.
      final storeShips = role == UserRole.partner
          ? ref.read(currentPartnerStoreShipsProvider).value
          : <StoreShip>[];
      if (storeShips == null) return null; // still loading

      return businessRedirect(
        user: user,
        state: state,
        role: role,
        storeShips: storeShips,
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
          GoRoute(
            path: 'create-business',
            name: BusinessRoute.createBusiness.name,
            builder: (context, state) => const CreateBusinessScreen(),
          ),
        ],
      ),

      // Store selection screen (if > 1)
      GoRoute(
        path: '/stores',
        name: BusinessRoute.stores.name,
        redirect: (context, state) {
          if (state.uri.path != '/stores') return null;
          final ships = ref.read(currentPartnerStoreShipsProvider).value ?? [];
          final completed = ships
              .where((s) => s.onboardingStatus == OnboardingStatus.completed)
              .toList();
          // Auto-redirect only when exactly one completed store.
          // Multiple stores → show StoreListScreen for selection.
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
                          return ItemScreen(itemId: itemId, storeId: storeId);
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
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
