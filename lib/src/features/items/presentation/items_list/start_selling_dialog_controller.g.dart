// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_selling_dialog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StartSellingDialogController)
const startSellingDialogControllerProvider =
    StartSellingDialogControllerProvider._();

final class StartSellingDialogControllerProvider
    extends $AsyncNotifierProvider<StartSellingDialogController, void> {
  const StartSellingDialogControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startSellingDialogControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startSellingDialogControllerHash();

  @$internal
  @override
  StartSellingDialogController create() => StartSellingDialogController();
}

String _$startSellingDialogControllerHash() =>
    r'f79f2eec7ef763c4e0c1328fc15cb405ad5fcfeb';

abstract class _$StartSellingDialogController extends $AsyncNotifier<void> {
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
