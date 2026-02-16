import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/store/data/store_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/routing/business_router.dart';

part 'create_store_page_controller.g.dart';

@riverpod
class CreateStoreController extends _$CreateStoreController {
  @override
  FutureOr<void> build() {
    // nothing to do;
  }

  Future<void> create(StoreDraft store) async {
    state = const AsyncLoading();

    final user = ref.watch(authStateChangesProvider).value;
    if (user == null) return;

    final value = await AsyncValue.guard(() {
      return ref
          .read(storeRepositoryProvider)
          .createStore(ownerId: user.uid, store: store);
    });
    final success = state.hasError == false;
    if (ref.mounted) {
      state = value;
      if (success) {
        ref.read(businessRouterProvider).goNamed(BusinessRoute.stores.name);
      }
    }
  }
}

@riverpod
class DeleteStoreController extends _$DeleteStoreController {
  @override
  FutureOr<void> build() {
    // no-op
  }

  Future<bool> deleteStore(String storeId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(storeRepositoryProvider).deleteStore(storeId),
    );
    return state.hasError == false;
  }
}
