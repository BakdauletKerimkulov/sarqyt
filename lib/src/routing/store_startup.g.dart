// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_startup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storeStartup)
const storeStartupProvider = StoreStartupFamily._();

final class StoreStartupProvider
    extends
        $FunctionalProvider<
          AsyncValue<StoreStartupData>,
          StoreStartupData,
          FutureOr<StoreStartupData>
        >
    with $FutureModifier<StoreStartupData>, $FutureProvider<StoreStartupData> {
  const StoreStartupProvider._({
    required StoreStartupFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'storeStartupProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storeStartupHash();

  @override
  String toString() {
    return r'storeStartupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<StoreStartupData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StoreStartupData> create(Ref ref) {
    final argument = this.argument as String;
    return storeStartup(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StoreStartupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storeStartupHash() => r'02f033eecbab977f273692f41a2ed4107d2692c1';

final class StoreStartupFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<StoreStartupData>, String> {
  const StoreStartupFamily._()
    : super(
        retry: null,
        name: r'storeStartupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StoreStartupProvider call(String storeId) =>
      StoreStartupProvider._(argument: storeId, from: this);

  @override
  String toString() => r'storeStartupProvider';
}
