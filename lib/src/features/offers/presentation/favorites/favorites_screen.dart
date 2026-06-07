import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/data/favorites_repository.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(favoriteStoresProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.loc.favorites)),
      body: AsyncValueWidget<List<Store>>(
        value: storesAsync,
        data: (stores) {
          if (stores.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: Sizes.p64,
                    color: Colors.grey,
                  ),
                  gapH16,
                  Text(
                    context.loc.noFavoriteRestaurants,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(Sizes.p16),
            itemCount: stores.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final store = stores[index];
              return _FavoriteStoreTile(store: store);
            },
          );
        },
      ),
    );
  }
}

class _FavoriteStoreTile extends StatelessWidget {
  const _FavoriteStoreTile({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: customImageProvider(store.logoUrl),
        ),
        title: Text(store.name),
        subtitle: Text(store.addressInfo),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          showNotImplementedAlertDialog(context: context);
        },
      ),
    );
  }
}
