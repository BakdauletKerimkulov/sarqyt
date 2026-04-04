// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_orders_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clientOrdersRepository)
const clientOrdersRepositoryProvider = ClientOrdersRepositoryProvider._();

final class ClientOrdersRepositoryProvider
    extends
        $FunctionalProvider<
          ClientOrdersRepository,
          ClientOrdersRepository,
          ClientOrdersRepository
        >
    with $Provider<ClientOrdersRepository> {
  const ClientOrdersRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientOrdersRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientOrdersRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClientOrdersRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClientOrdersRepository create(Ref ref) {
    return clientOrdersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientOrdersRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientOrdersRepository>(value),
    );
  }
}

String _$clientOrdersRepositoryHash() =>
    r'187c9212d3bcd105e8fa57b93f5fabcd774c6615';

@ProviderFor(customerOrdersStream)
const customerOrdersStreamProvider = CustomerOrdersStreamProvider._();

final class CustomerOrdersStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Order>>,
          List<Order>,
          Stream<List<Order>>
        >
    with $FutureModifier<List<Order>>, $StreamProvider<List<Order>> {
  const CustomerOrdersStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerOrdersStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerOrdersStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Order>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Order>> create(Ref ref) {
    return customerOrdersStream(ref);
  }
}

String _$customerOrdersStreamHash() =>
    r'1cd72d8665d77321ddb51591c463b394a1a7c84d';

@ProviderFor(customerOrderStream)
const customerOrderStreamProvider = CustomerOrderStreamFamily._();

final class CustomerOrderStreamProvider
    extends $FunctionalProvider<AsyncValue<Order?>, Order?, Stream<Order?>>
    with $FutureModifier<Order?>, $StreamProvider<Order?> {
  const CustomerOrderStreamProvider._({
    required CustomerOrderStreamFamily super.from,
    required OrderID super.argument,
  }) : super(
         retry: null,
         name: r'customerOrderStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerOrderStreamHash();

  @override
  String toString() {
    return r'customerOrderStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Order?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Order?> create(Ref ref) {
    final argument = this.argument as OrderID;
    return customerOrderStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerOrderStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerOrderStreamHash() =>
    r'47e5c788dc802ff237e68a7c31f220f56ce0e183';

final class CustomerOrderStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Order?>, OrderID> {
  const CustomerOrderStreamFamily._()
    : super(
        retry: null,
        name: r'customerOrderStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomerOrderStreamProvider call(OrderID id) =>
      CustomerOrderStreamProvider._(argument: id, from: this);

  @override
  String toString() => r'customerOrderStreamProvider';
}
