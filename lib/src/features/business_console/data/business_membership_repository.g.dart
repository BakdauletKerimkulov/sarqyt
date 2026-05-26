// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_membership_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(businessMembershipRepository)
const businessMembershipRepositoryProvider =
    BusinessMembershipRepositoryProvider._();

final class BusinessMembershipRepositoryProvider
    extends
        $FunctionalProvider<
          BusinessMembershipRepository,
          BusinessMembershipRepository,
          BusinessMembershipRepository
        >
    with $Provider<BusinessMembershipRepository> {
  const BusinessMembershipRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessMembershipRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessMembershipRepositoryHash();

  @$internal
  @override
  $ProviderElement<BusinessMembershipRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BusinessMembershipRepository create(Ref ref) {
    return businessMembershipRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BusinessMembershipRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BusinessMembershipRepository>(value),
    );
  }
}

String _$businessMembershipRepositoryHash() =>
    r'8ced906bf9bf326e3cca6128cabfca51229b9cc7';

@ProviderFor(businessMembershipStream)
const businessMembershipStreamProvider = BusinessMembershipStreamFamily._();

final class BusinessMembershipStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<BusinessMembership?>,
          BusinessMembership?,
          Stream<BusinessMembership?>
        >
    with
        $FutureModifier<BusinessMembership?>,
        $StreamProvider<BusinessMembership?> {
  const BusinessMembershipStreamProvider._({
    required BusinessMembershipStreamFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'businessMembershipStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$businessMembershipStreamHash();

  @override
  String toString() {
    return r'businessMembershipStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<BusinessMembership?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<BusinessMembership?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return businessMembershipStream(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is BusinessMembershipStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$businessMembershipStreamHash() =>
    r'ffcc15713e1cf721a365b3bc2d1beba9a5c4a85e';

final class BusinessMembershipStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<BusinessMembership?>,
          (String, String)
        > {
  const BusinessMembershipStreamFamily._()
    : super(
        retry: null,
        name: r'businessMembershipStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BusinessMembershipStreamProvider call(String businessId, String userId) =>
      BusinessMembershipStreamProvider._(
        argument: (businessId, userId),
        from: this,
      );

  @override
  String toString() => r'businessMembershipStreamProvider';
}

@ProviderFor(businessMembersStream)
const businessMembersStreamProvider = BusinessMembersStreamFamily._();

final class BusinessMembersStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BusinessMembership>>,
          List<BusinessMembership>,
          Stream<List<BusinessMembership>>
        >
    with
        $FutureModifier<List<BusinessMembership>>,
        $StreamProvider<List<BusinessMembership>> {
  const BusinessMembersStreamProvider._({
    required BusinessMembersStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'businessMembersStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$businessMembersStreamHash();

  @override
  String toString() {
    return r'businessMembersStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<BusinessMembership>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BusinessMembership>> create(Ref ref) {
    final argument = this.argument as String;
    return businessMembersStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BusinessMembersStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$businessMembersStreamHash() =>
    r'cfdf56e4987f0602a82673d4a56ab5983bedd9a8';

final class BusinessMembersStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<BusinessMembership>>, String> {
  const BusinessMembersStreamFamily._()
    : super(
        retry: null,
        name: r'businessMembersStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BusinessMembersStreamProvider call(String businessId) =>
      BusinessMembersStreamProvider._(argument: businessId, from: this);

  @override
  String toString() => r'businessMembersStreamProvider';
}
