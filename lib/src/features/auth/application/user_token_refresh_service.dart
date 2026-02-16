import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/data/user_metadata_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

part 'user_token_refresh_service.g.dart';

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
        _subscription = ref
            .read(userMetadataRepositoryProvider)
            .watchUserMetadata(user.uid)
            .listen((refreshTime) async {
              final user = ref.read(authRepositoryProvider).currentUser;
              if (refreshTime != null && user != null) {
                debugPrint(
                  'Force refresh token: $refreshTime, uid: ${user.uid}'
                      .hardcoded,
                );
                await user.forceRefreshIdToken();
              }
            });
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
