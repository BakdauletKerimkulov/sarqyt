import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sarqyt/src/features/orders/data/orders_repository.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<Object?> {}

void main() {
  late MockFirebaseFirestore firestore;
  late MockFirebaseFunctions functions;
  late MockHttpsCallable callable;
  late MockHttpsCallableResult result;
  late StoreOrdersRepository repository;

  setUp(() {
    firestore = MockFirebaseFirestore();
    functions = MockFirebaseFunctions();
    callable = MockHttpsCallable();
    result = MockHttpsCallableResult();
    repository = StoreOrdersRepository(firestore, functions);

    when(() => functions.httpsCallable('cancelOrder')).thenReturn(callable);
    when(() => callable.call(any())).thenAnswer((_) async => result);
    when(() => result.data).thenReturn({'success': true});
  });

  test('cancelOrder passes reason when provided', () async {
    await repository.cancelOrder('order1', reason: 'Товар закончился');

    final captured =
        verify(() => callable.call(captureAny())).captured.single as Map;
    expect(captured['orderId'], 'order1');
    expect(captured['reason'], 'Товар закончился');
  });

  test('cancelOrder omits reason field when not provided', () async {
    await repository.cancelOrder('order1');

    final captured =
        verify(() => callable.call(captureAny())).captured.single as Map;
    expect(captured['orderId'], 'order1');
    expect(captured.containsKey('reason'), isFalse);
  });
}
