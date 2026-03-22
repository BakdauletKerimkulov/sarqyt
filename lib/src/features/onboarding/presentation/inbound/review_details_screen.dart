// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/info_badge.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/common_widgets/static_map_preview.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/map/application/store_location_controller.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/store_draft_controller.dart';
import 'package:sarqyt/src/features/onboarding/presentation/onboarding_panel.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class ReviewDetailsScreen extends StatelessWidget {
  const ReviewDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      startBackground: 'assets/food-app-business-background.jpg',
      child: OnboardingPanel(
        onBackPressed: () => context.pop(),
        title: 'Review your store details'.hardcoded,
        child: ReviewDetailsContent(),
      ),
    );
  }
}

class ReviewDetailsContent extends ConsumerStatefulWidget {
  const ReviewDetailsContent({super.key});

  @override
  ConsumerState<ReviewDetailsContent> createState() =>
      _ReviewDetailsContentState();
}

class _ReviewDetailsContentState extends ConsumerState<ReviewDetailsContent> {
  @override
  void initState() {
    super.initState();
    // Trigger geocoding after the first frame so ref is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geocodeIfNeeded();
    });
  }

  void _geocodeIfNeeded() {
    final draft = ref.read(storeDraftControllerProvider);
    if (draft.location != null) return; // already have coordinates
    if (!draft.hasEnoughDataForCoordinates) return;

    ref.read(storeLocationProvider.notifier).getCoordinates(
      address: draft.address!,
      locality: draft.locality!,
      isoCode: draft.country!.isoCode,
      postalCode: draft.postalCode!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(storeDraftControllerProvider);
    final locationValue = ref.watch(storeLocationProvider);

    ref.listen(
      storeLocationProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 4.0,
          child: Padding(
            padding: EdgeInsets.all(Sizes.p8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 200.0,
                      child: AsyncValueWidget(
                        value: locationValue,
                        data: (location) {
                          return StaticMapPreview(location: location);
                        },
                      ),
                    ),
                    Positioned(
                      top: Sizes.p8,
                      right: Sizes.p8,
                      child: PrimaryWebButton(
                        text: 'Edit'.hardcoded,
                        onPressed: () =>
                            showNotImplementedAlertDialog(context: context),
                      ),
                    ),
                  ],
                ),
                gapH16,
                Row(
                  children: [
                    Text(
                      draft.name ?? '',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    InfoBadge(
                      backgroundColor: Colors.grey.withAlpha(50),
                      text: draft.storeType?.label ?? '',
                    ),
                  ],
                ),
                gapH16,
                Text(draft.fullAdrres),
                gapH8,
                Text(draft.phoneNumber ?? ''),
              ],
            ),
          ),
        ),
        gapH24,
        PrimaryWebButton(
          text: 'Continue'.hardcoded,
          isLoading: locationValue.isLoading,
          onPressed: () {
            final location = locationValue.value;
            if (location == null) return;

            ref
                .read(storeDraftControllerProvider.notifier)
                .saveLocation(location);

            final updatedDraft = ref.read(storeDraftControllerProvider);
            if (updatedDraft.canGoToStep3) {
              context.pushNamed(BusinessRoute.email.name);
            }
          },
        ),
      ],
    );
  }
}
