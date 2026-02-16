import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_business/registration/create_account_screen.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_business/sign_in/sigin_in_business_screen.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_business/verify_email/verify_email_screen.dart';
import 'package:sarqyt/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:sarqyt/src/features/dashboard/presentation/pages/create_offer_screen.dart';
import 'package:sarqyt/src/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sarqyt/src/features/dashboard/presentation/pages/employers_page.dart';
import 'package:sarqyt/src/features/dashboard/presentation/pages/offers_page.dart';
import 'package:sarqyt/src/features/dashboard/presentation/pages/store_products_page.dart';
import 'package:sarqyt/src/features/dashboard/presentation/pages/stores_page.dart';
import 'package:sarqyt/src/features/products/presentation/create_product_screen.dart';
import 'package:sarqyt/src/features/store/presentation/create_store_page.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/app_router_refresh_stream.dart';

part 'business_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

enum BusinessRoute {
  signIn,
  onBoarding,
  createAccount,
  verifyEmail,
  dashboard,
  stores,
  store,
  employers,
  createStore,
  createProduct,
  offers,
  createOffer,
}

@riverpod
GoRouter businessRouter(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) {
      final message = state.error == null
          ? 'Неизвестная ошибка'.hardcoded
          : state.error is PathNotFoundException
          ? 'Такой страницы не существует'
          : state.error!.message;

      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message, style: Theme.of(context).textTheme.headlineLarge),
              gapH16,
              PrimaryWebButton(text: 'Return to MyStore', onPressed: () {}),
            ],
          ),
        ),
      );
    },
    redirect: (context, state) async {
      final user = authRepo.currentUser;

      // Определяем статус пользователя
      final isLoggedIn = user != null;
      final isVerified = isLoggedIn && user.emailVerified;

      // Определяем, куда пользователь пытается попасть
      final path = state.uri.path;
      final isSignIn = path == '/signIn';
      final isCreatingAccount = path.startsWith('/create-account');
      final isVerifyingEmail = path.startsWith('/verify-email');

      // Объединяем их для удобства проверки
      final isAuthFlow = isSignIn || isCreatingAccount || isVerifyingEmail;

      // 1. Сценарий: Все отлично (Залогинен + Подтвержден)
      if (isVerified) {
        // Если пытается зайти на регистрацию или вход -> кидаем домой
        if (isAuthFlow) {
          return '/dashboard';
        }
        // В остальных случаях пускаем куда хочет
        return null;
      }

      // 2. Сценарий: Залогинен, НО НЕ подтвержден
      if (isLoggedIn && !isVerified) {
        if (isVerifyingEmail) {
          return null;
        }

        // Если user пытается попасть на Главную (например, перезапустил приложение)
        // Мы принудительно возвращаем его на процесс регистрации
        return '/verify-email';
      }

      // 3. Сценарий: Гость (Вообще не залогинен)
      if (!isLoggedIn) {
        // Если он не на экранах входа/регистрации -> кидаем на вход
        if (isSignIn || isCreatingAccount) {
          return null;
        }
        return '/signIn';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(authRepo.userChanges()),
    routes: [
      GoRoute(
        path: '/signIn',
        name: BusinessRoute.signIn.name,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: const SignInBusinessScreen(),
        ),
      ),
      GoRoute(
        path: '/create-account',
        name: BusinessRoute.createAccount.name,
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: CreateAccountScreen(),
        ),
      ),

      GoRoute(
        path: '/verify-email',
        name: BusinessRoute.verifyEmail.name,
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: VerifyEmailScreen(),
        ),
      ),

      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder: (context, state, child) {
          return MaterialPage(child: DashboardScreen(child: child));
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: BusinessRoute.dashboard.name,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: '/stores',
            name: BusinessRoute.stores.name,
            pageBuilder: (context, state) =>
                const MaterialPage(fullscreenDialog: true, child: StoresPage()),
            routes: [
              GoRoute(
                path: 'createStore',
                name: BusinessRoute.createStore.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CreateStorePage()),
              ),

              GoRoute(
                path: ':storeId',
                name: BusinessRoute.store.name,
                pageBuilder: (context, state) {
                  final storeId = state.pathParameters['storeId']!;
                  return MaterialPage(
                    fullscreenDialog: true,
                    child: StoreProductsPage(storeId: storeId),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'new-product',
                    name: BusinessRoute.createProduct.name,
                    pageBuilder: (context, state) {
                      final storeId = state.pathParameters['storeId']!;
                      return MaterialPage(
                        child: CreateProductScreen(storeId: storeId),
                      );
                    },
                  ),

                  GoRoute(
                    path: 'create-offer',
                    name: BusinessRoute.createOffer.name,
                    pageBuilder: (context, state) {
                      final productId = state.uri.queryParameters['productId']!;
                      final storeId = state.pathParameters['storeId']!;
                      return MaterialPage(
                        child: CreateOfferScreen(
                          productId: productId,
                          storeId: storeId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/offers',
            name: BusinessRoute.offers.name,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: OffersPage()),
          ),
          GoRoute(
            path: '/employers',
            name: BusinessRoute.employers.name,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: EmployersPage()),
          ),
        ],
      ),
    ],
  );
}
