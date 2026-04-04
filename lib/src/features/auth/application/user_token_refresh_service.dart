import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/data/user_metadata_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';

part 'user_token_refresh_service.g.dart';

final enableUserTokenRefreshServiceProvider = Provider<bool>((ref) => true);

class UserTokenRefreshService {
  UserTokenRefreshService(this.ref) {
    _init();
  }

  final Ref ref;
  StreamSubscription<DateTime?>? _subscription;

  void _init() {
    ref.listen<AsyncValue<AppUser?>>(authStateChangesProvider, (prev, next) {
      final user = next.value;
      // * if the previous subscription was active, dispose it
      _subscription?.cancel();

      if (user != null) {
        final uid = user.uid;
        // * on sign-in, listen to user metadata updates
        // * (and register a subscription)
        _subscription = ref
            .read(userMetadataRepositoryProvider)
            .watchUserMetadata(uid)
            .listen(
              (refreshTime) async {
                // * read user again as it may be null by the time we reach this callback
                final user = ref.read(authRepositoryProvider).currentUser;
                if (refreshTime != null && user != null) {
                  debugPrint(
                    'Force refresh token: $refreshTime, uid: ${user.uid}',
                  );
                  // * force an ID token refresh, which will cause a new stream event
                  // * to be emitted by [idTokenChanges]
                  await user.forceRefreshIdToken();
                }
              },
              onError: (Object error, StackTrace stackTrace) {
                debugPrint('watchUserMetadata failed for uid=$uid: $error');
              },
            );
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}

@Riverpod(keepAlive: true)
UserTokenRefreshService userTokenRefreshService(Ref ref) {
  final service = UserTokenRefreshService(ref);
  ref.onDispose(service.dispose);
  return service;
}
