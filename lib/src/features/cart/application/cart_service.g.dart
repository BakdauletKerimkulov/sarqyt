// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shoppingCartItems)
const shoppingCartItemsProvider = ShoppingCartItemsProvider._();

final class ShoppingCartItemsProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  const ShoppingCartItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shoppingCartItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shoppingCartItemsHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return shoppingCartItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$shoppingCartItemsHash() => r'80700af2e517f7be18320f4e508b454ef9b817fe';
