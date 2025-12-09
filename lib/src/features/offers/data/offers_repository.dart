import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/offers/domain/offer.dart';

part 'offers_repository.g.dart';

abstract class OffersRepository {
  Offer? getOffer(OfferID id);

  Future<List<Offer>> fetchOffersList();

  Stream<List<Offer>> watchOffersList();

  Future<Offer?> fetchOffer(OfferID id);

  Stream<Offer?> watchOffer(OfferID id);
}

@Riverpod(keepAlive: true)
OffersRepository offerRepository(Ref ref) => throw UnimplementedError();

@riverpod
Stream<List<Offer>> offerListStream(Ref ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.watchOffersList();
}

@riverpod
FutureOr<List<Offer>> offerListFuture(Ref ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.fetchOffersList();
}

@riverpod
Stream<Offer?> offerStream(Ref ref, String id) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.watchOffer(id);
}

@riverpod
FutureOr<Offer?> offerFuture(Ref ref, String id) {
  final repo = ref.watch(offerRepositoryProvider);
  return repo.fetchOffer(id);
}
