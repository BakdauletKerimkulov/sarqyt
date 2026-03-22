// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_image_picker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ItemImagePickerController)
const itemImagePickerControllerProvider = ItemImagePickerControllerFamily._();

final class ItemImagePickerControllerProvider
    extends
        $AsyncNotifierProvider<
          ItemImagePickerController,
          Either<File, Uint8List>?
        > {
  const ItemImagePickerControllerProvider._({
    required ItemImagePickerControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemImagePickerControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemImagePickerControllerHash();

  @override
  String toString() {
    return r'itemImagePickerControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ItemImagePickerController create() => ItemImagePickerController();

  @override
  bool operator ==(Object other) {
    return other is ItemImagePickerControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemImagePickerControllerHash() =>
    r'256f73c48de29207651c61538c64ceddeb4c2687';

final class ItemImagePickerControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ItemImagePickerController,
          AsyncValue<Either<File, Uint8List>?>,
          Either<File, Uint8List>?,
          FutureOr<Either<File, Uint8List>?>,
          String
        > {
  const ItemImagePickerControllerFamily._()
    : super(
        retry: null,
        name: r'itemImagePickerControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ItemImagePickerControllerProvider call(String id) =>
      ItemImagePickerControllerProvider._(argument: id, from: this);

  @override
  String toString() => r'itemImagePickerControllerProvider';
}

abstract class _$ItemImagePickerController
    extends $AsyncNotifier<Either<File, Uint8List>?> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<Either<File, Uint8List>?> build(String id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Either<File, Uint8List>?>,
              Either<File, Uint8List>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Either<File, Uint8List>?>,
                Either<File, Uint8List>?
              >,
              AsyncValue<Either<File, Uint8List>?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
