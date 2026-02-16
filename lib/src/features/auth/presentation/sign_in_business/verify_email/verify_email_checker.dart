// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// * Когда пользователь зарегистриван, но почта не подтверждена,
/// * навигация перекидывает на этот экран. Экран следит за своим
/// * состоянием, когда она была свернута и снова открыта, таким
/// * образом, не надо нигде держать слушателя, ведь если почта не подтверждена,
/// * то пользователь всегда будет на этом экране

class VerifyEmailChecker extends ConsumerStatefulWidget {
  const VerifyEmailChecker({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VerifyEmailCheckerState();
}

class _VerifyEmailCheckerState extends ConsumerState<VerifyEmailChecker>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null && !user.emailVerified) {
      user.sendEmailVerification();
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        user.reload();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authRepositoryProvider).currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Check your Inbox'.hardcoded,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        gapH16,
        Text(
          'Click on the link we\'ve sent to ${user?.email} to confirm it\'s really you. If you can\'t see the email, check the Spam folder as well.'
              .hardcoded,
        ),
        // gapH24,
        // PrimaryWebButton(
        //   text: 'Confirmed'.hardcoded,
        //   onPressed: state.isLoading
        //       ? null
        //       : () => ref
        //             .read(verifyEmailControllerProvider.notifier)
        //             .checkEmailVerified(),
        // ),
        // gapH16,
        // PrimaryWebButton(
        //   text: 'Send verification again'.hardcoded,
        //   onPressed: state.isLoading
        //       ? null
        //       : () => ref
        //             .read(verifyEmailControllerProvider.notifier)
        //             .resendVerificationEmail(),
        // ),
        // gapH16,
        // PrimaryWebButton(
        //   text: 'Return to Log in'.hardcoded,
        //   onPressed: state.isLoading
        //       ? null
        //       : () {
        //           ref.read(authRepositoryProvider).signOut();
        //         },
        // ),
      ],
    );
  }
}
