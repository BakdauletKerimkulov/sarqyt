import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/domain/item.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';

/// Dialog to choose between scheduled or one-time item creation.
class CreateItemTypeDialog extends StatelessWidget {
  const CreateItemTypeDialog({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p24),
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create new'.hardcoded,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              gapH8,
              Text(
                'Choose the type of surprise bag'.hardcoded,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
              gapH24,
              _TypeOption(
                icon: Icons.calendar_month,
                title: 'Scheduled'.hardcoded,
                description:
                    'Recurring surprise bag based on weekly schedule. Offers are created automatically every day.'
                        .hardcoded,
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to existing item creation flow
                  context.goNamed(
                    BusinessRoute.item.name,
                    pathParameters: {
                      'storeId': storeId,
                      'itemId': 'new',
                    },
                    queryParameters: {'tab': 'settings', 'type': 'scheduled'},
                  );
                },
              ),
              gapH12,
              _TypeOption(
                icon: Icons.flash_on,
                title: 'One-time'.hardcoded,
                description:
                    'Single surprise bag for a specific date. Perfect for unexpected surplus.'
                        .hardcoded,
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed(
                    BusinessRoute.item.name,
                    pathParameters: {
                      'storeId': storeId,
                      'itemId': 'new',
                    },
                    queryParameters: {'tab': 'settings', 'type': 'oneTime'},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    gapH4,
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
