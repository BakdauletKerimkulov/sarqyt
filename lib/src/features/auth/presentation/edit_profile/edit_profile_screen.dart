import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/data/user_profile_repository.dart';
import 'package:sarqyt/src/features/auth/presentation/edit_profile/edit_profile_controller.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) return const SizedBox.shrink();

    final profileAsync = ref.watch(userProfileStreamProvider(user.uid));
    final state = ref.watch(editProfileControllerProvider);

    ref.listen(editProfileControllerProvider, (_, s) {
      s.showAlertDialogOnError(context);
    });

    // Init controllers once from profile data
    if (!_initialized) {
      profileAsync.whenData((data) {
        if (data != null && !_initialized) {
          _nameController.text = (data['displayName'] as String?) ?? '';
          _phoneController.text = (data['phoneNumber'] as String?) ?? '';
          _initialized = true;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit profile'.hardcoded)),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Sizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email (read-only)
              Text('Email'.hardcoded,
                  style: Theme.of(context).textTheme.titleSmall),
              gapH8,
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(Sizes.p12),
                  ),
                  hintText: user.email ?? '',
                ),
              ),
              gapH20,

              // Display name
              Text('Name'.hardcoded,
                  style: Theme.of(context).textTheme.titleSmall),
              gapH8,
              TextField(
                controller: _nameController,
                enabled: !state.isLoading,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: 'Your name'.hardcoded,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(Sizes.p12),
                  ),
                ),
              ),
              gapH20,

              // Phone
              Text('Phone'.hardcoded,
                  style: Theme.of(context).textTheme.titleSmall),
              gapH8,
              TextField(
                controller: _phoneController,
                enabled: !state.isLoading,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: '+7 (777) 123-4567'.hardcoded,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(Sizes.p12),
                  ),
                ),
              ),
              gapH32,

              PrimaryButton(
                text: 'Save'.hardcoded,
                isLoading: state.isLoading,
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final success = await ref
                            .read(editProfileControllerProvider.notifier)
                            .save(
                              displayName: _nameController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                            );
                        if (success && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
