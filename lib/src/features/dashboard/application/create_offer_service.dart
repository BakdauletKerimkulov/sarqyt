import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/dashboard/domain/offer_form.dart';
import 'package:sarqyt/src/features/offers/data/business_offer_repository.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'create_offer_service.g.dart';

class CreateOfferService {
  const CreateOfferService(this.offerRepository);
  final BusinessOfferRepository offerRepository;

  Future<void> createOffer(OfferForm offer, {required StoreID storeId}) {
    final pickupStart = DateTime(
      offer.selectedDay!.year,
      offer.selectedDay!.month,
      offer.selectedDay!.day,
      offer.startPickupTime!.hour,
      offer.startPickupTime!.minute,
    );

    final pickupEnd = DateTime(
      offer.selectedDay!.year,
      offer.selectedDay!.month,
      offer.selectedDay!.day,
      offer.endPickupTime!.hour,
      offer.endPickupTime!.minute,
    );

    final data = {
      'storeId': storeId,
      'productId': offer.productId,
      'quantity': offer.quantity,
      'pickupStart': pickupStart.toUtc().toIso8601String(),
      'pickupEnd': pickupEnd.toUtc().toIso8601String(),
    };

    return offerRepository.createOffer(data);
  }
}

@riverpod
CreateOfferService createOfferService(Ref ref) {
  return CreateOfferService(ref.read(businessOfferRepositoryProvider));
}
