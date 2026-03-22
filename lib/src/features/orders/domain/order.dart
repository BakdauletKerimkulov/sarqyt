import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/utils/converters.dart';

part 'order.freezed.dart';
part 'order.g.dart';

typedef OrderID = String;

enum OrderStatus { confirmed, preparing, readyForPickup, completed, cancelled }

enum PaymentStatus { paid, refunded }

@freezed
abstract class Order with _$Order {
  const factory Order({
    required OrderID id,
    required ItemID itemId,
    required StoreID storeId,
    required UserID customerId,
    required String itemName,
    required String storeName,
    String? itemImageUrl,
    required double unitPrice,
    @Default('KZT') String currencyCode,
    @Default('₸') String currencySymbol,
    required int itemQuantity,
    required OrderStatus status,
    required PaymentStatus paymentStatus,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? updatedAt,
    int? orderNumber,
  }) = _Order;

  const Order._();

  String get price => 'Сумма заказа: ${unitPrice.round()} $currencySymbol';

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
