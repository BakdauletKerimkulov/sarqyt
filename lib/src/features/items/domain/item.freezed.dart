// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Item {

@JsonKey(fromJson: _readRequiredId) ItemID get id;@JsonKey(fromJson: _readRequiredName) String get name;@JsonKey(fromJson: _readRequiredPrice, toJson: _writePrice) double get price;@JsonKey(fromJson: _readRequiredSchedule, toJson: _writeSchedule) WeeklySchedule get schedule;@JsonKey(readValue: _readEstimatedValueSource, fromJson: _readOptionalPrice, toJson: _writeOptionalPrice) double? get estimatedValue; String? get imageUrl; String? get description; String? get category;@JsonKey(unknownEnumValue: DietaryType.notSpecified) DietaryType get dietaryType;@JsonKey(unknownEnumValue: PackagingOption.withBagOrOwnBag) PackagingOption get packagingType; String? get collectionInstructions; bool get isActive; bool get isBuffetFood; String? get storingAndAllergens; List<Badge> get badges; Rating? get averageOverallRating;
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCopyWith<Item> get copyWith => _$ItemCopyWithImpl<Item>(this as Item, _$identity);

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Item&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.estimatedValue, estimatedValue) || other.estimatedValue == estimatedValue)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.dietaryType, dietaryType) || other.dietaryType == dietaryType)&&(identical(other.packagingType, packagingType) || other.packagingType == packagingType)&&(identical(other.collectionInstructions, collectionInstructions) || other.collectionInstructions == collectionInstructions)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isBuffetFood, isBuffetFood) || other.isBuffetFood == isBuffetFood)&&(identical(other.storingAndAllergens, storingAndAllergens) || other.storingAndAllergens == storingAndAllergens)&&const DeepCollectionEquality().equals(other.badges, badges)&&(identical(other.averageOverallRating, averageOverallRating) || other.averageOverallRating == averageOverallRating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,schedule,estimatedValue,imageUrl,description,category,dietaryType,packagingType,collectionInstructions,isActive,isBuffetFood,storingAndAllergens,const DeepCollectionEquality().hash(badges),averageOverallRating);

@override
String toString() {
  return 'Item(id: $id, name: $name, price: $price, schedule: $schedule, estimatedValue: $estimatedValue, imageUrl: $imageUrl, description: $description, category: $category, dietaryType: $dietaryType, packagingType: $packagingType, collectionInstructions: $collectionInstructions, isActive: $isActive, isBuffetFood: $isBuffetFood, storingAndAllergens: $storingAndAllergens, badges: $badges, averageOverallRating: $averageOverallRating)';
}


}

/// @nodoc
abstract mixin class $ItemCopyWith<$Res>  {
  factory $ItemCopyWith(Item value, $Res Function(Item) _then) = _$ItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _readRequiredId) ItemID id,@JsonKey(fromJson: _readRequiredName) String name,@JsonKey(fromJson: _readRequiredPrice, toJson: _writePrice) double price,@JsonKey(fromJson: _readRequiredSchedule, toJson: _writeSchedule) WeeklySchedule schedule,@JsonKey(readValue: _readEstimatedValueSource, fromJson: _readOptionalPrice, toJson: _writeOptionalPrice) double? estimatedValue, String? imageUrl, String? description, String? category,@JsonKey(unknownEnumValue: DietaryType.notSpecified) DietaryType dietaryType,@JsonKey(unknownEnumValue: PackagingOption.withBagOrOwnBag) PackagingOption packagingType, String? collectionInstructions, bool isActive, bool isBuffetFood, String? storingAndAllergens, List<Badge> badges, Rating? averageOverallRating
});


