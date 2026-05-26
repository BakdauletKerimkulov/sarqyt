// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_ship.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoreShip {

 String get storeId; String get businessId; String get userId; List<String> get permissions; String get name;// ignore: invalid_annotation_target
@JsonKey(readValue: _readRole) StoreRole get role; String? get logoUrl;/// Set to true after the partner taps "Continue" on the welcome screen.
/// Used by the redirect to decide whether to show the welcome flow.
 bool get welcomeCompleted;/// Set to true after the partner has created at least one item.
/// Updated optimistically by the client; eventually consistent.
 bool get hasFirstItem;
/// Create a copy of StoreShip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreShipCopyWith<StoreShip> get copyWith => _$StoreShipCopyWithImpl<StoreShip>(this as StoreShip, _$identity);

  /// Serializes this StoreShip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreShip&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.permissions, permissions)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.welcomeCompleted, welcomeCompleted) || other.welcomeCompleted == welcomeCompleted)&&(identical(other.hasFirstItem, hasFirstItem) || other.hasFirstItem == hasFirstItem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,storeId,businessId,userId,const DeepCollectionEquality().hash(permissions),name,role,logoUrl,welcomeCompleted,hasFirstItem);

@override
String toString() {
  return 'StoreShip(storeId: $storeId, businessId: $businessId, userId: $userId, permissions: $permissions, name: $name, role: $role, logoUrl: $logoUrl, welcomeCompleted: $welcomeCompleted, hasFirstItem: $hasFirstItem)';
}


}

