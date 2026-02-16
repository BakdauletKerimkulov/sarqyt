import 'package:sarqyt/src/features/auth/presentation/sign_in_business/registration/register_business_controller.dart';

class StepHeader {
  final String title;
  final String? subtitle;

  const StepHeader({required this.title, this.subtitle});

  const StepHeader.empty() : title = '', subtitle = null;
}

extension RegisterStepHeader on RegisterStep {
  StepHeader get header {
    switch (this) {
      case RegisterStep.createAccount:
        return const StepHeader(
          title: 'Add your business details',
          subtitle: 'Please, provide your business details below',
        );
      case RegisterStep.reviewDetails:
        return const StepHeader(
          title: 'Review your details',
          subtitle: 'Make sure everything is correct',
        );
      case RegisterStep.createEmail:
        return const StepHeader(title: 'Create email');
    }
  }
}
