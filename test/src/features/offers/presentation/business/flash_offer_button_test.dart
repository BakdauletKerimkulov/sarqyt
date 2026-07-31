import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/offers/presentation/business/create_one_time_offer_dialog.dart';
import 'package:sarqyt/src/features/offers/presentation/business/flash_offer_button.dart';

Widget _buildSubject() {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const Scaffold(body: FlashOfferButton(storeId: 'store-1')),
    ),
  );
}

void main() {
  group('FlashOfferButton', () {
    testWidgets('tapping it opens CreateOneTimeOfferDialog', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FlashOfferButton));
      await tester.pumpAndSettle();

      expect(find.byType(CreateOneTimeOfferDialog), findsOneWidget);
    });
  });
}
