import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/common_widgets/responsive_card.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/items/presentation/item_create/item_image_picker.dart';
import 'package:sarqyt/src/features/onboarding/presentation/onboarding_panel.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class CreateItemScreen extends ConsumerWidget {
  const CreateItemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthLayout(
      startBackground: 'assets/sarqyt_background_2.png',
      child: OnboardingPanel(
        title: 'Create your first item'.hardcoded,
        subtitle:
            'Add an item to your store so customers can discover it.'.hardcoded,
        child: CreateItemContent(),
      ),
    );
  }
}

class CreateItemContent extends ConsumerWidget {
  const CreateItemContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResponsiveCard(child: ItemImagePicker(id: 'item')),
        gapH16,
        PrimaryWebButton(
          text: 'Continue'.hardcoded,
          onPressed: () =>
              context.pushNamed(BusinessRoute.titleAndDescription.name),
        ),
      ],
    );
  }
}
