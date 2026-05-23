import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/features/items/domain/weekly_schedule.dart';
import 'package:sarqyt/src/features/items/presentation/common/weekly_schedule_editor.dart';
import 'package:sarqyt/src/features/items/presentation/item_create/create_item_form_controller.dart';
import 'package:sarqyt/src/features/items/presentation/item_create/create_item_validators.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

/// Full-screen item creation form.
/// Used from Dashboard "+ Create new" button.
class CreateItemFormScreen extends ConsumerStatefulWidget {
  const CreateItemFormScreen({super.key, required this.storeId});

  final StoreID storeId;

  @override
  ConsumerState<CreateItemFormScreen> createState() =>
      _CreateItemFormScreenState();
}

class _CreateItemFormScreenState extends ConsumerState<CreateItemFormScreen>
    with CreateItemValidators {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController(text: 'Surprise Bag');
  final _descCtl = TextEditingController();
  final _priceCtl = TextEditingController();
  final _estimatedValueCtl = TextEditingController();

  ItemType _type = ItemType.scheduled;
  var _submitted = false;

  // Image
  final _imagePicker = ImagePicker();
  Either<File, Uint8List>? _selectedImage;
  Uint8List? _imagePreviewBytes;

  // Schedule (for scheduled type)
  late final Map<int, DaySchedule> _schedule = Map.from(
    WeeklySchedule.defaultSchedule().days,
  );

  // One-time fields
  late DateTime _oneTimeDate = DateTime.now();
  TimeOfDay _oneTimeStart = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _oneTimeEnd = const TimeOfDay(hour: 20, minute: 0);
  int _oneTimeQuantity = 1;

  @override
  void dispose() {
    _nameCtl.dispose();
    _descCtl.dispose();
    _priceCtl.dispose();
    _estimatedValueCtl.dispose();
    super.dispose();
  }

  /// Validates the non-text-field parts (schedule / one-time window).
  /// Text fields are validated by the [Form] via per-field validators.
  String? _validateExtras() {
    if (_type == ItemType.oneTime) {
      final startMin = _oneTimeStart.hour * 60 + _oneTimeStart.minute;
      final endMin = _oneTimeEnd.hour * 60 + _oneTimeEnd.minute;
      if (endMin <= startMin) return 'End time must be after start time';
    }
    if (_type == ItemType.scheduled) {
      final hasEnabled = _schedule.values.any((d) => d.enabled);
      if (!hasEnabled) return 'Enable at least one day';
    }
    return null;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    setState(() {
      _imagePreviewBytes = bytes;
      _selectedImage = kIsWeb ? Right(bytes) : Left(File(pickedFile.path));
    });
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final extrasError = _validateExtras();
    if (extrasError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(extrasError)));
      return;
    }

    final price = double.parse(_priceCtl.text);
    final evText = _estimatedValueCtl.text;
    final estimatedValue = evText.isNotEmpty ? double.tryParse(evText) : null;
    final isOneTime = _type == ItemType.oneTime;

    await ref
        .read(createItemFormControllerProvider.notifier)
        .submit(
          storeId: widget.storeId,
          name: _nameCtl.text.trim(),
          description: _descCtl.text.trim(),
          price: price,
          estimatedValue: estimatedValue,
          schedule: WeeklySchedule(_schedule),
          image: _selectedImage,
          type: isOneTime ? 'oneTime' : 'scheduled',
          oneTimeDate: isOneTime
              ? DateFormat('yyyy-MM-dd').format(_oneTimeDate)
              : null,
          oneTimeStartHour: isOneTime ? _oneTimeStart.hour : null,
          oneTimeStartMinute: isOneTime ? _oneTimeStart.minute : null,
          oneTimeEndHour: isOneTime ? _oneTimeEnd.hour : null,
          oneTimeEndMinute: isOneTime ? _oneTimeEnd.minute : null,
          oneTimeQuantity: isOneTime ? _oneTimeQuantity : null,
        );

    if (!mounted) return;
    final state = ref.read(createItemFormControllerProvider);
    if (!state.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.loc.itemCreated)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.loc;
    ref.listen<AsyncValue>(
      createItemFormControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final isLoading = ref.watch(createItemFormControllerProvider).isLoading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(loc.createSurpriseBag),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.p32,
            vertical: Sizes.p24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                GestureDetector(
                  onTap: isLoading ? null : _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(Sizes.p12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _imagePreviewBytes != null
                        ? Image.memory(
                            _imagePreviewBytes!,
                            fit: BoxFit.cover,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                              gapH8,
                              Text(
                                'Add photo'.hardcoded,
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                  ),
                ),
                gapH20,

                // Name
                _Label(loc.name),
                gapH8,
                TextFormField(
                  controller: _nameCtl,
                  enabled: !isLoading,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDeco(loc.surpriseBag),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) => !_submitted ? null : nameErrorText(v ?? '', loc),
                ),
                gapH20,

                // Description
                _Label(loc.description),
                gapH8,
                TextField(
                  controller: _descCtl,
                  enabled: !isLoading,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDeco(
                    loc.rescueSurpriseBag,
                  ),
                ),
                gapH20,

                // Price
                _Label(loc.price),
                gapH8,
                TextFormField(
                  controller: _priceCtl,
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDeco(
                    '1500',
                  ).copyWith(suffixText: '₸'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) =>
                      !_submitted ? null : priceErrorText(v ?? '', loc),
                  onChanged: (_) {
                    // re-validate estimated value, which depends on price
                    _formKey.currentState?.validate();
                  },
                ),
                gapH20,

                // Estimated value
                _Label(loc.estimatedValueOptional),
                gapH8,
                TextFormField(
                  controller: _estimatedValueCtl,
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDeco(
                    '5000',
                  ).copyWith(suffixText: '₸'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) => !_submitted
                      ? null
                      : estimatedValueErrorText(v ?? '', _priceCtl.text, loc),
                ),
                gapH24,
                const Divider(),
                gapH24,

                // Type selector
                _Label(loc.type),
                gapH12,
                SegmentedButton<ItemType>(
                  segments: [
                    ButtonSegment(
                      value: ItemType.scheduled,
                      label: Text(loc.scheduled),
                      icon: const Icon(Icons.calendar_month, size: 18),
                    ),
                    ButtonSegment(
                      value: ItemType.oneTime,
                      label: Text(loc.oneTime),
                      icon: const Icon(Icons.flash_on, size: 18),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: isLoading
                      ? null
                      : (v) => setState(() => _type = v.first),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primary.withAlpha(30);
                      }
                      return null;
                    }),
                  ),
                ),
                gapH24,

                // Type-specific fields
                if (_type == ItemType.scheduled)
                  _buildScheduleSection(theme, isLoading),
                if (_type == ItemType.oneTime)
                  _buildOneTimeSection(theme, isLoading),

                gapH32,

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Sizes.p16),
                      ),
                    ),
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            loc.createItem,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                gapH48,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSection(ThemeData theme, bool isLoading) {
    final loc = context.loc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(loc.weeklySchedule),
        gapH4,
        Text(
          loc.setPickupWindowAndQuantity,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        gapH16,
        WeeklyScheduleEditor(
          schedule: WeeklySchedule(_schedule),
          enabled: !isLoading,
          onToggleDay: (day, v) => setState(() {
            _schedule[day] = _schedule[day]!.copyWith(enabled: v);
          }),
          onPickStart: (day) async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _schedule[day]!.startTime,
            );
            if (picked != null) {
              setState(() {
                _schedule[day] = _schedule[day]!.copyWith(
                  startHour: picked.hour,
                  startMinute: picked.minute,
                );
              });
            }
          },
          onPickEnd: (day) async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _schedule[day]!.endTime,
            );
            if (picked != null) {
              setState(() {
                _schedule[day] = _schedule[day]!.copyWith(
                  endHour: picked.hour,
                  endMinute: picked.minute,
                );
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildOneTimeSection(ThemeData theme, bool isLoading) {
    final loc = context.loc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(loc.date),
        gapH8,
        InkWell(
          onTap: isLoading ? null : _pickDate,
          borderRadius: BorderRadius.circular(Sizes.p8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Sizes.p12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(Sizes.p8),
            ),
            child: Text(DateFormat('d MMMM y').format(_oneTimeDate)),
          ),
        ),
        gapH20,

        _Label(loc.pickupWindow),
        gapH8,
        Row(
          children: [
            Expanded(
              child: _timeButton(_oneTimeStart, _pickStartTime, isLoading),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: Sizes.p8),
              child: Text('–'),
            ),
            Expanded(child: _timeButton(_oneTimeEnd, _pickEndTime, isLoading)),
          ],
        ),
        gapH20,

        _Label(loc.quantity),
        gapH8,
        Row(
          children: [
            _CircleBtn(
              icon: Icons.remove,
              onPressed: isLoading || _oneTimeQuantity <= 1
                  ? null
                  : () => setState(() => _oneTimeQuantity--),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '$_oneTimeQuantity',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            _CircleBtn(
              icon: Icons.add,
              onPressed: isLoading || _oneTimeQuantity >= 30
                  ? null
                  : () => setState(() => _oneTimeQuantity++),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      hintText: hint,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(Sizes.p12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(Sizes.p12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(Sizes.p12),
      ),
    );
  }

  Widget _timeButton(TimeOfDay time, VoidCallback onTap, bool isLoading) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(Sizes.p8),
      child: Container(
        padding: const EdgeInsets.all(Sizes.p12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
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
    final picked = await showTimePicker(
      context: context,
      initialTime: _oneTimeStart,
    );
    if (picked != null) setState(() => _oneTimeStart = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _oneTimeEnd,
    );
    if (picked != null) setState(() => _oneTimeEnd = picked);
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null ? AppColors.primary : Colors.grey.shade300,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p12),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
