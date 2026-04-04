import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/verify_email_controller.dart';
import 'package:sarqyt/src/features/onboarding/presentation/onboarding_panel.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      startBackground: 'assets/food-app-business-background.jpg',
      child: OnboardingPanel(
        title: 'Check your inbox'.hardcoded,
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
    final user = ref.read(authRepositoryProvider).currentUser;

    ref.listen(
      verifyEmailControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Click on the link we\'ve sent to ${user?.email} to confirm it\'s really you. If you can\'t see the email, check the Spam folder as well.'
              .hardcoded,
        ),
        gapH24,
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          if (state.hasError)
            TextButton(
              onPressed: () => ref
                  .read(verifyEmailControllerProvider.notifier)
                  .checkAndComplete(),
              child: Text('Retry'.hardcoded),
            ),
          TextButton(
            onPressed: _sendVerification,
            child: Text('Resend verification email'.hardcoded),
          ),
        ],
      ],
    );
  }
}
