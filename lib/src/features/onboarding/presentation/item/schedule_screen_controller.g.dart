// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScheduleScreenController)
const scheduleScreenControllerProvider = ScheduleScreenControllerProvider._();

final class ScheduleScreenControllerProvider
    extends $NotifierProvider<ScheduleScreenController, WeeklySchedule> {
  const ScheduleScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleScreenControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleScreenControllerHash();

  @$internal
  @override
  ScheduleScreenController create() => ScheduleScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeeklySchedule value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeeklySchedule>(value),
    );
  }
}

String _$scheduleScreenControllerHash() =>
    r'a0d4d638810ac37059945e9e0b7e21589f2fc86f';

abstract class _$ScheduleScreenController extends $Notifier<WeeklySchedule> {
  WeeklySchedule build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<WeeklySchedule, WeeklySchedule>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WeeklySchedule, WeeklySchedule>,
              WeeklySchedule,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
