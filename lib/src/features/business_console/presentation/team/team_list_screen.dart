import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/business_console/presentation/team/invite_member_dialog.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class TeamListScreen extends ConsumerWidget {
  const TeamListScreen({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipsValue = ref.watch(storeShipsByStoreIdProvider(storeId));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Team'.hardcoded),
        actions: [
          TextButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => InviteMemberDialog(storeId: storeId),
            ),
            icon: const Icon(Icons.person_add),
            label: Text('Invite'.hardcoded),
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: shipsValue,
        data: (ships) {
          if (ships.isEmpty) {
            return Center(
              child: Text(
                'No team members yet'.hardcoded,
                style: textTheme.bodyLarge,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(Sizes.p16),
            itemCount: ships.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final member = ships[index];
              return _TeamMemberTile(member: member);
            },
          );
        },
      ),
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  const _TeamMemberTile({required this.member});

  final StoreShip member;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
        ),
      ),
      title: Text(member.name),
      subtitle: Text(member.role.label),
      trailing: member.permissions.isNotEmpty
          ? Chip(
              label: Text(
                '${member.permissions.length} permissions'.hardcoded,
                style: textTheme.labelSmall,
              ),
            )
          : null,
    );
  }
}

extension _StoreRoleLabelX on StoreRole {
  String get label => switch (this) {
    StoreRole.owner => 'Owner',
    StoreRole.operator => 'Operator',
    StoreRole.employer => 'Employee',
  };
}
