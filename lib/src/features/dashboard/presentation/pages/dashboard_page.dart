import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/responsive_center.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(child: Text('Dashboard'));
  }
}
