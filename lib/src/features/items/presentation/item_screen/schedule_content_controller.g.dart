// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_content_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScheduleContentController)
const scheduleContentControllerProvider = ScheduleContentControllerProvider._();

final class ScheduleContentControllerProvider
    extends $AsyncNotifierProvider<ScheduleContentController, void> {
  const ScheduleContentControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleContentControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleContentControllerHash();

  @$internal
  @override
  ScheduleContentController create() => ScheduleContentController();
}

String _$scheduleContentControllerHash() =>
    r'4f5dc07601e355583b026767a2dfbcb073da9573';

abstract class _$ScheduleContentController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
