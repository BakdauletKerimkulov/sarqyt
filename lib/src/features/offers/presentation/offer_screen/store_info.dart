import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/features/offers/data/client_offer_repository.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';

class StoreInfo extends ConsumerWidget {
  const StoreInfo(this.id, {super.key});
  final ProductID id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerFutureProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: offerAsync.value != null
            ? Text(offerAsync.value!.store.name)
            : Text('Store not found'),
      ),
    );
  }
}
