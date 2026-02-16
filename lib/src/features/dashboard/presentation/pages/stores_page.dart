// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/no_object_found_widget.dart';
import 'package:sarqyt/src/common_widgets/responsive_card.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/constants/breakpoints.dart';
import 'package:sarqyt/src/features/dashboard/presentation/pages/dashboard_page_layout.dart';
import 'package:sarqyt/src/features/store/data/store_repository.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/features/store/presentation/create_store_page_controller.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class StoresPage extends ConsumerWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      storeListStreamProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    // * Слушаем удаление
    ref.listen(deleteStoreControllerProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });
    final storesValue = ref.watch(storeListStreamProvider);

    final state = ref.watch(deleteStoreControllerProvider);

    return DashboardPageLayout(
      title: 'Stores'.hardcoded,
      subtitle: 'Manage your stores'.hardcoded,
      createLabel: 'Add new store'.hardcoded,
      onCreatePressed: () => context.goNamed(BusinessRoute.createStore.name),
      child: AsyncValueWidget(
        value: storesValue,
        data: (stores) {
          return stores.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    gapH24,
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                200, // максимальная ширина одной карточки
                            mainAxisExtent: 100, // высота карточки
                            crossAxisSpacing: Sizes.p16,
                            mainAxisSpacing: Sizes.p16,
                          ),
                      children: [
                        ResponsiveCard(
                          child: Column(
                            children: [
                              Text('Total stores'.hardcoded),
                              Text(
                                '${stores.length}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    gapH16,

                    // * Таблица магазинов
                    MyStoresTable(
                      stores: stores,
                      onDelete: state.isLoading
                          ? null
                          : (storeId) async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete store?'.hardcoded),
                                  content: Text(
                                    'Are you sure to delete this store?'
                                        .hardcoded,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => context.pop(false),
                                      child: Text('Cancel'.hardcoded),
                                    ),
                                    TextButton(
                                      onPressed: () => context.pop(true),
                                      child: Text('Delete'.hardcoded),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              final success = await ref
                                  .read(deleteStoreControllerProvider.notifier)
                                  .deleteStore(storeId);

                              if (!context.mounted) return;

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Store has been deleted'.hardcoded,
                                    ),
                                  ),
                                );
                              }
                            },
                    ),
                  ],
                )
              : NoObjectFoundWidget(text: 'No stores found');
        },
      ),
    );
  }
}

class MyStoresTable extends StatelessWidget {
  static const int nameFlex = 2;
  static const int locationFlex = 3;
  static const int contactFlex = 2;
  static const int staffFlex = 1;
  static const int actionsFlex = 2;

  const MyStoresTable({super.key, required this.stores, this.onDelete});

  final List<Store> stores;
  final Function(String)? onDelete;

  @override
  Widget build(BuildContext context) {
    return ResponsiveCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= Breakpoint.desktop;

          final tabletWidth = max(Breakpoint.desktop, constraints.maxWidth);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: isDesktop ? const NeverScrollableScrollPhysics() : null,
            child: SizedBox(
              width: tabletWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'My stores',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  gapH24,
                  // * Заголовок
                  Row(
                    children: [
                      Expanded(
                        flex: nameFlex,
                        child: Text(
                          'Store name'.hardcoded,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      gapW16,
                      Expanded(
                        flex: locationFlex,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 100),
                          child: Text(
                            'Location'.hardcoded,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      gapW16,
                      Expanded(
                        flex: contactFlex,
                        child: Text(
                          'Contact'.hardcoded,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      gapW16,
                      Expanded(
                        flex: staffFlex,
                        child: Center(
                          child: Text(
                            'Staff',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      gapW16,
                      Expanded(
                        flex: actionsFlex,
                        child: Text(
                          'Actions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  // * Таблица
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stores.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (BuildContext context, int index) {
                      final store = stores[index];
                      return Row(
                        children: [
                          Expanded(
                            flex: nameFlex,
                            child: Padding(
                              padding: const EdgeInsets.only(left: Sizes.p16),
                              child: Text(
                                store.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          gapW16,
                          Expanded(
                            flex: locationFlex,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 100),
                              child: Text(
                                store.addressInfo,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          gapW16,
                          Expanded(
                            flex: contactFlex,
                            child: Text(store.phoneNumber ?? '-'),
                          ),
                          gapW16,
                          Expanded(
                            flex: staffFlex,
                            child: Center(child: Text('0')),
                          ), // Сделай работников,
                          gapW16,
                          Expanded(
                            flex: actionsFlex,
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () => context.goNamed(
                                    BusinessRoute.store.name,
                                    pathParameters: {'storeId': store.id},
                                  ),
                                  child: Text('Products'.hardcoded),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    onDelete?.call(store.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
