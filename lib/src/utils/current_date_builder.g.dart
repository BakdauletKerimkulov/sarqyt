// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_date_builder.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injectable clock — override in tests to control time.
/// Presentation layer may still call `DateTime.now()` directly.

@ProviderFor(currentDateBuilder)
const currentDateBuilderProvider = CurrentDateBuilderProvider._();

/// Injectable clock — override in tests to control time.
/// Presentation layer may still call `DateTime.now()` directly.

final class CurrentDateBuilderProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// Injectable clock — override in tests to control time.
  /// Presentation layer may still call `DateTime.now()` directly.
  const CurrentDateBuilderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentDateBuilderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentDateBuilderHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return currentDateBuilder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$currentDateBuilderHash() =>
    r'3b6f1d6cae770a9ff63ab941298aedbeaa6bd8f8';
