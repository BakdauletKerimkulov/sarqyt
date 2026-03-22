// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_item_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateItemController)
const createItemControllerProvider = CreateItemControllerProvider._();

final class CreateItemControllerProvider
    extends $AsyncNotifierProvider<CreateItemController, void> {
  const CreateItemControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createItemControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createItemControllerHash();

  @$internal
  @override
  CreateItemController create() => CreateItemController();
}

String _$createItemControllerHash() =>
    r'1e262583f0c91d05236955e762406c9db82d452a';

abstract class _$CreateItemController extends $AsyncNotifier<void> {
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
