import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/responsive_center.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/constants/breakpoints.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/features/store/presentation/create_store_page_controller.dart';
import 'package:sarqyt/src/features/store/presentation/review_details_content.dart';
import 'package:sarqyt/src/features/store/presentation/store_form_content.dart';
import 'package:sarqyt/src/features/store/presentation/store_form_controller.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

enum CreateStoreStep { create, submit }

class CreateStorePage extends ConsumerStatefulWidget {
  const CreateStorePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateStorePage2State();
}

class _CreateStorePage2State extends ConsumerState<CreateStorePage> {
  var _currentStep = CreateStoreStep.create;

  @override
  Widget build(BuildContext context) {
    ref.listen(
      createStoreControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    ref.watch(storeDraftControllerProvider);

    return switch (_currentStep) {
      CreateStoreStep.create => SingleChildScrollView(
        child: ResponsiveCenter(
          maxContentWidth: Breakpoint.tablet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back),
              ),
              gapH16,
              StoreFormContent(
                initialDraft: StoreDraft(),
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

                  setState(() => _currentStep = CreateStoreStep.submit);
                },
                submitText: 'Continue',
              ),
              const SizedBox(height: 150.0),
            ],
          ),
        ),
      ),

      CreateStoreStep.submit => ResponsiveCenter(
        maxContentWidth: Breakpoint.tablet,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () =>
                  setState(() => _currentStep = CreateStoreStep.create),
              icon: Icon(Icons.arrow_back),
            ),
            gapH16,
            ReviewDetailsContent(
              onPressed: () {
                final storeDraft = ref.read(storeDraftControllerProvider);
                debugPrint(storeDraft.toString());
                ref
                    .read(createStoreControllerProvider.notifier)
                    .create(storeDraft);
              },
            ),
          ],
        ),
      ),
    };
  }
}
