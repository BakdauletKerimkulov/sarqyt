import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/business_console/data/business_repository.dart';
import 'package:sarqyt/src/features/business_console/presentation/business_verify/first_step.dart';
import 'package:sarqyt/src/features/business_console/presentation/business_verify/second_step.dart';
import 'package:sarqyt/src/features/business_console/presentation/business_verify/third_step.dart';
import 'package:sarqyt/src/features/business_console/presentation/business_verify/verify_dialog_controller.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/store_startup.dart';

Future<void> showVerifyDialog(BuildContext context) {
  return showDialog(context: context, builder: (_) => const VerifyDialog());
}

class VerifyDialog extends ConsumerStatefulWidget {
  const VerifyDialog({super.key});

  @override
  ConsumerState<VerifyDialog> createState() => _VerifyDialogState();
}

class _VerifyDialogState extends ConsumerState<VerifyDialog> {
  final _pageController = PageController();
  final _secondStepController = SecondStepController();

  int _currentStep = 0;
  bool _isSubmitting = false;

  static const _maxStep = 3;

  bool get canGoBack => _currentStep > 0;
  bool get canGoNext => _currentStep < _maxStep - 1;
  bool get isLastStep => _currentStep == _maxStep - 1;

  void _goToStep(int step) {
    if (step < 0 || step >= _maxStep) return;
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentStep == 1) {
      _secondStepController.submit();
      return;
    }
    if (isLastStep) {
      _submit();
      return;
    }
    _goToStep(_currentStep + 1);
  }

  Future<void> _submit() async {
    final draft = ref.read(businessDraftControllerProvider);
    if (!draft.hasCompletedRequiredFields) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields'.hardcoded)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final business = ref.read(currentBusinessProvider);
      final repo = ref.read(businessRepositoryProvider);
      await repo.submitVerification(business.id);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification submitted. Processing may take up to 30 seconds...'.hardcoded,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight = math.max(
      0.0,
      MediaQuery.sizeOf(context).height - (Sizes.p16 * 2),
    );
    final dialogHeight = math.min(availableHeight, 600.0);

    return Dialog(
      insetPadding: const EdgeInsets.all(Sizes.p16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.p16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SizedBox(
          width: double.infinity,
          height: dialogHeight,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(Sizes.p12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Business information required'.hardcoded,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(Sizes.p16),
                        child: FirstStep(),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(Sizes.p16),
                        child: SecondStep(
                          controller: _secondStepController,
                          onNext: () => _goToStep(_currentStep + 1),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(Sizes.p16),
                        child: ThirdStep(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.p16),
                child: _StepIndicator(
                  currentStep: _currentStep,
                  stepCount: _maxStep,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Sizes.p16),
                child: Row(
                  children: [
                    if (canGoBack)
                      OutlinedButton(
                        onPressed: () => _goToStep(_currentStep - 1),
                        child: Text('Back'),
                      ),

                    const Spacer(),

                    if (canGoNext || isLastStep)
                      OutlinedButton(
                        onPressed: _isSubmitting ? null : () => _onNext(),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(isLastStep ? 'Submit' : 'Next'),
                      ),
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

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep, required this.stepCount});

  final int stepCount;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(stepCount, (index) {
          final isFilled = index <= currentStep;
          final isActive = index == currentStep;
          return Expanded(
            child: Container(
              height: isActive ? 6 : 4,
              margin: const EdgeInsets.symmetric(horizontal: Sizes.p4),
              decoration: BoxDecoration(
                color: isFilled ? AppColors.primary : Colors.grey,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }),
      ],
    );
  }
}
