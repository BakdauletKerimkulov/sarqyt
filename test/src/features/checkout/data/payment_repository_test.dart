import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sarqyt/src/features/checkout/data/payment_repository.dart';

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<Object?> {}

void main() {
  late MockFirebaseFunctions functions;
  late MockHttpsCallable callable;
  late MockHttpsCallableResult result;
  late PaymentRepository repository;

  setUpAll(() {
    registerFallbackValue(
      HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );
  });

  setUp(() {
    functions = MockFirebaseFunctions();
    callable = MockHttpsCallable();
    result = MockHttpsCallableResult();
    repository = PaymentRepository(functions);

    when(
      () => functions.httpsCallable(
        'reserveOffer',
        options: any(named: 'options'),
      ),
    ).thenReturn(callable);
    when(() => callable.call(any())).thenAnswer((_) async => result);
    when(() => result.data).thenReturn({'success': true, 'orderId': 'o1'});
  });

  test('reserveOffer passes through the provided idempotencyKey', () async {
    final orderId = await repository.reserveOffer(
      offerId: 'offer1',
      quantity: 2,
      idempotencyKey: 'key-123',
    );

    expect(orderId, 'o1');
    final captured =
        verify(() => callable.call(captureAny())).captured.single as Map;
    expect(captured['offerId'], 'offer1');
    expect(captured['quantity'], 2);
    expect(captured['idempotencyKey'], 'key-123');
  });
}
