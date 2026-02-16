// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/info_badge.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/common_widgets/static_map_preview.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/map/application/store_location_controller.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/features/store/presentation/store_form_controller.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class ReviewDetailsContent extends ConsumerStatefulWidget {
  const ReviewDetailsContent({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReviewDetailsState();
}

class _ReviewDetailsState extends ConsumerState<ReviewDetailsContent> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final draft = ref.read(storeDraftControllerProvider);
      if (draft.hasEnoughDataForCoordinates) {
        _fetchCoordinates(draft);
      }
    });
  }

  void _fetchCoordinates(StoreDraft draft) {
    ref
        .read(storeLocationProvider.notifier)
        .getCoordinates(
          address: draft.address!,
          locality: draft.locality!,
          isoCode: draft.country!.isoCode,
          postalCode: draft.postalCode!,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<StoreDraft>(storeDraftControllerProvider, (previous, next) {
      if (!next.hasEnoughDataForCoordinates) return;

      final addressChanged =
          previous?.address != next.address ||
          previous?.locality != next.locality ||
          previous?.postalCode != next.postalCode;

      if (addressChanged) {
        _fetchCoordinates(next);
      }
    });

    ref.listen(
      storeLocationProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final draft = ref.watch(storeDraftControllerProvider);

    final locationValue = ref.watch(storeLocationProvider);

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
          onPressed: () {
            debugPrint(
              'ReviewDetalisContent.onContinue button has been called',
            );
            if (locationValue.value != null) {
              ref
                  .read(storeDraftControllerProvider.notifier)
                  .saveLocation(locationValue.value!);

              widget.onPressed?.call();
            }
          },
        ),
      ],
    );
  }
}
