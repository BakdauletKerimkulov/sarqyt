import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/presentation/item_tab.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class ItemActionDialog extends StatelessWidget {
  const ItemActionDialog({
    super.key,
    required this.item,
    required this.storeId,
  });

  final Item item;
  final StoreID storeId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(Sizes.p24),
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: Sizes.p16,
              right: Sizes.p16,
              top: Sizes.p20,
            ),
            child: Row(
              children: [
                Text(
                  item.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.clear),
                ),
              ],
            ),
          ),
          const Divider(),
          ...ItemTab.values.map((tab) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.of(context).pop();
                  context.goNamed(
                    BusinessRoute.item.name,
                    pathParameters: {'storeId': storeId, 'itemId': item.id},
                    queryParameters: {'tab': tab.param},
                  );
                },
                leading: Icon(tab.icon),
                title: Text(tab.title),
                trailing: Icon(Icons.chevron_right),
              ),
            );
          }),
          gapH16,
        ],
      ),
    );
  }
}
