import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/store_draft_controller.dart';
import 'package:sarqyt/src/features/onboarding/presentation/onboarding_panel.dart';
import 'package:sarqyt/src/features/store/presentation/store_form_content.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      startBackground: 'assets/food-app-business-background.jpg',
      child: Consumer(
        builder: (context, ref, child) {
          return OnboardingPanel(
            topSpacerHeight: 100,
            bottomSpacerHeight: 100,
            onBackPressed: () {
              final user = ref.read(authRepositoryProvider).currentUser;
              if (user != null) {
                ref.read(authRepositoryProvider).signOut();
              }
              context.goNamed(BusinessRoute.login.name);
            },
            title: 'Add your business details'.hardcoded,
            subtitle: 'Please provide your business details below.'.hardcoded,
            child: CreateAccountContent(),
          );
        },
      ),
    );
  }
}

class CreateAccountContent extends ConsumerWidget {
  const CreateAccountContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // read вместо watch — не перестраиваем виджет при изменении draft
    final initialDraft = ref.read(storeDraftControllerProvider);
    return StoreFormContent(
      initialDraft: initialDraft,
      onSubmit: (data) {
        ref
            .read(storeDraftControllerProvider.notifier)
            .saveStepOne(
              name: data.name!,
              storeType: data.storeType!,
              address: data.address!,
              postalCode: data.postalCode!,
              locality: data.locality!,
              country: data.country!,
              phoneNumber: data.phoneNumber!,
            );
        final updatedDraft = ref.read(storeDraftControllerProvider);
        if (updatedDraft.canGoToStep2) {
          context.pushNamed(BusinessRoute.reviewDetails.name);
        } else {
        }
      },
      submitText: 'Continue',
    );
  }
}
