// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_offer_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateOfferController)
const createOfferControllerProvider = CreateOfferControllerProvider._();

final class CreateOfferControllerProvider
    extends $AsyncNotifierProvider<CreateOfferController, void> {
  const CreateOfferControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createOfferControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createOfferControllerHash();

  @$internal
  @override
  CreateOfferController create() => CreateOfferController();
}

String _$createOfferControllerHash() =>
    r'6a3b0f205af7f1742bf7cf7fa102c89ccfe860b1';

abstract class _$CreateOfferController extends $AsyncNotifier<void> {
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

@ProviderFor(OfferFormController)
const offerFormControllerProvider = OfferFormControllerFamily._();

final class OfferFormControllerProvider
    extends $NotifierProvider<OfferFormController, OfferForm> {
  const OfferFormControllerProvider._({
    required OfferFormControllerFamily super.from,
    required ProductID super.argument,
  }) : super(
         retry: null,
         name: r'offerFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$offerFormControllerHash();

  @override
  String toString() {
    return r'offerFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OfferFormController create() => OfferFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfferForm value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfferForm>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OfferFormControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$offerFormControllerHash() =>
    r'ef651aa84a596d8d20ea59041f44a6b0d13c60e5';

final class OfferFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          OfferFormController,
          OfferForm,
          OfferForm,
          OfferForm,
          ProductID
        > {
  const OfferFormControllerFamily._()
    : super(
        retry: null,
        name: r'offerFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OfferFormControllerProvider call(ProductID productId) =>
      OfferFormControllerProvider._(argument: productId, from: this);

  @override
  String toString() => r'offerFormControllerProvider';
}

abstract class _$OfferFormController extends $Notifier<OfferForm> {
  late final _$args = ref.$arg as ProductID;
  ProductID get productId => _$args;

  OfferForm build(ProductID productId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<OfferForm, OfferForm>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OfferForm, OfferForm>,
              OfferForm,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
