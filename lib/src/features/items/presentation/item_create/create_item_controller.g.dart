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
    r'470204e92c47f4264668848379f1e5caa44ed783';

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
