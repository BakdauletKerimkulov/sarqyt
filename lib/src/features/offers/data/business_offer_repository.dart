import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'business_offer_repository.g.dart';

class BusinessOfferRepository {
  const BusinessOfferRepository(this._functions);
  final FirebaseFunctions _functions;

  Future<void> createOffer(Map<String, dynamic> data) async {
    final callable = _functions.httpsCallable("createOffer");

    final result = await callable.call(data);
    log(result.data.toString());
  }
}

@riverpod
BusinessOfferRepository businessOfferRepository(Ref ref) {
  return BusinessOfferRepository(FirebaseFunctions.instance);
}
