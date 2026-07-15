/// Material 3 window size class breakpoints.
abstract final class Breakpoints {
  static const double compact = 600;
  static const double expanded = 840;
}

enum WindowSize {
  compact,
  medium,
  expanded;

  static WindowSize fromWidth(double width) => switch (width) {
        < Breakpoints.compact => WindowSize.compact,
        < Breakpoints.expanded => WindowSize.medium,
        _ => WindowSize.expanded,
      };
}
