import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';
import 'package:sarqyt/src/features/business_console/domain/business_verification_draft.dart';
import 'package:sarqyt/src/features/business_console/presentation/business_verify/verify_dialog_controller.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class ThirdStep extends ConsumerWidget {
  const ThirdStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(businessDraftControllerProvider);

    return draft.businessType == BusinessType.company
        ? _CompanyReview(draft: draft.company)
        : _IndividualReview(draft: draft.individual);
  }
}

class _CompanyReview extends StatelessWidget {
  const _CompanyReview({required this.draft});

  final CompanyVerificationDraft draft;

  @override
  Widget build(BuildContext context) {
    final isVatRegistered = _hasValue(draft.vatId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Company'.hardcoded,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        gapH24,
        _ReviewField(
          label: 'Are you vat registered?'.hardcoded,
          value: isVatRegistered ? 'Yes'.hardcoded : 'No'.hardcoded,
        ),
        if (isVatRegistered) ...[
          gapH24,
          _ReviewField(label: 'VAT ID *'.hardcoded, value: draft.vatId),
        ],
        gapH24,
        _ReviewField(label: 'БИН компании'.hardcoded, value: draft.bin),
      ],
    );
  }
}

class _IndividualReview extends StatelessWidget {
  const _IndividualReview({required this.draft});

  final IndividualVerificationDraft draft;

  @override
  Widget build(BuildContext context) {
    final isVatRegistered = _hasValue(draft.vatId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Indiviual'.hardcoded,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        gapH24,
        _ReviewField(
          label: 'Are you vat registered?'.hardcoded,
          value: isVatRegistered ? 'Yes'.hardcoded : 'No'.hardcoded,
        ),
        if (isVatRegistered) ...[
          gapH24,
          _ReviewField(label: 'VAT ID *'.hardcoded, value: draft.vatId),
        ],
        gapH24,
        _ReviewField(
          label: 'Индивидуальный идентификационный номер. *'.hardcoded,
          value: draft.iin,
        ),
        gapH16,
        _ReviewField(
          label: 'Date of birth *'.hardcoded,
          value: draft.dateOfBirth,
        ),
        gapH16,
        _ReviewField(label: 'First name *'.hardcoded, value: draft.firstName),
        gapH16,
        _ReviewField(label: 'Last name *'.hardcoded, value: draft.lastName),
        gapH16,
        Text(
          'Address'.hardcoded,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        gapH16,
        _ReviewField(
          label: 'Address line 1 *'.hardcoded,
          value: draft.addressLine1,
        ),
        gapH16,
        _ReviewField(
          label: 'Address line 2'.hardcoded,
          value: draft.addressLine2,
        ),
        gapH16,
        _ReviewField(label: 'Postal code *'.hardcoded, value: draft.postalCode),
        gapH16,
        _ReviewField(label: 'City *'.hardcoded, value: draft.city),
        gapH16,
        _ReviewField(label: 'Region *'.hardcoded, value: draft.region),
        gapH16,
        _ReviewField(label: 'Country *'.hardcoded, value: draft.country),
      ],
    );
  }
}

class _ReviewField extends StatelessWidget {
  const _ReviewField({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        gapH4,
        Text(
          value?.trim().isNotEmpty == true ? value! : '-',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
