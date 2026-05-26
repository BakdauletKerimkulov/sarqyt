import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_details_settings_section.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_instructions_settings_section.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/settings_content_controller.dart';
import 'package:sarqyt/src/features/store/data/store_repository.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
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
        gapH24,
        _DeleteItemButton(
          item: item,
          storeId: storeId,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

class _DeleteItemButton extends ConsumerStatefulWidget {
  const _DeleteItemButton({
    required this.item,
    required this.storeId,
    required this.isLoading,
  });

  final Item item;
  final StoreID storeId;
  final bool isLoading;

  @override
  ConsumerState<_DeleteItemButton> createState() => _DeleteItemButtonState();
}

class _DeleteItemButtonState extends ConsumerState<_DeleteItemButton> {
  var _isDeleting = false;

  Future<void> _onDeletePressed() async {
    setState(() => _isDeleting = true);

    try {
      final controller =
          ref.read(settingsContentControllerProvider.notifier);
      final hasActive = await controller.hasActiveOrders(widget.storeId, widget.item.id);

      if (!mounted) return;

      if (hasActive) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Cannot delete'.hardcoded),
            content: Text(
              'There are active reservations. Cancel or complete them first.'
                  .hardcoded,
            ),
            actions: [
              TextButton(
                onPressed: () => ctx.pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Delete item'.hardcoded),
          content: Text(
            'Are you sure you want to delete this item? This action cannot be undone.'
                .hardcoded,
          ),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(false),
              child: Text('Cancel'.hardcoded),
            ),
            TextButton(
              onPressed: () => ctx.pop(true),
              child: Text(
                'Delete'.hardcoded,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      await controller.deleteItem(
        storeId: widget.storeId,
        itemId: widget.item.id,
      );

      if (!mounted) return;
      final state = ref.read(settingsContentControllerProvider);
      if (!state.hasError) {
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.isLoading || _isDeleting;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: disabled ? null : _onDeletePressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        icon: _isDeleting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              )
            : const Icon(Icons.delete_outline),
        label: Text('Delete item'.hardcoded),
      ),
    );
  }
}
