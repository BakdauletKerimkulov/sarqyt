import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_details_settings_section.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_instructions_settings_section.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/settings_content_controller.dart';
import 'package:sarqyt/src/features/store/data/store_repository.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class SettingsContent extends ConsumerWidget {
  const SettingsContent({super.key, required this.item, required this.storeId});

  final Item item;
  final StoreID storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      settingsContentControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final controllerState = ref.watch(settingsContentControllerProvider);
    final isLoading = controllerState.isLoading;
    final storeName = ref.watch(storeStreamProvider(storeId)).value?.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemDetailsSettingsSection(
          item: item,
          storeId: storeId,
          storeName: storeName,
          isLoading: isLoading,
        ),
        gapH24,
        ItemInstructionsSettingsSection(
          item: item,
          storeId: storeId,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
