import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/app.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/data/fake_auth_repository.dart';
import 'package:sarqyt/src/features/offers/data/fake_offer_repository.dart';
import 'package:sarqyt/src/features/offers/data/offers_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepo = FakeAuthRepository();
  final offerRepo = FakeOfferRepository();

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        offerRepositoryProvider.overrideWithValue(offerRepo),
      ],
      child: const MyApp(),
    ),
  );
  // runApp(ProviderScope(child: const MyApp()));
}