$RatingCopyWith<$Res>? get averageOverallRating;

}
/// @nodoc
class _$ItemCopyWithImpl<$Res>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._self, this._then);

  final Item _self;
  final $Res Function(Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? schedule = null,Object? estimatedValue = freezed,Object? imageUrl = freezed,Object? description = freezed,Object? category = freezed,Object? dietaryType = null,Object? packagingType = null,Object? collectionInstructions = freezed,Object? isActive = null,Object? isBuffetFood = null,Object? storingAndAllergens = freezed,Object? badges = null,Object? averageOverallRating = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ItemID,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as WeeklySchedule,estimatedValue: freezed == estimatedValue ? _self.estimatedValue : estimatedValue // ignore: cast_nullable_to_non_nullable
as double?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,dietaryType: null == dietaryType ? _self.dietaryType : dietaryType // ignore: cast_nullable_to_non_nullable
as DietaryType,packagingType: null == packagingType ? _self.packagingType : packagingType // ignore: cast_nullable_to_non_nullable
as PackagingOption,collectionInstructions: freezed == collectionInstructions ? _self.collectionInstructions : collectionInstructions // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isBuffetFood: null == isBuffetFood ? _self.isBuffetFood : isBuffetFood // ignore: cast_nullable_to_non_nullable
as bool,storingAndAllergens: freezed == storingAndAllergens ? _self.storingAndAllergens : storingAndAllergens // ignore: cast_nullable_to_non_nullable
as String?,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<Badge>,averageOverallRating: freezed == averageOverallRating ? _self.averageOverallRating : averageOverallRating // ignore: cast_nullable_to_non_nullable
as Rating?,
  ));
}
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingCopyWith<$Res>? get averageOverallRating {
    if (_self.averageOverallRating == null) {
    return null;
  }

  return $RatingCopyWith<$Res>(_self.averageOverallRating!, (value) {
    return _then(_self.copyWith(averageOverallRating: value));
  });
}
}


