import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';
import 'package:sarqyt/src/features/business_console/domain/business_verification_draft.dart';
import 'package:sarqyt/src/features/business_console/presentation/business_verify/verify_dialog_controller.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class SecondStepController {
  Object? _activeToken;
  VoidCallback? _submit;

  Object bind(VoidCallback submit) {
    final token = Object();
    _activeToken = token;
    _submit = submit;
    return token;
  }

  void unbind(Object token) {
    if (!identical(_activeToken, token)) return;
    _activeToken = null;
    _submit = null;
  }

  void submit() {
    _submit?.call();
  }
}

class SecondStep extends ConsumerWidget {
  const SecondStep({super.key, required this.controller, this.onNext});

  final SecondStepController controller;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(
      businessDraftControllerProvider.select((draft) => draft.businessType),
    );

    return type == BusinessType.company
        ? SecondStepForCompany(controller: controller, onNext: onNext)
        : SecondStepForIndividual(controller: controller, onNext: onNext);
  }
}

class SecondStepForIndividual extends ConsumerStatefulWidget {
  const SecondStepForIndividual({
    super.key,
    required this.controller,
    this.onNext,
  });

  final SecondStepController controller;
  final VoidCallback? onNext;

  @override
  ConsumerState<SecondStepForIndividual> createState() =>
      _SecondStepForIndividualState();
}

