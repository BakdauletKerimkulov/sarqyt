import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sarqyt/src/common_widgets/outlined_section_widget.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_details.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/item_settings_shared.dart';
import 'package:sarqyt/src/features/items/presentation/item_screen/settings_content_controller.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

class ItemDetailsSettingsSection extends ConsumerStatefulWidget {
  const ItemDetailsSettingsSection({
    super.key,
    required this.item,
    required this.storeId,
    required this.storeName,
    required this.isLoading,
  });

  final Item item;
  final StoreID storeId;
  final String? storeName;
  final bool isLoading;

  @override
  ConsumerState<ItemDetailsSettingsSection> createState() =>
      _ItemDetailsSettingsSectionState();
}

class _ItemDetailsSettingsSectionState
    extends ConsumerState<ItemDetailsSettingsSection> {
  static const _categoryOptions = ['meal'];

  final _imagePicker = ImagePicker();
  late final TextEditingController _descriptionCtl;
  late final TextEditingController _priceCtl;
  late final TextEditingController _estimatedValueCtl;

  bool _isEditing = false;
  String? _category;
  DietaryType _dietaryType = DietaryType.notSpecified;

  @override
  void initState() {
    super.initState();
    _descriptionCtl = TextEditingController();
    _priceCtl = TextEditingController();
    _estimatedValueCtl = TextEditingController();
    _syncFromItem(widget.item);
  }

  @override
  void didUpdateWidget(covariant ItemDetailsSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item && !_isEditing) {
      _syncFromItem(widget.item);
    }
  }

  @override
  void dispose() {
    _descriptionCtl.dispose();
    _priceCtl.dispose();
    _estimatedValueCtl.dispose();
    super.dispose();
  }

  void _syncFromItem(Item item) {
    _descriptionCtl.text = item.description ?? '';
    _priceCtl.text = item.price.round().toString();
    _estimatedValueCtl.text =
        item.estimatedValue != null ? item.estimatedValue!.round().toString() : '';
    _category = item.category;
    _dietaryType = item.dietaryType;
  }

  String? get _validationError {
    final price = double.tryParse(_priceCtl.text);
    if (price == null || price <= 0) return 'Price must be greater than 0';
    final evText = _estimatedValueCtl.text;
    if (evText.isNotEmpty) {
      final ev = double.tryParse(evText);
      if (ev == null || ev <= 0) return 'Estimated value must be greater than 0';
      if (ev <= price) return 'Estimated value must be greater than price';
    }
    return null;
  }

  bool get _haveChanges {
    final item = widget.item;
    final evStr = item.estimatedValue != null
        ? item.estimatedValue!.round().toString()
        : '';
    return _descriptionCtl.text != (item.description ?? '') ||
        _priceCtl.text != item.price.round().toString() ||
        _estimatedValueCtl.text != evStr ||
        _category != item.category ||
        _dietaryType != item.dietaryType;
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    final Either<File, Uint8List> image;
    if (kIsWeb) {
      image = Right(await pickedFile.readAsBytes());
    } else {
      image = Left(File(pickedFile.path));
    }

    await ref
        .read(settingsContentControllerProvider.notifier)
        .updateItemImage(
          storeId: widget.storeId,
          item: widget.item,
          image: image,
        );
  }

  void _showImageEditMenu(BuildContext buttonContext) {
    final button = buttonContext.findRenderObject() as RenderBox;
    final overlay =
        Navigator.of(buttonContext).overlay!.context.findRenderObject()
            as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: buttonContext,
      position: position,
      items: const [
        PopupMenuItem(value: 'item_image', child: Text('Change item image')),
        PopupMenuItem(value: 'store_logo', child: Text('Change store logo')),
      ],
    ).then((value) {
      if (value == 'item_image') {
        _pickAndUploadImage();
      }
    });
  }

  void _save() {
    final price = double.parse(_priceCtl.text);
    final evText = _estimatedValueCtl.text;
    final estimatedValue = evText.isNotEmpty ? double.parse(evText) : null;

    final updatedItem = widget.item.copyWith(
      description: _descriptionCtl.text,
      price: price,
      estimatedValue: estimatedValue,
      category: _category,
      dietaryType: _dietaryType,
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
    final colors = Theme.of(context).colorScheme;
    final canSave = _isEditing && _haveChanges && _validationError == null;

    return OutlinedSectionWidgetWithHeader(
      header: 'Item details',
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
          StoreHeaderCard(
            imageUrl: widget.item.imageUrl,
            storeName: widget.storeName,
            onEditPressed: _isEditing ? null : _showImageEditMenu,
          ),
          gapH24,
          DetailRow(
            label: 'Name',
            child: Text(widget.item.name, style: textTheme.bodyMedium),
          ),
          gapH16,
          DetailRow(
            label: 'Description',
            child: _isEditing
                ? TextField(
                    controller: _descriptionCtl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  )
                : Text(
                    widget.item.description ?? '-',
                    style: textTheme.bodyMedium,
                  ),
          ),
          gapH16,
          DetailRow(
            label: 'Category',
            child: _isEditing
                ? DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _categoryOptions
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value),
                  )
                : Text(
                    widget.item.category ?? '-',
                    style: textTheme.bodyMedium,
                  ),
          ),
          gapH16,
          DetailRow(
            label: 'Dietary type',
            child: _isEditing
                ? DropdownButtonFormField<DietaryType>(
                    initialValue: _dietaryType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: DietaryType.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _dietaryType = value);
                    },
                  )
                : Text(
                    widget.item.dietaryType.label,
                    style: textTheme.bodyMedium,
                  ),
          ),
          gapH16,
          DetailRow(
            label: 'Price',
            child: _isEditing
                ? TextField(
                    controller: _priceCtl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  )
                : Text(
                    '${widget.item.price.round()}',
                    style: textTheme.bodyMedium,
                  ),
          ),
          gapH16,
          DetailRow(
            label: 'Estimated value',
            child: _isEditing
                ? TextField(
                    controller: _estimatedValueCtl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      hintText: 'Optional',
                    ),
                    onChanged: (_) => setState(() {}),
                  )
                : Text(
                    widget.item.estimatedValue != null
                        ? '${widget.item.estimatedValue!.round()} (-${widget.item.discountPercent}%)'
                        : '-',
                    style: textTheme.bodyMedium,
                  ),
          ),
          if (_isEditing && _validationError != null) ...[
            gapH12,
            Text(
              _validationError!,
              style: textTheme.bodySmall?.copyWith(color: colors.error),
            ),
          ],
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