/// Adds pattern-matching-related methods to [Item].
extension ItemPatterns on Item {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Item value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Item value)  $default,){
final _that = this;
switch (_that) {
case _Item():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Item value)?  $default,){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _readRequiredId)  ItemID id, @JsonKey(fromJson: _readRequiredName)  String name, @JsonKey(fromJson: _readRequiredPrice, toJson: _writePrice)  double price, @JsonKey(fromJson: _readRequiredSchedule, toJson: _writeSchedule)  WeeklySchedule schedule, @JsonKey(readValue: _readEstimatedValueSource, fromJson: _readOptionalPrice, toJson: _writeOptionalPrice)  double? estimatedValue,  String? imageUrl,  String? description,  String? category, @JsonKey(unknownEnumValue: DietaryType.notSpecified)  DietaryType dietaryType, @JsonKey(unknownEnumValue: PackagingOption.withBagOrOwnBag)  PackagingOption packagingType,  String? collectionInstructions,  bool isActive,  bool isBuffetFood,  String? storingAndAllergens,  List<Badge> badges,  Rating? averageOverallRating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.schedule,_that.estimatedValue,_that.imageUrl,_that.description,_that.category,_that.dietaryType,_that.packagingType,_that.collectionInstructions,_that.isActive,_that.isBuffetFood,_that.storingAndAllergens,_that.badges,_that.averageOverallRating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _readRequiredId)  ItemID id, @JsonKey(fromJson: _readRequiredName)  String name, @JsonKey(fromJson: _readRequiredPrice, toJson: _writePrice)  double price, @JsonKey(fromJson: _readRequiredSchedule, toJson: _writeSchedule)  WeeklySchedule schedule, @JsonKey(readValue: _readEstimatedValueSource, fromJson: _readOptionalPrice, toJson: _writeOptionalPrice)  double? estimatedValue,  String? imageUrl,  String? description,  String? category, @JsonKey(unknownEnumValue: DietaryType.notSpecified)  DietaryType dietaryType, @JsonKey(unknownEnumValue: PackagingOption.withBagOrOwnBag)  PackagingOption packagingType,  String? collectionInstructions,  bool isActive,  bool isBuffetFood,  String? storingAndAllergens,  List<Badge> badges,  Rating? averageOverallRating)  $default,) {final _that = this;
switch (_that) {
case _Item():
return $default(_that.id,_that.name,_that.price,_that.schedule,_that.estimatedValue,_that.imageUrl,_that.description,_that.category,_that.dietaryType,_that.packagingType,_that.collectionInstructions,_that.isActive,_that.isBuffetFood,_that.storingAndAllergens,_that.badges,_that.averageOverallRating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _readRequiredId)  ItemID id, @JsonKey(fromJson: _readRequiredName)  String name, @JsonKey(fromJson: _readRequiredPrice, toJson: _writePrice)  double price, @JsonKey(fromJson: _readRequiredSchedule, toJson: _writeSchedule)  WeeklySchedule schedule, @JsonKey(readValue: _readEstimatedValueSource, fromJson: _readOptionalPrice, toJson: _writeOptionalPrice)  double? estimatedValue,  String? imageUrl,  String? description,  String? category, @JsonKey(unknownEnumValue: DietaryType.notSpecified)  DietaryType dietaryType, @JsonKey(unknownEnumValue: PackagingOption.withBagOrOwnBag)  PackagingOption packagingType,  String? collectionInstructions,  bool isActive,  bool isBuffetFood,  String? storingAndAllergens,  List<Badge> badges,  Rating? averageOverallRating)?  $default,) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.schedule,_that.estimatedValue,_that.imageUrl,_that.description,_that.category,_that.dietaryType,_that.packagingType,_that.collectionInstructions,_that.isActive,_that.isBuffetFood,_that.storingAndAllergens,_that.badges,_that.averageOverallRating);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Item extends Item {
  const _Item({@JsonKey(fromJson: _readRequiredId) required this.id, @JsonKey(fromJson: _readRequiredName) required this.name, @JsonKey(fromJson: _readRequiredPrice, toJson: _writePrice) required this.price, @JsonKey(fromJson: _readRequiredSchedule, toJson: _writeSchedule) required this.schedule, @JsonKey(readValue: _readEstimatedValueSource, fromJson: _readOptionalPrice, toJson: _writeOptionalPrice) this.estimatedValue, this.imageUrl, this.description, this.category, @JsonKey(unknownEnumValue: DietaryType.notSpecified) this.dietaryType = DietaryType.notSpecified, @JsonKey(unknownEnumValue: PackagingOption.withBagOrOwnBag) this.packagingType = PackagingOption.withBagOrOwnBag, this.collectionInstructions, this.isActive = false, this.isBuffetFood = false, this.storingAndAllergens, final  List<Badge> badges = const [], this.averageOverallRating}): _badges = badges,super._();
  factory _Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

@override@JsonKey(fromJson: _readRequiredId) final  ItemID id;
@override@JsonKey(fromJson: _readRequiredName) final  String name;
@override@JsonKey(fromJson: _readRequiredPrice, toJson: _writePrice) final  double price;
@override@JsonKey(fromJson: _readRequiredSchedule, toJson: _writeSchedule) final  WeeklySchedule schedule;
@override@JsonKey(readValue: _readEstimatedValueSource, fromJson: _readOptionalPrice, toJson: _writeOptionalPrice) final  double? estimatedValue;
@override final  String? imageUrl;
@override final  String? description;
@override final  String? category;
@override@JsonKey(unknownEnumValue: DietaryType.notSpecified) final  DietaryType dietaryType;
@override@JsonKey(unknownEnumValue: PackagingOption.withBagOrOwnBag) final  PackagingOption packagingType;
@override final  String? collectionInstructions;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isBuffetFood;
@override final  String? storingAndAllergens;
 final  List<Badge> _badges;
@override@JsonKey() List<Badge> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

@override final  Rating? averageOverallRating;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemCopyWith<_Item> get copyWith => __$ItemCopyWithImpl<_Item>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Item&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.estimatedValue, estimatedValue) || other.estimatedValue == estimatedValue)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.dietaryType, dietaryType) || other.dietaryType == dietaryType)&&(identical(other.packagingType, packagingType) || other.packagingType == packagingType)&&(identical(other.collectionInstructions, collectionInstructions) || other.collectionInstructions == collectionInstructions)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isBuffetFood, isBuffetFood) || other.isBuffetFood == isBuffetFood)&&(identical(other.storingAndAllergens, storingAndAllergens) || other.storingAndAllergens == storingAndAllergens)&&const DeepCollectionEquality().equals(other._badges, _badges)&&(identical(other.averageOverallRating, averageOverallRating) || other.averageOverallRating == averageOverallRating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,schedule,estimatedValue,imageUrl,description,category,dietaryType,packagingType,collectionInstructions,isActive,isBuffetFood,storingAndAllergens,const DeepCollectionEquality().hash(_badges),averageOverallRating);

