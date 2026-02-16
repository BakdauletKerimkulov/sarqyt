import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/presentation/account_screen/account_screen.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_form_type.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_screen.dart';
import 'package:sarqyt/src/features/checkout/presentation/checkout_screen.dart';
import 'package:sarqyt/src/features/map/presentation/map_example.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_list/discover_screen.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_screen/offer_screen.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_screen/store_info.dart';
import 'package:sarqyt/src/routing/app_router_refresh_stream.dart';
import 'package:sarqyt/src/routing/not_found_screen.dart';

part 'client_router.g.dart';

enum ClientRoute {
  home,
  signIn,
  offer,
  settings,
  account,
  map,
  store,
  checkout,
}

@riverpod
GoRouter clientRouter(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final user = authRepository.currentUser;
      final isLoggedIn = user != null;
      final path = state.uri.path;
      if (isLoggedIn) {
        if (path == '/signIn') {
          return '/';
        }
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    routes: [
      GoRoute(
        path: '/',
        name: ClientRoute.home.name,
        pageBuilder: (context, state) => const MaterialPage(
          canPop: false,
          fullscreenDialog: true,
          child: DiscoverScreen(),
        ),
        routes: [
          GoRoute(
            path: 'map',
            name: ClientRoute.map.name,
            pageBuilder: (context, state) =>
                const MaterialPage(fullscreenDialog: true, child: MapExample()),
          ),

          GoRoute(
            path: 'offer/:id',
            name: ClientRoute.offer.name,
            pageBuilder: (context, state) {
              final offerId = state.pathParameters['id']!;
              return MaterialPage(child: OfferScreen(productId: offerId));
            },
            routes: [
              GoRoute(
                path: 'store/:offerId',
                name: ClientRoute.store.name,
                pageBuilder: (context, state) {
                  final offerId = state.pathParameters['id']!;
                  return MaterialPage(child: StoreInfo(offerId));
                },
              ),
            ],
          ),
          GoRoute(
            path: 'checkout/:id',
            name: ClientRoute.checkout.name,
            pageBuilder: (context, state) {
              final param = state.pathParameters['id']!;
              return MaterialPage(child: CheckoutScreen(productID: param));
            },
          ),

          GoRoute(
            path: 'signIn',
            name: ClientRoute.signIn.name,
            pageBuilder: (context, state) => const MaterialPage(
              fullscreenDialog: true,
              child: EmailPasswordSignInScreen(
                formType: EmailPasswordSignInFormType.signIn,
              ),
            ),
          ),
          GoRoute(
            path: 'profile',
            name: ClientRoute.account.name,
            pageBuilder: (context, state) => const MaterialPage(
              fullscreenDialog: true,
              child: AccountScreen(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
