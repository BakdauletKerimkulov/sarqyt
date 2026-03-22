import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_ship.freezed.dart';
part 'store_ship.g.dart';

enum StoreRole { owner, operator, employer }

enum OnboardingStatus { storeCreated, itemCreated, completed }

@freezed
abstract class StoreShip with _$StoreShip {
  const factory StoreShip({
    required String storeId,
    required String businessId,
    required String userId,
    required List<String> permissions,
    required String name,
    required StoreRole storeRole,
    String? logoUrl,
    @Default(OnboardingStatus.storeCreated) OnboardingStatus onboardingStatus,
  }) = _StoreShip;

  factory StoreShip.fromJson(Map<String, dynamic> json) =>
      _$StoreShipFromJson(json);
}

extension StoreShipListX on List<StoreShip> {
  StoreShip? get pendingOnboarding => where(
    (s) => s.onboardingStatus != OnboardingStatus.completed,
  ).firstOrNull;

  String? get defaultStoreId => where(
    (s) => s.onboardingStatus == OnboardingStatus.completed,
  ).firstOrNull?.storeId;

  bool get hasActiveStores =>
      any((s) => s.onboardingStatus == OnboardingStatus.completed);
}
