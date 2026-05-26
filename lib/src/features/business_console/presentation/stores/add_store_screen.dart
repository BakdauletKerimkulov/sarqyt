import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/features/store/presentation/store_form_content.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/store_startup.dart';

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

    setState(() => _isLoading = true);

    try {
      final location = draft.location;
      final geohash = location != null
          ? GeoFirePoint(GeoPoint(location.latitude, location.longitude))
                .geohash
          : '';

      final callable =
          FirebaseFunctions.instance.httpsCallable('createAdditionalStore');
      final result = await callable.call<dynamic>({
        'name': draft.name,
        'storeType': draft.storeType?.name ?? '',
        'address': {
          'country': {
            'name': draft.country?.name ?? '',
            'isoCode': draft.country?.isoCode ?? '',
          },
          'address': draft.address ?? '',
          'locality': draft.locality ?? '',
          'postalCode': draft.postalCode ?? '',
        },
        'geo': {
          'geohash': geohash,
          'geopoint': {
            'latitude': location?.latitude ?? 0,
            'longitude': location?.longitude ?? 0,
          },
        },
        'phoneNumber': draft.phoneNumber ?? '',
        'businessId': business.id,
      });

      if (mounted) {
        final storeId = result.data['storeId'] as String;
        context.go('/stores/$storeId/dashboard');
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Failed to create store'.hardcoded)),
        );
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
