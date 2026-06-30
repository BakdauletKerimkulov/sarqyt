import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_ship.freezed.dart';
part 'store_ship.g.dart';

enum StoreRole { owner, operator, employer }

@freezed
abstract class StoreShip with _$StoreShip {
  const factory StoreShip({
    required String storeId,
    required String businessId,
    required String userId,
    required List<String> permissions,
    required String name,
    // ignore: invalid_annotation_target
    @JsonKey(readValue: _readRole) required StoreRole role,
    String? logoUrl,

    /// Set to true after the partner taps "Continue" on the welcome screen.
    /// Used by the redirect to decide whether to show the welcome flow.
    @Default(false) bool welcomeCompleted,

    /// Set to true after the partner has created at least one item.
    /// Updated optimistically by the client; eventually consistent.
    @Default(false) bool hasFirstItem,
  }) = _StoreShip;

  factory StoreShip.fromJson(Map<String, dynamic> json) =>
      _$StoreShipFromJson(json);
}

/// Reads `role` from new docs, falling back to `storeRole` for old docs.
Object? _readRole(Map map, String key) {
  return map['role'] ?? map['storeRole'];
}

extension StoreShipListX on List<StoreShip> {
  /// First owner storeShip whose welcome flow hasn't been completed yet, or null.
  /// Non-owner roles (employee, operator) skip the welcome flow entirely.
  StoreShip? get pendingWelcome =>
      where((s) => s.role == StoreRole.owner && !s.welcomeCompleted).firstOrNull;

  /// Default storeId to navigate to (first welcome-completed store).
  String? get defaultStoreId =>
      where((s) => s.welcomeCompleted).firstOrNull?.storeId;

  bool get hasActiveStores => any((s) => s.welcomeCompleted);
}