class _SecondStepForIndividualState
    extends ConsumerState<SecondStepForIndividual> {
  final _formKey = GlobalKey<FormState>();
  final _iinController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _countryController = TextEditingController();

  final _vatController = TextEditingController();

  bool _isVarRegistered = false;
  bool _submitted = false;
  late final Object _controllerToken;

  @override
  void initState() {
    super.initState();
    _applyDraft(ref.read(businessDraftControllerProvider).individual);
    _controllerToken = widget.controller.bind(_submit);
  }

  String? _requiredValidator(String? value) {
    if (!_submitted) return null;

    if (value == null || value.trim().isEmpty) {
      return 'This field is required'.hardcoded;
    }
    return null;
  }

  void _applyDraft(IndividualVerificationDraft draft) {
    _setControllerText(_vatController, draft.vatId);
    _setControllerText(_iinController, draft.iin);
    _setControllerText(_dateOfBirthController, draft.dateOfBirth);
    _setControllerText(_firstNameController, draft.firstName);
    _setControllerText(_lastNameController, draft.lastName);
    _setControllerText(_addressLine1Controller, draft.addressLine1);
    _setControllerText(_addressLine2Controller, draft.addressLine2);
    _setControllerText(_postalCodeController, draft.postalCode);
    _setControllerText(_cityController, draft.city);
    _setControllerText(_regionController, draft.region);
    _setControllerText(_countryController, draft.country);

    final isVatRegistered = _hasValue(draft.vatId);
    if (_isVarRegistered != isVatRegistered) {
      if (mounted) {
        setState(() => _isVarRegistered = isVatRegistered);
      } else {
        _isVarRegistered = isVatRegistered;
      }
    }
  }

  @override
  void dispose() {
    widget.controller.unbind(_controllerToken);
    _vatController.dispose();
    _iinController.dispose();
    _dateOfBirthController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref
        .read(businessDraftControllerProvider.notifier)
        .saveIndividualDetails(
          vatId: _isVarRegistered ? _vatController.text : null,
          iin: _iinController.text,
          dateOfBirth: _dateOfBirthController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          addressLine1: _addressLine1Controller.text,
          addressLine2: _addressLine2Controller.text,
          postalCode: _postalCodeController.text,
          city: _cityController.text,
          region: _regionController.text,
          country: _countryController.text,
        );
    widget.onNext?.call();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      businessDraftControllerProvider.select((draft) => draft.individual),
      (_, next) => _applyDraft(next),
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Indiviual'.hardcoded,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          gapH24,
          Row(
            children: [
              Text('Are you vat registered?'.hardcoded),
              const Spacer(),
              Switch(
                value: _isVarRegistered,
                onChanged: (value) => setState(() => _isVarRegistered = value),
              ),
            ],
          ),
          if (_isVarRegistered) ...[
            gapH24,
            Text('VAT ID *'.hardcoded),
            gapH4,
            TextFormField(
              controller: _vatController,
              validator: _requiredValidator,
            ),
          ],
          gapH24,
          Text('Индивидуальный идентификационный номер. *'.hardcoded),
          gapH4,
          TextFormField(
            controller: _iinController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: _requiredValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          gapH16,
          Text('Date of birth *'.hardcoded),
          gapH4,
          TextFormField(
            controller: _dateOfBirthController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'DD/MM/YYYY',
            ),
            validator: _requiredValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          gapH16,
          Text('First name *'.hardcoded),
          gapH4,
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: _requiredValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          gapH16,
          Text('Last name *'.hardcoded),
          gapH4,
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: _requiredValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          gapH16,
          Text(
            'Address'.hardcoded,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          gapH16,
          Text('Address line 1 *'.hardcoded),
          gapH4,
          TextFormField(
            controller: _addressLine1Controller,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: _requiredValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          gapH16,
          Text('Address line 2'.hardcoded),
          gapH4,
          TextFormField(
            controller: _addressLine2Controller,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          gapH16,
          Text('Postal code *'.hardcoded),
          gapH4,
          TextFormField(
            controller: _postalCodeController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: _requiredValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          gapH16,
          Text('City *'.hardcoded),
          gapH4,
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: _requiredValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          gapH16,
          Text('Region *'.hardcoded),
          gapH4,
          TextFormField(
            controller: _regionController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: _requiredValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          gapH16,
          Text('Country *'.hardcoded),
          gapH4,
          TextFormField(
            controller: _countryController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: _requiredValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          gapH16,
        ],
      ),
    );
  }
}

class SecondStepForCompany extends ConsumerStatefulWidget {
  const SecondStepForCompany({
    super.key,
    required this.controller,
    this.onNext,
  });

  final SecondStepController controller;
  final VoidCallback? onNext;

  @override
  ConsumerState<SecondStepForCompany> createState() =>
      _SecondStepForCompanyState();
}

class _SecondStepForCompanyState extends ConsumerState<SecondStepForCompany> {
  final _formKey = GlobalKey<FormState>();
  final _binController = TextEditingController();
  final _vatController = TextEditingController();

  bool _isVarRegistered = false;
  bool _submitted = false;
  late final Object _controllerToken;

  @override
  void initState() {
    super.initState();
    _applyDraft(ref.read(businessDraftControllerProvider).company);
    _controllerToken = widget.controller.bind(_submit);
  }

  String? _requiredValidator(String? value) {
    if (!_submitted) return null;

    if (value == null || value.trim().isEmpty) {
      return 'Поле не должно быть пустым';
    }
    return null;
  }

  void _applyDraft(CompanyVerificationDraft draft) {
    _setControllerText(_binController, draft.bin);
    _setControllerText(_vatController, draft.vatId);

    final isVatRegistered = _hasValue(draft.vatId);
    if (_isVarRegistered != isVatRegistered) {
      if (mounted) {
        setState(() => _isVarRegistered = isVatRegistered);
      } else {
        _isVarRegistered = isVatRegistered;
      }
    }
  }

  @override
  void dispose() {
    widget.controller.unbind(_controllerToken);
    _binController.dispose();
    _vatController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref
        .read(businessDraftControllerProvider.notifier)
        .saveCompanyDetails(
          bin: _binController.text,
          vatId: _isVarRegistered ? _vatController.text : null,
        );
    widget.onNext?.call();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      businessDraftControllerProvider.select((draft) => draft.company),
      (_, next) => _applyDraft(next),
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Company'.hardcoded,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          gapH24,
          Row(
            children: [
              Text('Are you vat registered?'.hardcoded),
              const Spacer(),
              Switch(
                value: _isVarRegistered,
                onChanged: (value) => setState(() => _isVarRegistered = value),
              ),
            ],
          ),
          if (_isVarRegistered) ...[
            gapH24,
            Text('VAT ID *'.hardcoded),
            gapH4,
            TextFormField(
              controller: _vatController,
              decoration: InputDecoration(border: OutlineInputBorder()),
              validator: _requiredValidator,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ],
          gapH24,
          Text('БИН компании'.hardcoded),
          gapH4,
          TextFormField(
            controller: _binController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            validator: _requiredValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ],
      ),
    );
  }
}

void _setControllerText(TextEditingController controller, String? value) {
  final nextValue = value ?? '';
  if (controller.text != nextValue) {
    controller.text = nextValue;
  }
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
