import 'package:mocktail/mocktail.dart';
import 'package:sarqyt/src/features/checkout/data/payment_repository.dart';
import 'package:sarqyt/src/features/orders/data/client_orders_repository.dart';
import 'package:sarqyt/src/features/orders/data/orders_repository.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

class MockClientOrdersRepository extends Mock
    implements ClientOrdersRepository {}

class MockStoreOrdersRepository extends Mock implements StoreOrdersRepository {}
