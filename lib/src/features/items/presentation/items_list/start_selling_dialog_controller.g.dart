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
    r'8a34d787deb44d851985ff2354b0590feaa8f6a9';

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
