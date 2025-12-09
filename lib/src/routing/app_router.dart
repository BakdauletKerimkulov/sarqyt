import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/presentation/signin_screen.dart';
import 'package:sarqyt/src/features/offers/presentation/offers_list_screen/offers_list_screen.dart';
import 'package:sarqyt/src/features/offers/presentation/product_screen/offer_screen.dart';
import 'package:sarqyt/src/routing/app_router_refresh_stream.dart';
import 'package:sarqyt/src/routing/not_found_screen.dart';

part 'app_router.g.dart';

enum AppRoute { home, signIn, offer }

@riverpod
GoRouter appRouter(Ref ref) {
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
      } else {
        return '/signIn';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        pageBuilder: (context, state) => const MaterialPage(
          canPop: false,
          fullscreenDialog: true,
          child: OffersListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'signIn',
            name: AppRoute.signIn.name,
            pageBuilder: (context, state) => const MaterialPage(
              fullscreenDialog: true,
              child: SigninScreen(),
            ),
          ),

          GoRoute(
            path: 'offer/:id',
            name: AppRoute.offer.name,
            pageBuilder: (context, state) {
              final offerId = state.pathParameters['id']!;
              return MaterialPage(child: OfferScreen(offerId: offerId));
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
