// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(databaseService)
const databaseServiceProvider = DatabaseServiceProvider._();

final class DatabaseServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<DatabaseService>,
          DatabaseService,
          FutureOr<DatabaseService>
        >
    with $FutureModifier<DatabaseService>, $FutureProvider<DatabaseService> {
  const DatabaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseServiceHash();

  @$internal
  @override
  $FutureProviderElement<DatabaseService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DatabaseService> create(Ref ref) {
    return databaseService(ref);
  }
}

String _$databaseServiceHash() => r'e1131c8f0709b64749b9fe81e593a949fa0c2aa4';
