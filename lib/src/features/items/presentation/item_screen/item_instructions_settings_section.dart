import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/outlined_section_widget.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_settings_shared.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/settings_content_controller.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

class ItemInstructionsSettingsSection extends ConsumerStatefulWidget {
  const ItemInstructionsSettingsSection({
    super.key,
    required this.item,
    required this.storeId,
    required this.isLoading,
  });

  final Item item;
  final StoreID storeId;
  final bool isLoading;

  @override
  ConsumerState<ItemInstructionsSettingsSection> createState() =>
      _ItemInstructionsSettingsSectionState();
}

class _ItemInstructionsSettingsSectionState
    extends ConsumerState<ItemInstructionsSettingsSection> {
  late final TextEditingController _collectionInstructionsCtl;
  late final TextEditingController _storingAndAllergensCtl;

  bool _isEditing = false;
  PackagingOption _packagingType = PackagingOption.withBagOrOwnBag;
  bool _isBuffetFood = false;

  @override
  void initState() {
    super.initState();
    _collectionInstructionsCtl = TextEditingController();
    _storingAndAllergensCtl = TextEditingController();
    _syncFromItem(widget.item);
  }

  @override
  void didUpdateWidget(covariant ItemInstructionsSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item && !_isEditing) {
      _syncFromItem(widget.item);
    }
  }

  @override
  void dispose() {
    _collectionInstructionsCtl.dispose();
    _storingAndAllergensCtl.dispose();
    super.dispose();
  }

  void _syncFromItem(Item item) {
    _packagingType = item.packagingType;
    _collectionInstructionsCtl.text = item.collectionInstructions ?? '';
    _isBuffetFood = item.isBuffetFood;
    _storingAndAllergensCtl.text = item.storingAndAllergens ?? '';
  }

  bool get _haveChanges {
    final item = widget.item;
    return _packagingType != item.packagingType ||
        _collectionInstructionsCtl.text != (item.collectionInstructions ?? '') ||
        _isBuffetFood != item.isBuffetFood ||
        _storingAndAllergensCtl.text != (item.storingAndAllergens ?? '');
  }

  void _save() {
    final updatedItem = widget.item.copyWith(
      packagingType: _packagingType,
      collectionInstructions: _collectionInstructionsCtl.text,
      isBuffetFood: _isBuffetFood,
      storingAndAllergens: _storingAndAllergensCtl.text,
    );

    ref
        .read(settingsContentControllerProvider.notifier)
        .updateItem(storeId: widget.storeId, updatedItem: updatedItem);
    setState(() => _isEditing = false);
  }

  void _cancel() {
    _syncFromItem(widget.item);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hintStyle = textTheme.bodySmall?.copyWith(
      color: Colors.grey.shade600,
    );
    final canSave = _isEditing && _haveChanges;

    return OutlinedSectionWidgetWithHeader(
      header: 'Instructions',
      trailing: _isEditing
          ? TextButton(onPressed: _cancel, child: const Text('Cancel'))
          : TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailRow(
            label: 'Packaging',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To ensure a smooth collection, select the packaging type you will offer.',
                  style: hintStyle,
                ),
                gapH8,
                _isEditing
                    ? DropdownButtonFormField<PackagingOption>(
                        initialValue: _packagingType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: PackagingOption.values
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _packagingType = value);
                          }
                        },
                      )
                    : Text(
                        widget.item.packagingType.label,
                        style: textTheme.bodyMedium,
                      ),
              ],
            ),
          ),
          gapH20,
          DetailRow(
            label: 'Collection instructions',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You can add additional instructions regarding collection here, and they will be shown in the app.',
                  style: hintStyle,
                ),
                gapH8,
                _isEditing
                    ? TextField(
                        controller: _collectionInstructionsCtl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'e.g. Come to the back door',
                        ),
                        onChanged: (_) => setState(() {}),
                      )
                    : Text(
                        widget.item.collectionInstructions?.isNotEmpty == true
                            ? widget.item.collectionInstructions!
                            : '-',
                        style: textTheme.bodyMedium,
                      ),
              ],
            ),
          ),
          gapH20,
          DetailRow(
            label: 'Buffet food safety',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Let us know if this Surprise Bag contains food from a buffet. Users will see buffet-specific food safety recommendations in the app.',
                  style: hintStyle,
                ),
                gapH8,
                _isEditing
                    ? SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          _isBuffetFood ? 'Yes' : 'No',
                          style: textTheme.bodyMedium,
                        ),
                        value: _isBuffetFood,
                        onChanged: (value) =>
                            setState(() => _isBuffetFood = value),
                      )
                    : Text(
                        widget.item.isBuffetFood ? 'Yes' : 'No',
                        style: textTheme.bodyMedium,
                      ),
              ],
            ),
          ),
          gapH20,
          DetailRow(
            label: 'Storing and allergens',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You can add recommendations for storing and handling food, including warnings about allergens, here, and they will be shown in the app.',
                  style: hintStyle,
                ),
                gapH8,
                _isEditing
                    ? TextField(
                        controller: _storingAndAllergensCtl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: 'e.g. Store in fridge, may contain nuts',
                        ),
                        onChanged: (_) => setState(() {}),
                      )
                    : Text(
                        widget.item.storingAndAllergens?.isNotEmpty == true
                            ? widget.item.storingAndAllergens!
                            : '-',
                        style: textTheme.bodyMedium,
                      ),
              ],
            ),
          ),
          if (_isEditing) ...[
            gapH20,
            PrimaryWebButton(
              text: 'Save',
              onPressed: canSave && !widget.isLoading ? _save : null,
              isLoading: widget.isLoading,
            ),
          ],
        ],
      ),
    );
  }
}
