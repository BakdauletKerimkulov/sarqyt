// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_one_time_offer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateOneTimeOfferController)
const createOneTimeOfferControllerProvider =
    CreateOneTimeOfferControllerProvider._();

final class CreateOneTimeOfferControllerProvider
    extends $AsyncNotifierProvider<CreateOneTimeOfferController, void> {
  const CreateOneTimeOfferControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createOneTimeOfferControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createOneTimeOfferControllerHash();

  @$internal
  @override
  CreateOneTimeOfferController create() => CreateOneTimeOfferController();
}

String _$createOneTimeOfferControllerHash() =>
    r'156faebb08d270b7ed62dc8a967809fd5f9d7dd0';

abstract class _$CreateOneTimeOfferController extends $AsyncNotifier<void> {
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
