// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_dialog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BusinessDraftController)
const businessDraftControllerProvider = BusinessDraftControllerProvider._();

final class BusinessDraftControllerProvider
    extends
        $NotifierProvider<BusinessDraftController, BusinessVerificationDraft> {
  const BusinessDraftControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessDraftControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessDraftControllerHash();

  @$internal
  @override
  BusinessDraftController create() => BusinessDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BusinessVerificationDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BusinessVerificationDraft>(value),
    );
  }
}

String _$businessDraftControllerHash() =>
    r'311af8fa94c732cd5f67f3be5e037883bb6acade';

abstract class _$BusinessDraftController
    extends $Notifier<BusinessVerificationDraft> {
  BusinessVerificationDraft build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<BusinessVerificationDraft, BusinessVerificationDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BusinessVerificationDraft, BusinessVerificationDraft>,
              BusinessVerificationDraft,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
