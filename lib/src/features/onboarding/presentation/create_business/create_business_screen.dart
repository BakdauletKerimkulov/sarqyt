import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/onboarding/data/onboarding_repository.dart';
import 'package:sarqyt/src/features/onboarding/presentation/onboarding_panel.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class CreateBusinessScreen extends ConsumerWidget {
  const CreateBusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthLayout(
      child: OnboardingPanel(
        onSkip: () => _skipOnboarding(context, ref),
        title: 'Register your business'.hardcoded,
        child: const CreateBusinessContent(),
      ),
    );
  }
}

Future<void> _skipOnboarding(BuildContext context, WidgetRef ref) async {
  final ships = ref.read(currentPartnerStoreShipsProvider).value ?? [];
  final storeId = ships.pendingOnboarding?.storeId;
  if (storeId == null) return;

  ref.read(onboardingRepositoryProvider).skipOptionalOnboarding(storeId);
  ref.invalidate(currentPartnerStoreShipsProvider);
}

class CreateBusinessContent extends ConsumerWidget {
  const CreateBusinessContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Register your business'.hardcoded,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        gapH8,
        Text(
          'Add your business details. You can skip this and do it later in settings.'
              .hardcoded,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        gapH32,
        TextButton(
          onPressed: () async {
            final isSkipped = await showAlertDialog(
              context: context,
              title: 'Are you sure you want to skip setting up your business?'
                  .hardcoded,
              cancelActionText: 'Cancel'.hardcoded,
            );

            if (isSkipped == true && context.mounted) {
              _skipOnboarding(context, ref);
            }
          },
          child: Text('Skip for now'.hardcoded),
        ),
        gapH24,
      ],
    );
  }
}
