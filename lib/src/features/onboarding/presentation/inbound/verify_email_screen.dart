import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/exceptions/app_exception.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/verify_email_controller.dart';
import 'package:sarqyt/src/features/onboarding/presentation/onboarding_panel.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      startBackground: 'assets/food-app-business-background.jpg',
      child: OnboardingPanel(
        title: context.loc.checkYourInbox,
        onBackPressed: () => ProviderScope.containerOf(
          context,
        ).read(authRepositoryProvider).signOut(),
        child: const _VerifyEmailContent(),
      ),
    );
  }
}

class _VerifyEmailContent extends ConsumerStatefulWidget {
  const _VerifyEmailContent();

  @override
  ConsumerState<_VerifyEmailContent> createState() =>
      _VerifyEmailContentState();
}

class _VerifyEmailContentState extends ConsumerState<_VerifyEmailContent>
    with WidgetsBindingObserver {
  static const _pollInterval = Duration(seconds: 3);

  Timer? _reloadTimer;

  @override
  void initState() {
    super.initState();
    _sendVerification();
    WidgetsBinding.instance.addObserver(this);
    _startReloadTimer();
  }

  @override
  void dispose() {
    _stopReloadTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(verifyEmailControllerProvider.notifier).checkAndComplete();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _sendVerification() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null || user.emailVerified) return;
    try {
      await user.sendEmailVerification();
      dev.log('Verification email sent to ${user.email}');
    } catch (e) {
      dev.log('sendEmailVerification failed: $e');
    }
  }

  void _startReloadTimer() {
    if (_reloadTimer != null) return;
    _reloadTimer = Timer.periodic(_pollInterval, (_) {
      if (!mounted) return;
      ref.read(verifyEmailControllerProvider.notifier).checkAndComplete();
    });
  }

  void _stopReloadTimer() {
    _reloadTimer?.cancel();
    _reloadTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyEmailControllerProvider);

    ref.listen(verifyEmailControllerProvider, (_, next) {
      // Don't show the generic error dialog for DraftNotFoundException —
      // the recovery UI handles it inline.
      if (next.hasError && next.error is! DraftNotFoundException) {
        next.showAlertDialogOnError(context);
      }
    });

    // Draft-not-found: show recovery state instead of polling UI.
    if (state.error is DraftNotFoundException) {
      _stopReloadTimer();
      return _DraftNotFoundRecovery();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.loc.verifyEmailMessage),
        gapH24,
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          if (state.hasError)
            TextButton(
              onPressed: () => ref
                  .read(verifyEmailControllerProvider.notifier)
                  .checkAndComplete(),
              child: Text(context.loc.retry),
            ),
          TextButton(
            onPressed: _sendVerification,
            child: Text(context.loc.resendVerificationEmail),
          ),
        ],
      ],
    );
  }
}

/// Shown when the store draft has expired or was never created.
/// Guides the user back to create-account to re-enter store details.
class _DraftNotFoundRecovery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.loc.draftExpiredTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        gapH12,
        Text(context.loc.draftExpiredMessage),
        gapH24,
        PrimaryWebButton(
          text: context.loc.fillDetailsAgain,
          onPressed: () => context.goNamed(BusinessRoute.createAccount.name),
        ),
      ],
    );
  }
}
