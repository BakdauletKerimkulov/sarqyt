import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/exceptions/error_logger.dart';
import 'package:sarqyt/src/features/store/data/store_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/features/store/presentation/store_form_content.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/store_startup.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class AddStoreScreen extends ConsumerWidget {
  const AddStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Add store'.hardcoded)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Sizes.p24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _AddStoreForm(),
          ),
        ),
      ),
    );
  }
}

class _AddStoreForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddStoreForm> createState() => _AddStoreFormState();
}

class _AddStoreFormState extends ConsumerState<_AddStoreForm> {
  bool _isLoading = false;

  Future<void> _submit(StoreDraft draft) async {
    final business = ref.read(currentBusinessProvider);
    // Read before the await: `ref` throws once the screen is disposed.
    final logger = ref.read(errorLoggerProvider);

    setState(() => _isLoading = true);

    try {
      final storeId = await ref
          .read(storeRepositoryProvider)
          .createAdditionalStore(draft: draft, businessId: business.id);

      if (mounted) {
        context.go('/stores/$storeId/dashboard');
      }
    } catch (e, st) {
      logger.logError(e, st);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(humanReadableError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _isLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          StoreFormContent(
            initialDraft: const StoreDraft(),
            onSubmit: _isLoading ? null : _submit,
            submitText: 'Create store'.hardcoded,
          ),
        ],
      ),
    );
  }
}
