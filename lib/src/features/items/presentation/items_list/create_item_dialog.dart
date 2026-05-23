import 'package:sarqyt/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/data/items_repository.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class CreateItemTypeDialog extends ConsumerStatefulWidget {
  const CreateItemTypeDialog({super.key, required this.storeId});

  final StoreID storeId;

  @override
  ConsumerState<CreateItemTypeDialog> createState() =>
      _CreateItemTypeDialogState();
}

class _CreateItemTypeDialogState extends ConsumerState<CreateItemTypeDialog> {
  // Step 0: choose type, Step 1: fill details
  int _step = 0;
  ItemType _type = ItemType.scheduled;

  // Item fields
  final _nameController = TextEditingController(text: 'Surprise Bag');
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _estimatedValueController = TextEditingController();

  // One-time fields
  late DateTime _oneTimeDate = DateTime.now();
  TimeOfDay _oneTimeStart = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _oneTimeEnd = const TimeOfDay(hour: 20, minute: 0);
  int _oneTimeQuantity = 1;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _estimatedValueController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty) return 'Name is required';
    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) return 'Enter a valid price';

    if (_type == ItemType.oneTime) {
      final startMin = _oneTimeStart.hour * 60 + _oneTimeStart.minute;
      final endMin = _oneTimeEnd.hour * 60 + _oneTimeEnd.minute;
      if (endMin <= startMin) return 'End time must be after start time';
      if (_oneTimeQuantity < 1) return 'Quantity must be at least 1';
    }

    return null;
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final price = double.parse(_priceController.text);
      final evText = _estimatedValueController.text;
      final estimatedValue =
          evText.isNotEmpty ? double.tryParse(evText) : null;

      final itemId = await ref.read(itemsRepositoryProvider).createItem(
            widget.storeId,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            price: price,
            estimatedValue: estimatedValue,
            schedule: WeeklySchedule.defaultSchedule(),
            type: _type == ItemType.oneTime ? 'oneTime' : 'scheduled',
            oneTimeDate: _type == ItemType.oneTime
                ? DateFormat('yyyy-MM-dd').format(_oneTimeDate)
                : null,
            oneTimeStartHour:
                _type == ItemType.oneTime ? _oneTimeStart.hour : null,
            oneTimeStartMinute:
                _type == ItemType.oneTime ? _oneTimeStart.minute : null,
            oneTimeEndHour:
                _type == ItemType.oneTime ? _oneTimeEnd.hour : null,
            oneTimeEndMinute:
                _type == ItemType.oneTime ? _oneTimeEnd.minute : null,
            oneTimeQuantity:
                _type == ItemType.oneTime ? _oneTimeQuantity : null,
          );

      if (!mounted) return;
      Navigator.pop(context, true);

      // For scheduled items → navigate to schedule tab
      if (_type == ItemType.scheduled) {
        context.goNamed(
          BusinessRoute.item.name,
          pathParameters: {
            'storeId': widget.storeId,
            'itemId': itemId,
          },
          queryParameters: {
            'tab': 'schedule',
            'type': _type.name,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(humanReadableError(e))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.loc;

    return Dialog(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Sizes.p24, Sizes.p20, Sizes.p8, Sizes.p8,
              ),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      onPressed: () => setState(() => _step = 0),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  Expanded(
                    child: Text(
                      _step == 0
                          ? loc.createNew
                          : loc.itemDetails,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Sizes.p24),
                child: _step == 0 ? _buildTypeStep(theme) : _buildDetailsStep(theme),
              ),
            ),

            // Button
            if (_step == 1) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(Sizes.p16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: Sizes.p12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Sizes.p24),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(loc.createItem),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeStep(ThemeData theme) {
    final loc = context.loc;
    return Column(
      children: [
        Text(
          loc.chooseSurpriseBagType,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        gapH24,
        _TypeOption(
          icon: Icons.calendar_month,
          title: loc.scheduled,
          description: loc.recurringSchedule,
          onTap: () => setState(() {
            _type = ItemType.scheduled;
            _step = 1;
          }),
        ),
        gapH12,
        _TypeOption(
          icon: Icons.flash_on,
          title: loc.oneTime,
          description: loc.singleSpecificDate,
          onTap: () => setState(() {
            _type = ItemType.oneTime;
            _step = 1;
          }),
        ),
      ],
    );
  }

  Widget _buildDetailsStep(ThemeData theme) {
    final loc = context.loc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        Text(loc.name, style: theme.textTheme.titleSmall),
        gapH8,
        TextField(
          controller: _nameController,
          enabled: !_isLoading,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(loc.surpriseBag),
        ),
        gapH16,

        // Description
        Text(loc.description, style: theme.textTheme.titleSmall),
        gapH8,
        TextField(
          controller: _descriptionController,
          enabled: !_isLoading,
          maxLines: 3,
          decoration: _inputDecoration(
            loc.rescueSurpriseBag,
          ),
        ),
        gapH16,

        // Price
        Text(loc.price, style: theme.textTheme.titleSmall),
        gapH8,
        TextField(
          controller: _priceController,
          enabled: !_isLoading,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('1500').copyWith(
            suffixText: '₸',
          ),
        ),
        gapH16,

        // Estimated value
        Text(loc.estimatedValueOptional,
            style: theme.textTheme.titleSmall),
        gapH8,
        TextField(
          controller: _estimatedValueController,
          enabled: !_isLoading,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('5000').copyWith(
            suffixText: '₸',
          ),
        ),
        gapH24,

        // One-time specific fields
        if (_type == ItemType.oneTime) ...[
          const Divider(),
          gapH16,
          Text(loc.date, style: theme.textTheme.titleSmall),
          gapH8,
          InkWell(
            onTap: _isLoading ? null : _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Sizes.p12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(Sizes.p8),
              ),
              child: Text(DateFormat('d MMMM y').format(_oneTimeDate)),
            ),
          ),
          gapH16,
          Text(loc.pickupWindow, style: theme.textTheme.titleSmall),
          gapH8,
          Row(
            children: [
              Expanded(child: _timeButton(_oneTimeStart, _pickStartTime)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.p8),
                child: Text('–'),
              ),
              Expanded(child: _timeButton(_oneTimeEnd, _pickEndTime)),
            ],
          ),
          gapH16,
          Text(loc.quantity, style: theme.textTheme.titleSmall),
          gapH8,
          Row(
            children: [
              IconButton(
                onPressed: _isLoading || _oneTimeQuantity <= 1
                    ? null
                    : () => setState(() => _oneTimeQuantity--),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$_oneTimeQuantity',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: _isLoading || _oneTimeQuantity >= 30
                    ? null
                    : () => setState(() => _oneTimeQuantity++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      hintText: hint,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(Sizes.p8),
      ),
    );
  }

  Widget _timeButton(TimeOfDay time, VoidCallback onTap) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(Sizes.p12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(Sizes.p8),
        ),
        child: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _oneTimeDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _oneTimeDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _oneTimeStart);
    if (picked != null) setState(() => _oneTimeStart = picked);
  }

  Future<void> _pickEndTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _oneTimeEnd);
    if (picked != null) setState(() => _oneTimeEnd = picked);
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Sizes.p12),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 32),
              gapW16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    gapH4,
                    Text(
                      description,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
