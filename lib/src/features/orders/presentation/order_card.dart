// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/info_badge.dart';
import 'package:sarqyt/src/common_widgets/responsive_card.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return ResponsiveCard(
      child: Column(
        children: [
          Text('Номер заказа: #${order.orderNumber}'),
          gapH16,
          Text('Статус заказа: '),
          gapH8,
          InfoBadge(text: order.status.name),
          gapH16,
          Text('Заказ создан: ${order.createdAt}'),
          gapH8,
          Text(order.totalFormatted),
          gapH8,
          Text(order.itemQuantity.toString()),
        ],
      ),
    );
  }
}
