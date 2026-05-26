import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class HelpCentreScreen extends StatelessWidget {
  const HelpCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Sizes.p32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.helpCentre,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          gapH8,
          Text(
            'Here you can find answers to most of the questions you might have about how to use Sarqyt. Select a topic below to find the answer to your question.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          gapH24,

          // Welcome banner
          _BannerCard(
            icon: Icons.play_circle_outline,
            text:
                'Welcome to Sarqyt! Make sure to watch our tutorial video to learn how to use our app.',
            onTap: () => showNotImplementedAlertDialog(context: context),
          ),
          gapH24,

          // Topic cards grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 600 ? 3 : 2;
              return Wrap(
                spacing: Sizes.p16,
                runSpacing: Sizes.p16,
                children: [
                  _TopicCard(
                    width: (constraints.maxWidth - Sizes.p16 * (crossCount - 1)) / crossCount,
                    icon: Icons.store_outlined,
                    title: loc.dailyOperations,
                    description:
                        'Get help with your daily operations including managing supply, collection time and customer payments.',
                    onTap: () =>
                        showNotImplementedAlertDialog(context: context),
                  ),
                  _TopicCard(
                    width: (constraints.maxWidth - Sizes.p16 * (crossCount - 1)) / crossCount,
                    icon: Icons.account_balance_wallet_outlined,
                    title: loc.financials,
                    description: loc.payoutsAndInvoices,
                    onTap: () =>
                        showNotImplementedAlertDialog(context: context),
                  ),
                  _TopicCard(
                    width: (constraints.maxWidth - Sizes.p16 * (crossCount - 1)) / crossCount,
                    icon: Icons.share_outlined,
                    title: loc.sharing,
                    description: loc.spreadTheWord,
                    onTap: () =>
                        showNotImplementedAlertDialog(context: context),
                  ),
                  _TopicCard(
                    width: (constraints.maxWidth - Sizes.p16 * (crossCount - 1)) / crossCount,
                    icon: Icons.help_outline,
                    title: loc.commonQuestions,
                    description:
                        'Answers to general questions and other useful information.',
                    onTap: () =>
                        showNotImplementedAlertDialog(context: context),
                  ),
                ],
              );
            },
          ),
          gapH48,

          // Contact us
          Center(
            child: Column(
              children: [
                Text(
                  loc.needFurtherHelp,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                gapH12,
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sizes.p24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.p32,
                      vertical: Sizes.p12,
                    ),
                  ),
                  onPressed: () =>
                      showNotImplementedAlertDialog(context: context),
                  child: Text(loc.contactUs),
                ),
              ],
            ),
          ),
          gapH48,
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Sizes.p12),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 32),
              gapW16,
              Expanded(
                child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Sizes.p12),
          child: Padding(
            padding: const EdgeInsets.all(Sizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.primary, size: 28),
                gapH12,
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                gapH8,
                Text(
                  description,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
