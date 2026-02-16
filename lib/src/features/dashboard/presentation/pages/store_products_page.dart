// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/responsive_centered_grid.dart';
import 'package:sarqyt/src/features/dashboard/presentation/pages/dashboard_page_layout.dart';
import 'package:sarqyt/src/features/products/data/products_repoitory.dart';
import 'package:sarqyt/src/features/products/presentation/product_card.dart';
import 'package:sarqyt/src/features/store/data/store_repository.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class StoreProductsPage extends ConsumerWidget {
  const StoreProductsPage({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeStreamProvider(storeId)).value;
    final productsValue = ref.watch(productsListStreamProvider(storeId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardPageLayout(
          title: '${store?.name ?? 'Store'} products',
          subtitle: 'Manage your products'.hardcoded,
          createLabel: 'Create new product'.hardcoded,
          onBackPressed: () => context.pop(),
          onCreatePressed: () => context.goNamed(
            BusinessRoute.createProduct.name,
            pathParameters: {'storeId': storeId},
          ),
          child: AsyncValueWidget(
            value: productsValue,
            data: (products) {
              return products.isEmpty
                  ? Center(
                      child: Text(
                        'No products',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    )
                  : ResponsiveCenteredGrid(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onPublish: () {
                            final productId = product.id;
                            context.goNamed(
                              BusinessRoute.createOffer.name,
                              pathParameters: {'storeId': storeId},
                              queryParameters: {'productId': productId},
                            );
                          },
                        );
                      },
                    );
            },
          ),
        ),
      ],
    );
  }
}