/// @nodoc
abstract mixin class $StoreShipCopyWith<$Res>  {
  factory $StoreShipCopyWith(StoreShip value, $Res Function(StoreShip) _then) = _$StoreShipCopyWithImpl;
@useResult
$Res call({
 String storeId, String businessId, String userId, List<String> permissions, String name,@JsonKey(readValue: _readRole) StoreRole role, String? logoUrl, bool welcomeCompleted, bool hasFirstItem
});




}
/// @nodoc
class _$StoreShipCopyWithImpl<$Res>
    implements $StoreShipCopyWith<$Res> {
  _$StoreShipCopyWithImpl(this._self, this._then);

  final StoreShip _self;
  final $Res Function(StoreShip) _then;

/// Create a copy of StoreShip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? storeId = null,Object? businessId = null,Object? userId = null,Object? permissions = null,Object? name = null,Object? role = null,Object? logoUrl = freezed,Object? welcomeCompleted = null,Object? hasFirstItem = null,}) {
  return _then(_self.copyWith(
storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StoreRole,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,welcomeCompleted: null == welcomeCompleted ? _self.welcomeCompleted : welcomeCompleted // ignore: cast_nullable_to_non_nullable
as bool,hasFirstItem: null == hasFirstItem ? _self.hasFirstItem : hasFirstItem // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreShip].
extension StoreShipPatterns on StoreShip {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreShip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreShip() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreShip value)  $default,){
final _that = this;
switch (_that) {
case _StoreShip():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreShip value)?  $default,){
final _that = this;
switch (_that) {
case _StoreShip() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String storeId,  String businessId,  String userId,  List<String> permissions,  String name, @JsonKey(readValue: _readRole)  StoreRole role,  String? logoUrl,  bool welcomeCompleted,  bool hasFirstItem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreShip() when $default != null:
return $default(_that.storeId,_that.businessId,_that.userId,_that.permissions,_that.name,_that.role,_that.logoUrl,_that.welcomeCompleted,_that.hasFirstItem);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String storeId,  String businessId,  String userId,  List<String> permissions,  String name, @JsonKey(readValue: _readRole)  StoreRole role,  String? logoUrl,  bool welcomeCompleted,  bool hasFirstItem)  $default,) {final _that = this;
switch (_that) {
case _StoreShip():
return $default(_that.storeId,_that.businessId,_that.userId,_that.permissions,_that.name,_that.role,_that.logoUrl,_that.welcomeCompleted,_that.hasFirstItem);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String storeId,  String businessId,  String userId,  List<String> permissions,  String name, @JsonKey(readValue: _readRole)  StoreRole role,  String? logoUrl,  bool welcomeCompleted,  bool hasFirstItem)?  $default,) {final _that = this;
switch (_that) {
case _StoreShip() when $default != null:
return $default(_that.storeId,_that.businessId,_that.userId,_that.permissions,_that.name,_that.role,_that.logoUrl,_that.welcomeCompleted,_that.hasFirstItem);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoreShip implements StoreShip {
  const _StoreShip({required this.storeId, required this.businessId, required this.userId, required final  List<String> permissions, required this.name, @JsonKey(readValue: _readRole) required this.role, this.logoUrl, this.welcomeCompleted = false, this.hasFirstItem = false}): _permissions = permissions;
  factory _StoreShip.fromJson(Map<String, dynamic> json) => _$StoreShipFromJson(json);

@override final  String storeId;
@override final  String businessId;
@override final  String userId;
 final  List<String> _permissions;
@override List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}

@override final  String name;
// ignore: invalid_annotation_target
@override@JsonKey(readValue: _readRole) final  StoreRole role;
@override final  String? logoUrl;
/// Set to true after the partner taps "Continue" on the welcome screen.
/// Used by the redirect to decide whether to show the welcome flow.
@override@JsonKey() final  bool welcomeCompleted;
/// Set to true after the partner has created at least one item.
/// Updated optimistically by the client; eventually consistent.
@override@JsonKey() final  bool hasFirstItem;

/// Create a copy of StoreShip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreShipCopyWith<_StoreShip> get copyWith => __$StoreShipCopyWithImpl<_StoreShip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreShipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreShip&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._permissions, _permissions)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.welcomeCompleted, welcomeCompleted) || other.welcomeCompleted == welcomeCompleted)&&(identical(other.hasFirstItem, hasFirstItem) || other.hasFirstItem == hasFirstItem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,storeId,businessId,userId,const DeepCollectionEquality().hash(_permissions),name,role,logoUrl,welcomeCompleted,hasFirstItem);

@override
String toString() {
  return 'StoreShip(storeId: $storeId, businessId: $businessId, userId: $userId, permissions: $permissions, name: $name, role: $role, logoUrl: $logoUrl, welcomeCompleted: $welcomeCompleted, hasFirstItem: $hasFirstItem)';
}


}

/// @nodoc
abstract mixin class _$StoreShipCopyWith<$Res> implements $StoreShipCopyWith<$Res> {
  factory _$StoreShipCopyWith(_StoreShip value, $Res Function(_StoreShip) _then) = __$StoreShipCopyWithImpl;
@override @useResult
$Res call({
 String storeId, String businessId, String userId, List<String> permissions, String name,@JsonKey(readValue: _readRole) StoreRole role, String? logoUrl, bool welcomeCompleted, bool hasFirstItem
});




}
/// @nodoc
class __$StoreShipCopyWithImpl<$Res>
    implements _$StoreShipCopyWith<$Res> {
  __$StoreShipCopyWithImpl(this._self, this._then);

  final _StoreShip _self;
  final $Res Function(_StoreShip) _then;

/// Create a copy of StoreShip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? storeId = null,Object? businessId = null,Object? userId = null,Object? permissions = null,Object? name = null,Object? role = null,Object? logoUrl = freezed,Object? welcomeCompleted = null,Object? hasFirstItem = null,}) {
  return _then(_StoreShip(
storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StoreRole,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,welcomeCompleted: null == welcomeCompleted ? _self.welcomeCompleted : welcomeCompleted // ignore: cast_nullable_to_non_nullable
as bool,hasFirstItem: null == hasFirstItem ? _self.hasFirstItem : hasFirstItem // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
