// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/features/dashboard/presentation/pages/dashboard_page_layout.dart';

class OffersPage extends ConsumerWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DashboardPageLayout(
      title: 'Offers',
      subtitle: 'Manage your offers',
      child: SizedBox.shrink(),
    );
  }
}
