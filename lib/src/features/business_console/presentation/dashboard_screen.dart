import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/outlined_section_widget.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';
import 'package:sarqyt/src/features/business_console/presentation/business_verify/verify_dialog.dart';
import 'package:sarqyt/src/features/items/presentation/items_list/create_item_dialog.dart';
import 'package:sarqyt/src/features/items/presentation/items_list/sliver_items_grid.dart';
import 'package:sarqyt/src/features/orders/data/orders_repository.dart';
import 'package:sarqyt/src/features/orders/presentation/business/business_orders_screen.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';
import 'package:sarqyt/src/routing/store_startup.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeShip = ref.watch(currentStoreShipProvider);
    final businessAsync = ref.watch(currentBusinessStreamProvider);
    final Business business =
        businessAsync.value ?? ref.read(currentBusinessProvider);
    final storeId = storeShip.storeId;

    final lineColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.p32,
            vertical: Sizes.p16,
          ),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Hi, ${storeShip.name}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        if (!business.isConfirmed)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.p32),
            sliver: SliverToBoxAdapter(
              child: _VerificationBanner(
                status: business.verificationStatus,
                lineColor: lineColor,
              ),
            ),
          ),

        if (!business.isConfirmed)
          const SliverToBoxAdapter(child: gapH24),

        // Reservations section
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.p32),
          sliver: OutlinedSectionSliverWidgetWithHeader(
            header: 'Reservations',
            sliver: SliverBusinessOrders(storeId: storeId),
          ),
        ),

        const SliverToBoxAdapter(child: gapH16),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.p32),
          sliver: OutlinedSectionSliverWidgetWithHeader(
            header: 'Your surprise bags',
            trailing: TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text('Create new'.hardcoded),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => CreateItemTypeDialog(storeId: storeId),
              ),
            ),
            sliver: SliverItemsGrid(storeId: storeId),
          ),
        ),
      ],
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  const _VerificationBanner({
    required this.status,
    required this.lineColor,
  });

  final VerificationStatus status;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final (message, color, buttonText) = switch (status) {
      VerificationStatus.unverified => (
          'Submit your tax information to prevent payout delays',
          Colors.red,
          'Submit',
        ),
      VerificationStatus.submitted => (
          'Verification in progress. This may take up to 30 seconds...',
          Colors.orange,
          null,
        ),
      VerificationStatus.rejected => (
          'Your verification was rejected. Please resubmit.',
          Colors.red,
          'Resubmit',
        ),
      VerificationStatus.verified => (
          '',
          Colors.transparent,
          null,
        ),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 320.0,
        decoration: BoxDecoration(
          border: BoxBorder.all(width: 1, color: lineColor),
          borderRadius: BorderRadius.circular(Sizes.p16),
        ),
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          children: [
            Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            if (status == VerificationStatus.submitted) ...[
              gapH12,
              const LinearProgressIndicator(),
            ],
            if (buttonText != null) ...[
              gapH16,
              PrimaryWebButton(
                text: buttonText,
                onPressed: () => showVerifyDialog(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
