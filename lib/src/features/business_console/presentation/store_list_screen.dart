import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/onboarding/presentation/onboarding_panel.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class StoreListScreen extends ConsumerWidget {
  const StoreListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipsValue = ref.watch(currentPartnerStoreShipsProvider);

    return AuthLayout(
      child: OnboardingPanel(
        title: 'Choose a store'.hardcoded,
        child: AsyncValueWidget(
          value: shipsValue,
          data: (ships) {
            final completed = ships
                .where((s) => s.onboardingStatus == OnboardingStatus.completed)
                .toList();

            if (completed.isEmpty) {
              return Text(
                'No stores found'.hardcoded,
                style: Theme.of(context).textTheme.titleLarge,
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: completed.length,
              itemBuilder: (context, index) {
                final store = completed[index];
                return ListTile(
                  leading: store.logoUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(store.logoUrl!),
                        )
                      : const CircleAvatar(child: Icon(Icons.store)),
                  title: Text(store.name),
                  subtitle: Text(store.storeRole.name),
                  onTap: () =>
                      context.go('/stores/${store.storeId}/dashboard'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
