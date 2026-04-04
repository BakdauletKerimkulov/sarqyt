import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/presentation/business/create_one_time_offer_controller.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class CreateOneTimeOfferDialog extends ConsumerStatefulWidget {
  const CreateOneTimeOfferDialog({super.key, required this.storeId});

  final StoreID storeId;

  @override
  ConsumerState<CreateOneTimeOfferDialog> createState() =>
      _CreateOneTimeOfferDialogState();
}

class _CreateOneTimeOfferDialogState
    extends ConsumerState<CreateOneTimeOfferDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  late DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);
  int _quantity = 1;

  String get _dateFormatted => DateFormat('d MMMM y').format(_selectedDate);

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty) return 'Enter offer name';
    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) return 'Enter a valid price';
    if (_quantity < 1) return 'Quantity must be at least 1';

    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    if (endMinutes <= startMinutes) return 'End time must be after start time';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
    if (isToday && endMinutes <= now.hour * 60 + now.minute) {
      return 'Pickup time is already past';
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

    final price = double.parse(_priceController.text);
    final success = await ref
        .read(createOneTimeOfferControllerProvider.notifier)
        .submit(
          storeId: widget.storeId,
          name: _nameController.text.trim(),
          price: price,
          date: _selectedDate,
          startTime: _startTime,
          endTime: _endTime,
          quantity: _quantity,
        );
    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createOneTimeOfferControllerProvider);
    final isLoading = state.isLoading;

    ref.listen(createOneTimeOfferControllerProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });

    return Dialog(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Sizes.p16),
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flash offer'.hardcoded,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              gapH4,
              Text(
                'Create a one-time offer'.hardcoded,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
              gapH16,
              const Divider(),
              gapH16,

              // Name
              Text('Offer name'.hardcoded,
                  style: Theme.of(context).textTheme.titleSmall),
              gapH8,
              TextField(
                controller: _nameController,
                enabled: !isLoading,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: 'e.g. Surprise Bag'.hardcoded,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(Sizes.p8),
                  ),
                ),
              ),
              gapH16,

              // Price
              Text('Price'.hardcoded,
                  style: Theme.of(context).textTheme.titleSmall),
              gapH8,
              TextField(
                controller: _priceController,
                enabled: !isLoading,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: '1500'.hardcoded,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(Sizes.p8),
                  ),
                  suffixText: '₸',
                ),
              ),
              gapH16,

              // Date
              Text('Date'.hardcoded,
                  style: Theme.of(context).textTheme.titleSmall),
              gapH8,
              InkWell(
                onTap: isLoading ? null : _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Sizes.p12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(Sizes.p8),
                  ),
                  child: Text(_dateFormatted),
                ),
              ),
              gapH16,

              // Time
              Text('Pickup window'.hardcoded,
                  style: Theme.of(context).textTheme.titleSmall),
              gapH8,
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: isLoading ? null : _pickStartTime,
                      child: Container(
                        padding: const EdgeInsets.all(Sizes.p12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(Sizes.p8),
                        ),
                        child: Text(_formatTime(_startTime),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: Sizes.p8),
                    child: Text('–'),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: isLoading ? null : _pickEndTime,
                      child: Container(
                        padding: const EdgeInsets.all(Sizes.p12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(Sizes.p8),
                        ),
                        child: Text(_formatTime(_endTime),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ],
              ),
              gapH16,

              // Quantity
              Text('Quantity'.hardcoded,
                  style: Theme.of(context).textTheme.titleSmall),
              gapH8,
              Row(
                children: [
                  IconButton(
                    onPressed: isLoading || _quantity <= 1
                        ? null
                        : () => setState(() => _quantity--),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: isLoading || _quantity >= 30
                        ? null
                        : () => setState(() => _quantity++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              gapH24,

              PrimaryWebButton(
                text: 'Create flash offer'.hardcoded,
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _startTime);
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _endTime);
    if (picked != null) setState(() => _endTime = picked);
  }
}
