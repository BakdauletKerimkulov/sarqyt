import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/responsive_center.dart';
import 'package:sarqyt/src/constants/breakpoints.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveCenter(
        maxContentWidth: Breakpoint.tablet,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Вы не являетесь партнером или администратором, поэтому у вас нет доступа к этому приложению.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) => ElevatedButton(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                child: const Text('Вернуться в MyStore'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
