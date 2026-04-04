// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(businessRepository)
const businessRepositoryProvider = BusinessRepositoryProvider._();

final class BusinessRepositoryProvider
    extends
        $FunctionalProvider<
          BusinessRepository,
          BusinessRepository,
          BusinessRepository
        >
    with $Provider<BusinessRepository> {
  const BusinessRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'businessRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$businessRepositoryHash();

  @$internal
  @override
  $ProviderElement<BusinessRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BusinessRepository create(Ref ref) {
    return businessRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BusinessRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BusinessRepository>(value),
    );
  }
}

String _$businessRepositoryHash() =>
    r'4d8b32c9677509dd643ccad42428ce07eabc78da';

@ProviderFor(businessFuture)
const businessFutureProvider = BusinessFutureFamily._();

final class BusinessFutureProvider
    extends
        $FunctionalProvider<
          AsyncValue<Business?>,
          Business?,
          FutureOr<Business?>
        >
    with $FutureModifier<Business?>, $FutureProvider<Business?> {
  const BusinessFutureProvider._({
    required BusinessFutureFamily super.from,
    required BusinessID super.argument,
  }) : super(
         retry: null,
         name: r'businessFutureProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$businessFutureHash();

  @override
  String toString() {
    return r'businessFutureProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Business?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Business?> create(Ref ref) {
    final argument = this.argument as BusinessID;
    return businessFuture(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BusinessFutureProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$businessFutureHash() => r'f427748821842a1c6cdd82eefe4447ff45672128';

final class BusinessFutureFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Business?>, BusinessID> {
  const BusinessFutureFamily._()
    : super(
        retry: null,
        name: r'businessFutureProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BusinessFutureProvider call(BusinessID id) =>
      BusinessFutureProvider._(argument: id, from: this);

  @override
  String toString() => r'businessFutureProvider';
}

@ProviderFor(businessStream)
const businessStreamProvider = BusinessStreamFamily._();

final class BusinessStreamProvider
    extends
        $FunctionalProvider<AsyncValue<Business?>, Business?, Stream<Business?>>
    with $FutureModifier<Business?>, $StreamProvider<Business?> {
  const BusinessStreamProvider._({
    required BusinessStreamFamily super.from,
    required BusinessID super.argument,
  }) : super(
         retry: null,
         name: r'businessStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$businessStreamHash();

  @override
  String toString() {
    return r'businessStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Business?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Business?> create(Ref ref) {
    final argument = this.argument as BusinessID;
    return businessStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BusinessStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$businessStreamHash() => r'a7423ff885214d5e052e8d4e99720d67f2c0976d';

final class BusinessStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Business?>, BusinessID> {
  const BusinessStreamFamily._()
    : super(
        retry: null,
        name: r'businessStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BusinessStreamProvider call(BusinessID id) =>
      BusinessStreamProvider._(argument: id, from: this);

  @override
  String toString() => r'businessStreamProvider';
}
