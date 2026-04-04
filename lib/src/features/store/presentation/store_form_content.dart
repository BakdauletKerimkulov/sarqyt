// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/features/store/domain/store_type.dart';

class StoreFormContent extends StatefulWidget {
  const StoreFormContent({
    super.key,
    required this.initialDraft,
    required this.onSubmit,
    required this.submitText,
  });

  final StoreDraft initialDraft;
  final void Function(StoreDraft)? onSubmit;
  final String submitText;

  @override
  State<StatefulWidget> createState() => _StoreFormContentState();
}

class _StoreFormContentState extends State<StoreFormContent> {
  final _node = FocusScopeNode();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _localityController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  StoreDraft get initialDraft => widget.initialDraft;

  @override
  void initState() {
    super.initState();

    _nameController.text = initialDraft.name ?? 'Sarqyt';
    _addressController.text = initialDraft.address ?? 'Проспект Гагарина 124';
    _postalCodeController.text = initialDraft.postalCode ?? '050000';
    _localityController.text = initialDraft.locality ?? 'Алматы';
    _phoneNumberController.text = initialDraft.phoneNumber ?? '+77771112233';
    _selectedStoreType = initialDraft.storeType ?? StoreType.cafe;
    _selectedCountry = initialDraft.country ?? countryList[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _localityController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  bool _submitted = false;

  StoreType? _selectedStoreType;
  CountryD? _selectedCountry;

  String? _requiredFieldError(String value) {
    return value.isEmpty ? 'Please, fill in the required field' : null;
  }

  String? _storeTypeError(StoreType? type) {
    return type == null ? 'Please select a store type' : null;
  }

  String? _countryError(CountryD? country) {
    return country == null ? 'Please select a country' : null;
  }

  String? _phoneError(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), '');
    if (normalized.isEmpty) return 'Phone number can\'t be empty';
    final validPattern = RegExp(r'^(\+7|7)\d{10}$');
    if (!validPattern.hasMatch(normalized)) return 'Enter a valid phone number';
    return null;
  }

  bool submit() {
    setState(() => _submitted = true);
    if (_formKey.currentState!.validate()) {
      final draft = StoreDraft(
        name: _nameController.text,
        storeType: _selectedStoreType,
        address: _addressController.text,
        locality: _localityController.text,
        postalCode: _postalCodeController.text,
        country: _selectedCountry,
        phoneNumber: _phoneNumberController.text,
      );
      widget.onSubmit!(draft);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _node,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Business details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            gapH8,
            const Text('Business name'),
            gapH8,
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                helperText: ' ',
                border: OutlineInputBorder(),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
                  !_submitted ? null : _requiredFieldError(value ?? ''),
            ),
            gapH8,
            const Text('Store type'),
            gapH8,
            DropdownButtonFormField<StoreType>(
              initialValue: _selectedStoreType,
              decoration: const InputDecoration(
                helperText: ' ',
                border: OutlineInputBorder(),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              items: StoreType.values.map((type) {
                return DropdownMenuItem<StoreType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, size: 20),
                      gapW12,
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (type) => _selectedStoreType = type,
              validator: (value) => !_submitted ? null : _storeTypeError(value),
            ),
            gapH16,
            const Text(
              'Business address',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            gapH8,
            const Text('Street name and number'),
            gapH8,
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                helperText: ' ',
                border: OutlineInputBorder(),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
                  !_submitted ? null : _requiredFieldError(value ?? ''),
            ),
            gapH8,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Postal code'),
                      gapH8,
                      TextFormField(
                        controller: _postalCodeController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          helperText: '',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => !_submitted
                            ? null
                            : _requiredFieldError(value ?? ''),
                      ),
                    ],
                  ),
                ),
                gapW8,
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('City'),
                      gapH8,
                      TextFormField(
                        controller: _localityController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          helperText: '',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => !_submitted
                            ? null
                            : _requiredFieldError(value ?? ''),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            gapH8,
            const Text('Country'),
            gapH8,
            DropdownButtonFormField<CountryD>(
              items: countryList
                  .map(
                    (c) => DropdownMenuItem<CountryD>(
                      value: c,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(
                helperText: ' ',
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedCountry,
              validator: (value) => !_submitted ? null : _countryError(value),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (country) => _selectedCountry = country,
            ),
            gapH24,
            const Text(
              'Contact details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            gapH8,
            const Text('Phone number'),
            gapH8,
            TextFormField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                helperText: ' ',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+()\-\s]')),
              ],
              validator: (value) =>
                  !_submitted ? null : _phoneError(value ?? ''),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            gapH24,
            PrimaryWebButton(
              text: widget.submitText,
              onPressed: () => submit(),
            ),
          ],
        ),
      ),
    );
  }
}
