import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_date_builder.g.dart';

/// Injectable clock — override in tests to control time.
/// Presentation layer may still call `DateTime.now()` directly.
@riverpod
DateTime Function() currentDateBuilder(Ref ref) => DateTime.now;
