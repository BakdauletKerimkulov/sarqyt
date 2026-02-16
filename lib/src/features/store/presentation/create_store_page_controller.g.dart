// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_store_page_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateStoreController)
const createStoreControllerProvider = CreateStoreControllerProvider._();

final class CreateStoreControllerProvider
    extends $AsyncNotifierProvider<CreateStoreController, void> {
  const CreateStoreControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createStoreControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createStoreControllerHash();

  @$internal
  @override
  CreateStoreController create() => CreateStoreController();
}

String _$createStoreControllerHash() =>
    r'5713e3d8c7b105e0d7302d7d70ba742cd8910ef4';

abstract class _$CreateStoreController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

@ProviderFor(DeleteStoreController)
const deleteStoreControllerProvider = DeleteStoreControllerProvider._();

final class DeleteStoreControllerProvider
    extends $AsyncNotifierProvider<DeleteStoreController, void> {
  const DeleteStoreControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteStoreControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteStoreControllerHash();

  @$internal
  @override
  DeleteStoreController create() => DeleteStoreController();
}

String _$deleteStoreControllerHash() =>
    r'90f2e9e8cfb0535c71710dc7ec96803201a56c53';

abstract class _$DeleteStoreController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
