import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';
import 'package:sarqyt/src/features/business_console/presentation/business_verify/business_type_ui.dart';
import 'package:sarqyt/src/features/business_console/presentation/business_verify/verify_dialog_controller.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class FirstStep extends ConsumerWidget {
  const FirstStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessType = ref.watch(
      businessDraftControllerProvider.select((draft) => draft.businessType),
    );
    final loc = context.loc;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.whyTaxInfo,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        gapH16,
        Text(
          loc.whyTaxInfoReason1,
        ),
        gapH24,
        Text('What to expect', style: Theme.of(context).textTheme.titleLarge),
        gapH16,
        Text(
          loc.whyTaxInfoReason2,
        ),
        gapH24,
        Text(
          loc.selectBusinessType,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        gapH16,
        Row(
          children: [
            ...BusinessType.values.indexed.expand((entry) {
              final (index, type) = entry;
              final isSelected = type == businessType;

              return [
                Expanded(
                  child: GestureDetector(
                    onTap: () => ref
                        .read(businessDraftControllerProvider.notifier)
                        .selectBusinessType(type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.p12,
                      ),
                      decoration: BoxDecoration(
                        border: BoxBorder.all(
                          width: 1.5,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(Sizes.p16),
                      ),
                      child: Column(
                        children: [
                          gapH16,
                          Icon(type.icon),
                          gapH8,
                          Text(
                            type.title(loc),
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          gapH8,
                          Text(
                            type.description(loc),
                            textAlign: TextAlign.center,
                          ),
                          gapH12,
                          _BusinessTypeRadioIndicator(isSelected: isSelected),
                          gapH16,
                        ],
                      ),
                    ),
                  ),
                ),
                if (index != BusinessType.values.length - 1) gapW12,
              ];
            }),
          ],
        ),
      ],
    );
  }
}

class _BusinessTypeRadioIndicator extends StatelessWidget {
  const _BusinessTypeRadioIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Sizes.p24,
      height: Sizes.p24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey,
          width: isSelected ? 2.5 : 1.5,
        ),
      ),
      child: Center(
        child: Container(
          width: isSelected ? Sizes.p8 : 0,
          height: isSelected ? Sizes.p8 : 0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
