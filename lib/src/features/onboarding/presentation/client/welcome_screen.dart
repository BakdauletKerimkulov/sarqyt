import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/onboarding/presentation/client/welcome_controller.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/client_router.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _WelcomePage(
      icon: Icons.restaurant,
      title: 'Save food, save money',
      subtitle:
          'Rescue surprise bags from your favorite restaurants and bakeries at a great price.',
    ),
    _WelcomePage(
      icon: Icons.location_on,
      title: 'Discover nearby',
      subtitle:
          'Find stores near you with surplus food ready for pickup today.',
    ),
    _WelcomePage(
      icon: Icons.eco,
      title: 'Make an impact',
      subtitle:
          'Every bag you save helps reduce food waste and protects the planet.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await ref.read(welcomeControllerProvider.notifier).completeOnboarding();
    if (mounted) {
      context.goNamed(ClientRoute.home.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(welcomeControllerProvider);

    ref.listen(welcomeControllerProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });

    return Scaffold(
      appBar: _currentPage < _pages.length - 1
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                TextButton(
                  onPressed: state.isLoading ? null : _complete,
                  child: Text('Skip'.hardcoded),
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: _pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _currentPage
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            gapH32,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.p24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sizes.p16),
                    ),
                  ),
                  onPressed: state.isLoading
                      ? null
                      : _currentPage == _pages.length - 1
                          ? _complete
                          : () => _controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _currentPage == _pages.length - 1
                              ? 'Get started'.hardcoded
                              : 'Next'.hardcoded,
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
            gapH48,
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.p32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: AppColors.primary),
          gapH32,
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          gapH16,
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
