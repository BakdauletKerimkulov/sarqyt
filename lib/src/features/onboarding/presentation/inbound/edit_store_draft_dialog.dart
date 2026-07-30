import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/store_draft_controller.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/features/store/presentation/store_form_content.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class EditStoreDraftDialog extends ConsumerStatefulWidget {
  const EditStoreDraftDialog({super.key, required this.initialDraft});

  final StoreDraft initialDraft;

  @override
  ConsumerState<EditStoreDraftDialog> createState() =>
      _EditStoreDraftDialogState();
}

class _EditStoreDraftDialogState extends ConsumerState<EditStoreDraftDialog> {
  final _formKey = GlobalKey<StoreFormContentState>();

  void _save() {
    final submitted = _formKey.currentState!.submit();
    if (!submitted) return;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit store details'.hardcoded),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: StoreFormContent(
            key: _formKey,
            initialDraft: widget.initialDraft,
            showSubmitButton: false,
            onSubmit: (draft) {
              ref
                  .read(storeDraftControllerProvider.notifier)
                  .saveStepOne(
                    name: draft.name!,
                    storeType: draft.storeType!,
                    address: draft.address!,
                    postalCode: draft.postalCode!,
                    locality: draft.locality!,
                    country: draft.country!,
                    phoneNumber: draft.phoneNumber!,
                  );
              Navigator.of(context).pop(true);
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'.hardcoded),
        ),
        FilledButton(onPressed: _save, child: Text('Save'.hardcoded)),
      ],
    );
  }
}
