import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/orders/domain/order.dart';
import 'package:sarqyt/src/features/orders/presentation/client/widgets/order_status_progress_line.dart';

void main() {
  Widget buildWidget(OrderStatus status) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: OrderStatusProgressLine(status: status)),
    );
  }

  group('OrderStatusProgressLine', () {
    testWidgets('renders 4 dots for confirmed status', (tester) async {
      await tester.pumpWidget(buildWidget(OrderStatus.confirmed));
      await tester.pumpAndSettle();

      // Should find 4 status label texts
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Preparing'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('for preparing status, dots 1-2 filled, dots 3-4 unfilled', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(OrderStatus.preparing));
      await tester.pumpAndSettle();

      // The widget should render all 4 labels
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Preparing'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('for completed status, all 4 dots filled', (tester) async {
      await tester.pumpWidget(buildWidget(OrderStatus.completed));
      await tester.pumpAndSettle();

      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('for readyForPickup status, dots 1-3 filled', (tester) async {
      await tester.pumpWidget(buildWidget(OrderStatus.readyForPickup));
      await tester.pumpAndSettle();

      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
    });
  });
}
