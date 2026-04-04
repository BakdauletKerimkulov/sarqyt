// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ordersRepository)
const ordersRepositoryProvider = OrdersRepositoryProvider._();

final class OrdersRepositoryProvider
    extends
        $FunctionalProvider<
          StoreOrdersRepository,
          StoreOrdersRepository,
          StoreOrdersRepository
        >
    with $Provider<StoreOrdersRepository> {
  const OrdersRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ordersRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ordersRepositoryHash();

  @$internal
  @override
  $ProviderElement<StoreOrdersRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StoreOrdersRepository create(Ref ref) {
    return ordersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreOrdersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreOrdersRepository>(value),
    );
  }
}

String _$ordersRepositoryHash() => r'e094903046b80108bb5c14eac0e286337dd6bfaf';

@ProviderFor(ordersListStream)
const ordersListStreamProvider = OrdersListStreamFamily._();

final class OrdersListStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Order>>,
          List<Order>,
          Stream<List<Order>>
        >
    with $FutureModifier<List<Order>>, $StreamProvider<List<Order>> {
  const OrdersListStreamProvider._({
    required OrdersListStreamFamily super.from,
    required StoreID super.argument,
  }) : super(
         retry: null,
         name: r'ordersListStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ordersListStreamHash();

  @override
  String toString() {
    return r'ordersListStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Order>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Order>> create(Ref ref) {
    final argument = this.argument as StoreID;
    return ordersListStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersListStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ordersListStreamHash() => r'08b6504cabd6027a4d623b4935d52fe2646c5958';

final class OrdersListStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Order>>, StoreID> {
  const OrdersListStreamFamily._()
    : super(
        retry: null,
        name: r'ordersListStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrdersListStreamProvider call(StoreID id) =>
      OrdersListStreamProvider._(argument: id, from: this);

  @override
  String toString() => r'ordersListStreamProvider';
}