@override
String toString() {
  return 'Item(id: $id, name: $name, price: $price, schedule: $schedule, estimatedValue: $estimatedValue, imageUrl: $imageUrl, description: $description, category: $category, dietaryType: $dietaryType, packagingType: $packagingType, collectionInstructions: $collectionInstructions, isActive: $isActive, isBuffetFood: $isBuffetFood, storingAndAllergens: $storingAndAllergens, badges: $badges, averageOverallRating: $averageOverallRating)';
}


}

/// @nodoc
abstract mixin class _$ItemCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$ItemCopyWith(_Item value, $Res Function(_Item) _then) = __$ItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _readRequiredId) ItemID id,@JsonKey(fromJson: _readRequiredName) String name,@JsonKey(fromJson: _readRequiredPrice, toJson: _writePrice) double price,@JsonKey(fromJson: _readRequiredSchedule, toJson: _writeSchedule) WeeklySchedule schedule,@JsonKey(readValue: _readEstimatedValueSource, fromJson: _readOptionalPrice, toJson: _writeOptionalPrice) double? estimatedValue, String? imageUrl, String? description, String? category,@JsonKey(unknownEnumValue: DietaryType.notSpecified) DietaryType dietaryType,@JsonKey(unknownEnumValue: PackagingOption.withBagOrOwnBag) PackagingOption packagingType, String? collectionInstructions, bool isActive, bool isBuffetFood, String? storingAndAllergens, List<Badge> badges, Rating? averageOverallRating
});


@override $RatingCopyWith<$Res>? get averageOverallRating;

}
/// @nodoc
class __$ItemCopyWithImpl<$Res>
    implements _$ItemCopyWith<$Res> {
  __$ItemCopyWithImpl(this._self, this._then);

  final _Item _self;
  final $Res Function(_Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? schedule = null,Object? estimatedValue = freezed,Object? imageUrl = freezed,Object? description = freezed,Object? category = freezed,Object? dietaryType = null,Object? packagingType = null,Object? collectionInstructions = freezed,Object? isActive = null,Object? isBuffetFood = null,Object? storingAndAllergens = freezed,Object? badges = null,Object? averageOverallRating = freezed,}) {
  return _then(_Item(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ItemID,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as WeeklySchedule,estimatedValue: freezed == estimatedValue ? _self.estimatedValue : estimatedValue // ignore: cast_nullable_to_non_nullable
as double?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,dietaryType: null == dietaryType ? _self.dietaryType : dietaryType // ignore: cast_nullable_to_non_nullable
as DietaryType,packagingType: null == packagingType ? _self.packagingType : packagingType // ignore: cast_nullable_to_non_nullable
as PackagingOption,collectionInstructions: freezed == collectionInstructions ? _self.collectionInstructions : collectionInstructions // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isBuffetFood: null == isBuffetFood ? _self.isBuffetFood : isBuffetFood // ignore: cast_nullable_to_non_nullable
as bool,storingAndAllergens: freezed == storingAndAllergens ? _self.storingAndAllergens : storingAndAllergens // ignore: cast_nullable_to_non_nullable
as String?,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<Badge>,averageOverallRating: freezed == averageOverallRating ? _self.averageOverallRating : averageOverallRating // ignore: cast_nullable_to_non_nullable
as Rating?,
  ));
}

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingCopyWith<$Res>? get averageOverallRating {
    if (_self.averageOverallRating == null) {
    return null;
  }

  return $RatingCopyWith<$Res>(_self.averageOverallRating!, (value) {
    return _then(_self.copyWith(averageOverallRating: value));
  });
}
}

// dart format on
