// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_item_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for the dashboard "Create item" form.
/// Tracks loading/error state via [AsyncValue]; the widget only listens.

@ProviderFor(CreateItemFormController)
const createItemFormControllerProvider = CreateItemFormControllerProvider._();

/// Controller for the dashboard "Create item" form.
/// Tracks loading/error state via [AsyncValue]; the widget only listens.
final class CreateItemFormControllerProvider
    extends $AsyncNotifierProvider<CreateItemFormController, void> {
  /// Controller for the dashboard "Create item" form.
  /// Tracks loading/error state via [AsyncValue]; the widget only listens.
  const CreateItemFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createItemFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createItemFormControllerHash();

  @$internal
  @override
  CreateItemFormController create() => CreateItemFormController();
}

String _$createItemFormControllerHash() =>
    r'2daa07f9b4f8da5ed441f83295f0ea98dee1fd38';

/// Controller for the dashboard "Create item" form.
/// Tracks loading/error state via [AsyncValue]; the widget only listens.

abstract class _$CreateItemFormController extends $AsyncNotifier<void> {
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
