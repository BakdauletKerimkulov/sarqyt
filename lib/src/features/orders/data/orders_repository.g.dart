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
        isAutoDispose: false,
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

String _$ordersRepositoryHash() => r'1a697d203c67332bce6850c828a53f90adf13afd';

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

String _$ordersListStreamHash() => r'2ff53b70b9e89e0a5ba66ff3ffe1ad0e325553ed';

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

@ProviderFor(ordersListForItemStream)
const ordersListForItemStreamProvider = OrdersListForItemStreamFamily._();

final class OrdersListForItemStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Order>>,
          List<Order>,
          Stream<List<Order>>
        >
    with $FutureModifier<List<Order>>, $StreamProvider<List<Order>> {
  const OrdersListForItemStreamProvider._({
    required OrdersListForItemStreamFamily super.from,
    required (StoreID, ItemID) super.argument,
  }) : super(
         retry: null,
         name: r'ordersListForItemStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ordersListForItemStreamHash();

  @override
  String toString() {
    return r'ordersListForItemStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Order>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Order>> create(Ref ref) {
    final argument = this.argument as (StoreID, ItemID);
    return ordersListForItemStream(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is OrdersListForItemStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ordersListForItemStreamHash() =>
    r'90d302c70906a6f60d7bf5941ced8716e26d2c97';

final class OrdersListForItemStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Order>>, (StoreID, ItemID)> {
  const OrdersListForItemStreamFamily._()
    : super(
        retry: null,
        name: r'ordersListForItemStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrdersListForItemStreamProvider call(StoreID storeId, ItemID itemId) =>
      OrdersListForItemStreamProvider._(
        argument: (storeId, itemId),
        from: this,
      );

  @override
  String toString() => r'ordersListForItemStreamProvider';
}
