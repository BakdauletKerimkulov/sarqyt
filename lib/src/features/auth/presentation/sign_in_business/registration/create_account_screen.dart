import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/inline_text_link.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_business/registration/create_email.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_business/registration/register_business_controller.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/auth/utils/step_header.dart';
import 'package:sarqyt/src/features/map/application/store_location_controller.dart';
import 'package:sarqyt/src/features/store/presentation/review_details_content.dart';
import 'package:sarqyt/src/features/store/presentation/store_form_content.dart';
import 'package:sarqyt/src/features/store/presentation/store_form_controller.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class CreateAccountScreen extends ConsumerWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(storeLocationProvider);
    ref.watch(storeDraftControllerProvider);

    final step = ref.watch(registrationStepControllerProvider);
    final controller = ref.read(registrationStepControllerProvider.notifier);

    final header = step.header;

    return AuthLayout(
      startBackground: 'assets/food-app-business-background.jpg',
      endBuilder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!step.canGoBack) const SizedBox(height: 100.0),

            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => step.canGoBack
                    ? controller.back()
                    : context.goNamed(BusinessRoute.signIn.name),
              ),
            ),

            Text(
              header.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),

            if (header.subtitle != null) ...[gapH16, Text(header.subtitle!)],
            gapH24,

            currentStep(step, ref),

            gapH16,

            if (!step.canGoBack)
              InlineTextLink(
                text: 'Already have an account? '.hardcoded,
                linkText: 'Log in'.hardcoded,
                onTap: () => context.goNamed(BusinessRoute.signIn.name),
              ),

            if (!step.canGoBack) const SizedBox(height: 100.0),
          ],
        );
      },
    );
  }

  Widget currentStep(RegisterStep step, WidgetRef ref) {
    return switch (step) {
      RegisterStep.createAccount => const CreateStoreStep(),
      RegisterStep.reviewDetails => const ReviewDetailsStep(),
      RegisterStep.createEmail => const CreateEmail(),
    };
  }
}

class CreateStoreStep extends ConsumerWidget {
  const CreateStoreStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialDraft = ref.watch(storeDraftControllerProvider);

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
        ref.read(registrationStepControllerProvider.notifier).next();
      },
      submitText: 'Continue',
    );
  }
}

class ReviewDetailsStep extends ConsumerWidget {
  const ReviewDetailsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReviewDetailsContent(
      onPressed: () =>
          ref.read(registrationStepControllerProvider.notifier).next(),
    );
  }
}
