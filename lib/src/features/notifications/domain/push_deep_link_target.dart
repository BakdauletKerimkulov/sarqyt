import 'package:flutter/foundation.dart';

/// Where a tapped push notification should navigate to, expressed as a
/// GoRouter route name plus its parameters (spec 034, R9).
///
/// Navigation is always by name, never by path string
/// (`ai_toolkit/gorouter.md`), so the applier only needs these three fields.
@immutable
class PushDeepLinkTarget {
  const PushDeepLinkTarget({
    required this.routeName,
    this.pathParameters = const {},
    this.queryParameters = const {},
  });

  final String routeName;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushDeepLinkTarget &&
          routeName == other.routeName &&
          mapEquals(pathParameters, other.pathParameters) &&
          mapEquals(queryParameters, other.queryParameters);

  @override
  int get hashCode => Object.hash(
    routeName,
    Object.hashAllUnordered(
      pathParameters.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    Object.hashAllUnordered(
      queryParameters.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}
