import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/business_console/data/business_repository.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';
import 'package:sarqyt/src/features/business_console/presentation/business_verify/verify_dialog.dart';
import 'package:sarqyt/src/features/items/presentation/item_create/create_item_screen.dart';
import 'package:sarqyt/src/features/onboarding/presentation/onboarding_panel.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// Welcome screen shown to a partner who has just created their store.
/// Two optional CTAs (create item / verify business) and a "Continue" button
/// that marks the welcome flow complete and lets the redirect take over.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipsAsync = ref.watch(currentPartnerStoreShipsProvider);

    return AuthLayout(
      child: OnboardingPanel(
        title: context.loc.welcomeToSarqyt,
        child: AsyncValueWidget(
          value: shipsAsync,
          data: (ships) {
            // Pick the first pending storeShip — or fall back to any first one.
            final ship = ships.pendingWelcome ?? ships.firstOrNull;
            if (ship == null) {
              return Text(context.loc.noStoreFound);
            }
            return _WelcomeContent(storeShip: ship);
          },
        ),
      ),
    );
  }
}

class _WelcomeContent extends ConsumerWidget {
  const _WelcomeContent({required this.storeShip});
  final StoreShip storeShip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessStreamProvider(storeShip.businessId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.loc.letsSetUp(storeShip.name),
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
        gapH24,

        // 1. Create first item
        _TaskCard(
          icon: Icons.shopping_bag_outlined,
          title: context.loc.createYourFirstItem,
          subtitle: context.loc.addSurpriseBagDescription,
          done: storeShip.hasFirstItem,
          doneLabel: context.loc.created,
          ctaLabel: context.loc.createItem,
          onTap: () => _openCreateItem(context, storeShip.storeId),
        ),
        gapH16,

        // 2. Verify business
        AsyncValueWidget<Business?>(
          value: businessAsync,
          data: (business) {
            final status =
                business?.verificationStatus ?? VerificationStatus.unverified;
            final loc = context.loc;
            return _TaskCard(
              icon: Icons.verified_user_outlined,
              title: loc.verifyYourBusiness,
              subtitle: _verifySubtitle(status, loc),
              done: status == VerificationStatus.verified,
              doneLabel: _verifyDoneLabel(status, loc),
              ctaLabel: status == VerificationStatus.rejected
                  ? loc.resubmit
                  : loc.startVerification,
              // Pending review → no action, just info.
              onTap: status == VerificationStatus.submitted
                  ? null
                  : () => showVerifyDialog(context),
            );
          },
        ),
        gapH32,

        // Continue → finishes welcome and lets redirect navigate to dashboard.
        SizedBox(
          height: Sizes.p48,
          child: ElevatedButton(
            onPressed: () => _continue(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Sizes.p12),
              ),
            ),
            child: Text(
              context.loc.continueToDashboard,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  String _verifySubtitle(VerificationStatus status, AppLocalizations loc) {
    return switch (status) {
      VerificationStatus.unverified => loc.submitBusinessForPayouts,
      VerificationStatus.submitted => loc.reviewingDocuments,
      VerificationStatus.verified => loc.businessVerified,
      VerificationStatus.rejected => loc.verificationRejected,
    };
  }

  String _verifyDoneLabel(VerificationStatus status, AppLocalizations loc) {
    return switch (status) {
      VerificationStatus.verified => loc.verified,
      VerificationStatus.submitted => loc.pending,
      _ => '',
    };
  }

  Future<void> _openCreateItem(BuildContext context, String storeId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Sizes.p16)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.sizeOf(ctx).height * 0.95,
        child: CreateItemFormScreen(storeId: storeId),
      ),
    );
  }

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;
    try {
      await ref.read(storeShipRepositoryProvider).markWelcomeCompleted(
            storeId: storeShip.storeId,
            uid: user.uid,
          );
      // Redirect listens to currentPartnerStoreShips and will navigate
      // to /stores once welcomeCompleted == true.
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to continue: $e')),
        );
      }
    }
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.doneLabel,
    required this.ctaLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;
  final String doneLabel;
  final String ctaLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(Sizes.p16),
      child: InkWell(
        onTap: done ? null : onTap,
        borderRadius: BorderRadius.circular(Sizes.p16),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: done
                    ? AppColors.primary
                    : AppColors.primary.withAlpha(30),
                child: Icon(
                  done ? Icons.check : icon,
                  color: done ? Colors.white : AppColors.primary,
                ),
              ),
              gapW16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    gapH4,
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (done && doneLabel.isNotEmpty) ...[
                      gapH8,
                      Text(
                        doneLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else if (onTap != null) ...[
                      gapH8,
                      Text(
                        ctaLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
